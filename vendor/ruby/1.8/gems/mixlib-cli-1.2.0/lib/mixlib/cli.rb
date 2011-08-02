#
# Author:: Adam Jacob (<adam@opscode.com>)
# Copyright:: Copyright (c) 2008 Opscode, Inc.
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

require 'optparse'

module Mixlib
  module CLI
    module ClassMethods       
      # Add a command line option.
      #
      # === Parameters
      # name<Symbol>:: The name of the option to add
      # args<Hash>:: A hash of arguments for the option, specifying how it should be parsed.
      # === Returns
      # true:: Always returns true.
      def option(name, args)
        @options ||= {}
        raise(ArgumentError, "Option name must be a symbol") unless name.kind_of?(Symbol)
        @options[name.to_sym] = args
      end
      
      # Get the hash of current options.
      #
      # === Returns
      # @options<Hash>:: The current options hash.
      def options
        @options ||= {}
        @options
      end
      
      # Set the current options hash
      #
      # === Parameters
      # val<Hash>:: The hash to set the options to
      #
      # === Returns
      # @options<Hash>:: The current options hash.
      def options=(val)
        raise(ArgumentError, "Options must recieve a hash") unless val.kind_of?(Hash)
        @options = val
      end
      
      # Change the banner.  Defaults to:
      #   Usage: #{0} (options)
      #
      # === Parameters
      # bstring<String>:: The string to set the banner to
      # 
      # === Returns
      # @banner<String>:: The current banner
      def banner(bstring=nil)
        if bstring
          @banner = bstring
        else
          @banner ||= "Usage: #{$0} (options)"
          @banner
        end
      end
    end
    
    attr_accessor :options, :config, :banner, :opt_parser
    
    # Create a new Mixlib::CLI class.  If you override this, make sure you call super!
    #
    # === Parameters
    # *args<Array>:: The array of arguments passed to the initializer
    #
    # === Returns
    # object<Mixlib::Config>:: Returns an instance of whatever you wanted :)
    def initialize(*args)
      @options = Hash.new
      @config  = Hash.new
      
      # Set the banner
      @banner  = self.class.banner
      
      # Dupe the class options for this instance
      klass_options = self.class.options
      klass_options.keys.inject(@options) { |memo, key| memo[key] = klass_options[key].dup; memo }
      
      # Set the default configuration values for this instance
      @options.each do |config_key, config_opts|
        config_opts[:on] ||= :on
        config_opts[:boolean] ||= false
        config_opts[:required] ||= false
        config_opts[:proc] ||= nil
        config_opts[:show_options] ||= false
        config_opts[:exit] ||= nil
        
        if config_opts.has_key?(:default)
          @config[config_key] = config_opts[:default]
        end
      end
      
      super(*args)
    end
    
    # Parses an array, by default ARGV, for command line options (as configured at 
    # the class level).
    # === Parameters
    # argv<Array>:: The array of arguments to parse; defaults to ARGV
    #
    # === Returns
    # argv<Array>:: Returns any un-parsed elements.
    def parse_options(argv=ARGV)
      argv = argv.dup
      @opt_parser = OptionParser.new do |opts|  
        # Set the banner
        opts.banner = banner        
        
        # Create new options
        options.sort { |a, b| a[0].to_s <=> b[0].to_s }.each do |opt_key, opt_val|          
          opt_args = build_option_arguments(opt_val)
          
          opt_method = case opt_val[:on]
            when :on
              :on
            when :tail
              :on_tail
            when :head
              :on_head
            else
              raise ArgumentError, "You must pass :on, :tail, or :head to :on"
            end
                      
          parse_block = case opt_val[:boolean]
            when true
              Proc.new() do
                config[opt_key] = (opt_val[:proc] && opt_val[:proc].call(true)) || true
                puts opts if opt_val[:show_options]
                exit opt_val[:exit] if opt_val[:exit]
              end
            when false
              Proc.new() do |c|
                config[opt_key] = (opt_val[:proc] && opt_val[:proc].call(c)) || c
                puts opts if opt_val[:show_options]
                exit opt_val[:exit] if opt_val[:exit]
              end
            end
                    
          full_opt = [ opt_method ]
          opt_args.inject(full_opt) { |memo, arg| memo << arg; memo }
          full_opt << parse_block
          opts.send(*full_opt)
        end
      end
      @opt_parser.parse!(argv)
      
      # Deal with any required values
      options.each do |opt_key, opt_value|
        if opt_value[:required]
          reqarg = opt_value[:short] || opt_value[:long]
          puts "You must supply #{reqarg}!"
          puts @opt_parser
          exit 2
        end
      end
      
      argv
    end
    
    def build_option_arguments(opt_setting)      
      arguments = Array.new
      
      arguments << opt_setting[:short] if opt_setting.has_key?(:short)
      arguments << opt_setting[:long] if opt_setting.has_key?(:long)
      
      if opt_setting.has_key?(:description)
        description = opt_setting[:description]
        description << " (required)" if opt_setting[:required]
        arguments << description
      end
          
      arguments
    end
    
    def self.included(receiver)
      receiver.extend(Mixlib::CLI::ClassMethods)
    end
    
  end
end
