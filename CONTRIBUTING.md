# Contributing to diaspora\*

First of all: thank you very much for helping us out!

## Things you need to know before contributing

If you want to get in touch with other diaspora\* developers, [check our wiki][how-we-communicate] for information on how we communicate. Feel free to ask if you have any questions!

Everyone interacting with our code, issue trackers, chat rooms, mailing lists, the wiki, and the discourse forum is expected to follow the [diaspora\* code of conduct][code-of-conduct].

## Report a security issue

Found a security issue? Please disclose it responsibly. We have a team of developers listening to [security@diasporafoundation.org][sec-mail]. The PGP fingerprint is [AB0D AB02 0FC5 D398 03AB 3CE1 6F70 243F 27AD 886A][pgp].

## Contributing to translations

We use [WebTranslateIt][webtranslateit] to manage translations of the app interface. Please read [our wiki page][translation-wiki] to find out more about this. If your language is featured on WebTranslateIt, please do **not** open a pull request to update translations. If it is not already featured on WebTranslateIt, please read the wiki article above to find out how to proceed.

## Contributing to the code

**Before opening a pull request** please read [how to contribute][contribute]. Doing things the right way from the start will save us time and mean that your contribution can be integrated quicker!
- Follow our [git workflow][git-workflow] method. In particular, *do not* open a pull request from the `master` or the `develop` branch.
- Follow our [styleguide][styleguide] and run pronto, our syntax analyzer, **locally before opening a pull request**. See [our wiki][pronto] for information on how to do this.
- [Write tests][testing-workflow].
- Use meaningful commit-messages and split larger tasks, e.g. refactoring, into separate commits. This makes the review process much easier.

## Other ways to contribute

You don’t know code? No worries, there are plenty other ways to help the diaspora* project! Please find out how you can help [on our wiki][other-ways].

[code-of-conduct]: https://github.com/diaspora/diaspora/blob/develop/CODE_OF_CONDUCT.md
[how-we-communicate]: https://wiki.diasporafoundation.org/How_we_communicate
[pgp]: https://pgp.mit.edu/pks/lookup?op=get&search=0x6F70243F27AD886A
[sec-mail]: mailto:security@diasporafoundation.org
[webtranslateit]: https://webtranslateit.com/en/projects/3020-Diaspora
[translation-wiki]: https://wiki.diasporafoundation.org/Contribute_translations
[contribute]: https://wiki.diasporafoundation.org/Getting_started_with_contributing
[git-workflow]: https://wiki.diasporafoundation.org/Git_Workflow
[styleguide]: https://wiki.diasporafoundation.org/Styleguide
[pronto]: https://wiki.diasporafoundation.org/Styleguide#Automatic_local_review
[testing-workflow]: https://wiki.diasporafoundation.org/Testing_Workflow
[other-ways]: https://wiki.diasporafoundation.org/Other_ways_to_contribute
