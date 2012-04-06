# Diaspora

Welcome to the Diaspora project, the privacy aware, personally controlled, do-it-all, open source social
network. [Diaspora Project](http://diasporaproject.org)

************************
Diaspora is currently going through a huge refactoring push, the code is changing fast!
If you want to do something big, reach out on IRC or the mailing list first, so you can contribute effectively <3333
************************

**THIS IS ALPHA SOFTWARE AND SHOULD BE TREATED ACCORDINGLY.**
**IT IS FUN TO GET RUNNING, BUT EXPECT THINGS TO BE BROKEN.**

[![Build Status](https://secure.travis-ci.org/diaspora/diaspora.png)](http://travis-ci.org/diaspora/diaspora)
[![Dependency Status](https://gemnasium.com/diaspora/diaspora.png?travis)](https://gemnasium.com/diaspora/diaspora)

**TL;DR**

## Are you a user?
You can get an account on [many Diaspora pods](http://podupti.me), or sign up for an invite
at the pod run by the original development team at https://joindiaspora.com

## Are you a developer?

Read on for how to get started.

We need you to fill out a
[contributor agreement form](https://spreadsheets.google.com/a/joindiaspora.com/spreadsheet/viewform?formkey=dFdRTnY0TGtfaklKQXZNUndsMlJ2eGc6MQ)
before we can accept your patches.  This dual license agreement allows
us to release limited pieces of Diaspora under the MIT license.  You can find it
[here](https://spreadsheets.google.com/a/joindiaspora.com/spreadsheet/viewform?formkey=dFdRTnY0TGtfaklKQXZNUndsMlJ2eGc6MQ).


## Installation Guides

We have guides for pod admins (called podmins) [here](https://github.com/diaspora/diaspora/wiki/Installation-Guides).


## Contributing to Diaspora

Information on contributing to the Diaspora project can be found on the wiki. You can check our [Issue tracker (bugs)](https://github.com/diaspora/diaspora/issues), learn how we [work with git](http://github.com/diaspora/diaspora/wiki/Git-Workflow), and [become more familiar with our system](https://github.com/diaspora/diaspora/wiki/Developers)



Here are a few good places to start:

- Take a look at the [issue tracker](https://github.com/diaspora/diaspora/issues) and pick a bug.
Write a spec for it, so it's easy for another developer to fix it.

Catches must be tested, and all your tests should be green, 
unless you're marking an existing bug, before a pull request is sent.
Unit tests should be in Rspec, Javascript tests should be in Jasmine, and integration tests should be in Cucumber.

Please make your changes in a branch to ensure that new commits to your master are 
not included in the pull request, and to make it easier for us to merge your commits.

Please do not rebase our tree into yours.
See [here](http://www.mail-archive.com/dri-devel@lists.sourceforge.net/msg39091.html)
for when to rebase.


## Resources

Here is our [bug tracker](https://github.com/diaspora/diaspora/issues) and our
[roadmap](https://github.com/diaspora/diaspora/wiki/Roadmap). Also, you can
find see what the core team is up to [here](http://www.pivotaltracker.com/projects/61641).


Ongoing discussion:

- [Diaspora Developer Google Group](http://groups.google.com/group/diaspora-dev)
- [Diaspora Discussion Google Group](http://groups.google.com/group/diaspora-discuss)
- [#diaspora IRC channel](irc://irc.freenode.net/#diaspora)
  ([join via the web client](http://webchat.freenode.net?channels=diaspora))
- [#diaspora-dev IRC channel](irc://irc.freenode.net/#diaspora-dev)
  ([join via the web client](http://webchat.freenode.net?channels=diaspora-dev))

General info and updates about the project can be found on
[our blog](http://blog.joindiaspora.com),
[our devblog](http://devblog.joindiaspora.com),
[and on Twitter](http://twitter.com/joindiaspora).
Also, be sure to join the official [mailing list](http://groups.google.com/group/diaspora-dev).

If you wish to contact us privately about any exploits in Diaspora you may
find, you can email
[exploits@joindiaspora.com](mailto:exploits@joindiaspora.com), [corresponding public key (keyID: 77485064)](http://pgp.mit.edu:11371/pks/lookup?op=vindex&search=0xCC6CAED977485064).
