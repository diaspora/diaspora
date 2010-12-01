require 'singleton'
require 'rubygems'

# Implements a dynamic plugin loading, configuration, and discovery system
# based on RubyGems and a simple additional name space that looks like a URI.
#
# A plugin is created and put into a category with the following code:
#
#  class MyThing < GemPlugin::Plugin "/things"
#    ...
#  end
# 
# What this does is sets up your MyThing in the plugin registry via GemPlugin::Manager.
# You can then later get this plugin with GemPlugin::Manager.create("/things/mything")
# and can also pass in options as a second parameter.
#
# This isn't such a big deal, but the power is really from the GemPlugin::Manager.load
# method.  This method will go through the installed gems and require_gem any
# that depend on the gem_plugin RubyGem.  You can arbitrarily include or exclude
# gems based on what they also depend on, thus letting you load these gems when appropriate.
#
# Since this system was written originally for the Mongrel project that'll be the
# best example of using it.
#
# Imagine you have a neat plugin for Mongrel called snazzy_command that gives the
# mongrel_rails a new command snazzy (like:  mongrel_rails snazzy).  You'd like
# people to be able to grab this plugin if they want and use it, because it's snazzy.
#
# First thing you do is create a gem of your project and make sure that it depends
# on "mongrel" AND "gem_plugin".  This signals to the GemPlugin system that this is
# a plugin for mongrel.
#
# Next you put this code into a file like lib/init.rb (can be anything really):
#
#  class Snazzy < GemPlugin::Plugin "/commands"
#    ...
#  end
#  
# Then when you create your gem you have the following bits in your Rakefile:
#
#  spec.add_dependency('mongrel', '>= 0.3.9')
#  spec.add_dependency('gem_plugin', '>= 0.1')
#  spec.autorequire = 'init.rb'
#
# Finally, you just have to now publish this gem for people to install and Mongrel
# will "magically" be able to install it.
#
# The "magic" part though is pretty simple and done via the GemPlugin::Manager.load
# method.  Read that to see how it is really done.
module GemPlugin

  EXCLUDE = true
  INCLUDE = false

  class PluginNotLoaded < StandardError; end

  
  # This class is used by people who use gem plugins (but don't necessarily make them)
  # to add plugins to their own systems.  It provides a way to load plugins, list them,
  # and create them as needed.
  #
  # It is a singleton so you use like this:  GemPlugins::Manager.instance.load
  class Manager
    include Singleton
    attr_reader :plugins
    attr_reader :gems
    

    def initialize
      # plugins that have been loaded
      @plugins = {}

      # keeps track of gems which have been loaded already by the manager *and*
      # where they came from so that they can be referenced later
      @gems = {}
    end


    # Responsible for going through the list of available gems and loading 
    # any plugins requested.  It keeps track of what it's loaded already
    # and won't load them again.
    #
    # It accepts one parameter which is a hash of gem depends that should include
    # or exclude a gem from being loaded.  A gem must depend on gem_plugin to be
    # considered, but then each system has to add it's own INCLUDE to make sure
    # that only plugins related to it are loaded.
    #
    # An example again comes from Mongrel.  In order to load all Mongrel plugins:
    #
    #  GemPlugin::Manager.instance.load "mongrel" => GemPlugin::INCLUDE
    #
    # Which will load all plugins that depend on mongrel AND gem_plugin.  Now, one
    # extra thing we do is we delay loading Rails Mongrel plugins until after rails
    # is configured.  Do do this the mongrel_rails script has:
    #
    # GemPlugin::Manager.instance.load "mongrel" => GemPlugin::INCLUDE, "rails" => GemPlugin::EXCLUDE
    # The only thing to remember is that this is saying "include a plugin if it
    # depends on gem_plugin, mongrel, but NOT rails".  If a plugin also depends on other
    # stuff then it's loaded just fine.  Only gem_plugin, mongrel, and rails are
    # ever used to determine if it should be included.
    #
    # NOTE: Currently RubyGems will run autorequire on gems that get required AND
    # on their dependencies.  This really messes with people running edge rails
    # since activerecord or other stuff gets loaded for just touching a gem plugin.
    # To prevent this load requires the full path to the "init.rb" file, which
    # avoids the RubyGems autorequire magic.
    def load(needs = {})
      sdir = File.join(Gem.dir, "specifications")
      gems = Gem::SourceIndex.from_installed_gems(sdir)
      needs = needs.merge({"gem_plugin" => INCLUDE})
      
      gems.each do |path, gem|
        # don't load gems more than once
        next if @gems.has_key? gem.name        
        check = needs.dup

        # rolls through the depends and inverts anything it finds
        gem.dependencies.each do |dep|
          # this will fail if a gem is depended more than once
          if check.has_key? dep.name
            check[dep.name] = !check[dep.name]
          end
        end
        
        # now since excluded gems start as true, inverting them
        # makes them false so we'll skip this gem if any excludes are found
        if (check.select {|name,test| !test}).length == 0
          # looks like no needs were set to false, so it's good
          
          # Previously was set wrong, we already have the correct gem path!
          #gem_dir = File.join(Gem.dir, "gems", "#{gem.name}-#{gem.version}")
          gem_dir = File.join(Gem.dir, "gems", path)
          
          require File.join(gem_dir, "lib", gem.name, "init.rb")
          @gems[gem.name] = gem_dir
        end
      end

      return nil
    end


    # Not necessary for you to call directly, but this is
    # how GemPlugin::Base.inherited actually adds a 
    # plugin to a category.
    def register(category, name, klass)
      @plugins[category] ||= {}
      @plugins[category][name.downcase] = klass
    end
   
 
    # Resolves the given name (should include /category/name) to
    # find the plugin class and create an instance.  You can
    # pass a second hash option that is then given to the Plugin 
    # to configure it.
    def create(name, options = {})
      last_slash = name.rindex("/")
      category = name[0 ... last_slash]
      plugin = name[last_slash .. -1]

      map = @plugins[category]
      if not map
        raise "Plugin category #{category} does not exist"
      elsif not map.has_key? plugin
        raise "Plugin #{plugin} does not exist in category #{category}"
      else
        map[plugin].new(options)
      end
    end
    

    # Simply says whether the given gem has been loaded yet or not.
    def loaded?(gem_name)
      @gems.has_key? gem_name
    end


    # GemPlugins can have a 'resources' directory which is packaged with them
    # and can hold any data resources the plugin may need.  The main problem
    # is that it's difficult to figure out where these resources are 
    # actually located on the file system.  The resource method tries to 
    # locate the real path for a given resource path.
    #
    # Let's say you have a 'resources/stylesheets/default.css' file in your
    # gem distribution, then finding where this file really is involves:
    #
    #   Manager.instance.resource("mygem", "/stylesheets/default.css")
    #
    # You either get back the full path to the resource or you get a nil
    # if it doesn't exist.
    #
    # If you request a path for a GemPlugin that hasn't been loaded yet
    # then it will throw an PluginNotLoaded exception.  The gem may be
    # present on your system in this case, but you just haven't loaded
    # it with Manager.instance.load properly.
    def resource(gem_name, path)
      if not loaded? gem_name
        raise PluginNotLoaded.new("Plugin #{gem_name} not loaded when getting resource #{path}")
      end
      
      file = File.join(@gems[gem_name], "resources", path)

      if File.exist? file
        return file
      else
        return nil
      end
    end

    
    # While Manager.resource will find arbitrary resources, a special
    # case is when you need to load a set of configuration defaults.
    # GemPlugin normalizes this to be if you have a file "resources/defaults.yaml"
    # then you'll be able to load them via Manager.config.
    #
    # How you use the method is you get the options the user wants set, pass
    # them to Manager.instance.config, and what you get back is a new Hash
    # with the user's settings overriding the defaults.
    #
    #   opts = Manager.instance.config "mygem", :age => 12, :max_load => .9
    #
    # In the above case, if defaults had {:age => 14} then it would be 
    # changed to 12.
    #
    # This loads the .yaml file on the fly every time, so doing it a 
    # whole lot is very stupid.  If you need to make frequent calls to
    # this, call it once with no options (Manager.instance.config) then
    # use the returned defaults directly from then on.
    def config(gem_name, options={})
      config_file = Manager.instance.resource(gem_name, "/defaults.yaml")
      if config_file
        begin
          defaults = YAML.load_file(config_file)
          return defaults.merge(options)
        rescue
          raise "Error loading config #{config_file} for gem #{gem_name}"
        end
      else
        return options
      end
    end
  end

  # This base class for plugins really does nothing
  # more than wire up the new class into the right category.
  # It is not thread-safe yet but will be soon.
  class Base
    
    attr_reader :options


    # See Mongrel::Plugin for an explanation.
    def Base.inherited(klass)
      name = "/" + klass.to_s.downcase
      Manager.instance.register(@@category, name, klass)
      @@category = nil
    end
    
    # See Mongrel::Plugin for an explanation.
    def Base.category=(category)
      @@category = category
    end

    def initialize(options = {})
      @options = options
    end

  end
  
  # This nifty function works with the GemPlugin::Base to give you
  # the syntax:
  #
  #  class MyThing < GemPlugin::Plugin "/things"
  #    ...
  #  end
  #
  # What it does is temporarily sets the GemPlugin::Base.category, and then
  # returns GemPlugin::Base.  Since the next immediate thing Ruby does is
  # use this returned class to create the new class, GemPlugin::Base.inherited
  # gets called.  GemPlugin::Base.inherited then uses the set category, class name,
  # and class to register the plugin in the right way.
  def GemPlugin::Plugin(c)
    Base.category = c
    Base
  end

end




