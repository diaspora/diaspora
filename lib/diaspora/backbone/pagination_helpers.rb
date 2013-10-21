
module Diaspora::Backbone
  module PaginationHelpers
    module Helpers

      def paginate(relation)
        @paginated = relation.paginate(page: page, per_page: per_page)
        set_pagination_header
        @paginated
      end

      private

      def page
        p = params[:page].to_i
        p.between?(1, Float::INFINITY) ? p : 1
      end

      def per_page
        max = 50
        if p = params[:per_page].to_i
          if p.between?(1, max)
            p
          elsif p > max
            max
          elsif p < 1
            15
          end
        else
          15
        end
      end

      def set_pagination_header
        request_url = request.url.split("?")[0]

        links = []
        links << %(<#{request_url}?page=#{@paginated.previous_page.to_s}&per_page=#{per_page}>; rel="prev") if @paginated.previous_page
        links << %(<#{request_url}?page=#{@paginated.next_page.to_s}&per_page=#{per_page}>; rel="next") if @paginated.next_page
        links << %(<#{request_url}?page=1&per_page=#{per_page}>; rel="first")
        links << %(<#{request_url}?page=#{@paginated.total_pages.to_s}&per_page=#{per_page}>; rel="last")

        headers "Link" => links.join(",")
      end

    end

    def self.registered(app)
      app.helpers PaginationHelpers::Helpers
    end
  end
end
