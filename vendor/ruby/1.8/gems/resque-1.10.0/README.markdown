Resque
======

Resque is a Redis-backed library for creating background jobs, placing
those jobs on multiple queues, and processing them later.

Background jobs can be any Ruby class or module that responds to
`perform`. Your existing classes can easily be converted to background
jobs or you can create new classes specifically to do work. Or, you
can do both.

Resque is heavily inspired by DelayedJob (which rocks) and comprises
three parts:

1. A Ruby library for creating, querying, and processing jobs
2. A Rake task for starting a worker which processes jobs
3. A Sinatra app for monitoring queues, jobs, and workers.

Resque workers can be distributed between multiple machines,
support priorities, are resilient to memory bloat / "leaks," are
optimized for REE (but work on MRI and JRuby), tell you what they're
doing, and expect failure.

Resque queues are persistent; support constant time, atomic push and
pop (thanks to Redis); provide visibility into their contents; and
store jobs as simple JSON packages.

The Resque frontend tells you what workers are doing, what workers are
not doing, what queues you're using, what's in those queues, provides
general usage stats, and helps you track failures.


The Blog Post
-------------

For the backstory, philosophy, and history of Resque's beginnings,
please see [the blog post][0].


Overview
--------

Resque allows you to create jobs and place them on a queue, then,
later, pull those jobs off the queue and process them.

Resque jobs are Ruby classes (or modules) which respond to the
`perform` method. Here's an example:

    class Archive
      @queue = :file_serve

      def self.perform(repo_id, branch = 'master')
        repo = Repository.find(repo_id)
        repo.create_archive(branch)
      end
    end

The `@queue` class instance variable determines which queue `Archive`
jobs will be placed in. Queues are arbitrary and created on the fly -
you can name them whatever you want and have as many as you want.

To place an `Archive` job on the `file_serve` queue, we might add this
to our application's pre-existing `Repository` class:

    class Repository
      def async_create_archive(branch)
        Resque.enqueue(Archive, self.id, branch)
      end
    end

Now when we call `repo.async_create_archive('masterbrew')` in our
application, a job will be created and placed on the `file_serve`
queue.

Later, a worker will run something like this code to process the job:

    klass, args = Resque.reserve(:file_serve)
    klass.perform(*args) if klass.respond_to? :perform

Which translates to:

    Archive.perform(44, 'masterbrew')

Let's start a worker to run `file_serve` jobs:

    $ cd app_root
    $ QUEUE=file_serve rake resque:work

This starts one Resque worker and tells it to work off the
`file_serve` queue. As soon as it's ready it'll try to run the
`Resque.reserve` code snippet above and process jobs until it can't
find any more, at which point it will sleep for a small period and
repeatedly poll the queue for more jobs.

Workers can be given multiple queues (a "queue list") and run on
multiple machines. In fact they can be run anywhere with network
access to the Redis server.


Jobs
----

What should you run in the background? Anything that takes any time at
all. Slow INSERT statements, disk manipulating, data processing, etc.

At GitHub we use Resque to process the following types of jobs:

* Warming caches
* Counting disk usage
* Building tarballs
* Building Rubygems
* Firing off web hooks
* Creating events in the db and pre-caching them
* Building graphs
* Deleting users
* Updating our search index

As of writing we have about 35 different types of background jobs.

Keep in mind that you don't need a web app to use Resque - we just
mention "foreground" and "background" because they make conceptual
sense. You could easily be spidering sites and sticking data which
needs to be crunched later into a queue.


### Persistence

Jobs are persisted to queues as JSON objects. Let's take our `Archive`
example from above. We'll run the following code to create a job:

    repo = Repository.find(44)
    repo.async_create_archive('masterbrew')

The following JSON will be stored in the `file_serve` queue:

    {
        'class': 'Archive',
        'args': [ 44, 'masterbrew' ]
    }

Because of this your jobs must only accept arguments that can be JSON encoded.

So instead of doing this:

    Resque.enqueue(Archive, self, branch)

do this:

    Resque.enqueue(Archive, self.id, branch)

This is why our above example (and all the examples in `examples/`)
uses object IDs instead of passing around the objects.

While this is less convenient than just sticking a marshaled object
in the database, it gives you a slight advantage: your jobs will be
run against the most recent version of an object because they need to
pull from the DB or cache.

If your jobs were run against marshaled objects, they could
potentially be operating on a stale record with out-of-date information.


### send_later / async

Want something like DelayedJob's `send_later` or the ability to use
instance methods instead of just methods for jobs? See the `examples/`
directory for goodies.

We plan to provide first class `async` support in a future release.


### Failure

If a job raises an exception, it is logged and handed off to the
`Resque::Failure` module. Failures are logged either locally in Redis
or using some different backend.

For example, Resque ships with Hoptoad support.

Keep this in mind when writing your jobs: you may want to throw
exceptions you would not normally throw in order to assist debugging.


Workers
-------

Resque workers are rake tasks that run forever. They basically do this:

    start
    loop do
      if job = reserve
        job.process
      else
        sleep 5
      end
    end
    shutdown

Starting a worker is simple. Here's our example from earlier:

    $ QUEUE=file_serve rake resque:work

By default Resque won't know about your application's
environment. That is, it won't be able to find and run your jobs - it
needs to load your application into memory.

If we've installed Resque as a Rails plugin, we might run this command
from our RAILS_ROOT:

    $ QUEUE=file_serve rake environment resque:work

This will load the environment before starting a worker. Alternately
we can define a `resque:setup` task with a dependency on the
`environment` rake task:

    task "resque:setup" => :environment

GitHub's setup task looks like this:

    task "resque:setup" => :environment do
      Grit::Git.git_timeout = 10.minutes
    end

We don't want the `git_timeout` as high as 10 minutes in our web app,
but in the Resque workers it's fine.


### Logging

Workers support basic logging to STDOUT. If you start them with the
`VERBOSE` env variable set, they will print basic debugging
information. You can also set the `VVERBOSE` (very verbose) env
variable.

    $ VVERBOSE=1 QUEUE=file_serve rake environment resque:work


### Priorities and Queue Lists

Resque doesn't support numeric priorities but instead uses the order
of queues you give it. We call this list of queues the "queue list."

Let's say we add a `warm_cache` queue in addition to our `file_serve`
queue. We'd now start a worker like so:

    $ QUEUES=file_serve,warm_cache rake resque:work

When the worker looks for new jobs, it will first check
`file_serve`. If it finds a job, it'll process it then check
`file_serve` again. It will keep checking `file_serve` until no more
jobs are available. At that point, it will check `warm_cache`. If it
finds a job it'll process it then check `file_serve` (repeating the
whole process).

In this way you can prioritize certain queues. At GitHub we start our
workers with something like this:

    $ QUEUES=critical,archive,high,low rake resque:work

Notice the `archive` queue - it is specialized and in our future
architecture will only be run from a single machine.

At that point we'll start workers on our generalized background
machines with this command:

    $ QUEUES=critical,high,low rake resque:work

And workers on our specialized archive machine with this command:

    $ QUEUE=archive rake resque:work


### Running All Queues

If you want your workers to work off of every queue, including new
queues created on the fly, you can use a splat:

    $ QUEUE=* rake resque:work

Queues will be processed in alphabetical order.


### Running Multiple Workers

At GitHub we use god to start and stop multiple workers. A sample god
configuration file is included under `examples/god`. We recommend this
method.

If you'd like to run multiple workers in development mode, you can do
so using the `resque:workers` rake task:

    $ COUNT=5 QUEUE=* rake resque:workers

This will spawn five Resque workers, each in its own thread. Hitting
ctrl-c should be sufficient to stop them all.


### Forking

On certain platforms, when a Resque worker reserves a job it
immediately forks a child process. The child processes the job then
exits. When the child has exited successfully, the worker reserves
another job and repeats the process.

Why?

Because Resque assumes chaos.

Resque assumes your background workers will lock up, run too long, or
have unwanted memory growth.

If Resque workers processed jobs themselves, it'd be hard to whip them
into shape. Let's say one is using too much memory: you send it a
signal that says "shutdown after you finish processing the current
job," and it does so. It then starts up again - loading your entire
application environment. This adds useless CPU cycles and causes a
delay in queue processing.

Plus, what if it's using too much memory and has stopped responding to
signals?

Thanks to Resque's parent / child architecture, jobs that use too much memory
release that memory upon completion. No unwanted growth.

And what if a job is running too long? You'd need to `kill -9` it then
start the worker again. With Resque's parent / child architecture you
can tell the parent to forcefully kill the child then immediately
start processing more jobs. No startup delay or wasted cycles.

The parent / child architecture helps us keep tabs on what workers are
doing, too. By eliminating the need to `kill -9` workers we can have
parents remove themselves from the global listing of workers. If we
just ruthlessly killed workers, we'd need a separate watchdog process
to add and remove them to the global listing - which becomes
complicated.

Workers instead handle their own state.


### Parents and Children

Here's a parent / child pair doing some work:

    $ ps -e -o pid,command | grep [r]esque
    92099 resque: Forked 92102 at 1253142769
    92102 resque: Processing file_serve since 1253142769

You can clearly see that process 92099 forked 92102, which has been
working since 1253142769.

(By advertising the time they began processing you can easily use monit
or god to kill stale workers.)

When a parent process is idle, it lets you know what queues it is
waiting for work on:

    $ ps -e -o pid,command | grep [r]esque
    92099 resque: Waiting for file_serve,warm_cache


### Signals

Resque workers respond to a few different signals:

* `QUIT` - Wait for child to finish processing then exit
* `TERM` / `INT` - Immediately kill child then exit
* `USR1` - Immediately kill child but don't exit
* `USR2` - Don't start to process any new jobs
* `CONT` - Start to process new jobs again after a USR2

If you want to gracefully shutdown a Resque worker, use `QUIT`.

If you want to kill a stale or stuck child, use `USR1`. Processing
will continue as normal unless the child was not found. In that case
Resque assumes the parent process is in a bad state and shuts down.

If you want to kill a stale or stuck child and shutdown, use `TERM`

If you want to stop processing jobs, but want to leave the worker running
(for example, to temporarily alleviate load), use `USR2` to stop processing,
then `CONT` to start it again.

### Mysql::Error: MySQL server has gone away

If your workers remain idle for too long they may lose their MySQL
connection. If that happens we recommend using [this
Gist](http://gist.github.com/238999).


The Front End
-------------

Resque comes with a Sinatra-based front end for seeing what's up with
your queue.

![The Front End](http://img.skitch.com/20091104-tqh5pgkwgbskjbk7qbtmpesnyw.jpg)

### Standalone

If you've installed Resque as a gem running the front end standalone is easy:

    $ resque-web

It's a thin layer around `rackup` so it's configurable as well:

    $ resque-web -p 8282

If you have a Resque config file you want evaluated just pass it to
the script as the final argument:

    $ resque-web -p 8282 rails_root/config/initializers/resque.rb

You can also set the namespace directly using `resque-web`:

    $ resque-web -p 8282 -N myapp

### Passenger

Using Passenger? Resque ships with a `config.ru` you can use. See
Phusion's guide:

<http://www.modrails.com/documentation/Users%20guide.html#_deploying_a_rack_based_ruby_application>

### Rack::URLMap

If you want to load Resque on a subpath, possibly alongside other
apps, it's easy to do with Rack's `URLMap`:

    require 'resque/server'

    run Rack::URLMap.new \
      "/"       => Your::App.new,
      "/resque" => Resque::Server.new

Check `examples/demo/config.ru` for a functional example (including
HTTP basic auth).


Resque vs DelayedJob
--------------------

How does Resque compare to DelayedJob, and why would you choose one
over the other?

* Resque supports multiple queues
* DelayedJob supports finer grained priorities
* Resque workers are resilient to memory leaks / bloat
* DelayedJob workers are extremely simple and easy to modify
* Resque requires Redis
* DelayedJob requires ActiveRecord
* Resque can only place JSONable Ruby objects on a queue as arguments
* DelayedJob can place _any_ Ruby object on its queue as arguments
* Resque includes a Sinatra app for monitoring what's going on
* DelayedJob can be queried from within your Rails app if you want to
  add an interface

If you're doing Rails development, you already have a database and
ActiveRecord. DelayedJob is super easy to setup and works great.
GitHub used it for many months to process almost 200 million jobs.

Choose Resque if:

* You need multiple queues
* You don't care / dislike numeric priorities
* You don't need to persist every Ruby object ever
* You have potentially huge queues
* You want to see what's going on
* You expect a lot of failure / chaos
* You can setup Redis
* You're not running short on RAM

Choose DelayedJob if:

* You like numeric priorities
* You're not doing a gigantic amount of jobs each day
* Your queue stays small and nimble
* There is not a lot failure / chaos
* You want to easily throw anything on the queue
* You don't want to setup Redis

In no way is Resque a "better" DelayedJob, so make sure you pick the
tool that's best for your app.


Installing Redis
----------------

Resque requires Redis 0.900 or higher.

Resque uses Redis' lists for its queues. It also stores worker state
data in Redis.

#### Homebrew

If you're on OS X, Homebrew is the simplest way to install Redis:

    $ brew install redis
    $ redis-server /usr/local/etc/redis.conf

You now have a Redis daemon running on 6379.

#### Via Resque

Resque includes Rake tasks (thanks to Ezra's redis-rb) that will
install and run Redis for you:

    $ git clone git://github.com/defunkt/resque.git
    $ cd resque
    $ rake redis:install dtach:install
    $ rake redis:start

Or, if you don't have admin access on your machine:

    $ git clone git://github.com/defunkt/resque.git
    $ cd resque
    $ PREFIX=<your_prefix> rake redis:install dtach:install
    $ rake redis:start

You now have Redis running on 6379. Wait a second then hit ctrl-\ to
detach and keep it running in the background.

The demo is probably the best way to figure out how to put the parts
together. But, it's not that hard.


Resque Dependencies
-------------------

    gem install redis redis-namespace yajl-ruby

If you cannot install `yajl-ruby` (JRuby?), you can install the `json`
gem and Resque will use it instead.

When problems arise, make sure you have the newest versions of the
`redis` and `redis-namespace` gems.


Installing Resque
-----------------

### In a Rack app, as a gem

First install the gem.

    $ gem install resque

Next include it in your application.

    require 'resque'

Now start your application:

    rackup config.ru

That's it! You can now create Resque jobs from within your app.

To start a worker, create a Rakefile in your app's root (or add this
to an existing Rakefile):

    require 'your/app'
    require 'resque/tasks'

Now:

    $ QUEUE=* rake resque:work

Alternately you can define a `resque:setup` hook in your Rakefile if you
don't want to load your app every time rake runs.


### In a Rails app, as a gem

First install the gem.

    $ gem install resque

Next include it in your application.

    $ cat config/initializers/load_resque.rb
    require 'resque'

Now start your application:

    $ ./script/server

That's it! You can now create Resque jobs from within your app.

To start a worker, add this to your Rakefile in `RAILS_ROOT`:

    require 'resque/tasks'

Now:

    $ QUEUE=* rake environment resque:work

Don't forget you can define a `resque:setup` hook in
`lib/tasks/whatever.rake` that loads the `environment` task every time.


### In a Rails app, as a plugin

    $ ./script/plugin install git://github.com/defunkt/resque

That's it! Resque will automatically be available when your Rails app
loads.

To start a worker:

    $ QUEUE=* rake environment resque:work

Don't forget you can define a `resque:setup` hook in
`lib/tasks/whatever.rake` that loads the `environment` task every time.


Configuration
-------------

You may want to change the Redis host and port Resque connects to, or
set various other options at startup.

Resque has a `redis` setter which can be given a string or a Redis
object. This means if you're already using Redis in your app, Resque
can re-use the existing connection.

String: `Resque.redis = 'localhost:6379'`

Redis: `Resque.redis = $redis`

For our rails app we have a `config/initializers/resque.rb` file where
we load `config/resque.yml` by hand and set the Redis information
appropriately.

Here's our `config/resque.yml`:

    development: localhost:6379
    test: localhost:6379
    staging: redis1.se.github.com:6379
    fi: localhost:6379
    production: redis1.ae.github.com:6379

And our initializer:

    rails_root = ENV['RAILS_ROOT'] || File.dirname(__FILE__) + '/../..'
    rails_env = ENV['RAILS_ENV'] || 'development'

    resque_config = YAML.load_file(rails_root + '/config/resque.yml')
    Resque.redis = resque_config[rails_env]

Easy peasy! Why not just use `RAILS_ROOT` and `RAILS_ENV`? Because
this way we can tell our Sinatra app about the config file:

    $ RAILS_ENV=production resque-web rails_root/config/initializers/resque.rb

Now everyone is on the same page.


Plugins and Hooks
-----------------

For a list of available plugins see
<http://wiki.github.com/defunkt/resque/plugins>.

If you'd like to write your own plugin, or want to customize Resque
using hooks (such as `Resque.after_fork`), see
[docs/HOOKS.md](http://github.com/defunkt/resque/blob/master/docs/HOOKS.md).


Namespaces
----------

If you're running multiple, separate instances of Resque you may want
to namespace the keyspaces so they do not overlap. This is not unlike
the approach taken by many memcached clients.

This feature is provided by the [redis-namespace][rs] library, which
Resque uses by default to separate the keys it manages from other keys
in your Redis server.

Simply use the `Resque.redis.namespace` accessor:

    Resque.redis.namespace = "resque:GitHub"

We recommend sticking this in your initializer somewhere after Redis
is configured.


Demo
----

Resque ships with a demo Sinatra app for creating jobs that are later
processed in the background.

Try it out by looking at the README, found at `examples/demo/README.markdown`.


Monitoring
----------

### god

If you're using god to monitor Resque, we have provided example
configs in `examples/god/`. One is for starting / stopping workers,
the other is for killing workers that have been running too long.

### monit

If you're using monit, `examples/monit/resque.monit` is provided free
of charge. This is **not** used by GitHub in production, so please
send patches for any tweaks or improvements you can make to it.


Development
-----------

Want to hack on Resque?

First clone the repo and run the tests:

    git clone git://github.com/defunkt/resque.git
    cd resque
    rake test

If the tests do not pass make sure you have Redis installed
correctly (though we make an effort to tell you if we feel this is the
case). The tests attempt to start an isolated instance of Redis to
run against.

Also make sure you've installed all the dependencies correctly. For
example, try loading the `redis-namespace` gem after you've installed
it:

    $ irb
    >> require 'rubygems'
    => true
    >> require 'redis/namespace'
    => true

If you get an error requiring any of the dependencies, you may have
failed to install them or be seeing load path issues.

Feel free to ping the mailing list with your problem and we'll try to
sort it out.


Contributing
------------

Once you've made your great commits:

1. [Fork][1] Resque
2. Create a topic branch - `git checkout -b my_branch`
3. Push to your branch - `git push origin my_branch`
4. Create an [Issue][2] with a link to your branch
5. That's it!

You might want to checkout our [Contributing][cb] wiki page for information
on coding standards, new features, etc.


Mailing List
------------

To join the list simply send an email to <resque@librelist.com>. This
will subscribe you and send you information about your subscription,
including unsubscribe information.

The archive can be found at <http://librelist.com/browser/>.


Meta
----

* Code: `git clone git://github.com/defunkt/resque.git`
* Home: <http://github.com/defunkt/resque>
* Docs: <http://defunkt.github.com/resque/>
* Bugs: <http://github.com/defunkt/resque/issues>
* List: <resque@librelist.com>
* Chat: <irc://irc.freenode.net/resque>
* Gems: <http://gemcutter.org/gems/resque>

This project uses [Semantic Versioning][sv].


Author
------

Chris Wanstrath :: chris@ozmm.org :: @defunkt

[0]: http://github.com/blog/542-introducing-resque
[1]: http://help.github.com/forking/
[2]: http://github.com/defunkt/resque/issues
[sv]: http://semver.org/
[rs]: http://github.com/defunkt/redis-namespace
[cb]: http://wiki.github.com/defunkt/resque/contributing
