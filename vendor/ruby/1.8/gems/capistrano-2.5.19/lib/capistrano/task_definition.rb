require 'capistrano/server_definition'

module Capistrano
  # Represents the definition of a single task.
  class TaskDefinition
    attr_reader :name, :namespace, :options, :body, :desc, :on_error, :max_hosts
    
    def initialize(name, namespace, options={}, &block)
      
      if name.to_s =~ /^(?:before_|after_)/
        Kernel.warn("[Deprecation Warning] Naming tasks with before_ and after_ is deprecated, please see the new before() and after() methods. (Offending task name was #{name})")
      end
      
      @name, @namespace, @options = name, namespace, options
      @desc = @options.delete(:desc)
      @on_error = options.delete(:on_error)
      @max_hosts = options[:max_hosts] && options[:max_hosts].to_i
      @body = block or raise ArgumentError, "a task requires a block"
      @servers = nil
    end
    
    # Returns the task's fully-qualified name, including the namespace
    def fully_qualified_name
      @fully_qualified_name ||= begin
        if namespace.default_task == self
          namespace.fully_qualified_name
        else
          [namespace.fully_qualified_name, name].compact.join(":")
        end
      end
    end
    
    # Returns the description for this task, with newlines collapsed and
    # whitespace stripped. Returns the empty string if there is no
    # description for this task.
    def description(rebuild=false)
      @description = nil if rebuild
      @description ||= begin
        description = @desc || ""
        
        indentation = description[/\A\s+/]
        if indentation
          reformatted_description = ""
          description.strip.each_line do |line|
            line = line.chomp.sub(/^#{indentation}/, "")
            line = line.gsub(/#{indentation}\s*/, " ") if line[/^\S/]
            reformatted_description << line << "\n"
          end
          description = reformatted_description
        end

        description.strip.gsub(/\r\n/, "\n")
      end
    end

    # Returns the first sentence of the full description. If +max_length+ is
    # given, the result will be truncated if it is longer than +max_length+,
    # and an ellipsis appended.
    def brief_description(max_length=nil)
      brief = description[/^.*?\.(?=\s|$)/] || description

      if max_length && brief.length > max_length
        brief = brief[0,max_length-3] + "..."
      end

      brief
    end

    # Indicates whether the task wants to continue, even if a server has failed
    # previously
    def continue_on_error?
      @on_error == :continue
    end
  end
end
