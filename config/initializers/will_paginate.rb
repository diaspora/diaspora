# frozen_string_literal: true

require 'will_paginate/array'

# Optional for Bootstrap :renderer => WillPaginate::ActionView::BootstrapLinkRenderer
# https://github.com/yrgoldteeth/bootstrap-will_paginate

module WillPaginate
  module ActionView
    def will_paginate(collection = nil, options = {} )
      options, collection = collection, nil if collection.is_a? Hash
      # Taken from original will_paginate code to handle if the helper is not passed a collection object.
      collection ||= infer_collection_from_controller
      options[:renderer] ||= WillPaginate::ActionView::LinkRenderer
      super.try :html_safe
    end

    class BootstrapLinkRenderer < LinkRenderer
      protected

      def html_container(html)
        tag :div, tag(:ul, html, class: "pagination"), container_attributes
      end

      def page_number(page)
        tag :li, link(page, page, :rel => rel_value(page)), :class => ('active' if page == current_page)
      end

      def gap
        tag :li, link(super, '#'), :class => 'disabled'
      end

      def previous_or_next_page(page, text, classname)
        tag :li, link(text, page || '#'), :class => [classname[0..3], classname, ('disabled' unless page)].join(' ')
      end
    end
  end
end
