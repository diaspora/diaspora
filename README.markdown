# What is Octopress?
Octopress gives developers a well designed starting point for a Jekyll blog. It's easy to configure and easy to deploy. Sweet huh?

## Why?
1. Building a Jekyll blog from scratch is a lot of work.
2. Jekyll doesn't have default layouts or themes.
3. Most developers don't want to do design.

## Octopress is made of
- [Jekyll](http://github.com/henrik/jekyll) a blog aware static site generator (Henrik's fork adds [HAML](http://haml-lang.com) support)
- [Compass](http://compass-style.org) an awesome [SASS](http://sass-lang.com) framework.
- [FSSM](http://github.com/ttilley/fssm/tree/master) + a rake task, automatically regenerates the blog as you work.
- [Serve](http://github.com/jlong/serve) for live previews of the site while in development
- [Rsync](http://samba.anu.edu.au/rsync/) for easy deployment.

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
2. Edit the top of the atom.haml and _layout/default.haml

## Usage
You should really read over the [Jekyll wiki](http://wiki.github.com/mojombo/jekyll) because most of your work will be using Jekyll. Beyond that Octopress is mostly some rake tasks, HAML, and SASS/Compass that has been meticulously crafted for ease of use and modification.

### Rake tasks
rake preview: Generates the site, starts the local web server, and opens your browser to show the generated site.

rake watch: Watches the source for changes and regenerates the site every time you save a file. You'll forget your working with a static site.

rake deploy: Generates the site and then uses rsync (based on your configurations in the Rakefile) to synchronize with your web host. In order to use rsync you'll need shell access to your host, and you'll probably want to use your public key for authentication.

rake stop_serve: Kills the local web server process.

*There are more but these are the ones you'll use the most. Read the Rakefile if you want to learn more*