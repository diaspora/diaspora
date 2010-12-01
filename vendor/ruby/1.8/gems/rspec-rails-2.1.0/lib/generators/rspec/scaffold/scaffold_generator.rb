require 'generators/rspec'
require 'rails/generators/resource_helpers'

module Rspec
  module Generators
    class ScaffoldGenerator < Base
      include Rails::Generators::ResourceHelpers
      source_paths << File.expand_path("../../helper/templates", __FILE__)
      argument :attributes, :type => :array, :default => [], :banner => "field:type field:type"

      class_option :orm, :desc => "ORM used to generate the controller"
      class_option :template_engine, :desc => "Template engine to generate view files"
      class_option :singleton, :type => :boolean, :desc => "Supply to create a singleton controller"

      class_option :controller_specs, :type => :boolean, :default => true,  :desc => "Generate controller specs"
      class_option :view_specs,       :type => :boolean, :default => true,  :desc => "Generate view specs"
      class_option :webrat_matchers,  :type => :boolean, :default => false, :desc => "Use webrat matchers in view specs"
      class_option :helper_specs,     :type => :boolean, :default => true,  :desc => "Generate helper specs"
      class_option :routing_specs,    :type => :boolean, :default => true,  :desc => "Generate routing specs"

      def generate_controller_spec
        return unless options[:controller_specs]

        template 'controller_spec.rb',
                 File.join('spec/controllers', controller_class_path, "#{controller_file_name}_controller_spec.rb")
      end

      def generate_view_specs
        return unless options[:view_specs]

        copy_view :edit
        copy_view :index unless options[:singleton]
        copy_view :new
        copy_view :show
      end

      # Invoke the helper using the controller name (pluralized)
      hook_for :helper, :as => :scaffold do |invoked|
        invoke invoked, [ controller_name ]
      end

      def generate_routing_spec
        return unless options[:routing_specs]

        template 'routing_spec.rb',
          File.join('spec/routing', controller_class_path, "#{controller_file_name}_routing_spec.rb")
      end

      hook_for :integration_tool, :as => :integration

      protected

        def webrat?
          options[:webrat_matchers] || @webrat_matchers_requested
        end

        def copy_view(view)
          template "#{view}_spec.rb",
                   File.join("spec/views", controller_file_path, "#{view}.html.#{options[:template_engine]}_spec.rb")
        end

        def params
          "{'these' => 'params'}"
        end

        # Returns the name of the mock. For example, if the file name is user,
        # it returns mock_user.
        #
        # If a hash is given, it uses the hash key as the ORM method and the
        # value as response. So, for ActiveRecord and file name "User":
        #
        #   mock_file_name(:save => true)
        #   #=> mock_user(:save => true)
        #
        # If another ORM is being used and another method instead of save is
        # called, it will be the one used.
        #
        def mock_file_name(hash=nil)
          if hash
            method, and_return = hash.to_a.first
            method = orm_instance.send(method).split('.').last.gsub(/\(.*?\)/, '')
            "mock_#{file_name}(:#{method} => #{and_return})"
          else
            "mock_#{file_name}"
          end
        end

        # Receives the ORM chain and convert to expects. For ActiveRecord:
        #
        #   should! orm_class.find(User, "37")
        #   #=> User.should_receive(:find).with(37)
        #
        # For Datamapper:
        #
        #   should! orm_class.find(User, "37")
        #   #=> User.should_receive(:get).with(37)
        #
        def should_receive!(chain)
          stub_or_should_chain(:should_receive, chain)
        end

        # Receives the ORM chain and convert to stub. For ActiveRecord:
        #
        #   stub! orm_class.find(User, "37")
        #   #=> User.stub!(:find).with(37)
        #
        # For Datamapper:
        #
        #   stub! orm_class.find(User, "37")
        #   #=> User.stub!(:get).with(37)
        #
        def stub!(chain)
          stub_or_should_chain(:stub, chain)
        end

        def stub_or_should_chain(mode, chain)
          receiver, method = chain.split(".")
          method.gsub!(/\((.*?)\)/, '')

          response = "#{receiver}.#{mode}(:#{method})"
          response << ".with(#{$1})" unless $1.blank?
          response
        end

        def value_for(attribute)
          case attribute.type
          when :string
            "#{attribute.name.titleize}".inspect
          else
            attribute.default.inspect
          end
        end

        def banner
          self.class.banner
        end

    end
  end
end
