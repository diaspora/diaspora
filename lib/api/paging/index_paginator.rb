# frozen_string_literal: true

module Api
  module Paging
    class IndexPaginator
      def initialize(query_base, current_page, limit)
        @query_base = query_base
        @current_page = current_page.to_i
        @limit = limit.to_i
      end

      def page_data
        @page_data ||= @query_base.paginate(page: @current_page, per_page: @limit)
        @max_page = (@query_base.count * 1.0 / @limit * 1.0).ceil
        @max_page = 1 if @max_page < 1
        @page_data
      end

      def next_page(for_url=true)
        page_data
        return nil if for_url && @current_page == @max_page

        return "page=#{@current_page + 1}" if for_url

        IndexPaginator.new(@query_base, @current_page + 1, @limit)
      end

      def previous_page(for_url=true)
        page_data
        return nil if for_url && @current_page == 1

        return "page=#{@current_page - 1}" if for_url

        IndexPaginator.new(@query_base, @current_page - 1, @limit)
      end

      def filter_parameters(parameters)
        parameters.delete(:page)
      end
    end
  end
end
