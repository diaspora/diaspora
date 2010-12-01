module ActionController
  module ConditionalGet
    extend ActiveSupport::Concern

    include RackDelegation
    include Head

    # Sets the etag, last_modified, or both on the response and renders a
    # "304 Not Modified" response if the request is already fresh.
    #
    # Parameters:
    # * <tt>:etag</tt>
    # * <tt>:last_modified</tt>
    # * <tt>:public</tt> By default the Cache-Control header is private, set this to true if you want your application to be cachable by other devices (proxy caches).
    #
    # Example:
    #
    #   def show
    #     @article = Article.find(params[:id])
    #     fresh_when(:etag => @article, :last_modified => @article.created_at.utc, :public => true)
    #   end
    #
    # This will render the show template if the request isn't sending a matching etag or
    # If-Modified-Since header and just a "304 Not Modified" response if there's a match.
    #
    def fresh_when(options)
      options.assert_valid_keys(:etag, :last_modified, :public)

      response.etag          = options[:etag]          if options[:etag]
      response.last_modified = options[:last_modified] if options[:last_modified]
      response.cache_control[:public] = true if options[:public]

      head :not_modified if request.fresh?(response)
    end

    # Sets the etag and/or last_modified on the response and checks it against
    # the client request. If the request doesn't match the options provided, the
    # request is considered stale and should be generated from scratch. Otherwise,
    # it's fresh and we don't need to generate anything and a reply of "304 Not Modified" is sent.
    #
    # Parameters:
    # * <tt>:etag</tt>
    # * <tt>:last_modified</tt>
    # * <tt>:public</tt> By default the Cache-Control header is private, set this to true if you want your application to be cachable by other devices (proxy caches).
    #
    # Example:
    #
    #   def show
    #     @article = Article.find(params[:id])
    #
    #     if stale?(:etag => @article, :last_modified => @article.created_at.utc)
    #       @statistics = @article.really_expensive_call
    #       respond_to do |format|
    #         # all the supported formats
    #       end
    #     end
    #   end
    def stale?(options)
      fresh_when(options)
      !request.fresh?(response)
    end

    # Sets a HTTP 1.1 Cache-Control header. Defaults to issuing a "private" instruction, so that
    # intermediate caches shouldn't cache the response.
    #
    # Examples:
    #   expires_in 20.minutes
    #   expires_in 3.hours, :public => true
    #   expires in 3.hours, 'max-stale' => 5.hours, :public => true
    #
    # This method will overwrite an existing Cache-Control header.
    # See http://www.w3.org/Protocols/rfc2616/rfc2616-sec14.html for more possibilities.
    def expires_in(seconds, options = {}) #:doc:
      response.cache_control.merge!(:max_age => seconds, :public => options.delete(:public))
      options.delete(:private)

      response.cache_control[:extras] = options.map {|k,v| "#{k}=#{v}"}
    end

    # Sets a HTTP 1.1 Cache-Control header of "no-cache" so no caching should occur by the browser or
    # intermediate caches (like caching proxy servers).
    def expires_now #:doc:
      response.cache_control.replace(:no_cache => true)
    end
  end
end
