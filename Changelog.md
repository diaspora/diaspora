# 0.0.3.0

## Refactor

* Removed unused stuff [#3714](https://github.com/diaspora/diaspora/pull/3714), [#3754](https://github.com/diaspora/diaspora/pull/3754)
* Last post link isn't displayed anymore if there are no visible posts [#3750](https://github.com/diaspora/diaspora/issues/3750)
* Ported tag followings to backbone [#3713](https://github.com/diaspora/diaspora/pull/3713)
* fixed tags on the profiles page (broken by the change of server side response in the switch to backbone) [#3775](https://github.com/diaspora/diaspora/pull/3777)
* Extracted configuration system to a gem.
* Made number of unicorn workers configurable.
* Made loading of the configuration environment independent of Rails.
* Do not generate paths like `/a/b/c/config/boot.rb/../../Gemfile` to require and open things, create a proper path instead.
* Remove the hack for loading the entire lib folder with a proper solution. [#3809](https://github.com/diaspora/diaspora/issues/3750)
* Update and refactor the default public view `public/default.html` [#3811](https://github.com/diaspora/diaspora/issues/3811)
* Write unicorn stderr and stdout [#3785](https://github.com/diaspora/diaspora/pull/3785)
* Ported aspects to backbone [#3850](https://github.com/diaspora/diaspora/pull/3850)

## Features

* Add 'screenshot tool' for taking before/after images of stylesheet changes. [#3797](https://github.com/diaspora/diaspora/pull/3797)
* Add possibility to contact the administrator. [#3792](https://github.com/diaspora/diaspora/pull/3792)
* Add simple background for unread messages/conversations mobile. [#3724](https://github.com/diaspora/diaspora/pull/3724)
* Add flash warning to conversation mobile, unification of flash warning with login and register mobile, and add support for flash warning to Opera browser. [#3686](https://github.com/diaspora/diaspora/pull/3686)
* Add progress percentage to upload images. [#3740](https://github.com/diaspora/diaspora/pull/3740)
* Mark all unread post-related notifications as read, if one of this gets opened. [#3787](https://github.com/diaspora/diaspora/pull/3787)
* Add flash-notice when sending messages to non-contacts. [#3723](https://github.com/diaspora/diaspora/pull/3723)
* Re-add hovercards [#3802](https://github.com/diaspora/diaspora/pull/3802)
* Add images to notifications [#3821](https://github.com/diaspora/diaspora/pull/3821)
* Show pod version in footer and updated the link to the changelog [#3822](https://github.com/diaspora/diaspora/pull/3822)
* User interface enhancements [#3832](https://github.com/diaspora/diaspora/pull/3832), [#3839](https://github.com/diaspora/diaspora/pull/3839), [#3834](https://github.com/diaspora/diaspora/pull/3834), [#3840](https://github.com/diaspora/diaspora/issues/3840), [#3846](https://github.com/diaspora/diaspora/issues/3846), [#3851](https://github.com/diaspora/diaspora/issues/3851), [#3828](https://github.com/diaspora/diaspora/issues/3828).

## Bug Fixes

* Force Typhoeus/cURL to use the CA bundle we query via the config. Also add a setting for extra verbose output.
* Validate input on sending invitations, validate email format, send correct ones. [#3748](https://github.com/diaspora/diaspora/pull/3748), [#3271](https://github.com/diaspora/diaspora/issues/3271)
* moved Aspects JS initializer to the correct place so aspect selection / deselection works again [#3737] (https://github.com/diaspora/diaspora/pull/3737)
* Do not strip "markdown" in links when posting to services [#3765](https://github.com/diaspora/diaspora/issues/3765)
* Renamed `server.db` to `server.database` to match the example configuration.
* Fix insecure image of cat on user edit page - New photo courtesy of [khanb1 on flickr](http://www.flickr.com/photos/albaraa/) under CC BY 2.0.
* Allow translation of "suggest member" of Community Spotlight. [#3791](https://github.com/diaspora/diaspora/issues/3791)
* Resize deletelabel and ignoreuser images to align them [#3779](https://github.com/diaspora/diaspora/issues/3779)
* Patch in Armenian pluralization rule until CLDR provides it.
* Fix reshare a post multiple times[#3831](https://github.com/diaspora/diaspora/issues/3671)

## Gem Updates

* Removed `debugger` since it was causing bundle problems, and is not necessary given 1.9.3 has a built-in debugger.
* jasmine 1.2.1 -> 1.3.1 (+ remove useless spec)
* foreman 0.60.2 -> 0.61
* unicorn 4.4.0 -> 4.5.0
* omniauth-twitter 0.0.13 -> 0.0.14
* twitter 4.2.0 -> 4.4.4
* rails_admin 0.2.0 -> 0.4.1
* rack 1.4.3 -> 1.4.4
* rack-rewrite 1.3.1 -> 1.3.3
* asset_sync 0.5.0 -> 0.5.4
* fog 1.6.0 -> 1.8.0
* rails-i18n 0.7.0 -> 0.7.2
* nokogiri 1.5.5 -> 1.5.6
* ruby-oembed 0.8.7 -> 0.8.8
* mobile-fu 1.1.0 -> 1.1.1
* will_paginate 3.0.4 -> 3.0.5
* sass 3.2.3 -> 3.2.5
* bootstap-sass 2.1.1.0 -> 2.2.2.0
* sass-rails 3.2.5 -> 3.2.6
* handlebars_assets 0.6.6 -> 0.8.2
* jquery-rails 2.1.3 -> 2.1.4
* gon 4.0.1 -> 4.0.2
* guard 1.5.4 -> 1.6.1
    * guard-cucumber 1.2.2 -> 1.3.2
    * guard-rspec 2.1.1 -> 2.3.3
    * guard-spork 1.2.3 -> 1.4.1
    * rb-fsevent 0.9.2 -> 0.9.3
    * rb-inotify 0.8.8 -> 0.9.0
* rspec 2.11.0 -> 2.12.0
* rspec-rails 2.11.4 -> 2.12.2
* selenium-webdriver 2.26.0 -> 2.27.2
* fixture_builder 0.3.4 -> 0.3.5
* ffi 1.1.5 -> 1.3.1

# 0.0.2.2

* Upgrade to Rails 3.2.11 (CVE-2012-0155, CVE-2012-0156). [Read more](http://weblog.rubyonrails.org/2013/1/8/Rails-3-2-11-3-1-10-3-0-19-and-2-3-15-have-been-released/)

# 0.0.2.1

* Upgrade to Rails 3.2.10 as per CVE-2012-5664. [Read more](https://groups.google.com/group/rubyonrails-security/browse_thread/thread/c2353369fea8c53)

# 0.0.2.0

## Refactor

### script/server

* Uses foreman now
* Reduce startup time by reducing calls to `script/get_config.rb`
* `config/script_server.yml` is removed and replaced by the `server` section in `config/diaspora.yml`
  Have a look at the updated example!
* Thin is dropped in favour of unicorn
* Already set versions of `RAILS_ENV` and `DB` are now prefered over those set in `config/diaspora.yml`
* **Heroku setups:** `ENVIRONMENT_UNICORN_EMBED_RESQUE_WORKER` got renamed to `SERVER_EMBED_RESQUE_WORKER`

### Other

* MessagesController. [#3657](https://github.com/diaspora/diaspora/pull/3657)
* **Fixed setting:** `follow_diasporahq` has now to be set to `true` to enable following the DiasporaHQ account. Was `false`
* Removal of some bash-/linux-isms from most of the scripts, rework of 'script/install.sh' output methods. [#3679](https://github.com/diaspora/diaspora/pull/3679)

## Features

* Add "My Activity" icon mobile -[Author Icon](http://www.gentleface.com/free_icon_set.html)-. [#3687](https://github.com/diaspora/diaspora/pull/3687)
* Add password_confirmation field to registration page. [#3647](https://github.com/diaspora/diaspora/pull/3647)
* When posting to Twitter, behaviour changed so that URL to post will only be added to the post when length exceeds 140 chars or post contains uploaded photos.
* Remove markdown formatting from post message when posting to Facebook or Twitter.

## Bug Fixes

* Fix missing X-Frame headers [#3739](https://github.com/diaspora/diaspora/pull/3739)
* Fix image path for padlocks [#3682](https://github.com/diaspora/diaspora/pull/3682)
* Fix posting to Facebook and Tumblr. Have a look at the updated [services guide](https://github.com/diaspora/diaspora/wiki/Howto-setup-services) for new Facebook instructions.
* Fix overflow button in mobile reset password. [#3697](https://github.com/diaspora/diaspora/pull/3697)
* Fix issue with interacted_at in post fetcher. [#3607](https://github.com/diaspora/diaspora/pull/3607)
* Fix error with show post Community Spotlight. [#3658](https://github.com/diaspora/diaspora/pull/3658)
* Fix javascripts problem with read/unread notifications. [#3656](https://github.com/diaspora/diaspora/pull/3656)
* Fix error with open/close registrations. [#3649](https://github.com/diaspora/diaspora/pull/3649)
* Fix javascripts error in invitations facebox. [#3638](https://github.com/diaspora/diaspora/pull/3638)
* Fix css overflow problem in aspect dropdown on welcome page. [#3637](https://github.com/diaspora/diaspora/pull/3637)
* Fix empty page after authenticating with other services. [#3693](https://github.com/diaspora/diaspora/pull/3693)
* Fix posting public posts to Facebook. [#2882](https://github.com/diaspora/diaspora/issues/2882), [#3650](https://github.com/diaspora/diaspora/issues/3650)
* Fix error with invite link box shows on search results page even if invites have been turned off. [#3708](https://github.com/diaspora/diaspora/pull/3708)
* Fix misconfiguration of Devise to allow the session to be remembered. [#3472](https://github.com/diaspora/diaspora/issues/3472)
* Fix problem with show reshares_count in stream. [#3700](https://github.com/diaspora/diaspora/pull/3700)
* Fix error with notifications count in mobile. [#3721](https://github.com/diaspora/diaspora/pull/3721)
* Fix conversation unread message count bug. [#2321](https://github.com/diaspora/diaspora/issues/2321)

## Gem updates

* bootstrap-sass 2.1.0.0 -> 2.1.1.0
* capybara 1.1.2 -> 1.1.3
* carrierwave 0.6.2 -> 0.7.1
* client\_side_validations 3.1.4 -> 3.2.1
* database_cleaner 0.8 -> 0.9.1
* faraday_middleware 0.8.8 -> 0.9.0
* foreman 0.59 -> 0.60.2
* fuubar 1.0.0 -> 1.1.0
* debugger 1.2.0 -> 1.2.1
* gon 4.0.0 -> 4.0.1
* guard
    * guard-cucumber 1.0.0 -> 1.2.2
    * guard-rspec 0.7.3 -> 2.1.1
    * guard-spork 0.8.0 -> 1.2.3
    * rb-inotify -> 0.8.8, new dependency
* handlebars_assets 0.6.5 -> 0.6.6
* omniauth-facebook 1.3.0 -> 1.4.1
* omniauth-twitter 0.0.11 -> 0.0.13
* rails_admin 0.1.1 -> 0.2.0
* rails-i18n -> 0.7.0
* rack-rewrite 1.2.1 -> 1.3.1
* redcarpet 2.1.1 -> 2.2.2
* resque 1.22.0 -> 1.23.0
* rspec-rails 2.11.0, 2.11.4
* selenium-webdriver 2.25.0 -> 2.26.0
* timecop 0.5.1 -> 0.5.3
* twitter 2.0.2 -> 4.2.0
* unicorn 4.3.1 -> 4.4.0, now default
* webmock 1.8.10 -> 1.8.11

And their dependencies.

# 0.0.1.2

Fix exception when the root of a reshare of a reshare got deleted [#3546](https://github.com/diaspora/diaspora/issues/3546)

# 0.0.1.1

* Fix syntax error in French Javascript pluralization rule.

# 0.0.1.0

## New configuration system!

Copy over config/diaspora.yml.example to config/diaspora.yml and migrate your settings! An updated Heroku guide including basic hints on howto migrate is [here](https://github.com/diaspora/diaspora/wiki/Installing-on-heroku).

The new configuration system allows all possible settings to be overriden by environment variables. This makes it possible to deploy heroku without checking any credentials into git. Read the top of `config/diaspora.yml.example` for an explanation on how to convert the setting names to environment variables.

### Environment variable changes:

#### deprectated

* REDISTOGO_URL in favour of REDIS_URL or ENVIRONMENT_REDIS

#### removed

*  application_yml - Obsolete, all settings are settable via environment variables now

#### renamed

* SINGLE_PROCESS_MODE -> ENVIRONMENT_SINGLE_PROCESS_MODE
* SINGLE_PROCESS -> ENVIRONMENT_SINGLE_PROCESS_MODE
* NO_SSL -> ENVIRONMENT_REQUIRE_SSL
* ASSET_HOST -> ENVIRONMENT_ASSETS_HOST


## Gem changes

### Updated gems

* omniauth-tumblr 1.0 -> 1.1
* rails_admin git -> 0.1.1
* activerecord-import 0.2.10 -> 0.2.11
* fog 1.4.0 -> 1.6.0
* asset_sync 0.4.2 -> 0.5.0
* jquery-rails 2.0.2 -> 2.1.3

### Removed gems

The following gems and their related files were removed as they aren't widely enough used to justify maintenance for them by the core developers. If you use them please maintain them in your fork.

* airbrake
* newrelic_rpm
* rpm_contrib
* heroku_san

The following gems were removed because their are neither used in daily development or are just CLI tools that aren't required to be loaded from the code:

* heroku
* oink
* yard


## Publisher

Refactoring of the JavaScript code; it is now completely rewritten to make use of Backbone.js.
This paves the way for future improvements such as post preview or edit toolbar/help.


## Removal of 'beta' code

The feature-flag on users and all the code in connection with experimental UX changes got removed/reverted. Those are the parts that became Makr.io.
The single-post view will also be revamped/reverted, but that didn't make it into this release.


## JS lib updates


## Cleanup in maintenance scripts and automated build environment

