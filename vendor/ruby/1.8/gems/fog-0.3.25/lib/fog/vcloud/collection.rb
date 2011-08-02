module Fog
  class Vcloud < Fog::Service
    class Collection < Fog::Collection

      def load(objects)
        objects = [ objects ] if objects.is_a?(Hash)
        super
      end

      def check_href!(opts = {})
        unless href
          if opts.is_a?(String)
            t = Hash.new
            t[:parent] = opts
            opts = t
          end
          msg = ":href missing, call with a :href pointing to #{if opts[:message]
                  opts[:message]
                elsif opts[:parent]
                  "the #{opts[:parent]} whos #{self.class.to_s.split('::').last.downcase} you want to enumerate"
                else
                  "the resource"
                end}"
          raise Fog::Errors::Error.new(msg)
        end
      end

    end
  end
end
