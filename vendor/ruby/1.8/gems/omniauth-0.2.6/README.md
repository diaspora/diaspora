# OmniAuth: Standardized Multi-Provider Authentication

OmniAuth is a new Rack-based authentication system for multi-provider external authentcation. OmniAuth is built from the ground up on the philosophy that **authentication is not the same as identity**, and is based on two observations:

1. The traditional 'sign up using a login and password' model is becoming the exception, not the rule. Modern web applications offer external authentication via OpenID, Facebook, and/or OAuth.
2. The interconnectable web is no longer a dream, it is a necessity. It is not unreasonable to expect that one application may need to be able to connect to one, three, or twelve other services. Modern authentication systems should allow a user's identity to be associated with many authentications.

## Installation

To install OmniAuth, simply install the gem:

    gem install omniauth

## Continuous Integration
[![Build Status](http://travis-ci.org/intridea/omniauth.png)](http://travis-ci.org/intridea/omniauth)

## Providers

OmniAuth currently supports the following external providers:

* via OAuth (OAuth 1.0, OAuth 2, and xAuth)
  * 37signals ID (credit: [mbleigh](https://github.com/mbleigh))
  * Bit.ly (credit: [philnash](https://github.com/philnash))
  * DailyMile (credit: [cdmwebs](https://github.com/cdmwebs))
  * Doit.im (credit: [chouti](https://github.com/chouti))
  * Dopplr (credit: [flextrip](https://github.com/flextrip))
  * Douban (credit: [quake](https://github.com/quake))
  * Evernote (credit: [szimek](https://github.com/szimek))
  * Facebook (credit: [mbleigh](https://github.com/mbleigh))
  * Foursquare (credit: [mbleigh](https://github.com/mbleigh))
  * GitHub (credit: [mbleigh](https://github.com/mbleigh))
  * GoodReads (credit: [cristoffer](https://github.com/christoffer))
  * Gowalla (credit: [kvnsmth](https://github.com/kvnsmth))
  * Hyves (credit: [mrdg](https://github.com/mrdg))
  * Identi.ca (credit: [dcu](https://github.com/dcu))
  * Instagram (credit: [kiyoshi](https://github.com/kiyoshi))
  * Instapaper (credit: [micpringle](https://github.com/micpringle))
  * LinkedIn (credit: [mbleigh](https://github.com/mbleigh))
  * Mailru (credit: [lexer](https://github.com/lexer))
  * Meetup (credit [coderoshi](https://github.com/coderoshi))
  * Miso (credit: [rickenharp](https://github.com/rickenharp))
  * Mixi (credit: [kiyoshi](https://github.com/kiyoshi))
  * Netflix (credit: [caged](https://github.com/caged))
  * Plurk (credit: [albb0920](http://github.com/albb0920))
  * Qzone (credit: [quake](https://github.com/quake))
  * Rdio (via [brandonweiss](https://github.com/brandonweiss))
  * Renren (credit: [quake](https://github.com/quake))
  * Salesforce (via [CloudSpokes](http://www.cloudspokes.com))
  * SmugMug (credit: [pchilton](https://github.com/pchilton))
  * SoundCloud (credit: [leemartin](https://github.com/leemartin))
  * T163 (credit: [quake](https://github.com/quake))
  * Taobao (credit: [l4u](https://github.com/l4u))
  * TeamBox (credit [jrom](https://github.com/jrom))
  * Tqq (credit: [quake](https://github.com/quake))
  * TradeMe (credit: [pchilton](https://github.com/pchilton))
  * TripIt (credit: [flextrip](https://github.com/flextrip))
  * Tsina (credit: [quake](https://github.com/quake))
  * Tsohu (credit: [quake](https://github.com/quake))
  * Tumblr (credit: [jamiew](https://github.com/jamiew))
  * Twitter (credit: [mbleigh](https://github.com/mbleigh))
  * Vimeo (credit: [jamiew](https://github.com/jamiew))
  * Vkontakte (credit: [german](https://github.com/german))
  * Yammer (credit: [kltcalamay](https://github.com/kltcalamay))
  * YouTube (credit: [jamiew](https://github.com/jamiew))
* CAS (Central Authentication Service) (credit: [jamesarosen](https://github.com/jamesarosen))
* Flickr (credit: [pchilton](https://github.com/pchilton))
* Google Apps (via OpenID) (credit: [mbleigh](https://github.com/mbleigh))
* LDAP (credit: [pyu10055](https://github.com/pyu10055))
* OpenID (credit: [mbleigh](https://github.com/mbleigh))
* Yupoo (credit: [chouti](https://github.com/chouti))

## Compatibility

OmniAuth is tested against the following Ruby versions:

* 1.8.7
* 1.9.1
* 1.9.2
* jRuby (note, the Evernote strategy is not available for jRuby)
* Rubinius
* REE

## Usage

OmniAuth is a collection of Rack middleware. To use a single strategy, you simply need to add the middleware:

    require 'oa-oauth'
    use OmniAuth::Strategies::Twitter, 'CONSUMER_KEY', 'CONSUMER_SECRET'

Now to initiate authentication you merely need to redirect the user to `/auth/twitter` via a link or other means. Once the user has authenticated to Twitter, they will be redirected to `/auth/twitter/callback`. You should build an endpoint that handles this URL, at which point you will will have access to the authentication information through the `omniauth.auth` parameter of the Rack environment. For example, in Sinatra you would do something like this:

    get '/auth/twitter/callback' do
      auth_hash = request.env['omniauth.auth']
    end

The hash in question will look something like this:

    {
      'uid' => '12356',
      'provider' => 'twitter',
      'user_info' => {
        'name' => 'User Name',
        'nickname' => 'username',
        # ...
      }
    }

The `user_info` hash will automatically be populated with as much information about the user as OmniAuth was able to pull from the given API or authentication provider.

## Resources

The best place to find more information is the [OmniAuth Wiki](https://github.com/intridea/omniauth/wiki). Some specific information you might be interested in:

* [CI Build Status](http://travis-ci.org/#!/intridea/omniauth)
* [Roadmap](https://github.com/intridea/omniauth/wiki/Roadmap)
* [Changelog](https://github.com/intridea/omniauth/wiki/Changelog)
* [Report Issues](https://github.com/intridea/omniauth/issues)
* [Mailing List](http://groups.google.com/group/omniauth)

## OmniAuth Core

* **Michael Bleigh** ([mbleigh](https://github.com/mbleigh))
* **Erik Michaels-Ober** ([sferik](https://github.com/sferik))

## License

OmniAuth is licensed under the MIT License.
