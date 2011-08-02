= OmniAuth::OpenID 

Provides strategies for authenticating to providers using the OpenID standard. 

== Installation

To get just OpenID functionality:

    gem install oa-openid

For the full auth suite:

    gem install omniauth

== Stand-Alone Example

Use the strategy as a middleware in your application:

    require 'omniauth/openid'
    require 'openid/store/filesystem'

    use Rack::Session::Cookie
    use OmniAuth::Strategies::OpenID, OpenID::Store::Filesystem.new('/tmp')

Then simply direct users to '/auth/open_id' to prompt them for their OpenID identifier. You may also pre-set the identifier by passing an <tt>identifier</tt> parameter to the URL (Example: <tt>/auth/open_id?openid_url=yahoo.com</tt>).

A list of all OpenID stores is available at http://github.com/openid/ruby-openid/tree/master/lib/openid/store/

== OmniAuth Builder

If OpenID is one of several authentication strategies, use the OmniAuth Builder:

    require 'omniauth/openid'
    require 'omniauth/basic'  # for Campfire
    require 'openid/store/filesystem'

    use OmniAuth::Builder do
      provider :open_id, OpenID::Store::Filesystem.new('/tmp')
      provider :campfire
    end

== Configured Identifiers

You may pre-configure an OpenID identifier.  For example, to use Google's main OpenID endpoint:

    use OmniAuth::Builder do
      provider :open_id, nil, :name => 'google', :identifier => 'https://www.google.com/accounts/o8/id'
    end

Note the use of nil, which will trigger ruby-openid's default Memory Store.

