#
# Author:: Adam Jacob (<adam@opscode.com>)
# Author:: Christopher Walters (<cw@opscode.com>)
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

require 'chef/mixin/params_validate'
require 'chef/mixin/check_helper'
require 'chef/mixin/language'
require 'chef/mixin/convert_to_class_name'
require 'chef/mixin/command'
require 'chef/resource_collection'
require 'chef/node'

require 'chef/mixin/deprecation'

class Chef
  class Resource
    class Notification < Struct.new(:resource, :action, :notifying_resource)

      def duplicates?(other_notification)
        unless other_notification.respond_to?(:resource) && other_notification.respond_to?(:action)
          msg = "only duck-types of Chef::Resource::Notification can be checked for duplication "\
                "you gave #{other_notification.inspect}"
          raise ArgumentError, msg
        end
        other_notification.resource == resource && other_notification.action == action
      end

      def resolve_resource_reference(resource_collection)
        return resource if resource.kind_of?(Chef::Resource)

        matching_resource = resource_collection.find(resource)
        if Array(matching_resource).size > 1
          msg = "Notification #{self} from #{notifying_resource} was created with a reference to multiple resources, "\
                "but can only notify one resource. Notifying resource was defined on #{notifying_resource.source_line}"
          raise Chef::Exceptions::InvalidResourceReference, msg
        end
        self.resource = matching_resource
      rescue Chef::Exceptions::ResourceNotFound => e
        err = Chef::Exceptions::ResourceNotFound.new(<<-FAIL)
Resource #{notifying_resource} is configured to notify resource #{resource} with action #{action}, \
but #{resource} cannot be found in the resource collection. #{notifying_resource} is defined in \
#{notifying_resource.source_line}
FAIL
        err.set_backtrace(e.backtrace)
        raise err
      rescue Chef::Exceptions::InvalidResourceSpecification => e
          err = Chef::Exceptions::InvalidResourceSpecification.new(<<-F)
Resource #{notifying_resource} is configured to notify resource #{resource} with action #{action}, \
but #{resource.inspect} is not valid syntax to look up a resource in the resource collection. Notification \
is defined near #{notifying_resource.source_line}
F
          err.set_backtrace(e.backtrace)
        raise err
      end

    end

    HIDDEN_IVARS = [:@allowed_actions, :@resource_name, :@source_line, :@run_context, :@name, :@node]

    include Chef::Mixin::CheckHelper
    include Chef::Mixin::ParamsValidate
    include Chef::Mixin::Language
    include Chef::Mixin::ConvertToClassName
    include Chef::Mixin::Deprecation
    
    attr_accessor :params
    attr_accessor :provider
    attr_accessor :allowed_actions
    attr_accessor :run_context
    attr_accessor :cookbook_name
    attr_accessor :recipe_name
    attr_accessor :enclosing_provider
    attr_accessor :source_line

    attr_reader :updated

    attr_reader :resource_name
    attr_reader :not_if_args
    attr_reader :only_if_args

    # Each notify entry is a resource/action pair, modeled as an
    # Struct with a #resource and #action member
    attr_reader :immediate_notifications
    attr_reader :delayed_notifications
    
    def initialize(name, run_context=nil)
      @name = name
      @run_context = run_context
      @noop = nil
      @before = nil
      @params = Hash.new
      @provider = nil
      @allowed_actions = [ :nothing ]
      @action = :nothing
      @updated = false
      @updated_by_last_action = false
      @supports = {}
      @ignore_failure = false
      @not_if = nil
      @not_if_args = {}
      @only_if = nil
      @only_if_args = {}
      @immediate_notifications = Array.new
      @delayed_notifications = Array.new
      @source_line = nil

      @node = run_context ? deprecated_ivar(run_context.node, :node, :warn) : nil
    end

    def updated=(true_or_false)
      Chef::Log.warn("Chef::Resource#updated=(true|false) is deprecated. Please call #updated_by_last_action(true|false) instead.")
      Chef::Log.warn("Called from:")
      caller[0..3].each {|line| Chef::Log.warn(line)}
      updated_by_last_action(true_or_false)
      @updated = true_or_false
    end

    def node
      run_context && run_context.node
    end

    # If an unknown method is invoked, determine whether the enclosing Provider's
    # lexical scope can fulfill the request. E.g. This happens when the Resource's
    # block invokes new_resource.
    def method_missing(method_symbol, *args, &block)
      if enclosing_provider && enclosing_provider.respond_to?(method_symbol)
        enclosing_provider.send(method_symbol, *args, &block)
      else
        raise NoMethodError, "undefined method `#{method_symbol.to_s}' for #{self.class.to_s}"
      end
    end
    
    def load_prior_resource
      begin
        prior_resource = run_context.resource_collection.lookup(self.to_s)
        Chef::Log.debug("Setting #{self.to_s} to the state of the prior #{self.to_s}")
        prior_resource.instance_variables.each do |iv|
          unless iv.to_sym == :@source_line || iv.to_sym == :@action
            self.instance_variable_set(iv, prior_resource.instance_variable_get(iv))
          end
        end
        true
      rescue Chef::Exceptions::ResourceNotFound => e
        true
      end
    end
    
    def supports(args={})
      if args.any?
        @supports = args
      else
        @supports
      end
    end
    
    def provider(arg=nil)
      klass = if arg.kind_of?(String) || arg.kind_of?(Symbol)
                lookup_provider_constant(arg)
              else
                arg
              end
      set_or_return(
        :provider,
        klass,
        :kind_of => [ Class ]
      )
    end
    
    def action(arg=nil)
      if arg
        action_list = arg.kind_of?(Array) ? arg : [ arg ]
        action_list = action_list.collect { |a| a.to_sym }
        action_list.each do |action|
          validate(
            {
              :action => action,
            },
            {
              :action => { :kind_of => Symbol, :equal_to => @allowed_actions },
            }
          )
        end
        @action = action_list
      else
        @action
      end
    end
    
    def name(name=nil)
      set_if_args(@name, name) do
        raise ArgumentError, "name must be a string!" unless name.kind_of?(String)
        @name = name
      end
    end
    
    def noop(tf=nil)
      set_if_args(@noop, tf) do 
        raise ArgumentError, "noop must be true or false!" unless tf == true || tf == false
        @noop = tf
      end
    end
    
    def ignore_failure(arg=nil)
      set_or_return(
        :ignore_failure,
        arg,
        :kind_of => [ TrueClass, FalseClass ]
      )
    end
    
    def epic_fail(arg=nil)
      ignore_failure(arg)
    end

    def notifies(*args)
      unless ( args.size > 0 && args.size < 4)
        raise ArgumentError, "Wrong number of arguments for notifies: should be 1-3 arguments, you gave #{args.inspect}"
      end

      if args.size > 1 # notifies(:action, resource) OR notifies(:action, resource, :immediately)
        add_notification(*args)
      else
        # This syntax is so weird. surely people will just give us one hash?
        notifications = args.flatten
        notifications.each do |resources_notifications|
          resources_notifications.each do |resource, notification|
            action, timing = notification[0], notification[1]
            Chef::Log.debug "adding notification from resource #{self} to `#{resource.inspect}' => `#{notification.inspect}'"
            add_notification(action, resource, timing)
          end
        end 
      end
    rescue NoMethodError
      Chef::Log.fatal("Error processing notifies(#{args.inspect}) on #{self}")
      raise
    end

    def add_notification(action, resources, timing=:delayed)
      resources = [resources].flatten
      resources.each do |resource|
        case timing.to_s
        when 'delayed'
          notifies_delayed(action, resource)
        when 'immediate', 'immediately'
          notifies_immediately(action, resource)
        else
          raise ArgumentError,  "invalid timing: #{timing} for notifies(#{action}, #{resources.inspect}, #{timing}) resource #{self} "\
                                "Valid timings are: :delayed, :immediate, :immediately"
        end
      end

      true
    end

    # Iterates over all immediate and delayed notifications, calling
    # resolve_resource_reference on each in turn, causing them to
    # resolve lazy/forward references.
    def resolve_notification_references
      @immediate_notifications.each { |n| n.resolve_resource_reference(run_context.resource_collection) }
      @delayed_notifications.each {|n| n.resolve_resource_reference(run_context.resource_collection) }
    end

    def notifies_immediately(action, resource_spec)
      @immediate_notifications << Notification.new(resource_spec, action, self)
    end

    def notifies_delayed(action, resource_spec)
      @delayed_notifications << Notification.new(resource_spec, action, self)
    end

    def resources(*args)
      run_context.resource_collection.find(*args)
    end
    
    def subscribes(action, resources, timing=:delayed)
      resources = [resources].flatten
      resources.each do |resource|
        resource.notifies(action, self, timing)
      end
      true
    end

    def is(*args)
      if args.size == 1
        args.first
      else
        return *args
      end
    end
    
    def to_s
      "#{@resource_name}[#{@name}]"
    end

    def to_text
      ivars = instance_variables.map { |ivar| ivar.to_sym } - HIDDEN_IVARS
      text = "# Declared in #{@source_line}\n"
      text << convert_to_snake_case(self.class.name, 'Chef::Resource') + "(\"#{name}\") do\n"
      ivars.each do |ivar|
        if (value = instance_variable_get(ivar)) && !(value.respond_to?(:empty?) && value.empty?)
          text << "  #{ivar.to_s.sub(/^@/,'')}(#{value.inspect})\n"
        end
      end
      text << "end\n"
    end
    
    # Serialize this object as a hash 
    def to_json(*a)
      instance_vars = Hash.new
      self.instance_variables.each do |iv|
        unless iv == "@run_context"
          instance_vars[iv] = self.instance_variable_get(iv) 
        end
      end
      results = {
        'json_class' => self.class.name,
        'instance_vars' => instance_vars
      }
      results.to_json(*a)
    end
    
    def to_hash
      instance_vars = Hash.new
      self.instance_variables.each do |iv|
        key = iv.to_s.sub(/^@/,'').to_sym
        instance_vars[key] = self.instance_variable_get(iv) unless (key == :run_context) || (key == :node)
      end
      instance_vars
    end
    
    def only_if(arg=nil, args = {}, &blk)
      if Kernel.block_given?
        @only_if = blk
        @only_if_args = args
      else
        @only_if = arg if arg
        @only_if_args = args if arg
      end
      @only_if
    end
    
    def not_if(arg=nil, args = {}, &blk)
      if Kernel.block_given?
        @not_if = blk
        @not_if_args = args
      else
        @not_if = arg if arg
        @not_if_args = args if arg
      end
      @not_if
    end
    
    def run_action(action)
      # ensure that we don't leave @updated_by_last_action set to true
      # on accident
      updated_by_last_action(false)

      # Check if this resource has an only_if block -- if it does,
      # evaluate the only_if block and skip the resource if
      # appropriate.
      if only_if
        unless Chef::Mixin::Command.only_if(only_if, only_if_args)
          Chef::Log.debug("Skipping #{self} due to only_if")
          return
        end
      end

      # Check if this resource has a not_if block -- if it does,
      # evaluate the not_if block and skip the resource if
      # appropriate.
      if not_if
        unless Chef::Mixin::Command.not_if(not_if, not_if_args)
          Chef::Log.debug("Skipping #{self} due to not_if")
          return
        end
      end

      provider = Chef::Platform.provider_for_resource(self)
      provider.load_current_resource
      provider.send("action_#{action}")
    end

    def updated_by_last_action(true_or_false)
      @updated ||= true_or_false
      @updated_by_last_action = true_or_false
    end

    def updated_by_last_action?
      @updated_by_last_action
    end
    
    def updated?
      updated
    end

    class << self
      
      def json_create(o)
        resource = self.new(o["instance_vars"]["@name"])
        o["instance_vars"].each do |k,v|
          resource.instance_variable_set(k.to_sym, v)
        end
        resource
      end
      
      include Chef::Mixin::ConvertToClassName
      
      def attribute(attr_name, validation_opts={})
        # This atrocity is the only way to support 1.8 and 1.9 at the same time
        # When you're ready to drop 1.8 support, do this:
        # define_method attr_name.to_sym do |arg=nil|
        # etc.
        shim_method=<<-SHIM
        def #{attr_name}(arg=nil)
          _set_or_return_#{attr_name}(arg)
        end
        SHIM
        class_eval(shim_method)
        
        define_method("_set_or_return_#{attr_name.to_s}".to_sym) do |arg|
          set_or_return(attr_name.to_sym, arg, validation_opts)
        end
      end
      
      def build_from_file(cookbook_name, filename)
        rname = filename_to_qualified_string(cookbook_name, filename)

        # Add log entry if we override an existing light-weight resource.
        class_name = convert_to_class_name(rname)
        overriding = Chef::Resource.const_defined?(class_name)
        Chef::Log.info("#{class_name} light-weight resource already initialized -- overriding!") if overriding
          
        new_resource_class = Class.new self do |cls|
          
          # default initialize method that ensures that when initialize is finally
          # wrapped (see below), super is called in the event that the resource
          # definer does not implement initialize
          def initialize(name, run_context)
            super(name, run_context)
          end
          
          @actions_to_create = []
          
          class << cls
            include Chef::Mixin::FromFile
            
            def actions_to_create
              @actions_to_create
            end
            
            define_method(:actions) do |*action_names|
              actions_to_create.push(*action_names)
            end
          end
          
          # load resource definition from file
          cls.class_from_file(filename)
          
          # create a new constructor that wraps the old one and adds the actions
          # specified in the DSL
          old_init = instance_method(:initialize)

          define_method(:initialize) do |name, *optional_args|
            args_run_context = optional_args.shift
            @resource_name = rname.to_sym
            old_init.bind(self).call(name, args_run_context)
            allowed_actions.push(self.class.actions_to_create).flatten!
          end
        end
        
        # register new class as a Chef::Resource
        class_name = convert_to_class_name(rname)
        Chef::Resource.const_set(class_name, new_resource_class)
        Chef::Log.debug("Loaded contents of #{filename} into a resource named #{rname} defined in Chef::Resource::#{class_name}")
        
        new_resource_class
      end
      
      # Resources that want providers namespaced somewhere other than 
      # Chef::Provider can set the namespace with +provider_base+
      # Ex:
      #   class MyResource < Chef::Resource
      #     provider_base Chef::Provider::Deploy
      #     # ...other stuff
      #   end
      def provider_base(arg=nil)
        @provider_base ||= arg
        @provider_base ||= Chef::Provider
      end
      
    end

    private

    def lookup_provider_constant(name)
      begin
        self.class.provider_base.const_get(convert_to_class_name(name.to_s))
      rescue NameError => e
        if e.to_s =~ /#{Regexp.escape(self.class.provider_base.to_s)}/
          raise ArgumentError, "No provider found to match '#{name}'"
        else
          raise e
        end
      end
    end

  end
end
