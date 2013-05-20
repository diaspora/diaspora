# 0.1.0.1

* Regression fix: 500 for deleted reshares introduced by the locator
* Federate locations

# 0.1.0.0

## Refactor

### Replaced Resque with Sidekiq - Migration guide - [#3993](https://github.com/diaspora/diaspora/pull/3993)

We replaced our queue system with Sidekiq. You might know that Resque needs Redis.
Sidekiq does too, so don't remove it, it's still required. Sidekiq uses a threaded
model so you'll need far less processes than with Resque to do the same amount
of work.

To update do the following:

1. Before updating (even before the `git pull`!) stop your application
   server (Unicorn by default, started through Foreman).
2. In case you did already run `git pull` checkout v0.0.3.4:
   
   ```
   git fetch origin
   git checkout v0.0.3.4
   bundle
   ```
   
3. Start Resque web (you'll need temporary access to port 5678, check
   your Firewall if needed!):

   ```
   bundle exec resque-web
   ```

   In case you need it you can adjust the port with the `-p` flag.
4. One last time, start a Resque worker:

   ```
   RAILS_ENV=production QUEUE=* bundle exec rake resque:work
   ```

   Visit Resque web via http://your_host:5678, wait until all queues but the
   failed one are empty (show 0 jobs).
5. Kill the Resque worker by hitting Ctrl+C. Kill Resque web with:

   ```
   bundle exec resque-web -k
   ```

   Don't forget to close the port on the Firewall again, if you had to open it.
6. In case you needed to do step 2., run:
   
   ```
   git checkout master
   bundle
   ```

7. Proceed with the update as normal (migrate database, precompile assets).
8. Before starting Diaspora again ensure that you reviewed the new
   `environment.sidekiq` section in `config/diaspora.yml.example` and,
   if wanted, transfered it to your `config/diaspora.yml` and made any
   needed changes. In particular increase the `environment.sidekiq.concurrency`
   setting on any medium sized pod. If you do change that value, edit
   your `config/database.yml` and add a matching `pool: n` to your database
   configuration. n should be equal or higher than the amount of
   threads per Sidekiq worker. This sets how many concurrent
   connections to the database ActiveRecord allows.


If you aren't using `script/server` but for example passenger, you no
longer need to start a Resque worker, but a Sidekiq worker now. The
command for that is:

```
bundle exec sidekiq
```


#### Heroku

The only gotcha for Heroku single gear setups is that the setting name
to spawn a background worker from the unicorn process changed. Run

```
heroku config:remove SERVER_EMBED_RESQUE_WORKER
heroku config:set SERVER_EMBED_SIDEKIQ_WORKER=true
```

We're automatically adjusting the ActiveRecord connection pool size for you.

Larger Heroku setups should have enough expertise to figure out what to do
by them self.

### Removal of Capistrano

The Capistrano deployment scripts were removed from the main source code
repository, since they were no longer working.
They will be moved into their own repository with a new maintainer,
you'll be able to find them under the Diaspora* Github organization once
everything is set up.

### Other

* Cleaned up requires of our own libraries [#3993](https://github.com/diaspora/diaspora/pull/3993)
* Refactor people_controller#show and photos_controller#index [#4002](https://github.com/diaspora/diaspora/issues/4002)
* Modularize layout [#3944](https://github.com/diaspora/diaspora/pull/3944)
* Add header to the sign up page [#3944](https://github.com/diaspora/diaspora/pull/3944)
* Add a configuration entry to set max-age header to Amazon S3 resources. [#4048](https://github.com/diaspora/diaspora/pull/4048)
* Load images via sprites [#4039](https://github.com/diaspora/diaspora/pull/4039)
* Delete unnecessary javascript views. [#4059](https://github.com/diaspora/diaspora/pull/4059)
* Cleanup of script/server
* Attempt to stabilize federation of attached photos (fix [#3033](https://github.com/diaspora/diaspora/issues/3033)  [#3940](https://github.com/diaspora/diaspora/pull/3940)
* Refactor develop install script [#4111](https://github.com/diaspora/diaspora/pull/4111)
* Remove special hacks for supporting Ruby 1.8 [#4113] (https://github.com/diaspora/diaspora/pull/4139)
* Moved custom oEmbed providers to config/oembed_providers.yml [#4131](https://github.com/diaspora/diaspora/pull/4131)
* Add specs for Post#find_by_guid_or_id_with_user

## Bug fixes

* Fix mass aspect selection [#4127](https://github.com/diaspora/diaspora/pull/4127)
* Fix posting functionality on tags show view [#4112](https://github.com/diaspora/diaspora/pull/4112)
* Fix cancel button on getting_started confirmation box [#4073](https://github.com/diaspora/diaspora/issues/4073)
* Reset comment box height after posting a comment. [#4030](https://github.com/diaspora/diaspora/issues/4030)
* Fade long tag names. [#3899](https://github.com/diaspora/diaspora/issues/3899)
* Avoid posting empty comments. [#3836](https://github.com/diaspora/diaspora/issues/3836)
* Delegate parent_author to the target of a RelayableRetraction
* Do not fail on receiving a SignedRetraction via the public route
* Pass the real values to stderr_path and stdout_path in unicorn.rb since it runs a case statement on them.
* Decode tag name before passing it into a TagFollowingAction [#4027](https://github.com/diaspora/diaspora/issues/4027)
* Fix reshares in single post-view [#4056](https://github.com/diaspora/diaspora/issues/4056)
* Fix mobile view of deleted reshares. [#4063](https://github.com/diaspora/diaspora/issues/4063)
* Hide comment button in the mobile view when not signed in. [#4065](https://github.com/diaspora/diaspora/issues/4065)
* Send profile alongside notification [#3976] (https://github.com/diaspora/diaspora/issues/3976)
* Fix off-center close button image on intro popovers [#3841](https://github.com/diaspora/diaspora/pull/3841)
* Remove unnecessary dotted CSS borders. [#2940](https://github.com/diaspora/diaspora/issues/2940)
* Fix default image url in profiles table. [#3795](https://github.com/diaspora/diaspora/issues/3795)
* Fix mobile buttons are only clickable when scrolled to the top. [#4102](https://github.com/diaspora/diaspora/issues/4102)
* Fix regression in bookmarklet causing uneditable post contents. [#4057](https://github.com/diaspora/diaspora/issues/4057)
* Redirect all mixed case tags to the lower case equivalents [#4058](https://github.com/diaspora/diaspora/issues/4058)
* Fix wrong message on infinite scroll on contacts page [#3681](https://github.com/diaspora/diaspora/issues/3681)
* My Activity mobile doesn't show second page when clicking "more". [#4109](https://github.com/diaspora/diaspora/issues/4109)
* Remove unnecessary navigation bar to access mobile site and re-add flash warning to mobile registrations. [#4085](https://github.com/diaspora/diaspora/pull/4085)
* Fix broken reactions link on mobile page [#4125](https://github.com/diaspora/diaspora/pull/4125)
* Missing translation "Back to top". [#4138](https://github.com/diaspora/diaspora/pull/4138)
* Fix preview with locator feature. [#4147](https://github.com/diaspora/diaspora/pull/4147)
* Fix mentions at end of post. [#3746](https://github.com/diaspora/diaspora/issues/3746)
* Fix missing indent to correct logged-out-header container relative positioning [#4134](https://github.com/diaspora/diaspora/pull/4134)
* Private post dont show error 404 when you are not authorized on mobile page [#4129](https://github.com/diaspora/diaspora/issues/4129)
* Show 404 instead of 500 if a not signed in user wants to see a non public or non existing post.

## Features

* Deleting a post that was shared to Facebook now deletes it from Facebook too [#3980]( https://github.com/diaspora/diaspora/pull/3980)
* Include reshares in a users public atom feed [#1781](https://github.com/diaspora/diaspora/issues/1781)
* Add the ability to upload photos from the mobile site. [#4004](https://github.com/diaspora/diaspora/issues/4004)
* Show timestamp when hovering on comment time-ago string. [#4042](https://github.com/diaspora/diaspora/issues/4042)
* If sharing a post with photos to Facebook, always include URL to post [#3706](https://github.com/diaspora/diaspora/issues/3706)
* Add possibiltiy to upload multiple photos from mobile. [#4067](https://github.com/diaspora/diaspora/issues/4067)
* Add hotkeys to navigate in stream [#4089](https://github.com/diaspora/diaspora/pull/4089)
* Add a brief explanatory text about external services connections to services index page [#3064](https://github.com/diaspora/diaspora/issues/3064)
* Add a preview for posts in the stream [#4099](https://github.com/diaspora/diaspora/issues/4099)
* Add shortcut key Shift to submit comments and publish posts. [#4096](https://github.com/diaspora/diaspora/pull/4096)
* Show the service username in a tooltip next to the publisher icons [#4126](https://github.com/diaspora/diaspora/pull/4126)
* Ability to add location when creating a post [#3803](https://github.com/diaspora/diaspora/pull/3803)
* Added oEmbed provider for MixCloud. [#4131](https://github.com/diaspora/diaspora/pull/4131)

## Gem updates

* Dropped everything related to Capistrano in preparation for maintaining it in a separate repository
* Replaced Resque with Sidekiq, see above. Added Sinatra and Slim for the Sidekiq  Monitor interface
* Added sinon-rails, compass-rails
* acts-as-taggable-on 2.3.3 -> 2.4.0
* addressable 2.3.2 -> 2.3.4
* client_side_validations 3.2.1 -> 3.2.5
* configurate 0.0.2 -> 0.0.7
* cucumber-rails 1.3.0 -> 1.3.1
* faraday 0.8.5 -> 0.8.7
* fog 1.9.0 -> 1.10.1
* foreigner 1.3.0 -> 1.4.1
* foreman 0.61 -> 0.62
* gon 4.0.2 -> 4.1.0
* guard 1.6.2 -> 1.7.0
* guard-cucumber 1.3.2 -> 1.4.0
* guard-rspec 2.4.0 -> 2.5.3
* guard-spork 1.4.2 -> 1.5.0
* haml 4.0.0 -> 4.0.2
* handlebars_assets 0.11.0 -> 0.1.2.0
* jasmine 1.3.1 -> 1.3.2
* nokogiri 1.5.6 -> 1.5.9
* oauth2 0.8.0 -> 0.8.1
* omniauth 1.1.3 -> 1.1.4
* omniauth-twitter 0.0.14 -> 0.0.16
* pg 0.14.1 -> 0.15.1
* rack-piwik 0.1.3 -> 0.2.2
* rails-i18n 0.7.2 -> 0.7.3
* rails_admin 0.4.5 -> 0.4.7
* roxml git release -> 3.1.6
* rspec-rails 2.12.2 -> 2.13.0
* safe_yaml 0.8.0 -> 0.9.1
* selenium-webdriver 2.29.0 -> 2.32.1
* timecop 0.5.9.2 -> 0.6.1
* twitter 4.5.0 -> 4.6.2
* uglifier 1.3.0 -> 2.0.1
* unicorn 4.6.0 -> 4.6.2


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

