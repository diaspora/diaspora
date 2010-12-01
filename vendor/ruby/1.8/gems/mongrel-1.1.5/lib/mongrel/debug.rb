# Copyright (c) 2005 Zed A. Shaw 
# You can redistribute it and/or modify it under the same terms as Ruby.
#
# Additional work donated by contributors.  See http://mongrel.rubyforge.org/attributions.html 
# for more information.

require 'logger'
require 'set'
require 'socket'
require 'fileutils'

module MongrelDbg
  SETTINGS = { :tracing => {}}
  LOGGING = { }

  def MongrelDbg::configure(log_dir = File.join("log","mongrel_debug"))
    FileUtils.mkdir_p(log_dir)
    @log_dir = log_dir
    $objects_out=open(File.join("log","mongrel_debug","objects.log"),"w")
    $objects_out.puts "run,classname,last,count,delta,lenmean,lensd,lenmax"
    $objects_out.sync = true
    $last_stat = nil
    $run_count = 0
  end

  
  def MongrelDbg::trace(target, message)
    if SETTINGS[:tracing][target] and LOGGING[target]
      LOGGING[target].log(Logger::DEBUG, message)
    end
  end

  def MongrelDbg::begin_trace(target)
    SETTINGS[:tracing][target] = true
    if not LOGGING[target]
      LOGGING[target] = Logger.new(File.join(@log_dir, "#{target.to_s}.log"))
    end                          
    MongrelDbg::trace(target, "TRACING ON #{Time.now}")
  end

  def MongrelDbg::end_trace(target)
    SETTINGS[:tracing][target] = false
    MongrelDbg::trace(target, "TRACING OFF #{Time.now}")
    LOGGING[target].close
    LOGGING[target] = nil
  end

  def MongrelDbg::tracing?(target)
    SETTINGS[:tracing][target]
  end
end



$open_files = {}

class IO
  alias_method :orig_open, :open
  alias_method :orig_close, :close

  def open(*arg, &blk)
    $open_files[self] = args.inspect
    orig_open(*arg,&blk)
  end

  def close(*arg,&blk)
    $open_files.delete self
    orig_close(*arg,&blk)
  end
end


module Kernel
  alias_method :orig_open, :open

  def open(*arg, &blk)
    $open_files[self] = arg[0]
    orig_open(*arg,&blk)
  end

  def log_open_files
    open_counts = {}
    $open_files.each do |f,args|
      open_counts[args] ||= 0
      open_counts[args] += 1
    end
    MongrelDbg::trace(:files, open_counts.to_yaml)
  end
end  



module RequestLog

  # Just logs whatever requests it gets to STDERR (which ends up in the mongrel
  # log when daemonized).
  class Access < GemPlugin::Plugin "/handlers"
    include Mongrel::HttpHandlerPlugin
    
    def process(request,response)
      p = request.params
      STDERR.puts "#{p['REMOTE_ADDR']} - [#{Time.now.httpdate}] \"#{p['REQUEST_METHOD']} #{p["REQUEST_URI"]} HTTP/1.1\""
    end
  end
  

  class Files < GemPlugin::Plugin "/handlers"
    include Mongrel::HttpHandlerPlugin
    
    def process(request, response)
      MongrelDbg::trace(:files, "#{Time.now} FILES OPEN BEFORE REQUEST #{request.params['PATH_INFO']}")
      log_open_files
    end
    
  end

  # stolen from Robert Klemme
  class Objects < GemPlugin::Plugin "/handlers"
    include Mongrel::HttpHandlerPlugin

    def process(request,response)
      begin
        stats = Hash.new(0)
        lengths = {}
        begin
          ObjectSpace.each_object do |o| 
            begin
              if o.respond_to? :length
                len = o.length
                lengths[o.class] ||= Mongrel::Stats.new(o.class)
                lengths[o.class].sample(len)
              end
            rescue Object
            end
  
            stats[o.class] += 1
          end
        rescue Object # Ignore since ObjectSpace might not be loaded on JRuby
        end

        stats.sort {|(k1,v1),(k2,v2)| v2 <=> v1}.each do |k,v|
          if $last_stat
            delta = v - $last_stat[k]
            if v > 10 and delta != 0
              if lengths[k]
                $objects_out.printf "%d,%s,%d,%d,%d,%f,%f,%f\n", $run_count, k, $last_stat[k], v, delta,lengths[k].mean,lengths[k].sd,lengths[k].max
              else
                $objects_out.printf "%d,%s,%d,%d,%d,,,\n", $run_count, k, $last_stat[k], v, delta
              end
            end
          end
        end

        $run_count += 1
        $last_stat = stats
      rescue Object
        STDERR.puts "object.log ERROR: #$!"
      end
    end
  end

  class Params < GemPlugin::Plugin "/handlers"
    include Mongrel::HttpHandlerPlugin

    def process(request, response)
      MongrelDbg::trace(:rails, "#{Time.now} REQUEST #{request.params['PATH_INFO']}")
      MongrelDbg::trace(:rails, request.params.to_yaml)
    end

  end

  class Threads < GemPlugin::Plugin "/handlers"
    include Mongrel::HttpHandlerPlugin

    def process(request, response)
      MongrelDbg::trace(:threads, "#{Time.now} REQUEST #{request.params['PATH_INFO']}")
      begin
        ObjectSpace.each_object do |obj|
          begin
            if obj.class == Mongrel::HttpServer
              worker_list = obj.workers.list
  
              if worker_list.length > 0
                keys = "-----\n\tKEYS:"
                worker_list.each {|t| keys << "\n\t\t-- #{t}: #{t.keys.inspect}" }
              end
  
              MongrelDbg::trace(:threads, "#{obj.host}:#{obj.port} -- THREADS: #{worker_list.length} #{keys}")
            end
          rescue Object # Ignore since obj.class can sometimes take parameters            
          end
        end
      rescue Object # Ignore since ObjectSpace might not be loaded on JRuby
      end
    end
  end
end


END {
  MongrelDbg::trace(:files, "FILES OPEN AT EXIT")
  log_open_files
}
