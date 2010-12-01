module Devise
  module Controllers
    module ScopedViews
      extend ActiveSupport::Concern

      module ClassMethods
        def scoped_views?
          defined?(@scoped_views) ? @scoped_views : Devise.scoped_views
        end

        def scoped_views=(value)
          @scoped_views = value
        end
      end

    protected

      # Render a view for the specified scope. Turned off by default.
      # Accepts just :controller as option.
      def render_with_scope(action, options={})
        controller_name = options.delete(:controller) || self.controller_name

        if self.class.scoped_views?
          begin
            render :template => "#{devise_mapping.plural}/#{controller_name}/#{action}"
          rescue ActionView::MissingTemplate
            render :template => "#{controller_path}/#{action}"
          end
        else
          render :template => "#{controller_path}/#{action}"
        end
      end
    end
  end
end