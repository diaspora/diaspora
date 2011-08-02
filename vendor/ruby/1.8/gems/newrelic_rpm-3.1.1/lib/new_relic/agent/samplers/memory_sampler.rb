require 'new_relic/agent/sampler'

module NewRelic
  module Agent
    module Samplers

      class MemorySampler < NewRelic::Agent::Sampler
        attr_accessor :sampler

        def initialize
          super :memory
          # macos, linux, solaris
          if defined? JRuby
            @sampler = JavaHeapSampler.new
          elsif platform =~ /linux/
            @sampler = ProcStatus.new
            if !@sampler.can_run?
              NewRelic::Agent.instance.warn.debug "Error attempting to use /proc/#{$$}/status file for reading memory. Using ps command instead."
              @sampler = ShellPS.new("ps -o rsz")
            else
              NewRelic::Agent.instance.log.debug "Using /proc/#{$$}/status for reading process memory."
            end
          elsif platform =~ /darwin9/ # 10.5
            @sampler = ShellPS.new("ps -o rsz")
          elsif platform =~ /darwin10/ # 10.6
            @sampler = ShellPS.new("ps -o rss")
          elsif platform =~ /freebsd/
            @sampler = ShellPS.new("ps -o rss")
          elsif platform =~ /solaris/
            @sampler = ShellPS.new("/usr/bin/ps -o rss -p")
          end

          raise Unsupported, "Unsupported platform for getting memory: #{platform}" if @sampler.nil?
          raise Unsupported, "Unable to run #{@sampler}" unless @sampler.can_run?
        end

        def self.supported_on_this_platform?
          defined?(JRuby) or platform =~ /linux|darwin9|darwin10|freebsd|solaris/
        end

        def self.platform
          if RUBY_PLATFORM =~ /java/
            %x[uname -s].downcase
          else
            RUBY_PLATFORM.downcase
          end
        end
        def platform
          NewRelic::Agent::Samplers::MemorySampler.platform
        end

        def stats
          stats_engine.get_stats("Memory/Physical", false)
        end
        def poll
          sample = @sampler.get_sample
          stats.record_data_point sample if sample
          stats
        end
        class Base
          def can_run?
            return false if @broken
            m = get_memory rescue nil
            m && m > 0
          end
          def get_sample
            return nil if @broken
            begin
              m = get_memory
              if m.nil?
                NewRelic::Agent.instance.log.error "Unable to get the resident memory for process #{$$}.  Disabling memory sampler."
                @broken = true
              end
              return m
            rescue => e
              NewRelic::Agent.instance.log.error "Unable to get the resident memory for process #{$$}. (#{e})"
              NewRelic::Agent.instance.log.debug e.backtrace.join("\n  ")
              NewRelic::Agent.instance.log.error "Disabling memory sampler."
              @broken = true
              return nil
            end
          end
        end

        class JavaHeapSampler < Base

          def get_memory
            raise "Can't sample Java heap unless running in JRuby" unless defined? JRuby
            java.lang.Runtime.getRuntime.totalMemory / (1024 * 1024).to_f rescue nil
          end
          def to_s
            "JRuby Java heap sampler"
          end
        end

        class ShellPS < Base
          def initialize(command)
            super()
            @command = command
          end
          # Returns the amount of resident memory this process is using in MB
          #
          def get_memory
            process = $$
            memory = `#{@command} #{process}`.split("\n")[1].to_f / 1024.0 rescue nil
            # if for some reason the ps command doesn't work on the resident os,
            # then don't execute it any more.
            raise "Faulty command: `#{@command} #{process}`" if memory.nil? || memory <= 0
            memory
          end
          def to_s
            "shell command sampler: #{@command}"
          end
        end

        # ProcStatus
        #
        # A class that samples memory by reading the file /proc/$$/status, which is specific to linux
        #
        class ProcStatus < Base

          # Returns the amount of resident memory this process is using in MB
          #
          def get_memory
            File.open(proc_status_file, "r") do |f|
              while !f.eof?
                if f.readline =~ /RSS:\s*(\d+) kB/i
                  return $1.to_f / 1024.0
                end
              end
            end
            raise "Unable to find RSS in #{proc_status_file}"
          end
          def proc_status_file
            "/proc/#{$$}/status"
          end
          def to_s
            "proc status file sampler: #{proc_status_file}"
          end
        end
      end
    end
  end
end
