module Fog
  module GoGrid
    class Compute
      class Real

        # List images
        #
        # ==== Parameters
        # * options<~Hash>:
        #   * 'datacenter'<~String> - datacenter to limit results to
        #   * 'isPublic'<~String>   - If true only returns public images, in ['false', 'true']
        #   * 'num_items'<~Integer> - Number of items to return
        #   * 'page'<~Integer>      - Page index for paginated results
        #   * 'state'<~String>      - state to limit results to, in ['Saving', 'Available']
        #   * 'type'<~String>       - image type to limit results to
        #
        # ==== Returns
        # * response<~Excon::Response>:
        #   * body<~Array>:
        # TODO: docs
        def grid_image_list(options={})
          request(
            :path     => 'grid/image/list',
            :query    => options
          )
        end

      end

      class Mock

        def grid_image_list(options={})
          #response = Excon::Response.new

          #images = @data[:list].values
          #for image in images
          #  case image['state']
          #  when 'Available'
        end

      end
    end
  end
end
