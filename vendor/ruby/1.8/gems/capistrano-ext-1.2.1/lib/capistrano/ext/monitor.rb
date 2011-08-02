require 'capistrano'
require 'thread'

module MonitorServers
  LONG_TIME_FORMAT  = "%Y-%m-%d %H:%M:%S"
  SHORT_TIME_FORMAT = "%H:%M:%S"

  # A helper method for encapsulating the behavior of the date/time column
  # in a report.
  def date_column(operation, *args)
    case operation
    when :init
      { :width => Time.now.strftime(LONG_TIME_FORMAT).length,
        :last => nil,
        :rows => 0 }
    when :show
      state = args.first
      now  = Time.now
      date = now.strftime(
        (state[:rows] % 10 == 0 || now.day != state[:last].day) ?
          LONG_TIME_FORMAT : SHORT_TIME_FORMAT)
      state[:last] = now
      state[:rows] += 1
      "%*s" % [state[:width], date]
    else
      raise "unknown operation #{operation.inspect}"
    end
  end

  # A helper method for formatting table headers in a report.
  def headers(*args)
    0.step(args.length-1, 2) do |n|
      header = args[n]
      size   = args[n+1]
      if header == "-" || header == " " 
        print header * size, "  "
      else
        print header
        padding = size - header.length
        print " " if padding > 0
        print "-" * (padding - 1) if padding > 1
        print "  "
      end
    end
    puts
  end

  # Get a value from the remote environment
  def remote_env(value)
    result = ""
    run("echo $#{value}", :once => true) do |ch, stream, data|
      raise "could not get environment variable #{value}: #{data}" if stream == :err
      result << data
    end
    result.chomp
  end

  # Monitor the load of the servers tied to the current task.
  def load(options={})
    servers = current_task.servers.sort
    names = servers.map { |s| s.match(/^([^.]+)/)[1] }
    time = date_column(:init)
    load_column_width = "0.00".length * 3 + 2

    puts "connecting..."
    connect!

    parser = Proc.new { |text| text.match(/average.*: (.*)$/)[1].split(/, /) }
    delay = (options[:delay] || 30).to_i

    running = true
    trap("INT") { running = false; puts "[stopping]" }

    # THE HEADER
    header = Proc.new do
      puts
      headers("-", time[:width], *names.map { |n| [n, load_column_width] }.flatten)
    end

    while running
      uptimes = {}
      run "uptime" do |ch, stream, data|
        raise "error: #{data}" if stream == :err
        uptimes[ch[:host]] = parser[data.strip]
      end

      # redisplay the header every 40 rows
      header.call if time[:rows] % 40 == 0

      print(date_column(:show, time), "  ")
      servers.each { |server| print(uptimes[server].join("/"), "  ") }
      puts

      # sleep this way, so that CTRL-C works immediately
      delay.times { sleep 1; break unless running }
    end
  end

  # Monitor the number of requests per second being logged on the various
  # servers.
  def requests_per_second(*logs)
    # extract our configurable options from the arguments
    options = logs.last.is_a?(Hash) ? logs.pop : {}
    request_pattern = options[:request_pattern] || "Completed in [0-9]"
    sample_size = options[:sample_size] || 5
    stats_to_show = options[:stats] || [0, 1, 5, 15]
    num_format = options[:format] || "%4.1f"

    # set up the date column formatter, and get the list of servers
    time = date_column(:init)
    servers = current_task.servers.sort

    # initialize various helper variables we'll be using
    mutex = Mutex.new
    count = Hash.new(0)
    running = false
    channels = {}

    windows = Hash.new { |h,k|
      h[k] = {
        1  => [], # last 1 minute
        5  => [], # last 5 minutes
        15 => []  # last 15 minutes
      }
    }

    minute_1 = 60 / sample_size
    minute_5 = 300 / sample_size
    minute_15 = 900 / sample_size

    # store our helper script on the servers. This script reduces the amount
    # of traffic caused by tailing busy logs across the network, and also reduces
    # the amount of work the client has to do.
    script = "#{remote_env("HOME")}/x-request-counter.rb"
    put_asset "request-counter.rb", script

    # set up (but don't start) the runner thread, which accumulates request
    # counts from the servers.
    runner = Thread.new do Thread.stop
      running = true
      run("echo 0 && tail -F #{logs.join(" ")} | ruby #{script} '#{request_pattern}'") do |ch, stream, out|
        channels[ch[:host]] ||= ch
        puts "#{ch[:host]}: #{out}" and break if stream == :err
        mutex.synchronize { count[ch[:host]] += out.to_i }
      end
      running = false
    end

    # let the runner thread get started
    runner.wakeup
    sleep 0.01 while !running

    # trap interrupt for graceful shutdown
    trap("INT") { puts "[stopping]"; channels.values.each { |ch| ch.close; ch[:status] = 0 } }

    # compute the stuff we need to know for displaying the header
    num_len = (num_format % 1).length
    column_width = num_len * (servers.length + 1) + servers.length
    abbvs = servers.map { |server| server.match(/^(\w+)/)[1][0,num_len] }
    col_header = abbvs.map { |v| "%-*s" % [num_len, v] }.join("/")

    # write both rows of the header
    stat_columns = stats_to_show.map { |n|
        case n
        when 0 then "#{sample_size} sec"
        when 1 then "1 min"
        when 5 then "5 min"
        when 15 then "15 min"
        else raise "unknown statistic #{n.inspect}"
        end
      }

    header = Proc.new do
      puts
      headers(" ", time[:width], *stat_columns.map { |v| [v, column_width] }.flatten)
      headers("-", time[:width], *([col_header, column_width] * stats_to_show.length))
    end
    
    while running
      # sleep for the specified sample size (5s by default)
      (sample_size * 2).times { sleep(0.5); break unless running }
      break unless running

      # lock the counters and compute our stats at this point in time
      mutex.synchronize do
        totals = Hash.new { |h,k| h[k] = Hash.new(0) }

        # for each server...
        count.each do |k,c|
          # push the latest sample onto the tracking queues
          windows[k][1] = windows[k][1].push(count[k]).last(minute_1)
          windows[k][5] = windows[k][5].push(count[k]).last(minute_5)
          windows[k][15] = windows[k][15].push(count[k]).last(minute_15)

          # compute the stats for this server (k)
          totals[k][0] = count[k].to_f / sample_size
          totals[k][1] = windows[k][1].inject(0) { |n,i| n + i } / (windows[k][1].length * sample_size).to_f
          totals[k][5] = windows[k][5].inject(0) { |n,i| n + i } / (windows[k][5].length * sample_size).to_f
          totals[k][15] = windows[k][15].inject(0) { |n,i| n + i } / (windows[k][15].length * sample_size).to_f

          # add those stats to the totals per category
          totals[:total][0] += totals[k][0]
          totals[:total][1] += totals[k][1]
          totals[:total][5] += totals[k][5]
          totals[:total][15] += totals[k][15]
        end

        # redisplay the header every 40 rows
        header.call if time[:rows] % 40 == 0

        # show the stats
        print(date_column(:show, time))
        stats_to_show.each do |stat|
          print "  "
          servers.each { |server| print "#{num_format}/" % totals[server][stat] }
          print(num_format % totals[:total][stat])
        end
        puts

        # reset the sample counter
        count = Hash.new(0)
      end
    end
  end

  def put_asset(name, to)
    put(File.read("#{File.dirname(__FILE__)}/assets/#{name}"), to)
  end

  def uptime
    results = {}

    puts "querying servers..."
    run "uptime" do |ch, stream, out|
      if stream == :err
        results[ch[:host]] = { :error => "error: #{out.strip}" }
      else
        if out.strip =~ /(\S+)\s+up\s+(.*?),\s+(\d+) users?,\s+load averages?: (.*)/
          time   = $1
          uptime = $2
          users  = $3
          loads  = $4

          results[ch[:host]] = { :uptime => uptime.strip.gsub(/  +/, " "),
                                 :loads  => loads,
                                 :users  => users,
                                 :time   => time }
        else
          results[ch[:host]] = { :error => "unknown uptime format: #{out.strip}" }
        end
      end
    end

    longest_hostname = results.keys.map { |k| k.length }.max
    longest_uptime = results.values.map { |v| (v[:uptime] || "").length }.max

    by_role = {}
    roles.each do |name, list|
      by_role[name] = {}
      list.each do |role|
        next unless results[role.host]
        by_role[name][role.host] = results.delete(role.host)
      end
    end

    by_role[:zzz] = results unless results.empty?

    add_newline = false
    by_role.keys.sort_by { |k| k.to_s }.each do |role|
      results = by_role[role]
      next if results.empty?

      puts "\n" if add_newline
      add_newline = true

      results.keys.sort.each do |server|
        print "[%-*s] " % [longest_hostname, server]
        if results[server][:error]
          puts results[server][:error]
        else
          puts "up %*s, load %s" % [longest_uptime, results[server][:uptime], results[server][:loads]]
        end
      end
    end
  end
end

Capistrano.plugin :monitor, MonitorServers

configuration = Capistrano::Configuration.respond_to?(:instance) ?
  Capistrano::Configuration.instance(:must_exist) :
  Capistrano.configuration(:must_exist)

configuration.load do
desc <<-STR
Watch the load on the servers. Display is updated every 30 seconds by default,
though you can specify a DELAY environment variable to make it update more or
less frequently.
STR
task :watch_load do
  monitor.load :delay => ENV["DELAY"]
end

desc <<-STR
Watch the number of requests/sec being logged on the application servers. By
default, the "production.log" is watched, but if your log is named something
else, you can specify it in the log_name variable.
STR
task :watch_requests, :roles => :app do
  monitor.requests_per_second("#{shared_path}/log/#{self[:log_name] || "production.log"}")
end

desc <<-STR
Display the current uptime and load for all servers, nicely formatted with
columns all lined up for easy scanning.
STR
task :uptime do
  monitor.uptime
end
end
