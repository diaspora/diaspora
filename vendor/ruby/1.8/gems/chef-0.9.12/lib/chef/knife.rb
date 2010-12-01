#
# Author:: Adam Jacob (<adam@opscode.com>)
# Author:: Christopher Brown (<cb@opscode.com>)
# Copyright:: Copyright (c) 2009 Opscode, Inc.
# License:: Apache License, Version 2.0
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
# 
#     http://www.apache.org/licenses/LICENSE-2.0
# 
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#

require 'chef/version'
require 'mixlib/cli'
require 'chef/mixin/convert_to_class_name'

require 'pp'

class Chef
  class Knife
    include Mixlib::CLI
    extend Chef::Mixin::ConvertToClassName

    # The "require paths" of the core knife subcommands bundled with chef
    DEFAULT_SUBCOMMAND_FILES = Dir[File.expand_path(File.join(File.dirname(__FILE__), 'knife', '*.rb'))]
    DEFAULT_SUBCOMMAND_FILES.map! { |knife_file| knife_file[/#{CHEF_ROOT}#{Regexp.escape(File::SEPARATOR)}(.*)\.rb/,1] }

    attr_accessor :name_args

    def self.msg(msg="")
      puts msg
    end

    def self.inherited(subclass)
      unless subclass.unnamed?
        subcommands[subclass.snake_case_name] = subclass
      end
    end

    # Explicitly set the category for the current command to +new_category+
    # The category is normally determined from the first word of the command
    # name, but some commands make more sense using two or more words
    # ===Arguments
    # new_category::: A String to set the category to (see examples)
    # ===Examples:
    # Data bag commands would be in the 'data' category by default. To put them
    # in the 'data bag' category:
    #   category('data bag')
    def self.category(new_category)
      @category = new_category
    end

    def self.subcommand_category
      @category || snake_case_name.split('_').first unless unnamed?
    end

    def self.snake_case_name
      convert_to_snake_case(name.split('::').last) unless unnamed?
    end

    # Does this class have a name? (Classes created via Class.new don't)
    def self.unnamed?
      name.nil? || name.empty?
    end

    def self.subcommands
      @@subcommands ||= {}
    end

    def self.subcommands_by_category
      unless @subcommands_by_category
        @subcommands_by_category = Hash.new { |hash, key| hash[key] = [] }
        subcommands.each do |snake_cased, klass|
          @subcommands_by_category[klass.subcommand_category] << snake_cased
        end
      end
      @subcommands_by_category
    end

    # Load all the sub-commands
    def self.load_commands
      DEFAULT_SUBCOMMAND_FILES.each { |subcommand| require subcommand }
      subcommands
    end

    # Print the list of subcommands knife knows about. If +preferred_category+
    # is given, only subcommands in that category are shown
    def self.list_commands(preferred_category=nil)
      load_commands
      category_desc = preferred_category ? preferred_category + " " : ''
      msg "Available #{category_desc}subcommands: (for details, knife SUB-COMMAND --help)\n\n"

      if preferred_category && subcommands_by_category.key?(preferred_category)
        commands_to_show = {preferred_category => subcommands_by_category[preferred_category]}
      else
        commands_to_show = subcommands_by_category
      end

      commands_to_show.sort.each do |category, commands|
        msg "** #{category.upcase} COMMANDS **"
        commands.each do |command|
          msg subcommands[command].banner if subcommands[command]
        end
        msg
      end
    end

    # Run knife for the given +args+ (ARGV), adding +options+ to the list of
    # CLI options that the subcommand knows how to handle.
    # ===Arguments
    # args::: usually ARGV
    # options::: A Mixlib::CLI option parser hash. These +options+ are how
    # subcommands know about global knife CLI options
    def self.run(args, options={})
      load_commands
      subcommand_class = subcommand_class_from(args)
      subcommand_class.options.merge!(options)
      instance = subcommand_class.new(args)
      instance.configure_chef
      instance.run
    end

    def self.guess_category(args)
      category_words = args.select {|arg| arg =~ /^([[:alnum:]]|_)+$/ }
      matching_category = nil
      while (!matching_category) && (!category_words.empty?)
        candidate_category = category_words.join(' ')
        matching_category = candidate_category if subcommands_by_category.key?(candidate_category)
        matching_category || category_words.pop
      end
      matching_category
    end

    def self.subcommand_class_from(args)
      command_words = args.select {|arg| arg =~ /^([[:alnum:]]|_)+$/ }
      subcommand_class = nil

      while ( !subcommand_class ) && ( !command_words.empty? )
        snake_case_class_name = command_words.join("_")
        unless subcommand_class = subcommands[snake_case_class_name]
          command_words.pop
        end
      end
      subcommand_class || subcommand_not_found!(args)
    end

    protected

    def load_late_dependency(dep, gem_name = nil)
      begin
        require dep
      rescue LoadError
        gem_name ||= dep.gsub('/', '-')
        Chef::Log.fatal "#{gem_name} is not installed. run \"gem install #{gem_name}\" to install it."
        exit 1
      end
    end

    private

    # :nodoc:
    # Error out and print usage. probably becuase the arguments given by the
    # user could not be resolved to a subcommand.
    def self.subcommand_not_found!(args)
      unless want_help?(args)
        Chef::Log.fatal("Cannot find sub command for: '#{args.join(' ')}'")
      end
      Chef::Knife.list_commands(guess_category(args))
      exit 10
    end

    # :nodoc:
    # TODO: duplicated with chef/application/knife
    # all logic should be removed from that and Chef::Knife should own it.
    def self.want_help?(args)
      (args.any? { |arg| arg =~ /^(:?(:?\-\-)?help|\-h)$/})
    end

    public

    # Create a new instance of the current class configured for the given
    # arguments and options
    def initialize(argv=[])
      super() # having to call super in initialize is the most annoying anti-pattern :(

      command_name_words = self.class.snake_case_name.split('_')

      # Mixlib::CLI ignores the embedded name_args
      @name_args = parse_options(argv)
      @name_args.reject! { |name_arg| command_name_words.delete(name_arg) }

      # knife node run_list add requires that we have extra logic to handle
      # the case that command name words could be joined by an underscore :/
      command_name_words = command_name_words.join('_')
      @name_args.reject! { |name_arg| command_name_words == name_arg }

      if config[:help]
        msg opt_parser
        exit 1
      end
    end

    def parse_options(args)
      super
    rescue OptionParser::InvalidOption => e
      puts "Error: " + e.to_s
      show_usage
      exit(1)
    end

    def ask_question(question, opts={})
      question = question + "[#{opts[:default]}] " if opts[:default]

      if opts[:default] and config[:defaults]

        opts[:default]

      else

        stdout.print question
        a = stdin.readline.strip

        if opts[:default]
          a.empty? ? opts[:default] : a
        else
          a
        end

      end

    end

    def configure_chef
      unless config[:config_file]
        full_path = Dir.pwd.split(File::SEPARATOR)
        (full_path.length - 1).downto(0) do |i|
          config_file_to_check = File.join([ full_path[0..i], ".chef", "knife.rb" ].flatten)
          if File.exists?(config_file_to_check)
            config[:config_file] = config_file_to_check 
            break
          end
        end
        # If we haven't set a config yet and $HOME is set, and the home
        # knife.rb exists, use it:
        if (!config[:config_file]) && ENV['HOME'] && File.exist?(File.join(ENV['HOME'], '.chef', 'knife.rb'))
          config[:config_file] = File.join(ENV['HOME'], '.chef', 'knife.rb')
        end
      end

      # Don't try to load a knife.rb if it doesn't exist.
      if config[:config_file]
        Chef::Config.from_file(config[:config_file])
      else
        # ...but do log a message if no config was found.
        self.msg("No knife configuration file found")
      end

      Chef::Config[:log_level] = config[:log_level] if config[:log_level]
      Chef::Config[:log_location] = config[:log_location] if config[:log_location]
      Chef::Config[:node_name] = config[:node_name] if config[:node_name]
      Chef::Config[:client_key] = config[:client_key] if config[:client_key]
      Chef::Config[:chef_server_url] = config[:chef_server_url] if config[:chef_server_url]
      Chef::Log.init(Chef::Config[:log_location])
      Chef::Log.level(Chef::Config[:log_level])

      Chef::Log.debug("Using configuration from #{config[:config_file]}")

      if Chef::Config[:node_name].nil?
        raise ArgumentError, "No user specified, pass via -u or specifiy 'node_name' in #{config[:config_file] ? config[:config_file] : "~/.chef/knife.rb"}"
      end
    end

    def pretty_print(data)
      puts data
    end

    def output(data)
      case config[:format]
      when "json", nil
        stdout.puts JSON.pretty_generate(data)
      when "yaml"
        require 'yaml'
        stdout.puts YAML::dump(data)
      when "text"
        # If you were looking for some attribute and there is only one match
        # just dump the attribute value
        if data.length == 1 and config[:attribute]
          stdout.puts data.values[0]
        else
          PP.pp(data, stdout)
        end
      else
        raise ArgumentError, "Unknown output format #{config[:format]}"
      end
    end

    def format_list_for_display(list)
      config[:with_uri] ? list : list.keys.sort { |a,b| a <=> b } 
    end

    def format_for_display(item)
      data = item.kind_of?(Chef::DataBagItem) ? item.raw_data : item

      if config[:attribute]
        config[:attribute].split(".").each do |attr|
          if data.respond_to?(:[])
            data = data[attr]
          elsif data.nil?
            nil # don't get no method error on nil
          else data.respond_to?(attr.to_sym)
            data = data.send(attr.to_sym)
          end
        end
        { config[:attribute] => data.kind_of?(Chef::Node::Attribute) ? data.to_hash : data }
      elsif config[:run_list]
        data = data.run_list.run_list
        { "run_list" => data }
      elsif config[:id_only]
        data.respond_to?(:name) ? data.name : data["id"]
      else
        data
      end
    end

    def edit_data(data, parse_output=true)
      output = JSON.pretty_generate(data)
      
      if (!config[:no_editor])
        filename = "knife-edit-"
        0.upto(20) { filename += rand(9).to_s }
        filename << ".js"
        filename = File.join(Dir.tmpdir, filename)
        tf = File.open(filename, "w")
        tf.sync = true
        tf.puts output
        tf.close
        raise "Please set EDITOR environment variable" unless system("#{config[:editor]} #{tf.path}") 
        tf = File.open(filename, "r")
        output = tf.gets(nil)
        tf.close
        File.unlink(filename)
      end

      parse_output ? JSON.parse(output) : output
    end

    def confirm(question, append_instructions=true)
      return true if config[:yes]

      stdout.print question
      stdout.print "? (Y/N) " if append_instructions
      answer = stdin.readline
      answer.chomp!
      case answer
      when "Y", "y"
        true
      when "N", "n"
        self.msg("You said no, so I'm done here.")
        exit 3 
      else
        self.msg("I have no idea what to do with #{answer}")
        self.msg("Just say Y or N, please.")
        confirm(question)
      end
    end

    def show_usage
      stdout.puts("USAGE: " + self.opt_parser.to_s)
    end

    def load_from_file(klass, from_file, bag=nil) 
      relative_path = ""
      if klass == Chef::Role
        relative_path = "roles"
      elsif klass == Chef::Node
        relative_path = "nodes"
      elsif klass == Chef::DataBagItem
        relative_path = "data_bags/#{bag}"
      end

      relative_file = File.expand_path(File.join(Dir.pwd, relative_path, from_file))
      filename = nil

      if file_exists_and_is_readable?(from_file)
        filename = from_file
      elsif file_exists_and_is_readable?(relative_file) 
        filename = relative_file 
      else
        Chef::Log.fatal("Cannot find file #{from_file}")
        exit 30
      end

      case from_file
      when /\.(js|json)$/
        JSON.parse(IO.read(filename))
      when /\.rb$/
        r = klass.new
        r.from_file(filename)
        r
      else
        Chef::Log.fatal("File must end in .js, .json, or .rb")
        exit 30
      end
    end

    def file_exists_and_is_readable?(file)
      File.exists?(file) && File.readable?(file)
    end

    def edit_object(klass, name)
      object = klass.load(name)

      output = edit_data(object)

      # Only make the save if the user changed the object.
      #
      # Output JSON for the original (object) and edited (output), then parse 
      # them without reconstituting the objects into real classes
      # (create_additions=false). Then, compare the resulting simple objects,
      # which will be Array/Hash/String/etc. 
      #
      # We wouldn't have to do these shenanigans if all the editable objects 
      # implemented to_hash, or if to_json against a hash returned a string 
      # with stable key order.
      object_parsed_again = JSON.parse(object.to_json, :create_additions => false)
      output_parsed_again = JSON.parse(output.to_json, :create_additions => false)
      if object_parsed_again != output_parsed_again
        output.save
        self.msg("Saved #{output}")
      else
        self.msg("Object unchanged, not saving")
      end

      output(format_for_display(object)) if config[:print_after]
    end

    def create_object(object, pretty_name=nil, &block)
      output = edit_data(object)

      if Kernel.block_given?
        output = block.call(output)
      else
        output.save
      end

      pretty_name ||= output

      self.msg("Created (or updated) #{pretty_name}")
      
      output(output) if config[:print_after]
    end

    def delete_object(klass, name, delete_name=nil, &block)
      confirm("Do you really want to delete #{name}")

      if Kernel.block_given?
        object = block.call
      else
        object = klass.load(name)
        object.destroy
      end

      output(format_for_display(object)) if config[:print_after]

      obj_name = delete_name ? "#{delete_name}[#{name}]" : object
      self.msg("Deleted #{obj_name}!")
    end

    def bulk_delete(klass, fancy_name, delete_name=nil, list=nil, regex=nil, &block)
      object_list = list ? list : klass.list(true)

      if regex
        to_delete = Hash.new
        object_list.each_key do |object|
          next if regex && object !~ /#{regex}/
          to_delete[object] = object_list[object]
        end
      else
        to_delete = object_list
      end

      output(format_list_for_display(to_delete))

      confirm("Do you really want to delete the above items")

      to_delete.each do |name, object|
        if Kernel.block_given?
          block.call(name, object)
        else
          object.destroy
        end
        output(format_for_display(object)) if config[:print_after]
        self.msg("Deleted #{fancy_name} #{name}")
      end
    end

    def msg(message)
      stdout.puts message
    end

    def stdout
      STDOUT
    end

    def stdin
      STDIN
    end

    def rest
      @rest ||= Chef::REST.new(Chef::Config[:chef_server_url])
    end

  end
end

