require 'rbconfig'

class Thor
  module Sandbox #:nodoc:
  end

  # This module holds several utilities:
  #
  # 1) Methods to convert thor namespaces to constants and vice-versa.
  #
  #   Thor::Utils.namespace_from_thor_class(Foo::Bar::Baz) #=> "foo:bar:baz"
  #
  # 2) Loading thor files and sandboxing:
  #
  #   Thor::Utils.load_thorfile("~/.thor/foo")
  #
  module Util

    # Receives a namespace and search for it in the Thor::Base subclasses.
    #
    # ==== Parameters
    # namespace<String>:: The namespace to search for.
    #
    def self.find_by_namespace(namespace)
      namespace = "default#{namespace}" if namespace.empty? || namespace =~ /^:/
      Thor::Base.subclasses.find { |klass| klass.namespace == namespace }
    end

    # Receives a constant and converts it to a Thor namespace. Since Thor tasks
    # can be added to a sandbox, this method is also responsable for removing
    # the sandbox namespace.
    #
    # This method should not be used in general because it's used to deal with
    # older versions of Thor. On current versions, if you need to get the
    # namespace from a class, just call namespace on it.
    #
    # ==== Parameters
    # constant<Object>:: The constant to be converted to the thor path.
    #
    # ==== Returns
    # String:: If we receive Foo::Bar::Baz it returns "foo:bar:baz"
    #
    def self.namespace_from_thor_class(constant)
      constant = constant.to_s.gsub(/^Thor::Sandbox::/, "")
      constant = snake_case(constant).squeeze(":")
      constant
    end

    # Given the contents, evaluate it inside the sandbox and returns the
    # namespaces defined in the sandbox.
    #
    # ==== Parameters
    # contents<String>
    #
    # ==== Returns
    # Array[Object]
    #
    def self.namespaces_in_content(contents, file=__FILE__)
      old_constants = Thor::Base.subclasses.dup
      Thor::Base.subclasses.clear

      load_thorfile(file, contents)

      new_constants = Thor::Base.subclasses.dup
      Thor::Base.subclasses.replace(old_constants)

      new_constants.map!{ |c| c.namespace }
      new_constants.compact!
      new_constants
    end

    # Returns the thor classes declared inside the given class.
    #
    def self.thor_classes_in(klass)
      stringfied_constants = klass.constants.map { |c| c.to_s }
      Thor::Base.subclasses.select do |subclass|
        next unless subclass.name
        stringfied_constants.include?(subclass.name.gsub("#{klass.name}::", ''))
      end
    end

    # Receives a string and convert it to snake case. SnakeCase returns snake_case.
    #
    # ==== Parameters
    # String
    #
    # ==== Returns
    # String
    #
    def self.snake_case(str)
      return str.downcase if str =~ /^[A-Z_]+$/
      str.gsub(/\B[A-Z]/, '_\&').squeeze('_') =~ /_*(.*)/
      return $+.downcase
    end

    # Receives a string and convert it to camel case. camel_case returns CamelCase.
    #
    # ==== Parameters
    # String
    #
    # ==== Returns
    # String
    #
    def self.camel_case(str)
      return str if str !~ /_/ && str =~ /[A-Z]+.*/
      str.split('_').map { |i| i.capitalize }.join
    end

    # Receives a namespace and tries to retrieve a Thor or Thor::Group class
    # from it. It first searches for a class using the all the given namespace,
    # if it's not found, removes the highest entry and searches for the class
    # again. If found, returns the highest entry as the class name.
    #
    # ==== Examples
    #
    #   class Foo::Bar < Thor
    #     def baz
    #     end
    #   end
    #
    #   class Baz::Foo < Thor::Group
    #   end
    #
    #   Thor::Util.namespace_to_thor_class("foo:bar")     #=> Foo::Bar, nil # will invoke default task
    #   Thor::Util.namespace_to_thor_class("baz:foo")     #=> Baz::Foo, nil
    #   Thor::Util.namespace_to_thor_class("foo:bar:baz") #=> Foo::Bar, "baz"
    #
    # ==== Parameters
    # namespace<String>
    #
    def self.find_class_and_task_by_namespace(namespace, fallback = true)
      if namespace.include?(?:) # look for a namespaced task
        pieces = namespace.split(":")
        task   = pieces.pop
        klass  = Thor::Util.find_by_namespace(pieces.join(":"))
      end
      unless klass # look for a Thor::Group with the right name
        klass, task = Thor::Util.find_by_namespace(namespace), nil
      end
      if !klass && fallback # try a task in the default namespace
        task = namespace
        klass = Thor::Util.find_by_namespace('')
      end
      return klass, task
    end

    # Receives a path and load the thor file in the path. The file is evaluated
    # inside the sandbox to avoid namespacing conflicts.
    #
    def self.load_thorfile(path, content=nil, debug=false)
      content ||= File.binread(path)

      begin
        Thor::Sandbox.class_eval(content, path)
      rescue Exception => e
        $stderr.puts "WARNING: unable to load thorfile #{path.inspect}: #{e.message}"
        if debug
          $stderr.puts *e.backtrace
        else
          $stderr.puts e.backtrace.first
        end
      end
    end

    def self.user_home
      @@user_home ||= if ENV["HOME"]
        ENV["HOME"]
      elsif ENV["USERPROFILE"]
        ENV["USERPROFILE"]
      elsif ENV["HOMEDRIVE"] && ENV["HOMEPATH"]
        File.join(ENV["HOMEDRIVE"], ENV["HOMEPATH"])
      elsif ENV["APPDATA"]
        ENV["APPDATA"]
      else
        begin
          File.expand_path("~")
        rescue
          if File::ALT_SEPARATOR
            "C:/"
          else
            "/"
          end
        end
      end
    end

    # Returns the root where thor files are located, dependending on the OS.
    #
    def self.thor_root
      File.join(user_home, ".thor").gsub(/\\/, '/')
    end

    # Returns the files in the thor root. On Windows thor_root will be something
    # like this:
    #
    #   C:\Documents and Settings\james\.thor
    #
    # If we don't #gsub the \ character, Dir.glob will fail.
    #
    def self.thor_root_glob
      files = Dir["#{thor_root}/*"]

      files.map! do |file|
        File.directory?(file) ? File.join(file, "main.thor") : file
      end
    end

    # Where to look for Thor files.
    #
    def self.globs_for(path)
      ["#{path}/Thorfile", "#{path}/*.thor", "#{path}/tasks/*.thor", "#{path}/lib/tasks/*.thor"]
    end

    # Return the path to the ruby interpreter taking into account multiple
    # installations and windows extensions.
    #
    def self.ruby_command
      @ruby_command ||= begin
        ruby = File.join(RbConfig::CONFIG['bindir'], RbConfig::CONFIG['ruby_install_name'])
        ruby << RbConfig::CONFIG['EXEEXT']

        # escape string in case path to ruby executable contain spaces.
        ruby.sub!(/.*\s.*/m, '"\&"')
        ruby
      end
    end

  end
end
