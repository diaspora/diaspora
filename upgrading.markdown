# Major changes

## New Jekyll

Octopress is leaving [Henrik's stale fork of jekyll](https://github.com/henrik/jekyll) for [Mojombo's official Jekyll](https://github.com/mojombo/jekyll). Why? Back when Henrik's Jekyll fork was current, it offered some nice features
like the option to use Haml and ruby instead of html and the liquid templating system. Switching from henrik-jekyll to jekyll, means Octopress will no longer support Haml layouts (until Jekyll does), but after using Octopress
for a year and a half, I can see that it's far better for Octopress to be able to take advantage of the jekyll's active development, than to hold out for full Haml support.

### Jekyll is Pluggable

Some new features make the transition worth it. You can write your own [plugins](https://github.com/mojombo/jekyll/wiki/Plugins) which consist of generators, converters, and liquid tags.
Now it's much easier to hack Jekyll without forking. I expect to see some great plugins emerge from the Jekyll community, and I'll be adding my favorites into Octopress.

## Upgrading

Unfortunately upgrading isn't as smooth as I would like. Some things have changed that require a bit of fiddling on your part. It's less than ideal, but if you were adverse to fiddling, you'd be using Wordpress right?

#### Update configs
I've moved configurations out of layouts and into the _config.yml. This means settings like title, url, and twitter_user can be accessed on the site object, eg. site.title, site.twitter_user.

#### Post dates
Before you could add date and time to the post filename, but for some reason Jekyll is more strict and won't see posts with that format. If you had a post `2009-11-13_14-23-hello-world` it should be renamed to `2009-11-13-hello-world`, leaving out the time-stamp.
If you want to keep the time-stamp data, you can now add dates to the post in the yaml front-matter, eg. `date: 2009-11-13 14:23`. It seems that you can also use parseable strings like November 13, 2009 2:23pm and Jekyll will generate the proper url and post metadata.

I've updated the new post rake task `rake post[title for your new post]` to correctly name new posts, and to automatically insert the time-stamp into the yaml front-matter for a new post. This way you can set the time when you want to publish without having to write out the whole post date.

TODO: add more steps for upgrading
