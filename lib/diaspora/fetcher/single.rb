module Diaspora
  module Fetcher
    module Single
      module_function

      # Fetch and store a remote public post
      # @param [String] guid the remote posts guid
      # @param [String] author_id Diaspora ID of a user known to have the post,
      #                 preferably the author
      # @yield [Post, Person] If a block is given it is yielded the post
      #                       and the author prior save
      # @return a saved post
      def find_or_fetch_from_remote guid, author_id
        post = Post.where(guid: guid).first
        return post if post

        post_author = Webfinger.new(author_id).fetch
        post_author.save! unless post_author.persisted?

        if fetched_post = fetch_post(post_author, guid)
          yield fetched_post, post_author if block_given?
          raise Diaspora::PostNotFetchable unless fetched_post.save
        end

        fetched_post
      end

      # Fetch a remote public post, used for receiving of unknown public posts
      # @param [Person] author the remote post's author
      # @param [String] guid the remote post's guid
      # @return [Post] an unsaved remote post or false if the post was not found
      def fetch_post author, guid
        url = author.url + "/p/#{guid}.xml"
        response = Faraday.get(url)
        raise Diaspora::PostNotFetchable if response.status == 404 # Old pod, Friendika, deleted
        raise "Failed to get #{url}" unless response.success? # Other error, N/A for example
        Diaspora::Parser.from_xml(response.body)
      end
    end
  end
end
