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

Here is the PGP key for exploits@joindiaspora.com:
-----BEGIN PGP PUBLIC KEY BLOCK-----
Version: GnuPG v1.4.11 (Darwin)

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
mnv9hQc6McLTP15uISdt5hIXBLs=
=6qWa
-----END PGP PUBLIC KEY BLOCK-----

