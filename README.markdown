# What is Octopress?
Octopress gives developers a well designed starting point for a Jekyll blog. It's easy to configure and easy to deploy. Sweet huh?

#### Octopress comes with
1. A nice, easy to configure theme that focuses on readability.
2. Built in support for Twitter, Delicious, and Disqus Comments.
3. Rake tasks that make development fast, and deployment easy.

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
#### First, clone Octopress locally.
    git clone git://github.com/imathis/octopress.git
#### Second, install required gems
    sudo gem install henrik-jekyll
    sudo gem install compass-edge
    sudo gem install fssm
    sudo gem install serve

#### Third
1. Edit the top of the Rakefile settings to match your web hosting info.
2. Edit the top of the atom.haml and _layout/default.haml.

## Usage
You should really read over the [Jekyll wiki](http://wiki.github.com/mojombo/jekyll) because most of your work will be using Jekyll. Beyond that Octopress is mostly some rake tasks, HAML, and SASS/Compass that has been meticulously crafted for ease of use and modification.

### Common Rake tasks
**rake preview**  
Generates the site, starts the local web server, and opens your browser to show the generated site.

**rake watch**  
Watches the source for changes and regenerates the site every time you save a file. You'll forget your working with a static site.

**rake deploy**  
Generates the site and then uses rsync (based on your configurations in the Rakefile) to synchronize with your web host. In order to use rsync you'll need shell access to your host, and you'll probably want to use your public key for authentication.

**rake stop_serve**  
Kills the local web server process.

*There are more but these are the ones you'll use the most. Read the Rakefile if you want to learn more*

## Third Party Integration
### Twitter
Twitter settings are at the top of _layouts/default.haml
You can also change:

    twitter_user: your_twitter_name
    show_replies: false
    tweet_count: 3

### Disqus Comments
Octopress has built in support for the Disqus commenting system, using the "universal code" installation method. First register your site at [http://disqus.com/comments/register/](http://disqus.com/comments/register/) Then, edit the settings at the top of _layouts/default.haml

    full_url: http://yoursite.com
    disqus_short_name: yourdisqusname

### Google Site Search
First setup sitesearch for your site at [http://google.com/sitesearch/](http://google.com/sitesearch/) then add your site\_search\_id to the YAML block in the default layout.

### Google Analytics
The analytics tracking scripts are already integrated into Octopress, all you have to do is register your site at [http://google.com/analytics/](http://google.com/analytics/).

### Removing Third party integrations
All third party integration is conditionally included. All you have to do is remove the variable from the layout and you're done. If you like, you can also remove the include blocks from the default layout.

## Style Configuration
### What you need to know
Octopress's stylesheets are written in [SASS](http://sass-lang.com). If you haven't learned SASS, you should. It's the future. Octopress also uses [Compass](http://compass-style.org) which is a framework for SASS and contains a great library of SASS mixins which make it trivial to write complicated CSS. This is also the future.

### Customizing the default theme
The default theme is comprised of Layout, Typography, Theme, and Partials. Octopress also has a library of SASS mixins.

**Layout**  
Edit the variables at the top of /stylesheets/_layout.sass to configure the primary structural dimensions, including the header, footer, main content, and sidebar.

**Typography**  
Octopress puts a strong focus on readability and borrows some concepts from the [better web readability project](http://code.google.com/p/better-web-readability-project/). As a result the base font size is 16px. Don't worry though, if you don't like that, you can simply change the variable !base\_font\_size at the top of /stylesheets/_typography.sass and all of the other typographic math (heading sizes, line-heights, margins, etc) will be resized to suit automatically.

If you want to add or modify site-wide typography, this is the file to do it in. If your changes are specific to a small section or feature of your site, you should probably add that under *Partials*.

Octopress ships with a typography test page /test/typography.html that lets you preview the default typographic styles, and see how your changes affect them.

**Theme**  
Every color used in Octopress is assigned to a variable in _theme.sass, so you can change them to suit your tastes without having to dig through a bunch of files to find the color your looking for. Also the colors variables are grouped by their location in the site layout to make them easier to find.

**Partials**  
These are the styles for subsections of the site. They're located in /stylesheets/partials and each subsection has it's own file. Here you'll find styles for the sidebar, blog posts, syntax highlighting, and specific page elements that don't belong in the base layout files.

Octopress ships with a syntax highlighting test page /test/syntax.html that lets you preview the default syntax highlighting styles, and see how your changes affect them.