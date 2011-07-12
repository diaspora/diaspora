1. **Octopress sports a clean responsive theme** written in semantic HTML5, focused on readability and friendliness toward mobile devices.
2. **Code blogging is easy and beautiful.** Embed code (with [Solarized](http://ethanschoonover.com/solarized) styling) in your posts from gists or from your filesystem.
3. **Third party integration is simple** with built-in support for Twitter, Pinboard, Delicious, Disqus Comments, and Google Analytics.
4. **It's easy to use.** A collection of rake tasks simplifies development and makes deploying a cinch.
5. **Ships with great plugins** some original and others from the Jekyll community &mdash; tested and improved.

## Getting Started

[Create a new repository](https://github.com/repositories/new) for your website then
open up a terminal and follow along. If you plan to host your site on [Github Pages](http://pages.github.com) for a user or organization, make sure the
repository is named `your_username.github.com` or `your_organization.github.com`.

    mkdir my_octopress_site
    cd my_octopress_site
    git init
    git remote add octopress git://github.com/imathis/octopress.git
    git pull octopress master
    git remote add origin (your repository url)
    git push origin master

    # Next, if you're using Github user or organization pages,
    # Create a source branch and push to origin source.
    git branch source
    git push origin source


Next, setup an [RVM](http://beginrescueend.com/) and install dependencies.

    rvm rvmrc trust
    bundle install

    # Install pygments (for syntax highlighing)
    sudo easy_install pip
    sudo pip install pygments

    # Install the default Octopress theme
    rake install

### Generating Your Blog

    rake generate   # Generates your blog into the public directory
    rake watch      # Watches files for changes and regenerates your blog
    rake preview    # Watches, and mounts a webserver at http://localhost:4000

Jekyll's built in webbrick server is handy, but if you're a [POW](http://pow.cx) user, you can set it up to work with Octopress like this.

    cd ~/.pow
    ln -s /path/to/octopress
    cd -

Now that you're setup with POW, you'll just run `rake watch` and load up `http://octopress.dev` instead.

## Writing A Post

Create your first post.

    rake post['hello world']

This will put a new post in source/_posts with a name like like `2011-07-3-hello-world.markdown` in the `source/_posts` directory.
Open that file in your favorite text editor and you'll see a block of [yaml front matter](https://github.com/mojombo/jekyll/wiki/yaml-front-matter)
which tells Jekyll how to processes posts and pages.

    ---
    title: Hello World
    date: 2011-07-03 5:59
    layout: post
    ---

Now beneath the yaml block, go ahead and type up a sample post, or use some [inspired filler](http://baconipsum.com/). If you're running the watcher, save and refresh your browser and you
should see the new post show up in your blog index.

Octopress does more than this though. Check out [Blogging with Octopress](#include_link) to learn about all the different ways Octopress makes blogging easier.

## Configuring Octopress

I've tried to keep configuring Octopress fairly simple. Here's a list of files for configuring Octopress.

    _config.yml       # Main config (Jekyll blog settings)
    Rakefile          # Config for Rsync deployment
    config.rb         # Compass config

    sass/custom/_colors.scss      # change your blog's color scheme
    sass/custom/_layout.scss      # change your blog's layout
    sass/custom/_styles.scss      # override your blog's styles

Octopress keeps it's main configurations in two places, the `Rakefile` and the `_config.yml`. You probably won't have to change anything in the rakefile except the
deployment configurations (if you're going to [deploy with Rsync over SSH](#deploy_with_rsync)).

## Deploying

### Deploying with Rsync via SSH

Add your server configurations to the `Rakefile` under Rsync deploy config. To deploy with Rsync, be sure your public key is listed in your server's `~/.ssh/authorized_keys` file.

    ssh_user      = "user@domain.com"
    document_root = "~/website.com/"

Now if you run `rake deploy` in your terminal, your `public` directory will be synced to your server's document root.

### Deploying to Github Pages

To setup deployment, you'll want to clone your target repository into the `_deploy` directory in your Octopress project.
If you're using Github project pages, clone the repository for that project, eg `git@github.com:username/project.git`.
If you're using Github user or organization pages, clone the repository `git@github.com:usernem/username.github.com.git`.

    # For Github project pages:
    git clone git@github.com:username/project.git _deploy
    rake config_deploy[gh-pages]

    # For Github user/organization pages:
    git clone git@github.com:username/username.github.com _deploy
    rake config_deploy[master]

    # Now to deploy, you'll run
    rake deploy

The `config_deploy` rake task takes a branch name as an argument and creates a [new empty branch](http://book.git-scm.com/5_creating_new_empty_branches.html), and adds an initial commit.
This prepares your branch for easy deployment. The `rake deploy` task copies the generated blog from the `public` directory to the `_deploy` directory, adds new files, removes old files, sets a commit message, and pushes to Github.
Github will queue your site for publishing (which usually occurs instantly or within minutes if it's your first commit).

## License
(The MIT License)

Copyright © 2009 Brandon Mathis

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the ‘Software’), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED ‘AS IS’, WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

#### If you want to be awesome.
- Proudly display the 'Powered by Octopress' credit in the footer.
- Add your site to the wiki so we can watch the community grow.
