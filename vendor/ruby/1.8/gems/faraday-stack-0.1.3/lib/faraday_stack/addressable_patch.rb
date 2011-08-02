require 'addressable/uri'

# feature-detect the bug
unless Addressable::URI.parse('/?a=1&b=2') === '/?b=2&a=1'
  # fix `normalized_query` by sorting query key-value pairs
  # (rejected: https://github.com/sporkmonger/addressable/issues/28)
  class Addressable::URI
    alias normalized_query_without_ordering_fix normalized_query
    
    def normalized_query
      fresh = @normalized_query.nil?
      query = normalized_query_without_ordering_fix
      if query && fresh
        @normalized_query = query.split('&', -1).sort_by {|q| q[0..(q.index('=')||-1)] }.join('&')
      else
        query
      end
    end
  end
end
