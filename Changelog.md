# 0.0.2.0pre

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

## Features

* Add "My Activity" icon mobile -[Author Icon](http://www.gentleface.com/free_icon_set.html)-. [#3687](https://github.com/diaspora/diaspora/pull/3687)
* Add password_confirmation field to registration page. [#3647](https://github.com/diaspora/diaspora/pull/3647)
* When posting to Twitter, behaviour changed so that URL to post will only be added to the post when length exceeds 140 chars or post contains uploaded photos.

## Bug Fixes

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
