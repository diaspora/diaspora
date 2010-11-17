# What is Octopress?
Octopress gives developers a well designed starting point for a Jekyll blog. It's easy to configure and easy to deploy. Sweet huh?

#### Octopress comes with
1. A nice, easy to configure theme that focuses on readability.
2. Built in support for Twitter, Delicious, Disqus Comments, Google Analytics, and Custom Search.
3. Rake tasks that make development fast, and deploying easy.

## Why?
1. Building a Jekyll blog from scratch is a lot of work.
2. Jekyll doesn't have default layouts or themes.
3. Most developers don't want to do design.

## Octopress is made of
- [Jekyll](http://github.com/henrik/jekyll) a blog aware static site generator (Henrik's fork adds [HAML](http://haml-lang.com) support)
- [Compass](http://compass-style.org) an awesome [SASS](http://sass-lang.com) framework
- [FSSM](http://github.com/ttilley/fssm/tree/master) + a rake task, automatically regenerates the blog as you work
- [Serve](http://github.com/jlong/serve) for live previews of the site while in development
- [Rsync](http://samba.anu.edu.au/rsync/) for easy deployment

## Setup
Setup is really simple.
  
1. Download Octopress: <code>git clone git://github.com/imathis/octopress.git</code>
2. Install dependencies (requires the bundler gem): <code>bundle install</code>
3. Run <code>rake preview</code> to build the site and preview it in a local webserver.

You'll want to change some settings, so check out the wiki for [Setup & Configurations](http://wiki.github.com/imathis/octopress/configuration).

#### Optional:
- Install Pygments (Python syntax highlighter), if you wish to enable _Syntax Highlighting_.  Download from [pygments.org](http://pygments.org), or <code>sudo aptitude install python-pigments</code> for Debian/Ubuntu users.

## Usage
Octopress is almost like a front-end for Jekyll. It provides some really handy rake tasks and automation to make blogging as simple as possible. With Octopress you can:

- Preview the site locally with the power of Serve.
- Automatically regenerate your blog while you work.
- Generate and deploy with a single command.

See the wiki to learn more about [Usage](http://wiki.github.com/imathis/octopress/usage).

## Third Party Integration
With search, comments, and analytics, you have no need for a database. This is what makes a statically generated blog possible.

- Twitter
- Disqus Comments
- Google Custom Search
- Google Analytics
- Delicious Bookmarks

If you already have an account with these services, you can get set up within seconds. Check out the wiki for [Third Party Configuration](http://wiki.github.com/imathis/octopress/third-party-integration) details, and to learn how to setup or remove these services.

## Octopress Style
- Stylesheets use [SASS](http://sass-lang.com) and [Compass](http://compass-style.org)
- They're broken up into Layout, Typography, Theme (colors), and Partials
- Checkout [the wiki](http://wiki.github.com/imathis/octopress/style-customization) for help with customization.

## License
(The MIT License)

Copyright © 2009 Brandon Mathis

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the ‘Software’), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED ‘AS IS’, WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

#### If you want to be awesome.
- Proudly display the 'Powered by Octopress' credit in the footer.
- Add your site to the wiki so we can watch the community grow.
