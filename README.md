# Diaspora

The privacy aware, personally controlled, do-it-all, open source social
network.

**DISCLAIMER: THIS IS PRE-ALPHA SOFTWARE AND SHOULD BE TREATED ACCORDINGLY.**
**PLEASE, DO NOT RUN IN PRODUCTION. IT IS FUN TO GET RUNNING, BUT EXPECT THINGS
TO BE BROKEN**

Initial installation instructions are [here](http://github.com/diaspora/diaspora/wiki/Installing-and-Running-Diaspora).

We are continuing to build features and improve the code base.
When we think it is ready for general use, we will post more final
instructions.

## Commit Guidlines

You are welcome to contribute, add to and extend Diaspora however you see fit.  We
will do our best to incorporate everything that meets our guidelines.

Please do not rebase our tree into yours.
See [here](http://www.mail-archive.com/dri-devel@lists.sourceforge.net/msg39091.html)
for when to rebase.

All commits must be tested, and all your tests should be green
before a pull request is sent.  Please write your tests in Rspec.

GEMS: We would like to keep external dependencies unduplicated.  We're using
Nokogiri, Mongomapper, and EM::HttpRequest as much as possible.  We have a few
gems in the project we'd rather not use, but if you can, use dependencies we
already have.

We need you to fill out a
[contributor agreement form](https://spreadsheets.google.com/a/joindiaspora.com/viewform?formkey=dGI2cHA3ZnNHLTJvbm10LUhXRTJjR0E6MQ&theme=0AX42CRMsmRFbUy1iOGYwN2U2Mi1hNWU0LTRlNjEtYWMyOC1lZmU4ODg1ODc1ODI&ifq)
before we can accept your patches.  The agreement gives Diaspora joint
ownership of the patch so the copyright isn't scattered.  You can find it
[here](https://spreadsheets.google.com/a/joindiaspora.com/viewform?formkey=dGI2cHA3ZnNHLTJvbm10LUhXRTJjR0E6MQ&theme=0AX42CRMsmRFbUy1iOGYwN2U2Mi1hNWU0LTRlNjEtYWMyOC1lZmU4ODg1ODc1ODI&ifq).

## Resources

We are maintaining a
[public tracker project](http://www.pivotaltracker.com/projects/61641)
and a
[roadmap](https://github.com/diaspora/diaspora/wiki/Roadmap). Also, you can
file [bug reports](https://github.com/diaspora/diaspora/issues) right here on
github.

Ongoing discussion:

- [Diaspora Developer Google Group](http://groups.google.com/group/diaspora-dev)
- [Diaspora Discussion Google Group](http://groups.google.com/group/diaspora-discuss)
- [Diaspora Q&A site](http://diaspora.shapado.com/)
- [#diaspora-dev IRC channel](irc://irc.freenode.net/#diaspora-dev)
  ([join via the web client](http://webchat.freenode.net?channels=diaspora-dev))

More general info and updates about the project can be found on:
[Our blog](http://joindiaspora.com),
[and on Twitter](http://twitter.com/joindiaspora).
Also, be sure to join the official [mailing list](http://http://eepurl.com/Vebk).

If you wish to contact us privately about any exploits in Diaspora you may
find, you can email
[exploits@joindiaspora.com](mailto:exploits@joindiaspora.com).
