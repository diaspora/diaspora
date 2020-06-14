# 0.7.14.0

## Refactor
* Update the suggested Ruby version to 2.6. If you run into trouble during the update and you followed our installation guides, run `rvm install 2.6`. [#7929](https://github.com/diaspora/diaspora/pull/7929)

## Bug fixes
* Don't link to deleted users in admin user stats [#8063](https://github.com/diaspora/diaspora/pull/8063)
* Properly validate a profile's gender field length instead of failing with a database error. [#8127](https://github.com/diaspora/diaspora/pull/8127)

## Features

# 0.7.13.0

## Security
* Fixes [USN-4274-1](https://usn.ubuntu.com/4274-1/), a potential Denial-of-Service vulnerability in Nokogiri. [#8108](https://github.com/diaspora/diaspora/pull/8108)

## Refactor
* Set better example values for unicorn stdout/stderr log settings [#8058](https://github.com/diaspora/diaspora/pull/8058)
* Replace dependency on rails-assets.org with custom gems cache at gems.diasporafoundation.org [#8087](https://github.com/diaspora/diaspora/pull/8087)

## Bug fixes
* Fix error while trying to fetch some sites with invalid OpenGraph data [#8049](https://github.com/diaspora/diaspora/pull/8049)
* Don't show sign up link on mobile when registrations are disabled [#8060](https://github.com/diaspora/diaspora/pull/8060)

## Features
* Add cronjob to cleanup pending photos which were never posted [#8041](https://github.com/diaspora/diaspora/pull/8041)

# 0.7.12.0

## Refactor
* Harmonize markdown titles sizes [#8029](https://github.com/diaspora/diaspora/pull/8029)

## Bug fixes
* Improve handling of mixed case hostnames while fetching OpenGraph data [#8021](https://github.com/diaspora/diaspora/pull/8021)
* Fix "remember me" with two factor authentication enabled [#8031](https://github.com/diaspora/diaspora/pull/8031)

## Features
* Add line mentioning diaspora\* on the splash page [#7966](https://github.com/diaspora/diaspora/pull/7966)
* Improve communication about signing up on closed pods [#7896](https://github.com/diaspora/diaspora/pull/7896)

# 0.7.11.0

## Refactor
* Enable paranoid mode for devise [#8003](https://github.com/diaspora/diaspora/pull/8003)
* Refactor likes cucumber test [#8002](https://github.com/diaspora/diaspora/pull/8002)

## Bug fixes
* Fix old photos without remote url for export [#8012](https://github.com/diaspora/diaspora/pull/8012)

## Features
* Add a manifest.json file as a first step to make diaspora\* a Progressive Web App [#7998](https://github.com/diaspora/diaspora/pull/7998)
* Allow `web+diaspora://` links to link to a profile with only the diaspora ID [#8000](https://github.com/diaspora/diaspora/pull/8000)
* Support TOTP two factor authentication [#7751](https://github.com/diaspora/diaspora/pull/7751)

# 0.7.10.0

## Refactor
* Replace dandelion.jpg with a public domain photo [#7976](https://github.com/diaspora/diaspora/pull/7976)

## Bug fixes
* Fix incorrect post sorting on tag streams and tag searches for tags containing the word "activity" [#7959](https://github.com/diaspora/diaspora/issues/7959)

# 0.7.9.0

## Refactor
* Improve public stream performance and cleanup unused indexes [#7944](https://github.com/diaspora/diaspora/pull/7944)
* Improve wording of "Toggle mobile" [#7926](https://github.com/diaspora/diaspora/pull/7926)

## Bug fixes
* Do not autofollow back a user you are ignoring [#7913](https://github.com/diaspora/diaspora/pull/7913)
* Fix photos gallery when too many thumbnails are shown [#7943](https://github.com/diaspora/diaspora/pull/7943)
* Fix extended profile visibility switch showing the wrong state [#7955](https://github.com/diaspora/diaspora/pull/7955)

## Features
* Support ignore users on mobile [#7884](https://github.com/diaspora/diaspora/pull/7884)

# 0.7.8.0

## Refactor
* Make setting up a development environment 9001% easier by adding a Docker-based setup [#7870](https://github.com/diaspora/diaspora/pull/7870)
* Improve `web+diaspora://` handler description [#7909](https://github.com/diaspora/diaspora/pull/7909)
* Move comment timestamp next to author name [#7905](https://github.com/diaspora/diaspora/pull/7905)
* Sharpen small and medium thumbnails [#7924](https://github.com/diaspora/diaspora/pull/7924)
* Show full-res image in Desktop's full-screen image view [#7890](https://github.com/diaspora/diaspora/pull/7890)

## Bug fixes
* Ignore invalid URLs for camo [#7922](https://github.com/diaspora/diaspora/pull/7922)
* Unliking a post did not update the participation icon without a reload [#7882](https://github.com/diaspora/diaspora/pull/7882)
* Fix broken Instagram embedding [#7920](https://github.com/diaspora/diaspora/pull/7920)

## Features
* Add the ability to assign roles in the admin panel [#7868](https://github.com/diaspora/diaspora/pull/7868)
* Improve memory usage with libjemalloc if available [#7919](https://github.com/diaspora/diaspora/pull/7919)

# 0.7.7.1

Fixes a potential cross-site scripting issue with maliciously crafted OpenGraph metadata on the mobile interface.

# 0.7.7.0

## Refactor
* Remove mention of deprecated `statistic.json` [#7867](https://github.com/diaspora/diaspora/pull/7867)
* Add quotes in `database.yml.example` to fields that may contain special characters [#7875](https://github.com/diaspora/diaspora/pull/7875)
* Removed broken, and thus deprecated, Facebook integration [#7874](https://github.com/diaspora/diaspora/pull/7874)

## Bug fixes
* Add compatibility with macOS to `script/configure_bundler` [#7830](https://github.com/diaspora/diaspora/pull/7830)
* Fix comment and like notifications on posts without text [#7857](https://github.com/diaspora/diaspora/pull/7857) [#7853](https://github.com/diaspora/diaspora/pull/7853)
* Fix issue with some language fallbacks not working correctly [#7861](https://github.com/diaspora/diaspora/pull/7861)
* Make sure URLs are encoded before sending them to camo [#7871](https://github.com/diaspora/diaspora/pull/7871)

## Features
* Add `web+diaspora://` link handler [#7826](https://github.com/diaspora/diaspora/pull/7826)

# 0.7.6.0

## Refactor
* Add unique index to poll participations on `poll_id` and `author_id` [#7798](https://github.com/diaspora/diaspora/pull/7798)
* Add 'completed at' date to account migrations [#7805](https://github.com/diaspora/diaspora/pull/7805)
* Handle duplicates for TagFollowing on account merging [#7807](https://github.com/diaspora/diaspora/pull/7807)
* Add link to the pod in the email footer [#7814](https://github.com/diaspora/diaspora/pull/7814)

## Bug fixes
* Fix compatibility with newer glibc versions [#7828](https://github.com/diaspora/diaspora/pull/7828)
* Allow fonts to be served from asset host in CSP [#7825](https://github.com/diaspora/diaspora/pull/7825)

## Features
* Support fetching StatusMessage by Poll GUID [#7815](https://github.com/diaspora/diaspora/pull/7815)
* Always include link to diaspora in facebook cross-posts [#7774](https://github.com/diaspora/diaspora/pull/7774)

# 0.7.5.0

## Refactor
* Remove the 'make contacts in this aspect visible to each other' option [#7769](https://github.com/diaspora/diaspora/pull/7769)
* Remove the requirement to have at least two users to disable the /podmin redirect [#7783](https://github.com/diaspora/diaspora/pull/7783)
* Randomize start times of daily Sidekiq-Cron jobs [#7787](https://github.com/diaspora/diaspora/pull/7787)

## Bug fixes
* Prefill conversation form on contacts page only with mutual contacts [#7744](https://github.com/diaspora/diaspora/pull/7744)
* Fix profiles sometimes not loading properly in background tabs [#7740](https://github.com/diaspora/diaspora/pull/7740)
* Show error message when creating posts with invalid aspects [#7742](https://github.com/diaspora/diaspora/pull/7742)
* Fix mention syntax backport for two immediately consecutive mentions [#7777](https://github.com/diaspora/diaspora/pull/7777)
* Fix link to 'make yourself an admin' [#7783](https://github.com/diaspora/diaspora/pull/7783)
* Fix calculation of content lengths when cross-posting to twitter [#7791](https://github.com/diaspora/diaspora/pull/7791)

## Features
* Make public stream accessible for logged out users [#7775](https://github.com/diaspora/diaspora/pull/7775)
* Add account-merging support when receiving an account migration [#7803](https://github.com/diaspora/diaspora/pull/7803)

# 0.7.4.1

Fixes a possible cross-site scripting issue with maliciously crafted OpenGraph metadata.

# 0.7.4.0

## Refactor
* Don't print a warning when starting the server outside a Git repo [#7712](https://github.com/diaspora/diaspora/pull/7712)
* Make script/server work on readonly filesystems [#7719](https://github.com/diaspora/diaspora/pull/7719)
* Add camo paths to the robots.txt [#7726](https://github.com/diaspora/diaspora/pull/7726)

## Bug fixes
* Prevent duplicate mention notifications when the post is received twice [#7721](https://github.com/diaspora/diaspora/pull/7721)
* Fixed a compatiblitiy issue with non-diaspora\* webfingers [#7718](https://github.com/diaspora/diaspora/pull/7718)
* Don't retry federation for accounts without a valid public key [#7717](https://github.com/diaspora/diaspora/pull/7717)
* Fix stream generation for tagged posts with many followed tags [#7715](https://github.com/diaspora/diaspora/pull/7715)
* Fix incomplete Occitan date localizations [#7731](https://github.com/diaspora/diaspora/pull/7731)

## Features
* Add basic html5 audio/video embedding support [#6418](https://github.com/diaspora/diaspora/pull/6418)
* Add the back-to-top button to all pages [#7729](https://github.com/diaspora/diaspora/pull/7729)

# 0.7.3.1

Re-updating the German translations to fix some UX issues that were introduced by recent translation efforts.

# 0.7.3.0

## Refactor
* Work on the data downloads: Fixed general layout of buttons, added a timestamp and implemented auto-deletion of old exports [#7684](https://github.com/diaspora/diaspora/pull/7684)
* Increase Twitter character limit to 280 [#7694](https://github.com/diaspora/diaspora/pull/7694)
* Improve password autocomplete with password managers [#7642](https://github.com/diaspora/diaspora/pull/7642)
* Remove the limit of participants in private conversations [#7705](https://github.com/diaspora/diaspora/pull/7705)
* Send blocks to the blocked persons pod for better UX [#7705](https://github.com/diaspora/diaspora/pull/7705)
* Send a dummy participation on all incoming public posts to increase interaction consistency [#7708](https://github.com/diaspora/diaspora/pull/7708)

## Bug fixes
* Fix invite link on the contacts page when the user has no contacts [#7690](https://github.com/diaspora/diaspora/pull/7690)
* Fix the mobile bookmarklet when called without parameters [#7698](https://github.com/diaspora/diaspora/pull/7698)
* Properly build the #newhere message for people who got invited [#7702](https://github.com/diaspora/diaspora/pull/7702)
* Fix the admin report view for posts without text [#7706](https://github.com/diaspora/diaspora/pull/7706)
* Upgrade Nokogiri to fix [a disclosed vulnerability in libxml2](https://github.com/sparklemotion/nokogiri/issues/1714)

## Features
* Check if redis is running in script/server [#7685](https://github.com/diaspora/diaspora/pull/7685)

# 0.7.2.1

Fixes notifications when people remove their birthday date [#7691](https://github.com/diaspora/diaspora/pull/7691)

# 0.7.2.0

## Bug fixes
* Ignore invalid `diaspora://` links [#7652](https://github.com/diaspora/diaspora/pull/7652)
* Fix deformed avatar in hovercards [#7656](https://github.com/diaspora/diaspora/pull/7656)
* Fix default aspects on profile page and bookmarklet publisher [#7679](https://github.com/diaspora/diaspora/issues/7679)

## Features
* Add birthday notifications [#7624](https://github.com/diaspora/diaspora/pull/7624)

# 0.7.1.1

Fixes an issue with installing and running diaspora\* with today released bundler v1.16.0.

# 0.7.1.0

## Ensure account deletions are run

There were some issues causing accounts deletions to not properly perform in some cases, see
[#7631](https://github.com/diaspora/diaspora/issues/7631) and [#7639](https://github.com/diaspora/diaspora/pull/7639).
To ensure these are reexecuted properly, please run `RAILS_ENV=production bin/rake migrations:run_account_deletions`
after you've upgraded.

## Refactor
* Remove title from profile photo upload button [#7551](https://github.com/diaspora/diaspora/pull/7551)
* Remove Internet Explorer workarounds [#7557](https://github.com/diaspora/diaspora/pull/7557)
* Sort notifications by last interaction [#7568](https://github.com/diaspora/diaspora/pull/7568) [#7648](https://github.com/diaspora/diaspora/pull/7648)
* Remove tiff support from photos [#7576](https://github.com/diaspora/diaspora/pull/7576)
* Remove reference from reshares when original post is deleted [#7578](https://github.com/diaspora/diaspora/pull/7578)
* Merge migrations from before 0.6.0.0 to CreateSchema [#7580](https://github.com/diaspora/diaspora/pull/7580)
* Remove auto detection of languages with highlightjs [#7591](https://github.com/diaspora/diaspora/pull/7591)
* Move enable/disable notification icon [#7592](https://github.com/diaspora/diaspora/pull/7592)
* Use Bootstrap 3 progress-bar for polls [#7600](https://github.com/diaspora/diaspora/pull/7600)
* Enable frozen string literals [#7595](https://github.com/diaspora/diaspora/pull/7595)
* Remove `rails_admin_histories` table [#7597](https://github.com/diaspora/diaspora/pull/7597)
* Optimize memory usage on profile export [#7627](https://github.com/diaspora/diaspora/pull/7627)
* Limit the number of parallel exports [#7629](https://github.com/diaspora/diaspora/pull/7629)
* Reduce memory usage for account deletion [#7639](https://github.com/diaspora/diaspora/pull/7639)

## Bug fixes
* Fix displaying polls with long answers [#7579](https://github.com/diaspora/diaspora/pull/7579)
* Fix S3 support [#7566](https://github.com/diaspora/diaspora/pull/7566)
* Fix mixed username and timestamp with LTR/RTL scripts [#7575](https://github.com/diaspora/diaspora/pull/7575)
* Prevent users from zooming in IE Mobile [#7589](https://github.com/diaspora/diaspora/pull/7589)
* Fix recipient prefill on contacts and profile page [#7599](https://github.com/diaspora/diaspora/pull/7599)
* Display likes and reshares without login [#7583](https://github.com/diaspora/diaspora/pull/7583)
* Fix invalid data in the database for user data export [#7614](https://github.com/diaspora/diaspora/pull/7614)
* Fix local migration run without old private key [#7558](https://github.com/diaspora/diaspora/pull/7558)
* Fix export not downloadable because the filename was resetted on access [#7622](https://github.com/diaspora/diaspora/pull/7622)
* Delete invalid oEmbed caches with binary titles [#7620](https://github.com/diaspora/diaspora/pull/7620)
* Delete invalid diaspora IDs from friendica [#7630](https://github.com/diaspora/diaspora/pull/7630)
* Cleanup relayables where the signature is missing [#7637](https://github.com/diaspora/diaspora/pull/7637)
* Avoid page to jump to top after a post deletion [#7638](https://github.com/diaspora/diaspora/pull/7638)
* Handle duplicate account deletions [#7639](https://github.com/diaspora/diaspora/pull/7639)
* Handle duplicate account migrations [#7641](https://github.com/diaspora/diaspora/pull/7641)
* Handle bugs related to missing users [#7632](https://github.com/diaspora/diaspora/pull/7632)
* Cleanup empty signatures [#7644](https://github.com/diaspora/diaspora/pull/7644)

## Features
* Ask for confirmation when leaving a submittable comment field [#7530](https://github.com/diaspora/diaspora/pull/7530)
* Show users vote in polls [#7550](https://github.com/diaspora/diaspora/pull/7550)
* Add explanation of ignore function to in-app help section [#7585](https://github.com/diaspora/diaspora/pull/7585)
* Add camo information to NodeInfo [#7617](https://github.com/diaspora/diaspora/pull/7617)
* Add support for `diaspora://` links [#7625](https://github.com/diaspora/diaspora/pull/7625)
* Add support to relay likes for comments [#7625](https://github.com/diaspora/diaspora/pull/7625)
* Implement RFC 7033 WebFinger [#7625](https://github.com/diaspora/diaspora/pull/7625)

# 0.7.0.1

Update nokogiri to fix [multiple libxml2 vulnerabilities](https://usn.ubuntu.com/usn/usn-3424-1/).

# 0.7.0.0

## Supported Ruby versions

This release recommends using Ruby 2.4, while retaining Ruby 2.3 as an officially supported version.
Ruby 2.1 is no longer officially supported.

## Delete public/.well-known/

Before upgrading, please check if your `public/` folder contains a hidden `.well-known/` folder.
If so, please delete it since it will prevent the federation from working properly.

## Refactor

* Make the mention syntax more flexible [#7305](https://github.com/diaspora/diaspora/pull/7305)
* Display @ before mentions [#7324](https://github.com/diaspora/diaspora/pull/7324)
* Simplify mentions in the publisher [#7302](https://github.com/diaspora/diaspora/pull/7302)
* Remove chartbeat and mixpanel support [#7280](https://github.com/diaspora/diaspora/pull/7280)
* Upgrade to jQuery 3 [#7303](https://github.com/diaspora/diaspora/pull/7303)
* Add i18n for color themes [#7369](https://github.com/diaspora/diaspora/pull/7369)
* Remove deprecated statistics.json [#7399](https://github.com/diaspora/diaspora/pull/7399)
* Always link comment count text on mobile [#7483](https://github.com/diaspora/diaspora/pull/7483)
* Switch to new federation protocol [#7436](https://github.com/diaspora/diaspora/pull/7436)
* Send public profiles publicly [#7501](https://github.com/diaspora/diaspora/pull/7501)
* Change sender for mails [#7495](https://github.com/diaspora/diaspora/pull/7495)
* Move back to top to the right to avoid misclicks [#7516](https://github.com/diaspora/diaspora/pull/7516)
* Include count in mobile post action link [#7520](https://github.com/diaspora/diaspora/pull/7520)
* Update the user data export archive format [#6726](https://github.com/diaspora/diaspora/pull/6726)
* Use id as fallback when sorting posts [#7523](https://github.com/diaspora/diaspora/pull/7523)
* Remove no-posts-info when adding posts to the stream [#7523](https://github.com/diaspora/diaspora/pull/7523)
* Upgrade to rails 5.1 [#7514](https://github.com/diaspora/diaspora/pull/7514)
* Refactoring single post view interactions [#7182](https://github.com/diaspora/diaspora/pull/7182)
* Update help pages [#7528](https://github.com/diaspora/diaspora/pull/7528)
* Disable rendering logging in production [#7529](https://github.com/diaspora/diaspora/pull/7529)
* Add some missing indexes and cleanup the database if needed [#7533](https://github.com/diaspora/diaspora/pull/7533)
* Remove avatar, name, timestamp and interactions from publisher preview [#7536](https://github.com/diaspora/diaspora/pull/7536)

## Bug fixes

* Fix height too high on mobile SPV [#7480](https://github.com/diaspora/diaspora/pull/7480)
* Improve stream when ignoring a person who posts a lot of tagged posts [#7503](https://github.com/diaspora/diaspora/pull/7503)
* Fix order of comments across pods [#7436](https://github.com/diaspora/diaspora/pull/7436)
* Prevent publisher from closing in preview mode [#7518](https://github.com/diaspora/diaspora/pull/7518)
* Increase reshare counter after reshare on mobile [#7520](https://github.com/diaspora/diaspora/pull/7520)
* Reset stuck exports and handle errors [#7535](https://github.com/diaspora/diaspora/pull/7535)

## Features
* Add support for mentions in comments to the backend [#6818](https://github.com/diaspora/diaspora/pull/6818)
* Add support for new mention syntax [#7300](https://github.com/diaspora/diaspora/pull/7300) [#7394](https://github.com/diaspora/diaspora/pull/7394)
* Render mentions as links in comments [#7327](https://github.com/diaspora/diaspora/pull/7327)
* Add support for mentions in comments to the front-end [#7386](https://github.com/diaspora/diaspora/pull/7386)
* Support direct links to comments on mobile [#7508](https://github.com/diaspora/diaspora/pull/7508)
* Add inviter first and last name in the invitation e-mail [#7484](https://github.com/diaspora/diaspora/pull/7484)
* Add markdown editor for comments and conversations [#7482](https://github.com/diaspora/diaspora/pull/7482)
* Improve responsive header in desktop version [#7509](https://github.com/diaspora/diaspora/pull/7509)
* Support cmd+enter to submit posts, comments and conversations [#7524](https://github.com/diaspora/diaspora/pull/7524)
* Add markdown editor for posts, comments and conversations on mobile [#7235](https://github.com/diaspora/diaspora/pull/7235)
* Mark as "Mobile Web App Capable" on Android [#7534](https://github.com/diaspora/diaspora/pull/7534)
* Add support for receiving account migrations [#6750](https://github.com/diaspora/diaspora/pull/6750)

# 0.6.7.0

## Refactor
* Cleanup some translations [#7465](https://github.com/diaspora/diaspora/pull/7465)

## Features
* Change email without confirmation when mail is disabled [#7455](https://github.com/diaspora/diaspora/pull/7455)
* Warn users if they leave the profile editing page with unsaved changes [#7473](https://github.com/diaspora/diaspora/pull/7473)
* Add admin pages to the mobile interface [#7295](https://github.com/diaspora/diaspora/pull/7295)
* Add links to discourse to footer and sidebar [#7446](https://github.com/diaspora/diaspora/pull/7446)

# 0.6.6.0

## Refactor
* Remove rails\_admin [#7440](https://github.com/diaspora/diaspora/pull/7440)
* Use guid instead of id at permalink and in SPV [#7453](https://github.com/diaspora/diaspora/pull/7453)

## Bug fixes
* Make photo upload button hover text translatable [#7429](https://github.com/diaspora/diaspora/pull/7429)
* Fix first comment in mobile view with french locale [#7441](https://github.com/diaspora/diaspora/pull/7441)
* Use post page title and post author in atom feed [#7420](https://github.com/diaspora/diaspora/pull/7420)
* Handle broken public keys when receiving posts [#7448](https://github.com/diaspora/diaspora/pull/7448)
* Fix welcome message when podmin is set to an invalid username [#7452](https://github.com/diaspora/diaspora/pull/7452)

## Features
* Add support for Nodeinfo 2.0 [#7447](https://github.com/diaspora/diaspora/pull/7447)

# 0.6.5.0

## Refactor
* Remove unused setPreload function [#7354](https://github.com/diaspora/diaspora/pull/7354)
* Remove jQuery deprecations [#7356](https://github.com/diaspora/diaspora/pull/7356)
* Use empty selector where "#" was used as a selector before (prepare jQuery 3 upgrade) [#7372](https://github.com/diaspora/diaspora/pull/7372)
* Increase maximal height of large thumbnail on mobile [#7383](https://github.com/diaspora/diaspora/pull/7383)
* Reduce conversation recipient size [#7376](https://github.com/diaspora/diaspora/pull/7376)
* Cleanup rtl css [#7374](https://github.com/diaspora/diaspora/pull/7374)
* Increase visual spacing between list items [#7401](https://github.com/diaspora/diaspora/pull/7401)
* Remove unused gem and cucumber step [#7410](https://github.com/diaspora/diaspora/pull/7410)
* Disable CSP header when `report_only` and no `report_uri` is set [#7367](https://github.com/diaspora/diaspora/pull/7367)

## Bug fixes
* Don't hide posts when blocking someone from the profile [#7379](https://github.com/diaspora/diaspora/pull/7379)
* Disable autocomplete for the conversation form recipient input [#7375](https://github.com/diaspora/diaspora/pull/7375)
* Fix sharing indicator on profile page for blocked users [#7382](https://github.com/diaspora/diaspora/pull/7382)
* Remove post only after a successful deletion on the server [#7385](https://github.com/diaspora/diaspora/pull/7385)
* Fix an issue where pod admins could get logged out when using sidekiq-web [#7395](https://github.com/diaspora/diaspora/pull/7395)
* Add avatar fallback for typeahead and conversations [#7414](https://github.com/diaspora/diaspora/pull/7414)

## Features
* Add links to liked and commented pages [#5502](https://github.com/diaspora/diaspora/pull/5502)

# 0.6.4.1

Fixes a possible Remote Code Execution ([CVE-2016-4658](https://cve.mitre.org/cgi-bin/cvename.cgi?name=CVE-2016-4658)) and a possible DoS ([CVE-2016-5131](https://cve.mitre.org/cgi-bin/cvename.cgi?name=CVE-2016-5131)) by updating Nokogiri, which in turn updates libxml2.

# 0.6.4.0

## Refactor
* Unify link colors [#7318](https://github.com/diaspora/diaspora/pull/7318)
* Increase time to wait before showing the hovercard [#7319](https://github.com/diaspora/diaspora/pull/7319)
* Remove some unused color-theme overrides [#7325](https://github.com/diaspora/diaspora/pull/7325)
* Change color of author-name on hover [#7326](https://github.com/diaspora/diaspora/pull/7326)
* Add like and reshare services [#7337](https://github.com/diaspora/diaspora/pull/7337)

## Bug fixes
* Fix path to `bundle` in `script/server` [#7281](https://github.com/diaspora/diaspora/pull/7281)
* Update comment in database example config [#7282](https://github.com/diaspora/diaspora/pull/7282)
* Make the \#newhere post public again [#7311](https://github.com/diaspora/diaspora/pull/7311)
* Remove whitespace from author link [#7330](https://github.com/diaspora/diaspora/pull/7330)
* Fix autosize in modals [#7339](https://github.com/diaspora/diaspora/pull/7339)
* Only display invite link on contacts page if invitations are enabled [#7342](https://github.com/diaspora/diaspora/pull/7342)
* Fix regex for hashtags for some languages [#7350](https://github.com/diaspora/diaspora/pull/7350)
* Create asterisk.png without digest after precompile [#7322](https://github.com/diaspora/diaspora/pull/7322)

## Features
* Add support for [Liberapay](https://liberapay.com) donations [#7290](https://github.com/diaspora/diaspora/pull/7290)
* Added a link to the community guidelines :) [#7298](https://github.com/diaspora/diaspora/pull/7298)

# 0.6.3.0

## Refactor
* Increase the spacing above and below post contents [#7267](https://github.com/diaspora/diaspora/pull/7267)
* Replace fileuploader-custom with FineUploader [#7083](https://github.com/diaspora/diaspora/pull/7083)
* Always show mobile reaction counts [#7207](https://github.com/diaspora/diaspora/pull/7207)
* Refactor mobile alerts for error responses [#7227](https://github.com/diaspora/diaspora/pull/7227)
* Switch content and given reason in the reports overview [#7180](https://github.com/diaspora/diaspora/pull/7180)

## Bug fixes
* Fix background color of year on notifications page with dark theme [#7263](https://github.com/diaspora/diaspora/pull/7263)
* Fix jasmine tests in firefox [#7246](https://github.com/diaspora/diaspora/pull/7246)
* Prevent scroll to top when clicking 'mark all as read' in the notification dropdown [#7253](https://github.com/diaspora/diaspora/pull/7253)
* Update existing notifications in dropdown on fetch [#7270](https://github.com/diaspora/diaspora/pull/7270)
* Fix link to post on mobile photo page [#7274](https://github.com/diaspora/diaspora/pull/7274)
* Fix some background issues on dark mobile themes [#7278](https://github.com/diaspora/diaspora/pull/7278)

## Features
* Add links to the aspects and followed tags pages on mobile [#7265](https://github.com/diaspora/diaspora/pull/7265)
* diaspora\* is now available in Gàidhlig, Occitan, and Schwiizerdütsch

# 0.6.2.0

## Refactor
* Use string-direction gem for rtl detection [#7181](https://github.com/diaspora/diaspora/pull/7181)
* Reduce i18n.load side effects [#7184](https://github.com/diaspora/diaspora/pull/7184)
* Force jasmine fails on syntax errors [#7185](https://github.com/diaspora/diaspora/pull/7185)
* Don't display mail-related view content if it is disabled in the pod's config [#7190](https://github.com/diaspora/diaspora/pull/7190)
* Use typeahead.js from rails-assets.org [#7192](https://github.com/diaspora/diaspora/pull/7192)
* Refactor ShareVisibilitesController to use PostService [#7196](https://github.com/diaspora/diaspora/pull/7196)
* Unify desktop and mobile head elements [#7194](https://github.com/diaspora/diaspora/pull/7194) [#7209](https://github.com/diaspora/diaspora/pull/7209)
* Refactor flash messages on ajax errors for comments, likes, reshares and aspect memberships [#7202](https://github.com/diaspora/diaspora/pull/7202)
* Only require AWS-module for fog [#7201](https://github.com/diaspora/diaspora/pull/7201)
* Only show community spotlight links on the contacts page if community spotlight is enabled [#7213](https://github.com/diaspora/diaspora/pull/7213)
* Require spec\_helper in .rspec [#7223](https://github.com/diaspora/diaspora/pull/7223)
* Make the CSRF mail a bit more friendly [#7238](https://github.com/diaspora/diaspora/pull/7238) [#7241](https://github.com/diaspora/diaspora/pull/7241)

## Bug fixes
* Fix fetching comments after fetching likes [#7167](https://github.com/diaspora/diaspora/pull/7167)
* Hide 'reshare' button on already reshared posts [#7169](https://github.com/diaspora/diaspora/pull/7169)
* Only reload profile header when changing aspect memberships [#7183](https://github.com/diaspora/diaspora/pull/7183)
* Fix visiblity on invitation modal when opening it from the stream [#7191](https://github.com/diaspora/diaspora/pull/7191)
* Add avatar fallback on tags page [#7198](https://github.com/diaspora/diaspora/pull/7198)
* Update notifications when changing the stream [#7199](https://github.com/diaspora/diaspora/pull/7199)
* Fix 500 on mobile commented and liked streams [#7219](https://github.com/diaspora/diaspora/pull/7219)

## Features
* Show spinner when loading comments in the stream [#7170](https://github.com/diaspora/diaspora/pull/7170)
* Add a dark color theme [#7152](https://github.com/diaspora/diaspora/pull/7152)
* Added setting for custom changelog URL [#7166](https://github.com/diaspora/diaspora/pull/7166)
* Show more information of recipients on conversation creation [#7129](https://github.com/diaspora/diaspora/pull/7129)
* Update notifications every 5 minutes and when opening the notification dropdown [#6952](https://github.com/diaspora/diaspora/pull/6952)
* Show browser notifications when receiving new unread notifications [#6952](https://github.com/diaspora/diaspora/pull/6952)
* Only clear comment textarea when comment submission was successful [#7186](https://github.com/diaspora/diaspora/pull/7186)
* Add support for graceful unicorn restarts [#7217](https://github.com/diaspora/diaspora/pull/7217)

# 0.6.1.0

Note: Although this is a minor release, the configuration file changed because the old Mapbox implementation is no longer valid, and the current implementation requires additional fields. Chances are high that if you're using the old integration, it will be broken anyway. If you do use Mapbox, please check out the `diaspora.yml.example` for new parameters.

## Refactor
* Indicate proper way to report bugs in the sidebar [#7039](https://github.com/diaspora/diaspora/pull/7039)
* Remove text color from notification mails and fix sender avatar [#7054](https://github.com/diaspora/diaspora/pull/7054)
* Make the session cookies HttpOnly again [#7041](https://github.com/diaspora/diaspora/pull/7041)
* Invalidate sessions with invalid CSRF tokens [#7050](https://github.com/diaspora/diaspora/pull/7050)
* Liking a post will no longer update its interacted timestamp [#7030](https://github.com/diaspora/diaspora/pull/7030)
* Improve W3C compliance [#7068](https://github.com/diaspora/diaspora/pull/7068) [#7082](https://github.com/diaspora/diaspora/pull/7082) [#7091](https://github.com/diaspora/diaspora/pull/7091) [#7092](https://github.com/diaspora/diaspora/pull/7092)
* Load jQuery in the head on mobile [#7086](https://github.com/diaspora/diaspora/pull/7086)
* Use translation for NodeInfo services [#7102](https://github.com/diaspora/diaspora/pull/7102)
* Adopt new Mapbox tile URIs [#7066](https://github.com/diaspora/diaspora/pull/7066)
* Refactored post interactions on the single post view [#7089](https://github.com/diaspora/diaspora/pull/7089)
* Extract inline JavaScript [#7113](https://github.com/diaspora/diaspora/pull/7113)
* Port conversations inbox to backbone.js [#7108](https://github.com/diaspora/diaspora/pull/7108)
* Refactored stream shortcuts for more flexibility [#7127](https://github.com/diaspora/diaspora/pull/7127)
* Link to admin dashboard instead of admin panel from the podmin landing page [#7130](https://github.com/diaspora/diaspora/pull/7130)

## Bug fixes
* Post comments no longer get collapsed when interacting with a post [#7040](https://github.com/diaspora/diaspora/pull/7040)
* Closed accounts will no longer show up in the account search [#7042](https://github.com/diaspora/diaspora/pull/7042)
* Code blocks in conversations no longer overflow the content [#7055](https://github.com/diaspora/diaspora/pull/7055)
* More buttons in mobile streams are fixed [#7036](https://github.com/diaspora/diaspora/pull/7036)
* Fixed missing sidebar background in the contacts tab [#7064](https://github.com/diaspora/diaspora/pull/7064)
* Fix tags URLs in hovercards [#7075](https://github.com/diaspora/diaspora/pull/7075)
* Fix 500 in html requests for post interactions [#7085](https://github.com/diaspora/diaspora/pull/7085)
* Remove whitespaces next to like link in stream [#7088](https://github.com/diaspora/diaspora/pull/7088)
* Prevent overflow of interaction avatars in the single post view [#7070](https://github.com/diaspora/diaspora/pull/7070)
* Fix moving publisher on first click after page load [#7094](https://github.com/diaspora/diaspora/pull/7094)
* Fix link to comment on report page [#7105](https://github.com/diaspora/diaspora/pull/7105)
* Fix duplicate flash message on mobile profile edit [#7107](https://github.com/diaspora/diaspora/pull/7107)
* Clicking photos on mobile should no longer cause 404s [#7071](https://github.com/diaspora/diaspora/pull/7071)
* Fix avatar size on mobile privacy page for ignored people [#7148](https://github.com/diaspora/diaspora/pull/7148)
* Don't display tag following button when logged out [#7155](https://github.com/diaspora/diaspora/pull/7155)
* Fix message modal on profile page [#7137](https://github.com/diaspora/diaspora/pull/7137)
* Display error message when aspect membership changes fail [#7132](https://github.com/diaspora/diaspora/pull/7132)
* Avoid the creation of pod that are none [#7145](https://github.com/diaspora/diaspora/pull/7145)
* Fixed tag pages with alternate default aspect settings [#7262](https://github.com/diaspora/diaspora/pull/7162)
* Suppressed CSP related deprecation warnings [#7263](https://github.com/diaspora/diaspora/pull/7163)

## Features
* Deleted comments will be removed when loading more comments [#7045](https://github.com/diaspora/diaspora/pull/7045)
* The "subscribe" indicator on a post now gets toggled when you like or rehsare a post [#7040](https://github.com/diaspora/diaspora/pull/7040)
* Add OpenGraph video support [#7043](https://github.com/diaspora/diaspora/pull/7043)
* You'll now get redirected to the invites page if you follow an invitation but you're already logged in [#7061](https://github.com/diaspora/diaspora/pull/7061)
* Add support for setting BOSH access protocol via chat configuration [#7100](https://github.com/diaspora/diaspora/pull/7100)
* Add number of unreviewed reports to admin dashboard and admin sidebar [#7109](https://github.com/diaspora/diaspora/pull/7109)
* Don't federate to pods that have been offline for an extended period of time [#7120](https://github.com/diaspora/diaspora/pull/7120)
* Add In-Reply-To and References headers to notification mails [#7122](https://github.com/diaspora/diaspora/pull/7122)
* Directly link to a comment in commented notification mails [#7124](https://github.com/diaspora/diaspora/pull/7124)
* Add optional `Content-Security-Policy` header [#7128](https://github.com/diaspora/diaspora/pull/7128)
* Add links to main stream and public stream to the mobile drawer [#7144](https://github.com/diaspora/diaspora/pull/7144)
* Allow opening search results from the dropdown in a new tab [#7021](https://github.com/diaspora/diaspora/issues/7021)
* Add user setting for default post visibility [#7118](https://github.com/diaspora/diaspora/issues/7118)

# 0.6.0.1

Fixes an issue with installing an running diaspora\*, caused by a recent bundler update that fixes a bundler bug on which we depended on.

# 0.6.0.0

## Warning: This release contains long migrations

This diaspora\* releases comes with a few database cleanup migrations and they could possible take a while. While you should always do that, it is especially important this time to make sure you run the migrations inside a detachable environment like `screen` or `tmux`. A interrupted SSH session could possibly harm your database. Also, please make a backup.

## The DB environment variable is gone

With Bundler 1.10 supporting optional groups, we removed the DB environment variable. When updating to this release, please update
bundler and select the database support you want:

```sh
gem install bundler
bundle install --with mysql # For MySQL and MariaDB
bundle install --with postgresql # For PostgreSQL
```

For production setups we now additionally recommend adding the `--deployment` flag.
If you set the DB environment variable anywhere, that's no longer necessary.

## Supported Ruby versions

This release recommends using Ruby 2.3, while retaining Ruby 2.1 as an officially supported version.
Ruby 2.0 is no longer officially supported.

## Configuration changes

Please note that the default listen parameter for production setups got
changed. diaspora\* will no longer listen on `0.0.0.0:3000` as it will now
bind to an UNIX socket at `unix:tmp/diaspora.sock`. Please change your local
`diaspora.yml` if necessary.

## Redis namespace support dropped

We dropped support for Redis namespaces in this release. If you previously set
a custom namespace, please note that diaspora\* will no longer use the
configured value. By default, Redis supports up to 8 databases which can be
selected via the Redis URL in `diaspora.yml`. Please check the examples
provided in our configuration example file.

## Terms of Use design changes

With the port to Bootstrap 3, app/views/terms/default.haml has a new structure. If you have created a customised app/views/terms/terms.haml or app/views/terms/terms.erb file, you will need to edit those files to base your customisations on the new default.haml file.

## API authentication

This release makes diaspora\* a OpenID Connect provider. This means you can authenticate to third parties with your diaspora\* account and let
them act as your diaspora\* account on your behalf. This feature is still considered in early development, we still expect edge cases and advanced
features of the specificiation to not be handled correctly or be missing. But we expect a basic OpenID Connect compliant client to work. Please submit issues!
We will also most likely still change the authorization scopes we offer and started with a very minimal set.
Most work still required is on documentation as well as designing and implementing the data API for all of Diaspora's functionality.
Contributions are very welcome, the hard work is done!

## Vines got replaced by Prosody

Due to many issues with Vines, we decided to remove Vines and offer a Prosody
example configuration instead. [Check the
wiki](https://wiki.diasporafoundation.org/Integration/Chat#Vines_to_Prosody)
for more information on how to migrate to Prosody if you've been using Vines
before.

## Sidekiq queue changes

We've decreased the amount of sidekiq queues from 13 to 5 in PR [#6950](https://github.com/diaspora/diaspora/pull/6950).
The new queues are organized according to priority for the jobs they will process. When upgrading please make sure to
empty the sidekiq queues before shutting down the server for an update.

If you run your sidekiq with a custom queue configuration, please make sure to update that for the new queues.

The new queues are: `urgent, high, medium, low, default`.

When you upgrade to the new version, some jobs may persist in the old queues. To move them to the default queue,
so they're processed, run:

```
bin/rake migrations:legacy_queues
```

Note that this will retry all dead jobs, if you want to prevent that empty the dead queue first.

The command will report queues that still have jobs and launch sidekiq process for that queues.

## Refactor
* Improve bookmarklet [#5904](https://github.com/diaspora/diaspora/pull/5904)
* Update listen configuration to listen on unix sockets by default [#5974](https://github.com/diaspora/diaspora/pull/5974)
* Port to Bootstrap 3 [#6015](https://github.com/diaspora/diaspora/pull/6015)
* Use a fixed width for the mobile drawer [#6057](https://github.com/diaspora/diaspora/pull/6057)
* Replace jquery.autoresize with autosize [#6104](https://github.com/diaspora/diaspora/pull/6104)
* Improve mobile conversation design [#6087](https://github.com/diaspora/diaspora/pull/6087)
* Replace remaining faceboxes with Bootstrap modals [#6106](https://github.com/diaspora/diaspora/pull/6106) [#6161](https://github.com/diaspora/diaspora/pull/6161)
* Rewrite header using Bootstrap 3 [#6109](https://github.com/diaspora/diaspora/pull/6109) [#6130](https://github.com/diaspora/diaspora/pull/6130) [#6132](https://github.com/diaspora/diaspora/pull/6132)
* Use upstream CSS mappings for Entypo [#6158](https://github.com/diaspora/diaspora/pull/6158)
* Replace some mobile icons with Entypo [#6218](https://github.com/diaspora/diaspora/pull/6218)
* Refactor publisher backbone view [#6228](https://github.com/diaspora/diaspora/pull/6228)
* Replace MBP.autogrow with autosize on mobile [#6261](https://github.com/diaspora/diaspora/pull/6261)
* Improve mobile drawer transition [#6233](https://github.com/diaspora/diaspora/pull/6233)
* Remove unused header icons and an unused favicon  [#6283](https://github.com/diaspora/diaspora/pull/6283)
* Replace mobile icons for post interactions with Entypo icons [#6291](https://github.com/diaspora/diaspora/pull/6291)
* Replace jquery.autocomplete with typeahead.js [#6293](https://github.com/diaspora/diaspora/pull/6293)
* Redesign sidebars on stream pages [#6309](https://github.com/diaspora/diaspora/pull/6309)
* Improve ignored users styling [#6349](https://github.com/diaspora/diaspora/pull/6349)
* Use Blueimp image gallery instead of lightbox [#6301](https://github.com/diaspora/diaspora/pull/6301)
* Unify mobile and desktop header design [#6285](https://github.com/diaspora/diaspora/pull/6285)
* Add white background and box-shadow to stream elements [#6324](https://github.com/diaspora/diaspora/pull/6324)
* Override Bootstrap list group design [#6345](https://github.com/diaspora/diaspora/pull/6345)
* Clean up publisher code [#6336](https://github.com/diaspora/diaspora/pull/6336)
* Port conversations to new design [#6431](https://github.com/diaspora/diaspora/pull/6431)
* Hide cancel button in publisher on small screens [#6435](https://github.com/diaspora/diaspora/pull/6435)
* Replace mobile background with color [#6415](https://github.com/diaspora/diaspora/pull/6415)
* Port flash messages to backbone [#6395](https://github.com/diaspora/diaspora/pull/6395)
* Change login/registration/forgot password button color [#6504](https://github.com/diaspora/diaspora/pull/6504)
* A note regarding ignoring users was added to the failure messages on commenting/liking [#6646](https://github.com/diaspora/diaspora/pull/6646)
* Replace sidetiq with sidekiq-cron [#6616](https://github.com/diaspora/diaspora/pull/6616)
* Refactor mobile comment section [#6509](https://github.com/diaspora/diaspora/pull/6509)
* Set vertical resize as default for all textareas [#6654](https://github.com/diaspora/diaspora/pull/6654)
* Unifiy max-widths and page layouts [#6675](https://github.com/diaspora/diaspora/pull/6675)
* Enable autosizing for all textareas [#6674](https://github.com/diaspora/diaspora/pull/6674)
* Stream faces are gone [#6686](https://github.com/diaspora/diaspora/pull/6686)
* Refactor mobile javascript and add tests [#6394](https://github.com/diaspora/diaspora/pull/6394)
* Dropped `parent_author_signature` from relayables [#6586](https://github.com/diaspora/diaspora/pull/6586)
* Attached ShareVisibilities to the User, not the Contact [#6723](https://github.com/diaspora/diaspora/pull/6723)
* Refactor mentions input, now based on typeahead.js [#6728](https://github.com/diaspora/diaspora/pull/6728)
* Optimized the pod up checks [#6727](https://github.com/diaspora/diaspora/pull/6727)
* Prune and do not create aspect visibilities for public posts [#6732](https://github.com/diaspora/diaspora/pull/6732)
* Optimized mobile login and registration forms [#6764](https://github.com/diaspora/diaspora/pull/6764)
* Redesign stream pages [#6535](https://github.com/diaspora/diaspora/pull/6535)
* Improve search and mentions suggestions [#6788](https://github.com/diaspora/diaspora/pull/6788)
* Redesign back to top button [#6782](https://github.com/diaspora/diaspora/pull/6782)
* Adjusted Facebook integration for a successful review [#6778](https://github.com/diaspora/diaspora/pull/6778)
* Redirect to the sign-in page instead of the stream on account deletion [#6784](https://github.com/diaspora/diaspora/pull/6784)
* Removed own unicorn killer by a maintained third-party gem [#6792](https://github.com/diaspora/diaspora/pull/6792)
* Removed deprecated `REDISTOGO_URL` environment variable [#6863](https://github.com/diaspora/diaspora/pull/6863)
* Use Poltergeist instead of Selenium [#6768](https://github.com/diaspora/diaspora/pull/6768)
* Redesigned the landing page and added dedicated notes for podmins [#6268](https://github.com/diaspora/diaspora/pull/6268)
* Moved the entire federation implementation into its own gem. 🎉 [#6873](https://github.com/diaspora/diaspora/pull/6873)
* Remove `StatusMessage#raw_message` [#6921](https://github.com/diaspora/diaspora/pull/6921)
* Extract photo export into a service class [#6922](https://github.com/diaspora/diaspora/pull/6922)
* Use handlebars template for aspect membership dropdown [#6864](https://github.com/diaspora/diaspora/pull/6864)
* Extract relayable signatures into their own tables [#6932](https://github.com/diaspora/diaspora/pull/6932)
* Remove outdated columns from posts table [#6940](https://github.com/diaspora/diaspora/pull/6940)
* Remove some unused routes [#6781](https://github.com/diaspora/diaspora/pull/6781)
* Consolidate sidekiq queues [#6950](https://github.com/diaspora/diaspora/pull/6950)
* Don't re-render the whole comment stream when adding comments [#6406](https://github.com/diaspora/diaspora/pull/6406)
* Drop legacy invitation system [#6976](https://github.com/diaspora/diaspora/pull/6976)
* More consistent and updated meta tags throughout [#6998](https://github.com/diaspora/diaspora/pull/6998)

## Bug fixes
* Destroy Participation when removing interactions with a post [#5852](https://github.com/diaspora/diaspora/pull/5852)
* Improve accessibility of a couple pages [#6227](https://github.com/diaspora/diaspora/pull/6227)
* Capitalize "Powered by diaspora" [#6254](https://github.com/diaspora/diaspora/pull/6254)
* Display username and avatar for NSFW posts in mobile view [#6245](https://github.com/diaspora/diaspora/pull/6245)
* Prevent multiple comment boxes on mobile [#6363](https://github.com/diaspora/diaspora/pull/6363)
* Correctly display location in post preview [#6429](https://github.com/diaspora/diaspora/pull/6429)
* Do not fail when submitting an empty comment in the mobile view [#6543](https://github.com/diaspora/diaspora/pull/6543)
* Limit flash message width on small devices [#6529](https://github.com/diaspora/diaspora/pull/6529)
* Add navbar on mobile when not logged in [#6483](https://github.com/diaspora/diaspora/pull/6483)
* Fix timeago tooltips for reshares [#6648](https://github.com/diaspora/diaspora/pull/6648)
* "Getting started" is now turned off after first visit on mobile [#6681](https://github.com/diaspora/diaspora/pull/6681)
* Fixed a 500 when liking on mobile without JS enabled [#6683](https://github.com/diaspora/diaspora/pull/6683)
* Fixed profile image upload in the mobile UI [#6684](https://github.com/diaspora/diaspora/pull/6684)
* Fixed eye not stopping all processes when trying to exit `script/server` [#6693](https://github.com/diaspora/diaspora/pull/6693)
* Do not change contacts count when marking notifications on the contacts page as read [#6718](https://github.com/diaspora/diaspora/pull/6718)
* Fix typeahead for non-latin characters [#6741](https://github.com/diaspora/diaspora/pull/6741)
* Fix upload size error on mobile [#6803](https://github.com/diaspora/diaspora/pull/6803)
* Connection tester handles invalid NodeInfo implementations [#6890](https://github.com/diaspora/diaspora/pull/6890)
* Do not allow to change email to an already used one [#6905](https://github.com/diaspora/diaspora/pull/6905)
* Correctly filter mentions on the server side [#6902](https://github.com/diaspora/diaspora/pull/6902)
* Add aspects to the aspect membership dropdown when creating them on the getting started page [#6864](https://github.com/diaspora/diaspora/pull/6864)
* Strip markdown from message preview in conversations list [#6923](https://github.com/diaspora/diaspora/pull/6923)
* Improve tag stream performance [#6903](https://github.com/diaspora/diaspora/pull/6903)
* Only show mutual contacts in conversations auto suggestions [#7001](https://github.com/diaspora/diaspora/pull/7001)

## Features
* Support color themes [#6033](https://github.com/diaspora/diaspora/pull/6033)
* Add mobile services and privacy settings pages [#6086](https://github.com/diaspora/diaspora/pull/6086)
* Optionally make your extended profile details public [#6162](https://github.com/diaspora/diaspora/pull/6162)
* Add admin dashboard showing latest diaspora\* version [#6216](https://github.com/diaspora/diaspora/pull/6216)
* Display poll & location on mobile [#6238](https://github.com/diaspora/diaspora/pull/6238)
* Update counts on contacts page dynamically [#6240](https://github.com/diaspora/diaspora/pull/6240)
* Add support for relay based public post federation [#6207](https://github.com/diaspora/diaspora/pull/6207)
* Bigger mobile publisher [#6261](https://github.com/diaspora/diaspora/pull/6261)
* Backend information panel & health checks for known pods [#6290](https://github.com/diaspora/diaspora/pull/6290)
* Allow users to view a posts locations on an OpenStreetMap [#6256](https://github.com/diaspora/diaspora/pull/6256)
* Redesign and unify error pages [#6428](https://github.com/diaspora/diaspora/pull/6428)
* Redesign and refactor report admin interface [#6378](https://github.com/diaspora/diaspora/pull/6378)
* Add permalink icon to stream elements [#6457](https://github.com/diaspora/diaspora/pull/6457)
* Move reshare count to interactions for stream elements [#6487](https://github.com/diaspora/diaspora/pull/6487)
* Posts of ignored users are now visible on that profile page [#6617](https://github.com/diaspora/diaspora/pull/6617)
* Add white color theme [#6631](https://github.com/diaspora/diaspora/pull/6631)
* Add answer counts to poll [#6641](https://github.com/diaspora/diaspora/pull/6641)
* Check for collapsible posts after images in posts have loaded [#6671](https://github.com/diaspora/diaspora/pull/6671)
* Add reason for post report to email sent to admins [#6679](https://github.com/diaspora/diaspora/pull/6679)
* Add links to the single post view of the related post to photos in the photo stream [#6621](https://github.com/diaspora/diaspora/pull/6621)
* Add a note for people with disabled JavaScript [#6777](https://github.com/diaspora/diaspora/pull/6777)
* Do not include conversation subject in notification mail [#6910](https://github.com/diaspora/diaspora/pull/6910)
* Add 'Be excellent to each other!' to the sidebar [#6914](https://github.com/diaspora/diaspora/pull/6914)
* Expose Sidekiq dead queue configuration options
* Properly support pluralization in timeago strings [#6926](https://github.com/diaspora/diaspora/pull/6926)
* Return all contacts in people search [#6951](https://github.com/diaspora/diaspora/pull/6951)
* Make screenreaders read alerts [#6973](https://github.com/diaspora/diaspora/pull/6973)
* Display message when there are no posts in a stream [#6974](https://github.com/diaspora/diaspora/pull/6974)
* Add bootstrap-markdown editor to the publisher [#6551](https://github.com/diaspora/diaspora/pull/6551)
* Don't create notifications for ignored users [#6984](https://github.com/diaspora/diaspora/pull/6984)
* Fetch missing persons when receiving a mention for them [#6992](https://github.com/diaspora/diaspora/pull/6992)

# 0.5.10.2

Update to Rails 4.2.7.1 which fixes [CVE-2016-6316](https://groups.google.com/forum/#!topic/ruby-security-ann/8B2iV2tPRSE) and [CVE-2016-6317](https://groups.google.com/forum/#!topic/ruby-security-ann/WccgKSKiPZA).

# 0.5.10.1

We made a mistake and removed `mysql2` from the `Gemfile.lock` in a recent gem update. Since this could cause some issues for some installations, we decided to release a hotfix.

# 0.5.10.0

## Refactor

* Removed the publisher from a user's photo stream due to various issues [#6851](https://github.com/diaspora/diaspora/pull/6851)
* Don't implicitly ignore missing templateName in app.views.Base [#6877](https://github.com/diaspora/diaspora/pull/6877)

# 0.5.9.1

Update Nokogiri to 1.6.8, which in turn updates libxml2 to 2.9.4 and libxslt to 1.1.29,
addressing a range of security issues. See https://groups.google.com/forum/#!topic/ruby-security-ann/RCHyF5K9Lbc
for more details.

# 0.5.9.0

## Refactor
* Remove unused mentions regex [#6810](https://github.com/diaspora/diaspora/pull/6810)

## Bug fixes
* Fix back to top button not appearing on Webkit browsers [#6782](https://github.com/diaspora/diaspora/pull/6782)
* Don't reset the notification timestamp when marking them as read [#6821](https://github.com/diaspora/diaspora/pull/6821)

## Features

* The sender's diaspora-ID is now shown in invitation mails [#6817](https://github.com/diaspora/diaspora/pull/6817)

# 0.5.8.0

## Refactor
* Sort tag autocompletion by tag name [#6734](https://github.com/diaspora/diaspora/pull/6734)
* Make account deletions faster by adding an index [#6771](https://github.com/diaspora/diaspora/pull/6771)

## Bug fixes
* Fix empty name field when editing aspect names [#6706](https://github.com/diaspora/diaspora/pull/6706)
* Fix internal server error when trying to log out of an expired session [#6707](https://github.com/diaspora/diaspora/pull/6707)
* Only mark unread notifications as read [#6711](https://github.com/diaspora/diaspora/pull/6711)
* Use https for OEmbeds [#6748](https://github.com/diaspora/diaspora/pull/6748)
* Fix birthday issues on leap days [#6738](https://github.com/diaspora/diaspora/pull/6738)

## Features
* Added the footer to conversation pages [#6710](https://github.com/diaspora/diaspora/pull/6710)
* Drop ChromeFrame and display an error page on old IE versions instead [#6751](https://github.com/diaspora/diaspora/pull/6751)

# 0.5.7.1

This security release disables post fetching for relayables. Due to an insecure implementation, fetching of root posts for relayables could allow an attacker to distribute malicious/spoofed/modified posts for any person.

Disabling the fetching will make the current federation a bit less reliable, but for a hotfix, this is the best solution. We will re-enable the fetching in 0.6.0.0 when we moved out the federation into its own library and are able to implement further validation during fetches.

# 0.5.7.0

## Refactor
* Internationalize controller rescue\_from text [#6554](https://github.com/diaspora/diaspora/pull/6554)
* Make mention parsing a bit more robust [#6658](https://github.com/diaspora/diaspora/pull/6658)
* Remove unlicensed images [#6673](https://github.com/diaspora/diaspora/pull/6673)
* Removed unused contacts\_title [#6687](https://github.com/diaspora/diaspora/pull/6687)

## Bug fixes
* Fix plural rules handling more than wanted as "one" [#6630](https://github.com/diaspora/diaspora/pull/6630)
* Fix `suppress_annoying_errors` eating too much errors [#6653](https://github.com/diaspora/diaspora/pull/6653)
* Ensure the rubyzip gem is properly loaded [#6659](https://github.com/diaspora/diaspora/pull/6659)
* Fix mobile registration layout after failed registration [#6677](https://github.com/diaspora/diaspora/pull/6677)
* Fix mirrored names when using a RTL language [#6680](https://github.com/diaspora/diaspora/pull/6680)
* Disable submitting a post multiple times in the mobile UI [#6682](https://github.com/diaspora/diaspora/pull/6682)

## Features
* Keyboard shortcuts now do work on profile pages as well [#6647](https://github.com/diaspora/diaspora/pull/6647/files)
* Add the podmin email address to 500 errors [#6652](https://github.com/diaspora/diaspora/pull/6652)

# 0.5.6.3

Fix evil regression caused by Active Model no longer exposing
`include_root_in_json` in instances.

# 0.5.6.2

* Fix [CVE-2016-0751](https://groups.google.com/forum/#!topic/rubyonrails-security/9oLY_FCzvoc) - Possible Object Leak and Denial of Service attack in Action Pack
* Fix [CVE-2015-7581](https://groups.google.com/forum/#!topic/rubyonrails-security/dthJ5wL69JE) - Object leak vulnerability for wildcard controller routes in Action Pack
* Fix [CVE-2015-7576](https://groups.google.com/forum/#!topic/rubyonrails-security/ANv0HDHEC3k) - Timing attack vulnerability in basic authentication in Action Controller
* Fix [CVE-2016-0752](https://groups.google.com/forum/#!topic/rubyonrails-security/335P1DcLG00) - Possible Information Leak Vulnerability in Action View
* Fix [CVE-2016-0753](https://groups.google.com/forum/#!topic/rubyonrails-security/6jQVC1geukQ) - Possible Input Validation Circumvention in Active Model
* Fix [CVE-2015-7577](https://groups.google.com/forum/#!topic/rubyonrails-security/cawsWcQ6c8g) - Nested attributes rejection proc bypass in Active Record
* Fix [CVE-2015-7579](https://groups.google.com/forum/#!topic/rubyonrails-security/OU9ugTZcbjc) - XSS vulnerability in rails-html-sanitizer
* Fix [CVE-2015-7578](https://groups.google.com/forum/#!topic/rubyonrails-security/uh--W4TDwmI) - Possible XSS vulnerability in rails-html-sanitizer

# 0.5.6.1

* Fix Nokogiri CVE-2015-7499
* Fix unsafe "Remember me" cookies in Devise

# 0.5.6.0

## Refactor
* Add more integration tests with the help of the new diaspora-federation gem [#6539](https://github.com/diaspora/diaspora/pull/6539)

## Bug fixes
* Fix mention autocomplete when pasting the username [#6510](https://github.com/diaspora/diaspora/pull/6510)
* Use and update updated\_at for notifications [#6573](https://github.com/diaspora/diaspora/pull/6573)
* Ensure the author signature is checked when receiving a relayable [#6539](https://github.com/diaspora/diaspora/pull/6539)
* Do not try to display hovercards when logged out [#6587](https://github.com/diaspora/diaspora/pull/6587)

## Features

* Display hovercards without aspect dropdown when logged out [#6603](https://github.com/diaspora/diaspora/pull/6603)
* Add media.ccc.de as a trusted oEmbed endpoint

# 0.5.5.1

* Fix XSS on profile pages
* Bump nokogiri to fix several libxml2 CVEs, see http://www.ubuntu.com/usn/usn-2834-1/

# 0.5.5.0

## Bug fixes
* Redirect to sign in page when a background request fails with 401 [#6496](https://github.com/diaspora/diaspora/pull/6496)
* Correctly skip setting sidekiq logfile on Heroku [#6500](https://github.com/diaspora/diaspora/pull/6500)
* Fix notifications for interactions by non-contacts [#6498](https://github.com/diaspora/diaspora/pull/6498)
* Fix issue where the publisher was broken on profile pages [#6503](https://github.com/diaspora/diaspora/pull/6503)
* Prevent participations being created for invalid interactions [#6552](https://github.com/diaspora/diaspora/pull/6552)
* Improve federation for reshare related interactions [#6481](https://github.com/diaspora/diaspora/pull/6481)

# 0.5.4.0

## Refactor
*  Improve infinite scroll triggering [#6451](https://github.com/diaspora/diaspora/pull/6451)

## Bug fixes
* Skip first getting started step if it looks done already [#6456](https://github.com/diaspora/diaspora/pull/6456)
* Normalize new followed tags and insert them alphabetically [#6454](https://github.com/diaspora/diaspora/pull/6454)
* Add avatar fallback for notification dropdown [#6463](https://github.com/diaspora/diaspora/pull/6463)
* Improve handling of j/k hotkeys [#6462](https://github.com/diaspora/diaspora/pull/6462)
* Fix JS error caused by hovercards [6480](https://github.com/diaspora/diaspora/pull/6480)

## Features
* Show spinner on initial stream load [#6384](https://github.com/diaspora/diaspora/pull/6384)
* Add new moderator role. Moderators can view and act on reported posts [#6351](https://github.com/diaspora/diaspora/pull/6351)
* Only post to the primary tumblr blog [#6386](https://github.com/diaspora/diaspora/pull/6386)
* Always show public photos on profile page [#6398](https://github.com/diaspora/diaspora/pull/6398)
* Expose Unicorn's pid option to our configuration system [#6411](https://github.com/diaspora/diaspora/pull/6411)
* Add stream of all public posts [#6465](https://github.com/diaspora/diaspora/pull/6465)
* Reload stream when clicking on already active one [#6466](https://github.com/diaspora/diaspora/pull/6466)
* Sign in user before evaluating post visibility [#6490](https://github.com/diaspora/diaspora/pull/6490)

# 0.5.3.1

Fix a leak of potentially private profile data to unauthorized users who were sharing with the person
and on a pod that received that data.

# 0.5.3.0

## Refactor
* Drop broken correlations from the admin pages [#6223](https://github.com/diaspora/diaspora/pull/6223)
* Extract PostService from PostsController [#6208](https://github.com/diaspora/diaspora/pull/6208)
* Drop outdated/unused mbp-respond.min.js and mbp-modernizr-custom.js [#6257](https://github.com/diaspora/diaspora/pull/6257)
* Refactor ApplicationController#after\_sign\_out\_path\_for [#6258](https://github.com/diaspora/diaspora/pull/6258)
* Extract StatusMessageService from StatusMessagesController [#6280](https://github.com/diaspora/diaspora/pull/6280)
* Refactor HomeController#toggle\_mobile [#6260](https://github.com/diaspora/diaspora/pull/6260)
* Extract CommentService from CommentsController [#6307](https://github.com/diaspora/diaspora/pull/6307)
* Extract user/profile discovery into the diaspora\_federation-rails gem [#6310](https://github.com/diaspora/diaspora/pull/6310)
* Refactor PostPresenter [#6315](https://github.com/diaspora/diaspora/pull/6315)
* Convert BackToTop to a backbone view [#6279](https://github.com/diaspora/diaspora/pull/6279) and [#6360](https://github.com/diaspora/diaspora/pull/6360)
* Automatically follow the new HQ-Account [#6369](https://github.com/diaspora/diaspora/pull/6369)

## Bug fixes
* Fix indentation and a link title on the default home page [#6212](https://github.com/diaspora/diaspora/pull/6212)
* Bring peeping Tom on the 404 page back [#6226](https://github.com/diaspora/diaspora/pull/6226)
* Fix mobile photos index page [#6243](https://github.com/diaspora/diaspora/pull/6243)
* Fix conversations view with no contacts [#6266](https://github.com/diaspora/diaspora/pull/6266)
* Links in the left sidebar are now clickable on full width [#6267](https://github.com/diaspora/diaspora/pull/6267)
* Guard against passing nil into person\_image\_tag [#6286](https://github.com/diaspora/diaspora/pull/6286)
* Prevent Handlebars from messing up indentation of pre tags [#6339](https://github.com/diaspora/diaspora/pull/6339)
* Fix pagination design on notifications page [#6364](https://github.com/diaspora/diaspora/pull/6364)

## Features

* Implement NodeInfo [#6239](https://github.com/diaspora/diaspora/pull/6239)
* Display original author on reshares of NSFW posts [#6270](https://github.com/diaspora/diaspora/pull/6270)
* Use avatars in hovercards as links to the profile [#6297](https://github.com/diaspora/diaspora/pull/6297)
* Remove avatars of ignored users from stream faces [#6320](https://github.com/diaspora/diaspora/pull/6320)
* New /m route to force the mobile view [#6354](https://github.com/diaspora/diaspora/pull/6354)

# 0.5.2.0

## Refactor
* Update perfect-scrollbar [#6085](https://github.com/diaspora/diaspora/pull/6085)
* Remove top margin for first heading in a post [#6110](https://github.com/diaspora/diaspora/pull/6110)
* Add link to pod statistics in right navigation [#6117](https://github.com/diaspora/diaspora/pull/6117)
* Update to Rails 4.2.3 [#6140](https://github.com/diaspora/diaspora/pull/6140)
* Refactor person related URL generation [#6168](https://github.com/diaspora/diaspora/pull/6168)
* Move webfinger and HCard generation out of the core and embed the `diaspora_federation-rails` gem [#6151](https://github.com/diaspora/diaspora/pull/6151/)
* Refactor rspec tests to to use `let` instead of before blocks [#6199](https://github.com/diaspora/diaspora/pull/6199)
* Refactor tests for EXIF stripping [#6183](https://github.com/diaspora/diaspora/pull/6183)

## Bug fixes
* Precompile facebox images [#6105](https://github.com/diaspora/diaspora/pull/6105)
* Fix wrong closing a-tag [#6111](https://github.com/diaspora/diaspora/pull/6111)
* Fix mobile more-button wording when there are less than 15 posts [#6118](https://github.com/diaspora/diaspora/pull/6118)
* Fix reappearing flash boxes during sign-in [#6146](https://github.com/diaspora/diaspora/pull/6146)
* Capitalize Wiki link [#6193](https://github.com/diaspora/diaspora/pull/6193)

## Features
* Add configuration options for some debug logs [#6090](https://github.com/diaspora/diaspora/pull/6090)
* Send new users a welcome message from the podmin [#6128](https://github.com/diaspora/diaspora/pull/6128)
* Cleanup temporary upload files daily [#6147](https://github.com/diaspora/diaspora/pull/6147)
* Add guid to posts and comments in the user export [#6185](https://github.com/diaspora/diaspora/pull/6185)

# 0.5.1.2

diaspora\* versions prior 0.5.1.2 leaked potentially private profile data (namely the bio, birthday, gender and location fields) to
unauthorized users. While the frontend properly hid them, the backend missed a check to not include them in responses.
Thanks to @cmrd-senya for finding and reporting the issue.

# 0.5.1.1

Update rails to 4.2.2, rack to 1.6.2 and jquery-rails to 4.0.4. This fixes

* [CVE-2015-3226](https://groups.google.com/d/msg/rubyonrails-security/7VlB_pck3hU/3QZrGIaQW6cJ)
* [CVE-2015-3227](https://groups.google.com/d/msg/rubyonrails-security/bahr2JLnxvk/x4EocXnHPp8J)
* [CVE-2015-1840](https://groups.google.com/d/msg/rubyonrails-security/XIZPbobuwaY/fqnzzpuOlA4J)
* [CVE-2015-3225](https://groups.google.com/d/msg/rubyonrails-security/gcUbICUmKMc/qiCotVZwXrMJ)

# 0.5.1.0

## Refactor
* Use Bootstrap modal for new aspect pane [#5850](https://github.com/diaspora/diaspora/pull/5850)
* Use asset helper instead of .css.erb [#5886](https://github.com/diaspora/diaspora/pull/5886)
* Dropped db/seeds.rb [#5896](https://github.com/diaspora/diaspora/pull/5896)
* Drop broken install scripts [#5907](https://github.com/diaspora/diaspora/pull/5907)
* Improve invoking mobile site in the testsuite [#5915](https://github.com/diaspora/diaspora/pull/5915)
* Do not retry a couple of unrecoverable job failures [#5938](https://github.com/diaspora/diaspora/pull/5938) [#5942](https://github.com/diaspora/diaspora/pull/5943)
* Remove some old temporary workarounds [#5964](https://github.com/diaspora/diaspora/pull/5964)
* Remove unused `hasPhotos` and `hasText` functions [#5969](https://github.com/diaspora/diaspora/pull/5969)
* Replace foreman with eye [#5966](https://github.com/diaspora/diaspora/pull/5966)
* Improved handling of reshares with deleted roots [#5968](https://github.com/diaspora/diaspora/pull/5968)
* Remove two unused methods [#5970](https://github.com/diaspora/diaspora/pull/5970)
* Refactored the Logger to add basic logrotating and more useful timestamps [#5975](https://github.com/diaspora/diaspora/pull/5975)
* Gracefully handle mailer failures if a like is already deleted again [#5983](https://github.com/diaspora/diaspora/pull/5983)
* Ensure posts have an author [#5986](https://github.com/diaspora/diaspora/pull/5986)
* Improve the logging messages of Sidekiq messages [#5988](https://github.com/diaspora/diaspora/pull/5988)
* Improve the logging of Eyes output [#5989](https://github.com/diaspora/diaspora/pull/5989)
* Gracefully handle XML parse errors within federation [#5991](https://github.com/diaspora/diaspora/pull/5991)
* Remove zip-zip workaround gem [#6001](https://github.com/diaspora/diaspora/pull/6001)
* Cleanup and reorganize image assets [#6004](https://github.com/diaspora/diaspora/pull/6004)
* Replace vendored assets for facebox by gem [#6005](https://github.com/diaspora/diaspora/pull/6005)
* Improve styling of horizontal ruler in posts [#6016](https://github.com/diaspora/diaspora/pull/6016)
* Increase post titles length to 50 and use configured pod name as title in the atom feed [#6020](https://github.com/diaspora/diaspora/pull/6020)
* Remove deprecated Facebook permissions [#6019](https://github.com/diaspora/diaspora/pull/6019)
* Make used post title lengths more consistent [#6022](https://github.com/diaspora/diaspora/pull/6022)
* Improved logging source [#6041](https://github.com/diaspora/diaspora/pull/6041)
* Gracefully handle duplicate entry while receiving share-visibility in parallel [#6068](https://github.com/diaspora/diaspora/pull/6068)
* Update twitter gem to get rid of deprecation warnings [#6083](https://github.com/diaspora/diaspora/pull/6083)
* Refactor photos federation to get rid of some hacks [#6082](https://github.com/diaspora/diaspora/pull/6082)

## Bug fixes
* Disable auto follow back on aspect deletion [#5846](https://github.com/diaspora/diaspora/pull/5846)
* Fix only sharing flag for contacts that are receiving [#5848](https://github.com/diaspora/diaspora/pull/5848)
* Return 406 when requesting a JSON representation of people/:guid/contacts [#5849](https://github.com/diaspora/diaspora/pull/5849)
* Hide manage services link in the publisher on certain pages [#5854](https://github.com/diaspora/diaspora/pull/5854)
* Fix notification mails for limited posts [#5877](https://github.com/diaspora/diaspora/pull/5877)
* Fix medium and small avatar URLs when using Camo [#5883](https://github.com/diaspora/diaspora/pull/5883)
* Improve output of script/server [#5885](https://github.com/diaspora/diaspora/pull/5885)
* Fix CSS for bold links [#5887](https://github.com/diaspora/diaspora/pull/5887)
* Correctly handle IE8 in the chrome frame middleware [#5878](https://github.com/diaspora/diaspora/pull/5878)
* Fix code reloading for PostPresenter [#5888](https://github.com/diaspora/diaspora/pull/5888)
* Fix closing account from mobile view [#5913](https://github.com/diaspora/diaspora/pull/5913)
* Allow using common custom template for desktop & mobile landing page [#5915](https://github.com/diaspora/diaspora/pull/5915)
* Use correct branding in Atom feed [#5929](https://github.com/diaspora/diaspora/pull/5929)
* Update the configurate gem to avoid issues by missed missing settings keys [#5934](https://github.com/diaspora/diaspora/pull/5934)
* ContactPresenter#full_hash_with_person did not contain relationship information [#5936](https://github.com/diaspora/diaspora/pull/5936)
* Fix inactive user removal not respecting configuration for daily limits [#5953](https://github.com/diaspora/diaspora/pull/5953)
* Fix missing localization of inactive user removal warning emails [#5950](https://github.com/diaspora/diaspora/issues/5950)
* Fix fetching for public post while Webfingering [#5958](https://github.com/diaspora/diaspora/pull/5958)
* Handle empty searchable in HCard gracefully [#5962](https://github.com/diaspora/diaspora/pull/5962)
* Fix a freeze in new post parsing [#5965](https://github.com/diaspora/diaspora/pull/5965)
* Add case insensitive unconfirmed email addresses as authentication key [#5967](https://github.com/diaspora/diaspora/pull/5967)
* Fix liking on single post views when accessed via GUID [#5978](https://github.com/diaspora/diaspora/pull/5978)
* Only return the current_users participation for post interactions [#6007](https://github.com/diaspora/diaspora/pull/6007)
* Fix tag rendering in emails [#6009](https://github.com/diaspora/diaspora/pull/6009)
* Fix the logo in emails [#6013](https://github.com/diaspora/diaspora/pull/6013)
* Disable autocorrect for username on mobile sign in [#6028](https://github.com/diaspora/diaspora/pull/6028)
* Fix broken default avatars in the database [#6014](https://github.com/diaspora/diaspora/pull/6014)
* Only strip text direction codepoints around hashtags [#6067](https://github.com/diaspora/diaspora/issues/6067)
* Fix selected week on admin weekly stats page [#6079](https://github.com/diaspora/diaspora/pull/6079)
* Fix that some unread conversations may be hidden [#6060](https://github.com/diaspora/diaspora/pull/6060)
* Fix photo links in the mobile interface [#6082](https://github.com/diaspora/diaspora/pull/6082)

## Features
* Hide post title of limited post in comment notification email [#5843](https://github.com/diaspora/diaspora/pull/5843)
* More and better environment checks in script/server [#5891](https://github.com/diaspora/diaspora/pull/5891)
* Enable aspect sorting again [#5559](https://github.com/diaspora/diaspora/pull/5559)
* Submit messages in conversations with Ctrl+Enter [#5910](https://github.com/diaspora/diaspora/pull/5910)
* Support syntax highlighting for fenced code blocks [#5908](https://github.com/diaspora/diaspora/pull/5908)
* Added link to diasporafoundation.org to invitation email [#5893](https://github.com/diaspora/diaspora/pull/5893)
* Gracefully handle missing `og:url`s [#5926](https://github.com/diaspora/diaspora/pull/5926)
* Remove private post content from "also commented" mails [#5931](https://github.com/diaspora/diaspora/pull/5931)
* Add a button to follow/unfollow tags to the mobile interface [#5941](https://github.com/diaspora/diaspora/pull/5941)
* Add a "Manage followed tags" page to mass unfollow tags in the mobile interface [#5945](https://github.com/diaspora/diaspora/pull/5945)
* Add popover/tooltip about email visibility to registration/settings page [#5956](https://github.com/diaspora/diaspora/pull/5956)
* Fetch person posts on sharing request [#5960](https://github.com/diaspora/diaspora/pull/5960)
* Introduce 'authorized' configuration option for services [#5985](https://github.com/diaspora/diaspora/pull/5985)
* Added configuration options for log rotating [#5994](https://github.com/diaspora/diaspora/pull/5994)

# 0.5.0.1

Use the correct setting for captcha length instead of defaulting to 1 always.

# 0.5.0.0

## Major Sidekiq update
This release includes a major upgrade of the background processing system Sidekiq. To upgrade cleanly:

1. Stop diaspora*
2. Run `RAILS_ENV=production bundle exec sidekiq` and wait 5-10 minutes, then stop it again (hit `CTRL+C`)
3. Do a normal upgrade of diaspora*
4. Start diaspora*

## Rails 4 - Manual action required
Please edit `config/initializers/secret_token.rb`, replacing `secret_token` with
`secret_key_base`.

```ruby
# Old
Rails.application.config.secret_token = '***********...'

# New
Diaspora::Application.config.secret_key_base = '*************...'
```

You also need to take care to set `RAILS_ENV` and to clear the cache while precompiling assets: `RAILS_ENV=production bundle exec rake tmp:cache:clear assets:precompile`

## Supported Ruby versions
This release drops official support for the Ruby 1.9 series. This means we will no longer test against this Ruby version or take care to choose libraries
that work with it. However that doesn't mean we won't accept patches that improve running diaspora* on it.

At the same time we adopt support for the Ruby 2.1 series and recommend running on the latest Ruby version of that branch. We continue to support the Ruby 2.0
series and run our comprehensive test suite against it.

## Change in defaults.yml
The default for including jQuery from a CDN has changed. If you want to continue to include it from a CDN, please explicitly set the `jquery_cdn` setting to `true` in diaspora.yml.

## Change in database.yml
For MySQL databases, replace `charset: utf8` with `encoding: utf8mb4` and  change `collation` from `utf8_bin` to `utf8mb4_bin` in the file `config/database.yml`.
This is enables full UTF8 support (4bytes characters), including standard emoji characters.
See `database.yml.example` for reference.
Please make sure to stop Diaspora prior running this migration!

## Experimental chat feature
This release adds experimental integration with XMPP for real-time chat. Please see  [our wiki](https://wiki.diasporafoundation.org/Vines) for further informations.

## Change in statistics.json schema
The way services are shown in the `statistics.json` route is changing. The keys relating to showing whether services are enabled or not are moving to their own container as `"services": {....}`, instead of having them all in the root level of the JSON.

The keys will still be available in the root level within the 0.5 release. The old keys will be removed in the 0.6 release.

## New maintenance feature to automatically expire inactive accounts
Removing of old inactive users can now be done automatically by background processing. The amount of inactivity is set by `after_days`. A warning email will be sent to the user and after an additional `warn_days`, the account will be automatically closed.

This maintenance is not enabled by default. Podmins can enable it by for example copying over the new settings under `settings.maintenance` to their `diaspora.yml` file and setting it enabled. The default setting is to expire accounts that have been inactive for 2 years (no login).

## Camo integration to proxy external assets
It is now possible to enable an automatic proxying of external assets, for example images embedded via Markdown or OpenGraph thumbnails loaded from insecure third party servers through a [Camo proxy](https://github.com/atmos/camo).

This is disabled by default since it requires the installation of additional packages and might cause some traffic. Check the [wiki page](https://wiki.diasporafoundation.org/Installation/Camo) for more information and detailed installation instructions.

## Paypal unhosted button and currency
Podmins can now set the currency for donations, and use an unhosted button if they can't use
a hosted one. Note: you need to **copy the new settings from diaspora.yml.example to your
diaspora.yml file**. The existing settings from 0.4.x and before will not work any more.

## Custom splash page changes
diaspora* no longer adds a `div.container` to wrap custom splash pages. This adds the ability for podmins to write home pages using Bootstrap's fluid design. Podmins who added a custom splash page in `app/views/home/_show.{html,mobile}.haml` need to wrap the contents into a `div.container` to keep the old design. You will find updated examples [in our wiki](https://wiki.diasporafoundation.org/Custom_splash_page).

## Refactor
* Redesign contacts page [#5153](https://github.com/diaspora/diaspora/pull/5153)
* Improve profile page design on mobile [#5084](https://github.com/diaspora/diaspora/pull/5084)
* Port test suite to RSpec 3 [#5170](https://github.com/diaspora/diaspora/pull/5170)
* Port tag stream to Bootstrap [#5138](https://github.com/diaspora/diaspora/pull/5138)
* Consolidate migrations, if you need a migration prior 2013, checkout the latest release in the 0.4.x series first [#5173](https://github.com/diaspora/diaspora/pull/5173)
* Add tests for mobile sign up [#5185](https://github.com/diaspora/diaspora/pull/5185)
* Display new conversation form on conversations/index [#5178](https://github.com/diaspora/diaspora/pull/5178)
* Port profile page to Backbone [#5180](https://github.com/diaspora/diaspora/pull/5180)
* Pull punycode.js from rails-assets.org [#5263](https://github.com/diaspora/diaspora/pull/5263)
* Redesign profile page and port to Bootstrap [#4657](https://github.com/diaspora/diaspora/pull/4657)
* Unify stream selection links in the left sidebar [#5271](https://github.com/diaspora/diaspora/pull/5271)
* Refactor schema of statistics.json regarding services [#5296](https://github.com/diaspora/diaspora/pull/5296)
* Pull jquery.idle-timer.js from rails-assets.org [#5310](https://github.com/diaspora/diaspora/pull/5310)
* Pull jquery.placeholder.js from rails-assets.org [#5299](https://github.com/diaspora/diaspora/pull/5299)
* Pull jquery.textchange.js from rails-assets.org [#5297](https://github.com/diaspora/diaspora/pull/5297)
* Pull jquery.hotkeys.js from rails-assets.org [#5368](https://github.com/diaspora/diaspora/pull/5368)
* Reduce amount of useless background job retries and pull public posts when missing [#5209](https://github.com/diaspora/diaspora/pull/5209)
* Updated Weekly User Stats admin page to show data for the most recent week including reversing the order of the weeks in the drop down to show the most recent. [#5331](https://github.com/diaspora/diaspora/pull/5331)
* Convert some cukes to RSpec tests [#5289](https://github.com/diaspora/diaspora/pull/5289)
* Hidden overflow for long names on tag pages [#5279](https://github.com/diaspora/diaspora/pull/5279)
* Always reshare absolute root of a post [#5276](https://github.com/diaspora/diaspora/pull/5276)
* Convert remaining SASS stylesheets to SCSS [#5342](https://github.com/diaspora/diaspora/pull/5342)
* Update rack-protection [#5403](https://github.com/diaspora/diaspora/pull/5403)
* Cleanup diaspora.yml [#5426](https://github.com/diaspora/diaspora/pull/5426)
* Replace `opengraph_parser` with `open_graph_reader` [#5462](https://github.com/diaspora/diaspora/pull/5462)
* Make sure conversations without any visibilities left are deleted [#5478](https://github.com/diaspora/diaspora/pull/5478)
* Change tooltip for delete button in conversations view [#5477](https://github.com/diaspora/diaspora/pull/5477)
* Replace a modifier-rescue with a specific rescue [#5491](https://github.com/diaspora/diaspora/pull/5491)
* Port contacts page to backbone [#5473](https://github.com/diaspora/diaspora/pull/5473)
* Replace CSS vendor prefixes automatically [#5532](https://github.com/diaspora/diaspora/pull/5532)
* Use sentence case consistently throughout UI [#5588](https://github.com/diaspora/diaspora/pull/5588)
* Hide sign up button when registrations are disabled [#5612](https://github.com/diaspora/diaspora/pull/5612)
* Standardize capitalization throughout the UI [#5588](https://github.com/diaspora/diaspora/pull/5588)
* Display photos on the profile page as thumbnails [#5521](https://github.com/diaspora/diaspora/pull/5521)
* Unify not connected pages (sign in, sign up, forgot password) [#5391](https://github.com/diaspora/diaspora/pull/5391)
* Port remaining stream pages to Bootstrap [#5715](https://github.com/diaspora/diaspora/pull/5715)
* Port notification dropdown to Backbone [#5707](https://github.com/diaspora/diaspora/pull/5707) [#5761](https://github.com/diaspora/diaspora/pull/5761)
* Add rounded corners for avatars [#5733](https://github.com/diaspora/diaspora/pull/5733)
* Move registration form to a partial [#5764](https://github.com/diaspora/diaspora/pull/5764)
* Add tests for liking and unliking posts [#5741](https://github.com/diaspora/diaspora/pull/5741)
* Rewrite slide effect in conversations as css transition for better performance [#5776](https://github.com/diaspora/diaspora/pull/5776)
* Various cleanups and improvements in the frontend code [#5781](https://github.com/diaspora/diaspora/pull/5781) [#5769](https://github.com/diaspora/diaspora/pull/5769) [#5763](https://github.com/diaspora/diaspora/pull/5763) [#5762](https://github.com/diaspora/diaspora/pull/5762) [#5758](https://github.com/diaspora/diaspora/pull/5758) [#5755](https://github.com/diaspora/diaspora/pull/5755) [#5747](https://github.com/diaspora/diaspora/pull/5747) [#5734](https://github.com/diaspora/diaspora/pull/5734) [#5786](https://github.com/diaspora/diaspora/pull/5786) [#5768](https://github.com/diaspora/diaspora/pull/5798)
* Add specs and validations to the role model [#5792](https://github.com/diaspora/diaspora/pull/5792)
* Replace 'Make something' text by diaspora ball logo on registration page [#5743](https://github.com/diaspora/diaspora/pull/5743)

## Bug fixes
* orca cannot see 'Add Contact' button [#5158](https://github.com/diaspora/diaspora/pull/5158)
* Move submit button to the right in conversations view [#4960](https://github.com/diaspora/diaspora/pull/4960)
* Handle long URLs and titles in OpenGraph descriptions [#5208](https://github.com/diaspora/diaspora/pull/5208)
* Fix deformed getting started popover [#5227](https://github.com/diaspora/diaspora/pull/5227)
* Use correct locale for invitation subject [#5232](https://github.com/diaspora/diaspora/pull/5232)
* Initial support for IDN emails
* Fix services settings reported by statistics.json [#5256](https://github.com/diaspora/diaspora/pull/5256)
* Only collapse empty comment box [#5328](https://github.com/diaspora/diaspora/pull/5328)
* Fix pagination for people/guid/contacts [#5304](https://github.com/diaspora/diaspora/pull/5304)
* Fix poll creation on Bootstrap pages [#5334](https://github.com/diaspora/diaspora/pull/5334)
* Show error message on invalid reset password attempt [#5325](https://github.com/diaspora/diaspora/pull/5325)
* Fix translations on mobile password reset pages [#5318](https://github.com/diaspora/diaspora/pull/5318)
* Handle unset user agent when signing out [#5316](https://github.com/diaspora/diaspora/pull/5316)
* More robust URL parsing for oEmbed and OpenGraph [#5347](https://github.com/diaspora/diaspora/pull/5347)
* Fix Publisher doesn't expand while uploading images [#3098](https://github.com/diaspora/diaspora/issues/3098)
* Drop unneeded and too open crossdomain.xml
* Fix hidden aspect dropdown on getting started page [#5407](https://github.com/diaspora/diaspora/pulls/5407)
* Fix a few issues on Bootstrap pages [#5401](https://github.com/diaspora/diaspora/pull/5401)
* Improve handling of the `more` link on mobile stream pages [#5400](https://github.com/diaspora/diaspora/pull/5400)
* Fix prefilling publisher after getting started [#5442](https://github.com/diaspora/diaspora/pull/5442)
* Fix overflow in profile sidebar [#5450](https://github.com/diaspora/diaspora/pull/5450)
* Fix code overflow in SPV and improve styling for code tags [#5422](https://github.com/diaspora/diaspora/pull/5422)
* Correctly validate if local recipients actually want to receive a conversation [#5449](https://github.com/diaspora/diaspora/pull/5449)
* Improve consistency of poll answer ordering [#5471](https://github.com/diaspora/diaspora/pull/5471)
* Fix broken aspect selectbox on asynchronous search results [#5488](https://github.com/diaspora/diaspora/pull/5488)
* Replace %{third_party_tools} by the appropriate hyperlink in tags FAQ [#5509](https://github.com/diaspora/diaspora/pull/5509)
* Repair downloading the profile image from Facebook [#5493](https://github.com/diaspora/diaspora/pull/5493)
* Fix localization of post and comment timestamps on mobile [#5482](https://github.com/diaspora/diaspora/issues/5482)
* Fix mobile JS loading to quieten errors. Fixes also service buttons on mobile bookmarklet.
* Don't error out when adding a too long location to the profile [#5614](https://github.com/diaspora/diaspora/pull/5614)
* Correctly decrease unread count for conversations [#5646](https://github.com/diaspora/diaspora/pull/5646)
* Fix automatic scroll for conversations [#5646](https://github.com/diaspora/diaspora/pull/5646)
* Fix missing translation on privacy settings page [#5671](https://github.com/diaspora/diaspora/pull/5671)
* Fix code overflow for the mobile website [#5675](https://github.com/diaspora/diaspora/pull/5675)
* Strip Unicode format characters prior post processing [#5680](https://github.com/diaspora/diaspora/pull/5680)
* Disable email notifications for closed user accounts [#5640](https://github.com/diaspora/diaspora/pull/5640)
* Total user statistic no longer includes closed accounts [#5041](https://github.com/diaspora/diaspora/pull/5041)
* Don't add a space when rendering a mention [#5711](https://github.com/diaspora/diaspora/pull/5711)
* Fix flickering hovercards [#5714](https://github.com/diaspora/diaspora/pull/5714) [#5876](https://github.com/diaspora/diaspora/pull/5876)
* Improved stripping markdown in post titles [#5730](https://github.com/diaspora/diaspora/pull/5730)
* Remove border from reply form for conversations [#5744](https://github.com/diaspora/diaspora/pull/5744)
* Fix overflow for headings, blockquotes and other elements [#5731](https://github.com/diaspora/diaspora/pull/5731)
* Correct photo count on profile page [#5751](https://github.com/diaspora/diaspora/pull/5751)
* Fix mobile sign up from an invitation [#5754](https://github.com/diaspora/diaspora/pull/5754)
* Set max-width for tag following button on tag page [#5752](https://github.com/diaspora/diaspora/pull/5752)
* Display error messages for failed password change [#5580](https://github.com/diaspora/diaspora/pull/5580)
* Display correct error message for too long tags [#5783](https://github.com/diaspora/diaspora/pull/5783)
* Fix displaying reshares in the stream on mobile [#5790](https://github.com/diaspora/diaspora/pull/5790)
* Remove bottom margin from lists that are the last element of a post. [#5721](https://github.com/diaspora/diaspora/pull/5721)
* Fix pagination design on conversations page [#5791](https://github.com/diaspora/diaspora/pull/5791)
* Prevent inserting posts into the wrong stream [#5838](https://github.com/diaspora/diaspora/pull/5838)
* Update help section [#5857](https://github.com/diaspora/diaspora/pull/5857) [#5859](https://github.com/diaspora/diaspora/pull/5859)
* Fix asset precompilation check in script/server [#5863](https://github.com/diaspora/diaspora/pull/5863)
* Convert MySQL databases to utf8mb4 [#5530](https://github.com/diaspora/diaspora/pull/5530) [#5624](https://github.com/diaspora/diaspora/pull/5624) [#5865](https://github.com/diaspora/diaspora/pull/5865)
* Don't upcase labels on mobile sign up/sign in [#5872](https://github.com/diaspora/diaspora/pull/5872)

## Features
* Don't pull jQuery from a CDN by default [#5105](https://github.com/diaspora/diaspora/pull/5105)
* Better character limit message [#5151](https://github.com/diaspora/diaspora/pull/5151)
* Remember whether a AccountDeletion was performed [#5156](https://github.com/diaspora/diaspora/pull/5156)
* Increased the number of notifications shown in drop down bar to 15 [#5129](https://github.com/diaspora/diaspora/pull/5129)
* Increase possible captcha length [#5169](https://github.com/diaspora/diaspora/pull/5169)
* Display visibility icon in publisher aspects dropdown [#4982](https://github.com/diaspora/diaspora/pull/4982)
* Add a link to the reported comment in the admin panel [#5337](https://github.com/diaspora/diaspora/pull/5337)
* Strip search query from leading and trailing whitespace [#5317](https://github.com/diaspora/diaspora/pull/5317)
* Add the "network" key to statistics.json and set it to "Diaspora" [#5308](https://github.com/diaspora/diaspora/pull/5308)
* Infinite scrolling in the notifications dropdown [#5237](https://github.com/diaspora/diaspora/pull/5237)
* Maintenance feature to automatically expire inactive accounts [#5288](https://github.com/diaspora/diaspora/pull/5288)
* Add LibreJS markers to JavaScript [5320](https://github.com/diaspora/diaspora/pull/5320)
* Ask for confirmation when leaving a submittable publisher [#5309](https://github.com/diaspora/diaspora/pull/5309)
* Allow page-specific styling via individual CSS classes [#5282](https://github.com/diaspora/diaspora/pull/5282)
* Change diaspora logo in the header on hover [#5355](https://github.com/diaspora/diaspora/pull/5355)
* Display diaspora handle in search results [#5419](https://github.com/diaspora/diaspora/pull/5419)
* Show a message on the ignored users page when there are none [#5434](https://github.com/diaspora/diaspora/pull/5434)
* Truncate too long OpenGraph descriptions [#5387](https://github.com/diaspora/diaspora/pull/5387)
* Make the source code URL configurable [#5410](https://github.com/diaspora/diaspora/pull/5410)
* Prefill publisher on the tag pages [#5442](https://github.com/diaspora/diaspora/pull/5442)
* Don't include the content of non-public posts into notification mails [#5494](https://github.com/diaspora/diaspora/pull/5494)
* Allow to set unhosted button and currency for paypal donation [#5452](https://github.com/diaspora/diaspora/pull/5452)
* Add followed tags in the mobile menu [#5468](https://github.com/diaspora/diaspora/pull/5468)
* Replace Pagedown with markdown-it [#5526](https://github.com/diaspora/diaspora/pull/5526)
* Do not truncate notification emails anymore [#4342](https://github.com/diaspora/diaspora/issues/4342)
* Allows users to export their data in gzipped JSON format from their user settings page [#5499](https://github.com/diaspora/diaspora/pull/5499)
* Strip EXIF data from newly uploaded images [#5510](https://github.com/diaspora/diaspora/pull/5510)
* Hide user setting if the community spotlight is not enabled on the pod [#5562](https://github.com/diaspora/diaspora/pull/5562)
* Add HTML view for pod statistics [#5464](https://github.com/diaspora/diaspora/pull/5464)
* Added/Moved hide, block user, report and delete button in SPV [#5547](https://github.com/diaspora/diaspora/pull/5547)
* Added keyboard shortcuts r(reshare), m(expand Post), o(open first link in post) [#5602](https://github.com/diaspora/diaspora/pull/5602)
* Added dropdown to add/remove people from/to aspects in mobile view [#5594](https://github.com/diaspora/diaspora/pull/5594)
* Dynamically compute minimum and maximum valid year for birthday field [#5639](https://github.com/diaspora/diaspora/pull/5639)
* Show hovercard on mentions [#5652](https://github.com/diaspora/diaspora/pull/5652)
* Make help sections linkable [#5667](https://github.com/diaspora/diaspora/pull/5667)
* Add invitation link to contacts page [#5655](https://github.com/diaspora/diaspora/pull/5655)
* Add year to notifications page [#5676](https://github.com/diaspora/diaspora/pull/5676)
* Give admins the ability to lock & unlock accounts [#5643](https://github.com/diaspora/diaspora/pull/5643)
* Add reshares to the stream view immediately [#5699](https://github.com/diaspora/diaspora/pull/5699)
* Update and improve help section [#5665](https://github.com/diaspora/diaspora/pull/5665), [#5706](https://github.com/diaspora/diaspora/pull/5706)
* Expose participation controls in the stream view [#5511](https://github.com/diaspora/diaspora/pull/5511)
* Reimplement photo export [#5685](https://github.com/diaspora/diaspora/pull/5685)
* Add participation controls in the single post view [#5722](https://github.com/diaspora/diaspora/pull/5722)
* Display polls on reshares [#5782](https://github.com/diaspora/diaspora/pull/5782)
* Remove footer from stream pages [#5816](https://github.com/diaspora/diaspora/pull/5816)

# 0.4.1.3

* Update Redcarped, fixes [OSVDB-120415](http://osvdb.org/show/osvdb/120415).

# 0.4.1.2

* Update Rails, fixes [CVE-2014-7818](https://groups.google.com/forum/#!topic/rubyonrails-security/dCp7duBiQgo).

# 0.4.1.1

* Fix XSS issue in poll questions [#5274](https://github.com/diaspora/diaspora/issues/5274)

# 0.4.1.0

## New 'Terms of Service' feature and template

This release brings a new ToS feature that allows pods to easily display to users the terms of service they are operating on. This feature is not enabled by default. If you want to enable it, please add under `settings` in `config/diaspora.yml` the following and restart diaspora. If in doubt see `config/diaspora.yml.example`:

    terms:
      enable: true

When enabled, the footer and sidebar will have a link to terms page, and sign up will have a disclaimer indicating that creating an account means the user accepts the terms of use.

While the project itself doesn't restrict what kind of terms pods run on, we realize not all podmins want to spend time writing them from scratch. Thus there is a basic ToS template included that will be used unless a custom one available.

To modify (or completely rewrite) the terms template, create a file called `app/views/terms/terms.haml` or `app/views/terms/terms.erb` and it will automatically replace the default template, which you can find at `app/views/terms/default.haml`.

There are also two configuration settings to customize the terms (when using the default template). These are optional.

* `settings.terms.jurisdiction` - indicate here in which country or state any legal disputes are handled.
* `settings.terms.minimum_age` - indicate here if you want to show a minimum required age for creating an account.

## Rake task to email users

There is a new Rake task `podmin:admin_mail` available to allow podmins to easily send news and notices to users. The rake task triggers emails via the normal diaspora mailer mechanism (so they are embedded in the standard template) and takes the following parameters:

1) Users definition

* `all` - all users in the database (except deleted)
* `active_yearly` - users logged in within the last year
* `active_monthly` - users logged in within the last month
* `active_halfyear` - users logged in within the last 6 months

2) Path to message file

* Give here a path to a HTML or plain text file that contains the message.

3) Subject

* A subject for the email

Example shell command (depending on your environment);

`RAILS_ENV=production bundle exec rake podmin:admin_mail['active_monthly','./message.html','Important message from pod']`

Read more about [specifying arguments to Rake tasks](http://stackoverflow.com/a/825832/1489738).

## Refactor
* Port help pages to Bootstrap [#5050](https://github.com/diaspora/diaspora/pull/5050)
* Refactor Notification#notify [#4945](https://github.com/diaspora/diaspora/pull/4945)
* Port getting started to Bootstrap [#5057](https://github.com/diaspora/diaspora/pull/5057)
* Port people search page to Bootstrap [#5077](https://github.com/diaspora/diaspora/pull/5077)
* Clarify explanations and defaults in diaspora.yml.example [#5088](https://github.com/diaspora/diaspora/pull/5088)
* Consistent header spacing on Bootstrap pages [#5108](https://github.com/diaspora/diaspora/pull/5108)
* Port settings pages (account, profile, privacy, services) to Bootstrap [#5039](https://github.com/diaspora/diaspora/pull/5039)
* Port contacts and community spotlight pages to Bootstrap [#5118](https://github.com/diaspora/diaspora/pull/5118)
* Redesign login page [#5112](https://github.com/diaspora/diaspora/pull/5112)
* Change mark read link on notifications page [#5141](https://github.com/diaspora/diaspora/pull/5141)

## Bug fixes
* Fix hiding of poll publisher on close [#5029](https://github.com/diaspora/diaspora/issues/5029)
* Fix padding in user menu [#5047](https://github.com/diaspora/diaspora/pull/5047)
* Fix self-XSS when renaming an aspect [#5048](https://github.com/diaspora/diaspora/pull/5048)
* Fix live updating when renaming an aspect [#5049](https://github.com/diaspora/diaspora/pull/5049)
* Use double quotes when embedding translations into Javascript [#5055](https://github.com/diaspora/diaspora/issues/5055)
* Fix regression in mobile sign-in ([commit](https://github.com/diaspora/diaspora/commit/4a2836b108f8a9eb6f46ca58cfcb7b23f40bb076))
* Set mention notification as read when viewing post [#5006](https://github.com/diaspora/diaspora/pull/5006)
* Set sharing notification as read when viewing profile [#5009](https://github.com/diaspora/diaspora/pull/5009)
* Ensure a consistent border on text input elements [#5069](https://github.com/diaspora/diaspora/pull/5069)
* Escape person name in contacts json returned by Conversations#new
* Make sure all parts of the hovercard are always in front [#5188](https://github.com/diaspora/diaspora/pull/5188)

## Features
* Port admin pages to bootstrap, polish user search results, allow accounts to be closed from the backend [#5046](https://github.com/diaspora/diaspora/pull/5046)
* Reference Salmon endpoint in Webfinger XRD to aid discovery by alternative implementations [#5062](https://github.com/diaspora/diaspora/pull/5062)
* Change minimal birth year for the birthday field to 1910 [#5083](https://github.com/diaspora/diaspora/pull/5083)
* Add scrolling thumbnail switcher in the lightbox [#5102](https://github.com/diaspora/diaspora/pull/5102)
* Add help section about keyboard shortcuts [#5100](https://github.com/diaspora/diaspora/pull/5100)
* Automatically add poll answers as needed [#5109](https://github.com/diaspora/diaspora/pull/5109)
* Add Terms of Service as an option for podmins, includes base template [#5104](https://github.com/diaspora/diaspora/pull/5104)
* Add rake task to send a mail to all users [#5111](https://github.com/diaspora/diaspora/pull/5111)
* Expose which services are configured in /statistics.json [#5121](https://github.com/diaspora/diaspora/pull/5121)
* In filtered notification views, replace "Mark all as read" with "Mark shown as read" [#5122](https://github.com/diaspora/diaspora/pull/5122)
* When ignoring a user remove his posts from the stream instantly [#5127](https://github.com/diaspora/diaspora/pull/5127)
* Allow to delete photos from the pictures stream [#5131](https://github.com/diaspora/diaspora/pull/5131)

# 0.4.0.1

## Bug fixes

* Fix performance regression on stream loading with MySQL/MariaDB database backends [#5014](https://github.com/diaspora/diaspora/issues/5014)
* Fix issue with post reporting [#5017](https://github.com/diaspora/diaspora/issues/5017)

# 0.4.0.0

## Ensure account deletions are run

A regression caused accounts deletions to not properly perform in some cases, see [#4792](https://github.com/diaspora/diaspora/issues/4792).
To ensure these are reexecuted properly, please run `RAILS_ENV=production bundle exec rake accounts:run_deletions`
after you've upgraded.

## Change in guid generation

This version will break federation to pods running on versions prior 0.1.1.0.

Read more in [#4249](https://github.com/diaspora/diaspora/pull/4249) and [#4883](https://github.com/diaspora/diaspora/pull/4883)

## Refactor
* Drop number of followers from tags page [#4717](https://github.com/diaspora/diaspora/pull/4717)
* Remove some unused beta code [#4738](https://github.com/diaspora/diaspora/pull/4738)
* Style improvements for SPV, use original author's avatar for reshares [#4754](https://github.com/diaspora/diaspora/pull/4754)
* Update image branding to the new decided standard [#4702](https://github.com/diaspora/diaspora/pull/4702)
* Consistent naming of conversations and messages [#4756](https://github.com/diaspora/diaspora/pull/4756)
* Improve stream generation time [#4769](https://github.com/diaspora/diaspora/pull/4769)
* Port help pages to backbone [#4768](https://github.com/diaspora/diaspora/pull/4768)
* Add participants to conversations menu [#4656](https://github.com/diaspora/diaspora/pull/4656)
* Update forgot_password and reset_password pages [#4707](https://github.com/diaspora/diaspora/pull/4707)
* Change jQuery CDN to jquery.com from googleapis.com [#4765](https://github.com/diaspora/diaspora/pull/4765)
* Update to jQuery 10
* Port publisher and bookmarklet to Bootstrap [#4678](https://github.com/diaspora/diaspora/pull/4678)
* Improve search page, add better indications [#4794](https://github.com/diaspora/diaspora/pull/4794)
* Port notifications and hovercards to Bootstrap [#4814](https://github.com/diaspora/diaspora/pull/4814)
* Replace .rvmrc by .ruby-version and .ruby-gemset [#4854](https://github.com/diaspora/diaspora/pull/4855)
* Reorder and reword items on user settings page [#4912](https://github.com/diaspora/diaspora/pull/4912)
* SPV: Improve padding and interaction counts [#4426](https://github.com/diaspora/diaspora/pull/4426)
* Remove auto 'mark as read' for notifications [#4810](https://github.com/diaspora/diaspora/pull/4810)
* Improve set read/unread in notifications dropdown [#4869](https://github.com/diaspora/diaspora/pull/4869)
* Refactor publisher: trigger events for certain actions, introduce 'disabled' state [#4932](https://github.com/diaspora/diaspora/pull/4932)

## Bug fixes
* Fix user account deletion [#4953](https://github.com/diaspora/diaspora/pull/4953) and [#4963](https://github.com/diaspora/diaspora/pull/4963)
* Fix email body language when invite a friend [#4832](https://github.com/diaspora/diaspora/issues/4832)
* Improve time agos by updating the plugin [#4281](https://github.com/diaspora/diaspora/pull/4281)
* Do not add a space after adding a mention [#4767](https://github.com/diaspora/diaspora/issues/4767)
* Fix active user statistics by saving a last seen timestamp for users [#4802](https://github.com/diaspora/diaspora/pull/4802)
* Render HTML in atom user feed [#4835](https://github.com/diaspora/diaspora/pull/4835)
* Fix plaintext mode of Mentionable [#4831](https://github.com/diaspora/diaspora/pull/4831)
* Fixed Atom Feed Error if reshared Post is deleted [#4841](https://github.com/diaspora/diaspora/pull/4841)
* Show hovercards in the notification drop-down for users on the same pod [#4843](https://github.com/diaspora/diaspora/pull/4843)
* The photo stream no longer repeats after the last photo [#4787](https://github.com/diaspora/diaspora/pull/4787)
* Fix avatar alignment for hovercards in the notifications dropdown [#4853](https://github.com/diaspora/diaspora/pull/4853)
* Do not parse hashtags inside Markdown links [#4856](https://github.com/diaspora/diaspora/pull/4856)
* Restore comment textarea content after revealing more comments [#4858](https://github.com/diaspora/diaspora/pull/4858)
* OpenGraph: don't make description into links [#4708](https://github.com/diaspora/diaspora/pull/4708)
* Don't cut off long tags in stream posts [#4878](https://github.com/diaspora/diaspora/pull/4878)
* Do not replace earlier appearances of the name while mentioning somebody [#4882](https://github.com/diaspora/diaspora/pull/4882)
* Catch exceptions when trying to decode an invalid URI [#4889](https://github.com/diaspora/diaspora/pull/4889)
* Redirect to the stream when switching the mobile publisher to desktop [#4917](https://github.com/diaspora/diaspora/pull/4917)
* Parsing mention witch contain in username special characters [#4919](https://github.com/diaspora/diaspora/pull/4919)
* Do not show your own hovercard [#4758](https://github.com/diaspora/diaspora/pull/4758)
* Hit Nominatim via https [#4968](https://github.com/diaspora/diaspora/pull/4968)

## Features
* You can report a single post or comment by clicking the correct icon in the controler section [#4517](https://github.com/diaspora/diaspora/pull/4517) [#4781](https://github.com/diaspora/diaspora/pull/4781)
* Add permalinks for comments [#4577](https://github.com/diaspora/diaspora/pull/4577)
* New menu for the mobile version [#4673](https://github.com/diaspora/diaspora/pull/4673)
* Added comment count to statistic to enable calculations of posts/comments ratios [#4799](https://github.com/diaspora/diaspora/pull/4799)
* Add filters to notifications controller [#4814](https://github.com/diaspora/diaspora/pull/4814)
* Activate hovercards in SPV and conversations [#4870](https://github.com/diaspora/diaspora/pull/4870)
* Added possibility to conduct polls [#4861](https://github.com/diaspora/diaspora/pull/4861) [#4894](https://github.com/diaspora/diaspora/pull/4894) [#4897](https://github.com/diaspora/diaspora/pull/4897) [#4899](https://github.com/diaspora/diaspora/pull/4899)

# 0.3.0.3

* Bump Rails to 3.2.17, fixes CVE-2014-0081, CVE-2014-0082. For more information see http://weblog.rubyonrails.org/2014/2/18/Rails_3_2_17_4_0_3_and_4_1_0_beta2_have_been_released/

# 0.3.0.2

## Bug fixes
* Use youtube HTTPS scheme for oEmbed [#4743](https://github.com/diaspora/diaspora/pull/4743)
* Fix infinite scroll on aspect streams [#4747](https://github.com/diaspora/diaspora/pull/4747)
* Fix hovercards [#4782](https://github.com/diaspora/diaspora/pull/4782)
* Bump kaminari to fix admin panel [#4714](https://github.com/diaspora/diaspora/issues/4714)

# 0.3.0.1

## Bug fixes
* Fix regression caused by using after_commit with nested '#save' which lead to an infinite recursion [#4715](https://github.com/diaspora/diaspora/issues/4715)
* Save textarea value before rendering comments when clicked 'show more...' [#4858](https://github.com/diaspora/diaspora/pull/4858)

# 0.3.0.0

## Pod statistics
A new feature [has been added](https://github.com/diaspora/diaspora/pull/4602) to allow pods to report extra statistics. Automatically after this code change, the route /statistics.json contains some basic data that was also available before via page headers (pod name, version, status of signups). But also, optionally podmins can enable user and post counts in the diaspora.yml configuration file. The counts are by default switched off, so if you want to report the total user, active user and local post counts, please edit your diaspora.yml configuration with the example values in diaspora.yml.example and uncomment the required lines as indicated.

## Ruby 2.0

We now recommend using Ruby 2.0 with Diaspora. If you're using RVM make sure to run:
```bash
rvm get stable
rvm install 2.0.0
cd ~/diaspora
git pull
cd - && cd ..
```

For more details see https://wiki.diasporafoundation.org/Updating

## Refactor
* Remove old SPV code [#4612](https://github.com/diaspora/diaspora/pull/4612)
* Move non-model federation stuff into lib/ [#4363](https://github.com/diaspora/diaspora/pull/4363)
* Build a color palette to uniform color usage [#4437](https://github.com/diaspora/diaspora/pull/4437) [#4469](https://github.com/diaspora/diaspora/pull/4469) [#4479](https://github.com/diaspora/diaspora/pull/4479)
* Rename bitcoin_wallet_id setting to bitcoin_address [#4485](https://github.com/diaspora/diaspora/pull/4485)
* Batch insert posts into stream collection for a small speedup [#4341](https://github.com/diaspora/diaspora/pull/4351)
* Ported fileuploader to Backbone and refactored publisher views [#4480](https://github.com/diaspora/diaspora/pull/4480)
* Refactor 404.html, fix [#4078](https://github.com/diaspora/diaspora/issues/4078)
* Remove the (now useless) last post link from the user profile. [#4540](https://github.com/diaspora/diaspora/pull/4540)
* Refactor ConversationsController, move query building to User model. [#4547](https://github.com/diaspora/diaspora/pull/4547)
* Refactor the Twitter service model [#4387](https://github.com/diaspora/diaspora/pull/4387)
* Refactor ConversationsController#create, move more stuff to User model [#4551](https://github.com/diaspora/diaspora/pull/4551)
* Refactor MessagesController#create, move stuff to User model [#4556](https://github.com/diaspora/diaspora/pull/4556)
* Reorder the left bar side menu to put the stream first [#4569](https://github.com/diaspora/diaspora/pull/4569)
* Improve notifications and conversations views design on mobile [#4593](https://github.com/diaspora/diaspora/pull/4593)
* Slight redesign of mobile publisher [#4604](https://github.com/diaspora/diaspora/pull/4604)
* Port conversations to Bootstrap [#4622](https://github.com/diaspora/diaspora/pull/4622)
* Remove participants popover and improve conversations menu [#4644](https://github.com/diaspora/diaspora/pull/4644)
* Refactor right side bar [#4793](https://github.com/diaspora/diaspora/pull/4793)

## Bug fixes
* Highlight down arrow at the user menu on hover [#4441](https://github.com/diaspora/diaspora/pull/4441)
* Make invite code input width consistent across browsers [#4448](https://github.com/diaspora/diaspora/pull/4448)
* Fix style of contacts in profile sidebar [#4451](https://github.com/diaspora/diaspora/pull/4451)
* Fix profile mobile when logged out [#4464](https://github.com/diaspora/diaspora/pull/4464)
* Fix preview with more than one mention [#4450](https://github.com/diaspora/diaspora/issues/4450)
* Fix size of images in the SPV [#4471](https://github.com/diaspora/diaspora/pull/4471)
* Adjust 404 message description to not leak logged out users if a post exists or not [#4477](https://github.com/diaspora/diaspora/pull/4477)
* Make I18n system more robust against missing keys in pluralization data
* Prevent overflow of too long strings in the single post view [#4487](https://github.com/diaspora/diaspora/pull/4487)
* Disable submit button in sign up form after submission to avoid email already exists error [#4506](https://github.com/diaspora/diaspora/issues/4506)
* Do not pull the 404 pages assets from Amazon S3 [#4501](https://github.com/diaspora/diaspora/pull/4501)
* Fix counter background does not cover more than 2 digits on profile [#4499](https://github.com/diaspora/diaspora/issues/4499)
* Fix commenting upon submission fail [#4005] (https://github.com/diaspora/diaspora/issues/4005)
* Fix date color and alignment in the notifications dropdown [#4502](https://github.com/diaspora/diaspora/issues/4502)
* Add a white background to images shown in the lightbox [#4475](https://github.com/diaspora/diaspora/issues/4475)
* Refactor getting_started page, test if facebook is available, fix [#4520](https://github.com/diaspora/diaspora/issues/4520)
* Avoid publishing empty posts [#4542](https://github.com/diaspora/diaspora/pull/4542)
* Force comments sort order in mobile spv [#4578](https://github.com/diaspora/diaspora/pull/4578)
* Fix getting started page for mobile [#4536](https://github.com/diaspora/diaspora/pull/4536)
* Refactor mobile header, fix [#4579](https://github.com/diaspora/diaspora/issues/4579)
* Fix avatar display on mobile profile [#4591](https://github.com/diaspora/diaspora/pull/4591)
* Add lightbox to unauthenticated header, fix [#4432](https://github.com/diaspora/diaspora/issues/4432)
* Fix "more picture" indication (+n) on mobile by adding a link on the indication [#4592](https://github.com/diaspora/diaspora/pull/4592)
* Display errors when photo upload fails [#4509](https://github.com/diaspora/diaspora/issues/4509)
* Fix posting to Twitter by correctly catching exception [#4627](https://github.com/diaspora/diaspora/issues/4627)
* Change "Show n more comments"-link, fix [#3119](https://github.com/diaspora/diaspora/issues/3119)
* Specify Firefox version for Travis-CI [#4623](https://github.com/diaspora/diaspora/pull/4623)
* Remove location when publisher is cleared by user
* On signup form errors, don't empty previous values by user, fix [#4663](https://github.com/diaspora/diaspora/issues/4663)
* Remove background from badges in header [#4692](https://github.com/diaspora/diaspora/issues/4692)

## Features
* Add oEmbed content to the mobile view [#4343](https://github.com/diaspora/diaspora/pull/4353)
* One click to select the invite URL [#4447](https://github.com/diaspora/diaspora/pull/4447)
* Disable "mark all as read" link if all notifications are read [#4463](https://github.com/diaspora/diaspora/pull/4463)
* Collapse aspect list and tag followings list when switching to other views [#4462](https://github.com/diaspora/diaspora/pull/4462)
* Highlight current stream in left sidebar [#4445](https://github.com/diaspora/diaspora/pull/4445)
* Added ignore user icon on user profile [#4417](https://github.com/diaspora/diaspora/pull/4417)
* Improve the management of the contacts visibility settings in an aspect [#4567](https://github.com/diaspora/diaspora/pull/4567)
* Add actions on aspects on the contact page [#4570](https://github.com/diaspora/diaspora/pull/4570)
* Added a statistics route with general pod information, and if enabled in pod settings, total user, half year/monthly active users and local post counts [#4602](https://github.com/diaspora/diaspora/pull/4602)
* Add indication about markdown formatting in the publisher [#4589](https://github.com/diaspora/diaspora/pull/4589)
* Add captcha to signup form [#4659](https://github.com/diaspora/diaspora/pull/4659)
* Update Underscore.js 1.3.1 to 1.5.2, update Backbone.js 0.9.2 to 1.1.0 [#4662](https://github.com/diaspora/diaspora/pull/4662)
* Display more than 8 pictures on a post [#4796](https://github.com/diaspora/diaspora/pull/4796)

## Gem updates
Added:
* atomic (1.1.14)
* bcrypt-ruby (3.1.2)
* backbone-on-rails (1.1.0.0)
* devise thread_safe (0.1)
* eco (1.0.0)
* eco-source (1.1.0.rc.1)
* ejs (1.1.1)
* galetahub-simple_captcha (0.1.5)
* thread_safe (0.1.3)
* zip-zip (0.2)

Removed:
* bcrypt-ruby
* rb-kqueue
* slim
* temple

Updated:
* acts_as_api 0.4.1 -> 0.4.2
* capybara 2.1.0 -> 2.2.1
* celluloid (0.13.0 -> 0.15.2
* chunky_png 1.2.8 -> 1.2.9
* client_side_validations 3.2.5 -> 3.2.6
* coderay 1.0.9 -> 1.1.0
* connection_pool 1.0.0 -> 1.2.0
* crack 0.4.0 -> 0.4.1
* cucumber 1.3.5 -> 1.3.10
* cucumber-rails 1.3.1 -> 1.4.0
* database_cleaner 1.1.0 -> 1.2.0
* devise 3.0.2 -> 3.2.2
* diff-lcs 1.2.4 -> 1.2.5
* ethon 0.5.12 -> 0.6.2
* excon 0.25.3 -> 0.31.0
* factory_girl 4.2.0 -> 4.3.0
* factory_girl_rails 4.2.0 -> 4.3.0
* faraday 0.8.8 -> 0.8.9
* ffi 1.9.0 -> 1.9.3
* fog 1.14.0 -> 1.19.0
* foreigner 1.4.2 -> 1.6.1
* fuubar 1.1.1 -> 1.3.2
* gherkin 2.12.0 -> 2.12.2
* guard 1.8.2 -> 2.2.5
* guard-cucumber 1.4.0 -> 1.4.1
* guard-rspec 3.0.2 -> 4.2.4
* haml 4.0.3 -> 4.0.5
* i18n-inflector-rails 1.0.6 -> 1.0.7
* json 1.8.0 -> 1.8.1
* jwt 0.1.8 -> 0.1.10
* kaminari 0.14.1 -> 0.15.0
* kgio 2.8.0 -> 2.8.1
* listen 1.2.2 -> 2.4.0
* mini_magick 3.6.0 -> 3.7.0
* mini_profile 0.5.1 -> 0.5.2
* mobile-fu 1.2.1 -> 1.2.2
* multi_json 1.7.9 -> 1.8.4
* multi_test 0.0.2 -> 0.0.3
* mysql2 0.3.13 -> 0.3.14
* net-ssh 2.6.8 -> 2.7.0
* nokogiri 1.6.0 -> 1.6.1
* omniauth-facebook 1.4.1 -> 1.6.0
* omniauth-twitter 1.0.0 -> 1.0.1
* orm_adapter 0.4.0 -> 0.5.0
* pry 0.9.12.2 -> 0.9.12.4
* rack-google-analytics 0.11.0 -> 0.14.0
* rack-rewrite 1.3.3 -> 1.5.0
* rails_autolink 1.1.0 -> 1.1.5
* raindrops 0.11.0 -> 0.12.0
* rake 10.1.0 -> 10.1.1
* rb-fsevent 0.9.3 -> 0.9.4
* rb-inotify 0.9.0 -> 0.9.3
* redis 3.0.4 -> 3.0.6
* redis-namespace 1.3.0 -> 1.4.1
* rspec 2.13.0 -> 2.14.1
* rspec-core 2.13.1 -> 2.14.7
* rspec-expectations 2.13.0 -> 2.14.4
* rspec-mocks 2.13.1 -> 2.14.4
* rspec-rails 2.13.2 -> 2.14.1
* ruby-oembed 0.8.8 -> 0.8.9
* ruby-progressbar 1.1.1 -> 1.4.0
* selenium-webdriver 2.34.0 -> 2.39.0
* sidekiq 2.11.1 -> 2.17.2
* slop 3.4.6 -> 3.4.7
* spork 1.0.0rc3 -> 1.0.0rc4
* strong_parameters 0.2.1 -> 0.2.2
* test_after_commit 0.2.0 -> 0.2.2
* timers 1.0.0 -> 1.1.0
* timecop 0.6.1 -> 0.7.1
* typhoeus 0.6.3 -> 0.6.7
* unicorn 4.6.3 -> 4.8.0
* webmock 1.13.0 -> 1.16.1
* will_paginate 3.0.4 -> 3.0.5

# 0.2.0.1

* Bump rails to version 3.2.16, fixes several security issues, see http://weblog.rubyonrails.org/2013/12/3/Rails_3_2_16_and_4_0_2_have_been_released/
* Bump recommended Ruby version to 1.9.3-p484, see https://www.ruby-lang.org/en/news/2013/11/22/heap-overflow-in-floating-point-parsing-cve-2013-4164/

# 0.2.0.0

**Attention:** This release includes a potentially long running migration! However it should be safe to run this while keeping your application servers on.

## Refactor
* Service and ServiceController, general code reorg to make it cleaner/+ testable/+ extensible [#4344](https://github.com/diaspora/diaspora/pull/4344)
* Background actual mailing when sending invitations [#4069](https://github.com/diaspora/diaspora/issues/4069)
* Set the current user on the client side through gon [#4028](https://github.com/diaspora/diaspora/issues/4028)
* Update sign out route to a DELETE request [#4068](https://github.com/diaspora/diaspora/issues/4068)
* Convert all ActivityStreams::Photo to StatusMessages and drop ActivityStreams::Photo [#4144](https://github.com/diaspora/diaspora/issues/4144)
* Port the Rails application to strong_parameters in preparation to the upgrade to Rails 4 [#4143](https://github.com/diaspora/diaspora/issues/4143)
* Refactor left bar side menu, improve tag autosuggestion design [#4271](https://github.com/diaspora/diaspora/issues/4271), [#4316](https://github.com/diaspora/diaspora/pull/4316)
* Extract and factorize the header css in a new file, fix ugly header in registration [#4389](https://github.com/diaspora/diaspora/pull/4389)
* Move contact list on profile to profile information, show user his own contacts on profile [#4360](https://github.com/diaspora/diaspora/pull/4360)
* Refactor metas, HTML is now valid [#4356](https://github.com/diaspora/diaspora/pull/4356)
* Improve sharing message and mention/message buttons on profile [#4374](https://github.com/diaspora/diaspora/pull/4374)

## Bug fixes
* Check twitter write access before adding/authorizing it for a user. [#4124](https://github.com/diaspora/diaspora/issues/4124)
* Don't focus comment form on 'show n more comments' [#4265](https://github.com/diaspora/diaspora/issues/4265)
* Do not render mobile photo view for none-existing photos [#4194](https://github.com/diaspora/diaspora/issues/4194)
* Render markdown content for prettier email subjects and titles [#4182](https://github.com/diaspora/diaspora/issues/4182)
* Disable invite button after sending invite [#4173](https://github.com/diaspora/diaspora/issues/4173)
* Fix pagination for people list on the tag stream page [#4245](https://github.com/diaspora/diaspora/pull/4245)
* Fix missing timeago tooltip in conversations [#4257](https://github.com/diaspora/diaspora/issues/4257)
* Fix link to background image [#4289](https://github.com/diaspora/diaspora/pull/4289)
* Fix Facebox icons 404s when called from Backbone
* Fix deleting a post from Facebook [#4290](https://github.com/diaspora/diaspora/pull/4290)
* Display notices a little bit longer to help on sign up errors [#4274](https://github.com/diaspora/diaspora/issues/4274)
* Fix user contact sharing/receiving [#4163](https://github.com/diaspora/diaspora/issues/4163)
* Change image to ajax-loader when closing lightbox [#3229](https://github.com/diaspora/diaspora/issues/3229)
* Fix pointer cursor on the file upload button [#4349](https://github.com/diaspora/diaspora/pull/4349)
* Resize preview button [#4355](https://github.com/diaspora/diaspora/pull/4355)
* Fix compability problem with MySQL 5.6 [#4312](https://github.com/diaspora/diaspora/issues/4312)
* Don't collapse the post preview [#4346](https://github.com/diaspora/diaspora/issues/4346)
* Improve mobile usability [#4354](https://github.com/diaspora/diaspora/pull/4354)
* Descending text is no longer cut off in orange welcome banner [#4377](https://github.com/diaspora/diaspora/issues/4377)
* Adjust Facebook character limit to reality [#4380](https://github.com/diaspora/diaspora/issues/4380)
* Restore truncated URLs when posting to Twitter [#4211](https://github.com/diaspora/diaspora/issues/4211)
* Fix mobile search tags [#4392](https://github.com/diaspora/diaspora/issues/4392)
* Remove placeholders for name fields in settings (no more Sofaer) [#4385](https://github.com/diaspora/diaspora/pull/4385)
* Problems with layout the registration page for mobile. [#4396](https://github.com/diaspora/diaspora/issues/4396)
* Do not display photos in the background in the SPV [#4407](https://github.com/diaspora/diaspora/pull/4407)
* Fix mobile view of deleted reshares [#4397](https://github.com/diaspora/diaspora/issues/4397)
* Fix the overlapping of embedded youtube videos [#2943](https://github.com/diaspora/diaspora/issues/2943)
* Fix opacity of control icons [#4414](https://github.com/diaspora/diaspora/issues/4414/)
* Add hover state to header icons [#4436](https://github.com/diaspora/diaspora/pull/4436)
* Fix check icon regression on contacts page [#4440](https://github.com/diaspora/diaspora/pull/4440)
* Do not leak non public photos
* Fix check icon alignment in aspect dropdown [#4443](https://github.com/diaspora/diaspora/pull/4443)

## Features
* Admin: add option to find users under 13 (COPPA) [#4252](https://github.com/diaspora/diaspora/pull/4252)
* Show the user if a contact is sharing with them when viewing their profile page [#2948](https://github.com/diaspora/diaspora/issues/2948)
* Made Unicorn timeout configurable and increased the default to 90 seconds
* Follow DiasporaHQ upon account creation is now configurable to another account [#4278](https://github.com/diaspora/diaspora/pull/4278)
* Use first header as title in the single post view, when possible [#4256](https://github.com/diaspora/diaspora/pull/4256)
* Close publisher when clicking on the page outside of it [#4282](https://github.com/diaspora/diaspora/pull/4282)
* Deleting a post deletes it from Tumblr too [#4331](https://github.com/diaspora/diaspora/pull/4331)
* OpenGraph support [#4215](https://github.com/diaspora/diaspora/pull/4215)
* Added Wordpress service ability for posts. [#4321](https://github.com/diaspora/diaspora/pull/4321)
* Implement tag search autocomplete in header search box [#4169](https://github.com/diaspora/diaspora/issues/4169)
* Uncheck 'make contacts visible to each other' by default when adding new aspect. [#4343](https://github.com/diaspora/diaspora/issues/4343)
* Add possibility to ask for Bitcoin donations [#4375](https://github.com/diaspora/diaspora/pull/4375)
* Remove posts, comments and private conversations from the mobile site. [#4408](https://github.com/diaspora/diaspora/pull/4408) [#4409](https://github.com/diaspora/diaspora/pull/4409)
* Added a link to user photos and thumbnails are shown in the left side bar [#4347](https://github.com/diaspora/diaspora/issues/4347)
* Rework the single post view [#4410](https://github.com/diaspora/diaspora/pull/4410)
* Add aspect modification on contacts page, close [#4397](https://github.com/diaspora/diaspora/issues/4397)
* Add help page [#4405](https://github.com/diaspora/diaspora/issues/4405)

## Gem updates

* Added entypo-rails, mini_portile, multi_test, omniauth-wordpress, opengraph_parser, strong_parameters, test_after_commit
* addressable 2.3.4 -> 2.3.5
* asset_sync 0.5.4 -> 1.0.0
* bcrypt-ruby 3.0.1 -> 3.1.1
* capybara 1.1.3 -> 2.1.0
* carrierwave 0.8.0 -> 0.9.0
* coffee-script-source 1.6.2 -> 1.6.3
* cucumber 1.3.2 -> 1.3.5
* database_cleaner 1.0.1 -> 1.1.0
* devise 2.1.3 -> 3.0.2
* excon 0.23.0 -> 0.25.3
* faraday 0.8.7 -> 0.8.8
* fixture_builder 0.3.5 -> 0.3.6
* fog 1.12.1 -> 1.14.0
* font-awesome-rails 3.1.1.3 -> 3.2.1.2
* foreigner 1.4.1 -> 1.4.2
* guard 1.8.0 -> 1.8.2
* guard-rspec 3.0.1 -> 3.0.2
* guard-spork 1.5.0 -> 1.5.1
* i18n-inflector 2.6.6 -> 2.6.7
* listen 1.2.0 -> 1.2.2
* lumberjack 1.0.3 -> 1.0.4
* method_source 0.8.1 -> 0.8.2
* multi_json 1.7.6 -> 1.7.8
* mysql2 0.3.11 -> 0.3.13
* net-scp 1.1.1 -> 1.1.2
* net-ssh 2.6.7 -> 2.6.8
* nokogiri 1.5.9 -> 1.6.0
* omniauth-twitter 0.0.16 -> 1.0.0
* pg 0.15.1 -> 0.16.0
* rails-i18n 0.7.3 -> 0.7.4
* rake 10.0.4 -> 10.1.0
* redcarpet 2.3.0 -> 3.0.0
* remotipart 1.0.5 -> 1.2.1
* safe_yaml 0.9.3 -> 0.9.5
* sass 3.2.9 -> 3.2.10
* selenium-webdriver 2.32.1 -> 2.34.0
* sinon-rails 1.4.2.1 -> 1.7.3
* slop 3.4.5 -> 3.4.6
* temple 0.6.5 -> 0.6.6
* twitter 4.7.0 -> 4.8.1
* uglifier 2.1.1 -> 2.1.2
* unicorn 4.6.2 -> 4.6.3
* warden 1.2.1 -> 1.2.3
* webmock 1.11.0 -> 1.13.0
* xpath 0.1.4 -> 2.0.0

# 0.1.1.0

## Refactor

* Refactored config/ directory [#4144](https://github.com/diaspora/diaspora/pull/4145).
* Drop misleading fallback donation form. [Proposal](https://www.loomio.org/discussions/1045?proposal=2722)
* Update Typhoeus to 0.6.3 and refactor HydraWrapper. [#4162](https://github.com/diaspora/diaspora/pull/4162)
* Bump recomended Ruby version to 1.9.3-p448, see [Ruby news](http://www.ruby-lang.org/en/news/2013/06/27/hostname-check-bypassing-vulnerability-in-openssl-client-cve-2013-4073/).
* Remove length restriciton on GUIDs in the database schema [#4249](https://github.com/diaspora/diaspora/pull/4249)

## Bug fixes

* Fix deletelabel icon size regression after sprites [$4180](https://github.com/diaspora/diaspora/issues/4180)
* Don't use Pathname early to circumvent some rare initialization errors [#3816](https://github.com/diaspora/diaspora/issues/3816)
* Don't error out in script/server if git is unavailable.
* Fix post preview from tag pages [#4157](https://github.com/diaspora/diaspora/issues/4157)
* Fix tags ordering in chrome [#4133](https://github.com/diaspora/diaspora/issues/4133)
* Fix src URL for oEmbed iFrame [#4178](https://github.com/diaspora/diaspora/pull/4178)
* Add back-to-top button on tag and user pages [#4185](https://github.com/diaspora/diaspora/issues/4185)
* Fix reopened issue by changing the comment/post submit keyboard sortcut to ctrl+enter from shift+enter [#3897](https://github.com/diaspora/diaspora/issues/3897)
* Show medium avatar in hovercard [#4203](https://github.com/diaspora/diaspora/pull/4203)
* Fix posting to Twitter [#2758](https://github.com/diaspora/diaspora/issues/2758)
* Don't show hovercards for current user in comments [#3999](https://github.com/diaspora/diaspora/issues/3999)
* Replace mentions of out-of-aspect people with markdown links [#4161](https://github.com/diaspora/diaspora/pull/4161)
* Unify hide and ignore [#3828](https://github.com/diaspora/diaspora/issues/3828)
* Remove alpha branding [#4196](https://github.com/diaspora/diaspora/issues/4196)
* Fix dynamic loading of asset_sync
* Fix login for short passwords [#4123](https://github.com/diaspora/diaspora/issues/4123)
* Add loading indicator on tag pages, remove the second one from the profile page [#4041](https://github.com/diaspora/diaspora/issues/4041)
* Leaving the `to` field blank when sending a private message causes a server error [#4227](https://github.com/diaspora/diaspora/issues/4227)
* Fix hashtags that start a line when posting to Facebook or Twitter [#3768](https://github.com/diaspora/diaspora/issues/3768) [#4154](https://github.com/diaspora/diaspora/issues/4154)
* Show avatar of recent user in conversation list [#4237](https://github.com/diaspora/diaspora/issues/4237)
* Private message fails if contact not entered correctly [#4210](https://github.com/diaspora/diaspora/issues/4210)

## Features

* Deleting a post that was shared to Twitter now deletes it from Twitter too [#4156](https://github.com/diaspora/diaspora/pull/4156)
* Improvement on how participants are displayed on each conversation without opening it [#4149](https://github.com/diaspora/diaspora/pull/4149)

## Gem updates

* acts-as-taggable-on 2.4.0 -> 2.4.1
* configurate 0.0.7 -> 0.0.8
* database_cleaner 0.9.1 -> 1.0.1
* fog 1.10.1 -> 1.12.1
* fuubar 1.10 -> 1.1.1
* gon 4.1.0 -> 4.1.1
* guard-rspec 2.5.3 -> 3.0.1
* haml 4.0.2 -> 4.0.3
* json 1.7.7 -> 1.8.0
* mini_magick 3.5 -> 3.6.0
* mobile-fu 1.1.1 -> 1.2.1
* rack-cors 0.2.7 -> 0.2.8
* rails_admin 0.4.7 -> 0.4.9
* rails_autolink 1.0.9 -> 1.1.0
* redcarpet 2.2.2 -> 2.3.0
* rspec-rails 2.13.0 -> 2.13.2
* slim 1.3.8 -> 1.3.9
* twitter 4.6.2 -> 4.7.0
* typhoeus 0.3.3 -> 0.6.3
* uglifier 2.0.1 -> 2.1.1
* webmock 1.8.11 -> 1.11.0


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
* Attempt to stabilize federation of attached photos (fix [#3033](https://github.com/diaspora/diaspora/issues/3033)  [#3940](https://github.com/diaspora/diaspora/pull/3940) )
* Refactor develop install script [#4111](https://github.com/diaspora/diaspora/pull/4111)
* Remove special hacks for supporting Ruby 1.8 [#4113](https://github.com/diaspora/diaspora/pull/4139)
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
* Send profile alongside notification [#3976](https://github.com/diaspora/diaspora/issues/3976)
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
* Fix posting to Facebook and Tumblr. Have a look at the updated [services guide](http://wiki.diasporafoundation.org/Integrating_Other_Social_Networks) for new Facebook instructions.
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

Copy over config/diaspora.yml.example to config/diaspora.yml and migrate your settings! An updated Heroku guide including basic hints on howto migrate is [here](http://wiki.diasporafoundation.org/Installing_on_Heroku).

The new configuration system allows all possible settings to be overriden by environment variables. This makes it possible to deploy heroku without checking any credentials into git. Read the top of `config/diaspora.yml.example` for an explanation on how to convert the setting names to environment variables.

### Environment variable changes:

#### deprecated

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
