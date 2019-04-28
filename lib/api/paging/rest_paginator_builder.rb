# frozen_string_literal: true

module Api
  module Paging
    class RestPaginatorBuilder
      MAX_LIMIT = 100
      DEFAULT_LIMIT = 15

      def initialize(base_query, request, allow_default_page=true, default_limit=DEFAULT_LIMIT)
        @base_query = base_query
        @request = request
        @allow_default_page = allow_default_page
        @default_limit = if default_limit < MAX_LIMIT && default_limit > 0
                           default_limit
                         else
                           DEFAULT_LIMIT
                         end
      end

      def index_pager(params)
        current_page = current_page_settings(params)
        paged_response_builder(IndexPaginator.new(@base_query, current_page, limit_settings(params)))
      end

      def time_pager(params, query_time_field="created_at", data_time_field=query_time_field)
        is_descending, current_time = time_settings(params)
        paged_response_builder(
          TimePaginator.new(
            query_base:       @base_query,
            query_time_field: query_time_field,
            data_time_field:  data_time_field,
            current_time:     current_time,
            is_descending:    is_descending,
            limit:            limit_settings(params)
          )
        )
      end

      private

      def current_page_settings(params)
        if params["page"]
          requested_page = params["page"].to_i
          requested_page = 1 if requested_page < 1
          requested_page
        elsif @allow_default_page
          1
        else
          raise ActionController::ParameterMissing
        end
      end

      def paged_response_builder(paginator)
        Api::Paging::RestPagedResponseBuilder.new(paginator, @request)
      end

      def time_settings(params)
        time_params = params.permit("before", "after")
        time_params["before"] = (Time.current + 1.year).iso8601 if time_params.empty? && @allow_default_page

        raise "Missing time parameters for query building" if time_params.empty?

        if time_params["before"]
          is_descending = true
          current_time = Time.iso8601(time_params["before"])
        else
          is_descending = false
          current_time = Time.iso8601(time_params["after"])
        end
        [is_descending, current_time]
      end

      def limit_settings(params)
        requested_limit = params["per_page"].to_i if params["per_page"]
        return @default_limit unless requested_limit

        requested_limit = [1, requested_limit].max
        [requested_limit, MAX_LIMIT].min
      end
    end
  end
end
