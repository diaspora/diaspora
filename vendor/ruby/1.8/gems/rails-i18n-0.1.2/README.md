Rails Locale Data Repository
============================

Central point to collect locale data for use in Ruby on Rails.

## Gem installation

Add to your Gemfile:

    gem 'rails-i18n'

or run this command:

    gem install rails-i18n


## Manual installation

Download the locale files that are found in the directory [rails/locale](http://github.com/svenfuchs/rails-i18n/tree/master/rails/locale/) and put them into the `config/locales` directory of your Rails application.

If any translation doesn't suit well to the requirements of your application, edit them or add your own locale files.

For more information, visit [Rails Internationalization (I18n) API](http://guides.rubyonrails.org/i18n.html) on the _RailsGuides._

Available locales are:

> ar, bg, bn-IN, bs, ca, cs, cy, da, de, de-AT, de-CH, dsb, el, en-AU, en-GB, en-US, eo, es,
> es-AR, es-CL, es-CO, es-MX, es-PE, et, eu, fa, fi, fr, fr-CA, fr-CH, fur, gl-ES,
> gsw-CH, he, hi-IN, hr, hsb, hu, id, is, it, ja, kn, ko, lo, lt, lv, mk, mn, nb,
> nl, nn, pl, pt-BR, pt-PT, rm, ro, ru, sk, sl, sr, sr-Latn, sv-SE, sw, th,
> tr, uk, vi, zh-CN, zh-TW

Note that all locale files are not yet ready for Rails 3. Currently, following locales are ready for Rails 2 and 3:

> ar, ca, cs, cy, da, de, en-AU, en-GB, en-US, eo, es, es-AR, es-CL, es-CO, es-MX, et, eu, fa, fi, fr, fr-CA, fr-CH, gsw-CH, he, hi, hi-IN, hu, is, it, ja, kn, ko, lv, nb, nl, pl, pt-BR, pt-PT, ro, ru, sk, sv-SE, sw, th, uk, zh-CN, zh-TW

Not-yet-ready locales are:

> bg, bn-IN, bs, de-AT, de-CH, dsb, el, es-PE, fur, gl-ES, hr, hsb, id, lo, lt, mk, mn, nn, rm, sl, sr, sr-Latn, tr, vi

We always welcome your contributions!

## How to contribute

### Quick contribution

If you are familiar with GitHub operations, follow the procedures described in the subsequent sections.

If you are not,

* Save your locale data on the [Gist](http://gist.github.com).
* Open an issue with reference to the Gist you created.

### Fetch the `rails-18n` repository

* Get a github account and Git program if you haven't. See [Help.Github](http://help.github.com/) for instructions.
* Fork `svenfuchs/rails-i18n` repository and clone it into your PC.

### Create or edit your locale file

* Have a look in `rails/locale/en-US.yml`, which can be used as the base of your translation.
  This file is a compound of all translation files in the Rails 2 and 3 packages.
  Note that we use `&errors_messages` and `<<: *errors_messages` to anchor and merge a part of translation data.
* Create or edit your locale file.
  Please include a comment with the language/locale name and your name and email address (or other contact information like your github profile) to the locale file so people can come contact you and ask questions etc.
  Also, please pay attention to save your files as UTF-8.

### Test your locale file

Before commit and push your changes, test the integrity of your locale file.

Make sure you have the <code>i18n</code> and <code>thor</code> installed. If you haven't, install them:

    sudo gem install i18n thor

You can test your locale by running following command on the root directory of this repository:

    thor locales:test [your-locale]

Assuming that there is a file <code>rails/locale/[your-locale].{rb,yml}</code> you will get a list of keys missing from your locale data.

Invoke following command to test all locale files:

    thor locales:test_all

You can list all locales that are ready both for Rails version 2 and 3:

    thor locales:ready

You can also list the locales ready for a specific version of Rails. For example:

    thor locales:ready_for 3

Lastly, you can list all available locales:

    thor locales:list

### Edit README.md

Add your locale name to the list in `README.md` if it isn't there.

### Send pull request

If you are ready, push the repository into the Github and send us a pull request.

We will do the formality check and publish it as quick as we can.

## License

[MIT](https://github.com/svenfuchs/rails-i18n/blob/master/MIT-LICENSE.txt)

## Contributors

See [https://github.com/svenfuchs/rails-i18n/contributors](https://github.com/svenfuchs/rails-i18n/contributors)

## Special thanks

[Tsutomu Kuroda](https://github.com/kuroda) for untiringly taking care of this repository, issues and pull requests
