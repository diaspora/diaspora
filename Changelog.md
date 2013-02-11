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

