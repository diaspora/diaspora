# frozen_string_literal: true

module Api
  module Paging
    class TimePaginator
      def initialize(opts={})
        @query_base = opts[:query_base]
        @query_time_field = opts[:query_time_field]
        @data_time_field = opts[:data_time_field]
        @current_time = opts[:current_time]
        @limit = opts[:limit]
        @is_descending = opts[:is_descending]
        direction = if @is_descending
                      "<"
                    else
                      ">"
                    end
        @time_query_string = "#{@query_time_field} #{direction} ?"
        @sort_string = if @is_descending
                         "#{@query_time_field} DESC"
                       else
                         "#{@query_time_field} ASC"
                       end
      end

      def page_data
        return @data if @data

        @data = @query_base.where([@time_query_string, @current_time.iso8601(3)]).limit(@limit).order(@sort_string)
        time_data = @data.map {|d| d[@data_time_field] }.sort
        @min_time = time_data.first
        @max_time = time_data.last + 0.001.seconds if time_data.last

        @data
      end

      def next_page(for_url=true)
        page_data
        return nil unless next_time

        return next_page_as_query_parameter if for_url

        TimePaginator.new(
          query_base:       @query_base,
          query_time_field: @query_time_field,
          query_data_field: @data_time_field,
          current_time:     next_time,
          is_descending:    @is_descending,
          limit:            @limit
        )
      end

      def previous_page(for_url=true)
        page_data
        return nil unless previous_time

        return previous_page_as_query_parameter if for_url

        TimePaginator.new(
          query_base:       @query_base,
          query_time_field: @query_time_field,
          query_data_field: @data_time_field,
          current_time:     previous_time,
          is_descending:    !@is_descending,
          limit:            @limit
        )
      end

      def filter_parameters(parameters)
        parameters.delete(:before)
        parameters.delete(:after)
      end

      private

      def next_time
        if @is_descending
          @min_time
        else
          @max_time
        end
      end

      def previous_time
        if @is_descending
          @max_time
        else
          @min_time
        end
      end

      def next_page_as_query_parameter
        if @is_descending
          "before=#{next_time.iso8601(3)}"
        else
          "after=#{next_time.iso8601(3)}"
        end
      end

      def previous_page_as_query_parameter
        if @is_descending
          "after=#{previous_time.iso8601(3)}"
        else
          "before=#{previous_time.iso8601(3)}"
        end
      end
    end
  end
end
