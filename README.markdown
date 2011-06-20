1. **Octopress sports a clean responsive theme** written in semantic HTML5, focused on readability and friendliness toward mobile devices.
2. **Code blogging is easy and beautiful.** Embed code (with [Solarized](http://ethanschoonover.com/solarized) styling) in your posts from gists or from your filesystem.
3. **Third party integration is simple** with built-in support for Twitter, Pinboard, Delicious, Disqus Comments, and Google Analytics.
4. **It's easy to use.** A collection of rake tasks simplifies development and makes deploying a cinch.
5. **Get curated plugins.** Plugins are hand selected from the Jekyll community then tested and improved.

## Get Setup

[Fork Octopress](https://github.com/imathis/octopress), then open the console and follow along.

    git clone (your repo url)

    # Optionally add a branch for pulling in Octopress updates
    git remote add octopress git://github.com/imathis/octopress.git

Setup an [RVM](http://beginrescueend.com/) and install dependencies.

    source .rvmrc
    bundle install

    # Install pygments (for syntax highlighing)
    sudo easy_install pip
    sudo pip install pygments

    # Install the default Octopress theme
    rake install

### Write A Post

    rake post['hello world']

This will create a new post named something like `2011-06-17-hello-world.markdown` in the `source/_posts` directory.
Open that file in your favorite text editor and you'll see a block of [yaml front matter](https://github.com/mojombo/jekyll/wiki/yaml-front-matter)
which tells Jekyll how to processes posts and pages.

    ---
    title: Hello World
    date: 2011-06-17 14:34
    layout: post
    ---

Octopress adds some custom paramaters to give you more publishing flexibility and you can [read about those here](#include_link),
but for now. Go ahead and type up a sample post or use some [inspired filler](http://baconipsum.com/).

{% pullquote %}
  When writing longform posts, I find it helpful to include pullquotes, which help those scanning a post discern whether or not a post is helpful.
  It is important to note, {" pullquotes are merely visual in presentation and should not appear twice in the text. "} That is why it is prefered
  to use a CSS only technique for styling pullquotes.
{% endpullquote %}

## Generate Your Blog

    rake preview

This will generate your blog, watch your `sass` and `source` directories for changes regenerating automatically, and mount Jekyll's built in webbrick server. Open your browser to `http://localhost:4000` and check it out.

If you'd rather use [POW](http://pow.cx) to serve up your site, you can do this instead.

    cd ~/.pow
    ln -s /path/to/octopress

    #Then generate your site
    rake watch

`rake watch` does the same thing as `rake preview` except it doesn't mount Jekyll's webbrick server.

### Configure Octopress

Octopress keeps configurations in two places, the `Rakefile` and the `_config.yml`.

In the `rakefile` you'll want to set up your deployment configurations.

    ## -- Rsync Deploy config -- ##
    # Be sure your public key is listed in your server's ~/.ssh/authorized_keys file
    ssh_user      = "mathisweb@imathis.com"
    document_root = "~/dev.octopress.org/"

    ## -- Git deploy config -- ##
    source_branch = "source" # this compiles to your deploy branch
    deploy_branch = "master" # For user/organization pages, use "master" for project pages use "gh-pages"

If you want to deploy with github pages, read [http://pages.github.com](http://pages.github.com) for guidance.

TODO : Write _configt.yml instructions…

## License
(The MIT License)

Copyright © 2009 Brandon Mathis

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the ‘Software’), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED ‘AS IS’, WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

#### If you want to be awesome.
- Proudly display the 'Powered by Octopress' credit in the footer.
- Add your site to the wiki so we can watch the community grow.
