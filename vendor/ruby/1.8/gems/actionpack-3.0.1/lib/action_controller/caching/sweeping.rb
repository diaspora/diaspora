module ActionController #:nodoc:
  module Caching
    # Sweepers are the terminators of the caching world and responsible for expiring caches when model objects change.
    # They do this by being half-observers, half-filters and implementing callbacks for both roles. A Sweeper example:
    #
    #   class ListSweeper < ActionController::Caching::Sweeper
    #     observe List, Item
    #
    #     def after_save(record)
    #       list = record.is_a?(List) ? record : record.list
    #       expire_page(:controller => "lists", :action => %w( show public feed ), :id => list.id)
    #       expire_action(:controller => "lists", :action => "all")
    #       list.shares.each { |share| expire_page(:controller => "lists", :action => "show", :id => share.url_key) }
    #     end
    #   end
    #
    # The sweeper is assigned in the controllers that wish to have its job performed using the <tt>cache_sweeper</tt> class method:
    #
    #   class ListsController < ApplicationController
    #     caches_action :index, :show, :public, :feed
    #     cache_sweeper :list_sweeper, :only => [ :edit, :destroy, :share ]
    #   end
    #
    # In the example above, four actions are cached and three actions are responsible for expiring those caches.
    #
    # You can also name an explicit class in the declaration of a sweeper, which is needed if the sweeper is in a module:
    #
    #   class ListsController < ApplicationController
    #     caches_action :index, :show, :public, :feed
    #     cache_sweeper OpenBar::Sweeper, :only => [ :edit, :destroy, :share ]
    #   end
    module Sweeping
      extend ActiveSupport::Concern

      module ClassMethods #:nodoc:
        def cache_sweeper(*sweepers)
          configuration = sweepers.extract_options!

          sweepers.each do |sweeper|
            ActiveRecord::Base.observers << sweeper if defined?(ActiveRecord) and defined?(ActiveRecord::Base)
            sweeper_instance = (sweeper.is_a?(Symbol) ? Object.const_get(sweeper.to_s.classify) : sweeper).instance

            if sweeper_instance.is_a?(Sweeper)
              around_filter(sweeper_instance, :only => configuration[:only])
            else
              after_filter(sweeper_instance, :only => configuration[:only])
            end
          end
        end
      end
    end

    if defined?(ActiveRecord) and defined?(ActiveRecord::Observer)
      class Sweeper < ActiveRecord::Observer #:nodoc:
        attr_accessor :controller

        def before(controller)
          self.controller = controller
          callback(:before) if controller.perform_caching
          true # before method from sweeper should always return true
        end

        def after(controller)
          callback(:after) if controller.perform_caching
          # Clean up, so that the controller can be collected after this request
          self.controller = nil
        end

        protected
          # gets the action cache path for the given options.
          def action_path_for(options)
            Actions::ActionCachePath.new(controller, options).path
          end

          # Retrieve instance variables set in the controller.
          def assigns(key)
            controller.instance_variable_get("@#{key}")
          end

        private
          def callback(timing)
            controller_callback_method_name = "#{timing}_#{controller.controller_name.underscore}"
            action_callback_method_name     = "#{controller_callback_method_name}_#{controller.action_name}"

            __send__(controller_callback_method_name) if respond_to?(controller_callback_method_name, true)
            __send__(action_callback_method_name)     if respond_to?(action_callback_method_name, true)
          end

          def method_missing(method, *arguments, &block)
            return if @controller.nil?
            @controller.__send__(method, *arguments, &block)
          end
      end
    end
  end
end
