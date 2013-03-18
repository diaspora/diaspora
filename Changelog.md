# 0.0.3.4

* Bump Rails to 3.2.13, fixes CVE-2013-1854, CVE-2013-1855, CVE-2013-1856 and CVE-2013-1857. [Read more](http://weblog.rubyonrails.org/2013/3/18/SEC-ANN-Rails-3-2-13-3-1-12-and-2-3-18-have-been-released/)

# 0.0.3.3

* Switch Gemfile source to https to be compatible with bundler 1.3

# 0.0.3.2

* Fix XSS vulnerability in conversations#new [#4010](https://github.com/diaspora/diaspora/issues/4010)

# 0.0.3.1

* exec foreman in ./script/server to replace the process so that we can Ctrl+C it again.
* Include our custom fileuploader on the mobile site too. [#3994](https://github.com/diaspora/diaspora/pull/3994)
* Move custom splash page logic into the controller [#3991](https://github.com/diaspora/diaspora/issues/3991)
* Fixed removing images from publisher on the profile and tags pages. [#3995](https://github.com/diaspora/diaspora/pull/3995)
* Wrap text if too long in mobile notifications. [#3990](https://github.com/diaspora/diaspora/pull/3990)
* Sort tag followings alphabetically, not in reverse [#3986](https://github.com/diaspora/diaspora/issues/3986)

# 0.0.3.0

## Refactor

* Removed unused stuff [#3714](https://github.com/diaspora/diaspora/pull/3714), [#3754](https://github.com/diaspora/diaspora/pull/3754)
* Last post link isn't displayed anymore if there are no visible posts [#3750](https://github.com/diaspora/diaspora/issues/3750)
* Ported tag followings to backbone [#3713](https://github.com/diaspora/diaspora/pull/3713), [#3775](https://github.com/diaspora/diaspora/pull/3777)
* Extracted configuration system to a gem.
* Made number of unicorn workers configurable.
* Made loading of the configuration environment independent of Rails.
* Do not generate paths like `/a/b/c/config/boot.rb/../../Gemfile` to require and open things, create a proper path instead.
* Remove the hack for loading the entire lib folder with a proper solution. [#3809](https://github.com/diaspora/diaspora/issues/3750)
* Update and refactor the default public view `public/default.html` [#3811](https://github.com/diaspora/diaspora/issues/3811)
* Write unicorn stderr and stdout [#3785](https://github.com/diaspora/diaspora/pull/3785)
* Ported aspects to backbone [#3850](https://github.com/diaspora/diaspora/pull/3850)
* Join tagging's table instead of tags to improve a bit the query [#3932](https://github.com/diaspora/diaspora/pull/3932)
* Refactor contacts/index view [#3937](https://github.com/diaspora/diaspora/pull/3937)
* Ported aspect membership dropdown to backbone [#3864](https://github.com/diaspora/diaspora/pull/3864)

## Features

* Updates to oEmbed, added new providers and fixed photo display. [#3880](https://github.com/diaspora/diaspora/pull/3880)
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
* Footer links moved to sidebar [#3827](https://github.com/diaspora/diaspora/pull/3827)
* Changelog now points to correct revision if possible [#3921](https://github.com/diaspora/diaspora/pull/3921)
* User interface enhancements [#3832](https://github.com/diaspora/diaspora/pull/3832), [#3839](https://github.com/diaspora/diaspora/pull/3839), [#3834](https://github.com/diaspora/diaspora/pull/3834), [#3840](https://github.com/diaspora/diaspora/issues/3840), [#3846](https://github.com/diaspora/diaspora/issues/3846), [#3851](https://github.com/diaspora/diaspora/issues/3851), [#3828](https://github.com/diaspora/diaspora/issues/3828), [#3874](https://github.com/diaspora/diaspora/issues/3874), [#3806](https://github.com/diaspora/diaspora/issues/3806), [#3906](https://github.com/diaspora/diaspora/issues/3906).
* Add settings web mobile. [#3701](https://github.com/diaspora/diaspora/pull/3701)
* Stream form on profile page [#3910](https://github.com/diaspora/diaspora/issues/3910).
* Add Getting_Started page mobile. [#3949](https://github.com/diaspora/diaspora/issues/3949).
* Autoscroll to the first unread message in conversations. [#3216](https://github.com/diaspora/diaspora/issues/3216)
* Friendlier new-conversation mobile. [#3984](https://github.com/diaspora/diaspora/issues/3984) 

## Bug Fixes

* Force Typhoeus/cURL to use the CA bundle we query via the config. Also add a setting for extra verbose output.
* Validate input on sending invitations, validate email format, send correct ones. [#3748](https://github.com/diaspora/diaspora/pull/3748), [#3271](https://github.com/diaspora/diaspora/issues/3271)
* moved Aspects JS initializer to the correct place so aspect selection / deselection works again. [#3737](https://github.com/diaspora/diaspora/pull/3737)
* Do not strip "markdown" in links when posting to services. [#3765](https://github.com/diaspora/diaspora/issues/3765)
* Renamed `server.db` to `server.database` to match the example configuration.
* Fix insecure image of cat on user edit page - New photo courtesy of [khanb1 on flickr](http://www.flickr.com/photos/albaraa/) under CC BY 2.0.
* Allow translation of "suggest member" of Community Spotlight. [#3791](https://github.com/diaspora/diaspora/issues/3791)
* Resize deletelabel and ignoreuser images to align them. [#3779](https://github.com/diaspora/diaspora/issues/3779)
* Patch in Armenian pluralization rule until CLDR provides it.
* Fix reshare a post multiple times. [#3831](https://github.com/diaspora/diaspora/issues/3671)
* Fix services index view. [#3884](https://github.com/diaspora/diaspora/issues/3884)
* Excessive padding with "user-controls" in single post view. [#3861](https://github.com/diaspora/diaspora/issues/3861)
* Resize full scaled image to a specific width. [#3818](https://github.com/diaspora/diaspora/issues/3818)
* Fix translation issue in contacts_helper [#3937](https://github.com/diaspora/diaspora/pull/3937)
* Show timestamp hovering a timeago string (stream) [#3149](https://github.com/diaspora/diaspora/issues/3149)
* Fix reshare and like a post on a single post view [#3672](https://github.com/diaspora/diaspora/issues/3672)
* Fix posting multiple times the same content [#3272](https://github.com/diaspora/diaspora/issues/3272)
* Excessive padding with select aspect in mobile publisher. [#3951](https://github.com/diaspora/diaspora/issues/3951)
* Adapt css for search mobile page. [#3953](https://github.com/diaspora/diaspora/issues/3953)
* Twitter/Facebook/Tumblr count down characters is hidden by the picture of the post. [#3963](https://github.com/diaspora/diaspora/issues/3963)
* Buttons on mobile are hard to click on. [#3973](https://github.com/diaspora/diaspora/issues/3973)
* RTL-language characters in usernames no longer overlay post dates [#2339](https://github.com/diaspora/diaspora/issues/2339)
* Overflow info author mobile web. [#3983](https://github.com/diaspora/diaspora/issues/3983)
* Overflow name author mobile post. [#3981](https://github.com/diaspora/diaspora/issues/3981)

## Gem Updates

* Removed `debugger` since it was causing bundle problems, and is not necessary given 1.9.3 has a built-in debugger.
* dropped unnecessary fastercsv
* markerb switched from git release to 1.0.1
* added rmagick as development dependency for making screenshot comparisons
* jasmine 1.2.1 -> 1.3.1 (+ remove useless spec)
* activerecord-import 0.2.11 -> 0.3.1
* asset_sync 0.5.0 -> 0.5.4
* bootstap-sass 2.1.1.0 -> 2.2.2.0
* carrierwave 0.7.1 -> 0.8.0
* configurate 0.0.1 -> 0.0.2
* factory_girl_rails 4.1.0 -> 4.2.0
* faraday 0.8.4 -> 0.8.5
* ffi 1.1.5 -> 1.4.0
* fixture_builder 0.3.4 -> 0.3.5
* fog 1.6.0 -> 1.9.0
* foreigner 1.2.1 -> 1.3.0
* foreman 0.60.2 -> 0.61
* gon 4.0.1 -> 4.0.2
* guard 1.5.4 -> 1.6.2
    * guard-cucumber 1.2.2 -> 1.3.2
    * guard-rspec 2.1.1 -> 2.4.0
    * guard-spork 1.2.3 -> 1.4.2
    * rb-fsevent 0.9.2 -> 0.9.3
    * rb-inotify 0.8.8 -> 0.9.0
* haml 3.1.7 -> 4.0.0
* handlebars_assets 0.6.6 -> 0.11.0
* jquery-rails 2.1.3 -> 2.1.4
* jquery-ui-rails 2.0.2 -> 3.0.1
* mini_magick 3.4 -> 3.5.0
* mobile-fu 1.1.0 -> 1.1.1
* multi_json 1.5.1 -> 1.6.1
* nokogiri 1.5.5 -> 1.5.6
* omniauth 1.1.1 -> 1.1.3
    * omniauth-twitter 0.0.13 -> 0.0.14
* rack-ssl 1.3.2 -> 1.3.3
* rack-rewrite 1.3.1 -> 1.3.3
* rails-i18n 0.7.0 -> 0.7.2
* rails_admin 0.2.0 -> 0.4.5
* remotipart 1.0.2 -> 1.0.5
* ruby-oembed 0.8.7 -> 0.8.8
* rspec 2.11.0 -> 2.12.0
* rspec-rails 2.11.4 -> 2.12.2
* sass-rails 3.2.5 -> 3.2.6
* selenium-webdriver 2.26.0 -> 2.29.0
* timecop 0.5.3 -> 0.5.9.2
* twitter 4.2.0 -> 4.5.0
* unicorn 4.4.0 -> 4.6.0
* will_paginate 3.0.3 -> 3.0.4


# 0.0.2.5

* Fix CVE-2013-0269 by updating the gems json to 1.7.7 and multi\_json to 1.5.1. [Read more](https://groups.google.com/forum/?fromgroups=#!topic/rubyonrails-security/4_YvCpLzL58)
* Additionally ensure can't affect us by bumping Rails to 3.2.12. [Read more](https://groups.google.com/forum/?fromgroups=#!topic/rubyonrails-security/AFBKNY7VSH8)
* And exclude CVE-2013-0262 and CVE-2013-0263 by updating rack to 1.4.5.

# 0.0.2.4

* Fix XSS vulnerabilities caused by not escaping a users name fields when loading it from JSON. [#3948](https://github.com/diaspora/diaspora/issues/3948)

# 0.0.2.3

* Upgrade to Devise 2.1.3 [Read more](http://blog.plataformatec.com.br/2013/01/security-announcement-devise-v2-2-3-v2-1-3-v2-0-5-and-v1-5-3-released/)

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

