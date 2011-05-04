# Diaspora

The privacy aware, personally controlled, do-it-all, open source social
network.

**THIS IS ALPHA SOFTWARE AND SHOULD BE TREATED ACCORDINGLY.**
**IT IS FUN TO GET RUNNING, BUT EXPECT THINGS TO BE BROKEN.**

## Installation instructions

Installation instructions are [here](http://github.com/diaspora/diaspora/wiki/Installing-and-Running-Diaspora).

Thanks for helping battle test Diaspora.
Please report any bugs you see at [bugs.joindiaspora.com](http://bugs.joindiaspora.com).

## Contributing to Diaspora

You can find an introduction to the source code [here](http://github.com/diaspora/diaspora/wiki/An-Introduction-to-the-Diaspora-Source).
Bugs and pending features are on our [issue tracker](http://bugs.joindiaspora.com). 
A step-by-step guide to development using git can be found [here](http://github.com/diaspora/diaspora/wiki/Git-Workflow).

Here are a few good places to start:

- Run "rake spec" to run our [Rspec](http://blog.davidchelimsky.net/2007/05/14/an-introduction-to-rspec-part-i/) 
unit test suite.

- Run "rake cucumber" to run our [Cucumber](http://rubylearning.com/blog/2010/10/05/outside-in-development/)
integration test suite.  As you can see, we need more integration tests.  Pick a feature and write one!

- Take a look at the [issue tracker](http://bugs.joindiaspora.com) and pick a bug.
Write a spec for it, so it's easy for another developer to fix it.

Patches must be tested, and all your tests should be green, 
unless you're marking an existing bug, before a pull request is sent.
Unit tests should be in Rspec, and integration tests should be in Cucumber.

Please make your changes in a branch to ensure that new commits to your master are 
not included in the pull request, and to make it easier for us to merge your commits.

Please do not rebase our tree into yours.
See [here](http://www.mail-archive.com/dri-devel@lists.sourceforge.net/msg39091.html)
for when to rebase.

We need you to fill out a
[contributor agreement form](https://spreadsheets.google.com/a/joindiaspora.com/viewform?formkey=dGI2cHA3ZnNHLTJvbm10LUhXRTJjR0E6MQ&theme=0AX42CRMsmRFbUy1iOGYwN2U2Mi1hNWU0LTRlNjEtYWMyOC1lZmU4ODg1ODc1ODI&ifq)
before we can accept your patches.  The agreement gives Diaspora joint
ownership of the patch so the copyright isn't scattered.  You can find it
[here](https://spreadsheets.google.com/a/joindiaspora.com/viewform?formkey=dGI2cHA3ZnNHLTJvbm10LUhXRTJjR0E6MQ&theme=0AX42CRMsmRFbUy1iOGYwN2U2Mi1hNWU0LTRlNjEtYWMyOC1lZmU4ODg1ODc1ODI&ifq).
We're currently working on revising it more details on what we're going for can be found [here](http://blog.joindiaspora.com/licensing.html).

## Resources

Here is our [bug tracker](http://bugs.joindiaspora.com) and our
[roadmap](https://github.com/diaspora/diaspora/wiki/Roadmap). Also, you can
find see what the core team is up to [here](http://www.pivotaltracker.com/projects/61641).


Ongoing discussion:

- [Diaspora Developer Google Group](http://groups.google.com/group/diaspora-dev)
- [Diaspora Discussion Google Group](http://groups.google.com/group/diaspora-discuss)
- [Diaspora Q&A site](http://diaspora.shapado.com/)
- [Diasproa on Get Satisfaction](http://getsatisfaction.com/diaspora/)
- [#diaspora IRC channel](irc://irc.freenode.net/#diaspora)
  ([join via the web client](http://webchat.freenode.net?channels=diaspora))
- [#diaspora-dev IRC channel](irc://irc.freenode.net/#diaspora-dev)
  ([join via the web client](http://webchat.freenode.net?channels=diaspora-dev))

More general info and updates about the project can be found on
[our blog](http://blog.joindiaspora.com),
[and on Twitter](http://twitter.com/joindiaspora).
Also, be sure to join the official [mailing list](http://eepurl.com/Vebk).

If you wish to contact us privately about any exploits in Diaspora you may
find, you can email
[exploits@joindiaspora.com](mailto:exploits@joindiaspora.com).
