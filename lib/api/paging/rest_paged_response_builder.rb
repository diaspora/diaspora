# frozen_string_literal: true

module Api
  module Paging
    class RestPagedResponseBuilder
      def initialize(pager, request, allowed_params=nil)
        @pager = pager
        @base_url = request.original_url.split("?").first if request
        @query_parameters = if allowed_params
                              allowed_params
                            elsif request&.query_parameters
                              request&.query_parameters
                            else
                              {}
                            end
      end

      def response
        {
          links: navigation_builder,
          data:  @pager.page_data
        }
      end

      private

      def navigation_builder
        previous_page = @pager.previous_page
        links = {}
        links[:previous] = link_builder(previous_page) if previous_page

        next_page = @pager.next_page
        links[:next] = link_builder(next_page) if next_page

        links
      end

      def link_builder(page_parameter)
        "#{@base_url}?#{filtered_original_parameters}#{page_parameter}"
      end

      def filtered_original_parameters
        @pager.filter_parameters(@query_parameters)
        return "" if @query_parameters.empty?

        @query_parameters.map {|k, v| "#{k}=#{v}" }.join("&") + "&"
      end
    end
  end
end
