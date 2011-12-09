require 'erb'

module Diaspora
  module Markdownify
    class HTML < Redcarpet::Render::HTML
      include ActionView::Helpers::TextHelper
      include ActionView::Helpers::TagHelper

      def resolve_redirection( url_s )
        cached = ShortUrlExpansion.find_by_url_short(url_s)
        if cached
          return cached.url_expanded
        end

        begin
          resolution = url_s
          url = URI.parse(url_s)
          res = nil
          num_redirections = 0

          timeout(3) do
            while num_redirections < 8
              if url.host && url.port
                host, port = url.host, url.port
              else
                break
              end

              req = Net::HTTP::Get.new(url.path)
              res = Net::HTTP.start(host, port) { |http|  http.request(req) }

              if res.header['location']
                url = URI.parse(res.header['location'])
                num_redirections += 1
              else
                resolution = url.to_s
                ShortUrlExpansion.create(
                  :url_short => url_s,
                  :url_expanded => resolution
                )
                break
              end
            end

            resolution
          end
        rescue Timeout::Error, URI::InvalidURIError, IOError, Errno::ECONNREFUSED, Errno::ECONNRESET, Net::HTTPBadResponse, ArgumentError
          url_s
        end
      end

      def autolink(link_, type)
        case link_
        when %r{^http://(bit\.ly|j\.mp|goo\.gl|is\.gd|tinyurl\.com|t\.co|ow\.ly|cli\.gs|dia\.so|2\.gp|n4rky\.me)/[a-zA-Z0-9]+$}
          link = resolve_redirection( link_ )
        else
          link = link_
        end

        auto_link(
          link,
          :link => :urls,
          :html => {
            'target' => '_blank',
            'title'  => link != link_ ? link : nil,
          }
        ) { link_ }
      end

    end
  end
end
