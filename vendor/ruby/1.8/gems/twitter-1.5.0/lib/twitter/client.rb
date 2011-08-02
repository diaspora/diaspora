module Twitter
  # Wrapper for the Twitter REST API
  #
  # @note All methods have been separated into modules and follow the same grouping used in {http://dev.twitter.com/doc the Twitter API Documentation}.
  # @see http://dev.twitter.com/pages/every_developer
  class Client < API
    # Require client method modules after initializing the Client class in
    # order to avoid a superclass mismatch error, allowing those modules to be
    # Client-namespaced.
    require 'twitter/client/utils'
    require 'twitter/client/account'
    require 'twitter/client/block'
    require 'twitter/client/direct_messages'
    require 'twitter/client/favorites'
    require 'twitter/client/friendship'
    require 'twitter/client/friends_and_followers'
    require 'twitter/client/geo'
    require 'twitter/client/legal'
    require 'twitter/client/list'
    require 'twitter/client/list_members'
    require 'twitter/client/list_subscribers'
    require 'twitter/client/local_trends'
    require 'twitter/client/notification'
    require 'twitter/client/spam_reporting'
    require 'twitter/client/saved_searches'
    require 'twitter/client/timeline'
    require 'twitter/client/trends'
    require 'twitter/client/tweets'
    require 'twitter/client/user'

    alias :api_endpoint :endpoint

    include Twitter::Client::Utils

    include Twitter::Client::Account
    include Twitter::Client::Block
    include Twitter::Client::DirectMessages
    include Twitter::Client::Favorites
    include Twitter::Client::Friendship
    include Twitter::Client::FriendsAndFollowers
    include Twitter::Client::Geo
    include Twitter::Client::Legal
    include Twitter::Client::List
    include Twitter::Client::ListMembers
    include Twitter::Client::ListSubscribers
    include Twitter::Client::LocalTrends
    include Twitter::Client::Notification
    include Twitter::Client::SpamReporting
    include Twitter::Client::SavedSearches
    include Twitter::Client::Timeline
    include Twitter::Client::Trends
    include Twitter::Client::Tweets
    include Twitter::Client::User
  end
end
