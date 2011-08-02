## 1.10.0 (2010-08-23)

* Support redis:// string format in `Resque.redis=`
* Using new cross-platform JSON gem.
* Added `after_enqueue` plugin hook.
* Added `shutdown?` method which can be overridden.
* Added support for the "leftright" gem when running tests.
* Grammarfix: In the README

## 1.9.10 (2010-08-06)

* Bugfix: before_fork should get passed the job

## 1.9.9 (2010-07-26)

* Depend on redis-namespace 0.8.0
* Depend on json_pure instead of json (for JRuby compat)
* Bugfix: rails_env display in stats view

## 1.9.8 (2010-07-20)

* Bugfix: Worker.all should never return nil
* monit example: Fixed Syntax Error and adding environment to the rake task
* redis rake task: Fixed typo in copy command

## 1.9.7 (2010-07-09)

* Improved memory usage in Job.destroy
* redis-namespace 0.7.0 now required
* Bugfix: Reverted $0 changes
* Web Bugfix: Payload-less failures in the web ui work

## 1.9.6 (2010-06-22)

* Bugfix: Rakefile logging works the same as all the other logging

## 1.9.5 (2010-06-16)

* Web Bugfix: Display the configured namespace on the stats page
* Revert Bugfix: Make ps -o more cross platform friendly

## 1.9.4 (2010-06-14)

* Bugfix: Multiple failure backend gets exception information when created

## 1.9.3 (2010-06-14)

* Bugfix: Resque#queues always returns an array

## 1.9.2 (2010-06-13)

* Bugfix: Worker.all returning nil fix
* Bugfix: Make ps -o more cross platform friendly

## 1.9.1 (2010-06-04)

* Less strict JSON dependency
* Included HISTORY.md in gem

## 1.9.0 (2010-06-04)

* Redis 2 support
* Depend on redis-namespace 0.5.0
* Added Resque::VERSION constant (alias of Resque::Version)
* Bugfix: Specify JSON dependency
* Bugfix: Hoptoad plugin now works on 1.9

## 1.8.5 (2010-05-18)

* Bugfix: Be more liberal in which Redis clients we accept.

## 1.8.4 (2010-05-18)

* Try to resolve redis-namespace dependency issue

## 1.8.3 (2010-05-17)

* Depend on redis-rb ~> 1.0.7

## 1.8.2 (2010-05-03)

* Bugfix: Include "tasks/" dir in RubyGem

## 1.8.1 (2010-04-29)

* Bugfix: Multiple failure backend did not support requeue-ing failed jobs
* Bugfix: Fix /failed when error has no backtrace
* Bugfix: Add `Redis::DistRedis` as a valid client

## 1.8.0 (2010-04-07)

* Jobs that never complete due to killed worker are now failed.
* Worker "working" state is now maintained by the parent, not the child.
* Stopped using deprecated redis.rb methods
* `Worker.working` race condition fixed
* `Worker#process` has been deprecated.
* Monit example fixed
* Redis::Client and Redis::Namespace can be passed to `Resque.redis=`

## 1.7.1 (2010-04-02)

* Bugfix: Make job hook execution order consistent
* Bugfix: stdout buffering in child process

## 1.7.0 (2010-03-31)

* Job hooks API. See docs/HOOKS.md.
* web: Hovering over dates shows a timestamp
* web: AJAXify retry action for failed jobs
* web bugfix: Fix pagination bug

## 1.6.1 (2010-03-25)

* Bugfix: Workers may not be clearing their state correctly on
  shutdown
* Added example monit config.
* Exception class is now recorded when an error is raised in a
  worker.
* web: Unit tests
* web: Show namespace in header and footer
* web: Remove a queue
* web: Retry failed jobs

## 1.6.0 (2010-03-09)

* Added `before_first_fork`, `before_fork`, and `after_fork` hooks.
* Hoptoad: Added server_environment config setting
* Hoptoad bugfix: Don't depend on RAILS_ROOT
* 1.8.6 compat fixes

## 1.5.2 (2010-03-03)

* Bugfix: JSON check was crazy.

## 1.5.1 (2010-03-03)

* `Job.destroy` and `Resque.dequeue` return the # of destroyed jobs.
* Hoptoad notifier improvements
* Specify the namespace with `resque-web` by passing `-N namespace`
* Bugfix: Don't crash when trying to parse invalid JSON.
* Bugfix: Non-standard namespace support
* Web: Red backgound for queue "failed" only shown if there are failed jobs.
* Web bugfix: Tabs highlight properly now
* Web bugfix: ZSET partial support in stats
* Web bugfix: Deleting failed jobs works again
* Web bugfix: Sets (or zsets, lists, etc) now paginate.

## 1.5.0 (2010-02-17)

* Version now included in procline, e.g. `resque-1.5.0: Message`
* Web bugfix: Ignore idle works in the "working" page
* Added `Resque::Job.destroy(queue, klass, *args)`
* Added `Resque.dequeue(klass, *args)`

## 1.4.0 (2010-02-11)

* Fallback when unable to bind QUIT and USR1 for Windows and JRuby.
* Fallback when no `Kernel.fork` is provided (for IronRuby).
* Web: Rounded corners in Firefox
* Cut down system calls in `Worker#prune_dead_workers`
* Enable switching DB in a Redis server from config
* Support USR2 and CONT to stop and start job processing.
* Web: Add example failing job
* Bugfix: `Worker#unregister_worker` shouldn't call `done_working`
* Bugfix: Example god config now restarts Resque properly.
* Multiple failure backends now permitted.
* Hoptoad failure backend updated to new API

## 1.3.1 (2010-01-11)

* Vegas bugfix: Don't error without a config

## 1.3.0 (2010-01-11)

* Use Vegas for resque-web
* Web Bugfix: Show proper date/time value for failed_at on Failures
* Web Bugfix: Make the / route more flexible
* Add Resque::Server.tabs array (so plugins can add their own tabs)
* Start using [Semantic Versioning](http://semver.org/)

## 1.2.4 (2009-12-15)

* Web Bugfix: fix key links on stat page

## 1.2.3 (2009-12-15)

* Bugfix: Fixed `rand` seeding in child processes.
* Bugfix: Better JSON encoding/decoding without Yajl.
* Bugfix: Avoid `ps` flag error on Linux
* Add `PREFIX` observance to `rake` install tasks.

## 1.2.2 (2009-12-08)

* Bugfix: Job equality was not properly implemented.

## 1.2.1 (2009-12-07)

* Added `rake resque:workers` task for starting multiple workers.
* 1.9.x compatibility
* Bugfix: Yajl decoder doesn't care about valid UTF-8
* config.ru loads RESQUECONFIG if the ENV variable is set.
* `resque-web` now sets RESQUECONFIG
* Job objects know if they are equal.
* Jobs can be re-queued using `Job#recreate`

## 1.2.0 (2009-11-25)

* If USR1 is sent and no child is found, shutdown.
* Raise when a job class does not respond to `perform`.
* Added `Resque.remove_queue` for deleting a queue

## 1.1.0 (2009-11-04)

* Bugfix: Broken ERB tag in failure UI
* Bugfix: Save the worker's ID, not the worker itself, in the failure module
* Redesigned the sinatra web interface
* Added option to clear failed jobs

## 1.0.0 (2009-11-03)

* First release.
