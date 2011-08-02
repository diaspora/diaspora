# Copyright (c) 2008 Nicholas A. Evans
# http://ekenosen.net/nick/devblog/2008/12/better-progress-bar-for-rspec/
#
# With some tweaks (slow spec profiler, growl support)
# By Nick Zadrozny
# http://gist.github.com/71340
#  
# Further tweaks (formatador, elapsed time instead of eta)
# By geemus (Wesley Beary)
# http://gist.github.com/266221
#
# Permission is hereby granted, free of charge, to any person obtaining
# a copy of this software and associated documentation files (the
# "Software"), to deal in the Software without restriction, including
# without limitation the rights to use, copy, modify, merge, publish,
# distribute, sublicense, and/or sell copies of the Software, and to
# permit persons to whom the Software is furnished to do so, subject to
# the following conditions:
#  
# The above copyright notice and this permission notice shall be
# included in all copies or substantial portions of the Software.
#  
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
# EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
# MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
# NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE
# LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION
# OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION
# WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

require 'spec/runner/formatter/base_text_formatter'
require "rubygems"
require 'formatador'

module Spec
  module Runner
    module Formatter
      class CompactProgressBarFormatter < BaseTextFormatter
        # Threshold for slow specs, in seconds.
        # Anything that takes longer than this will be printed out
        # It would be great to get this down to 0.5 or less...
        SLOW_SPEC_THRESHOLD = 2.0

        # Keep track the slowest specs and print a report at the end
        SLOW_SPEC_REPORT = 3

        attr_reader :total, :current

        def start(example_count)
          @current     = 0
          @started_at  = Time.now
          @total       = example_count
          @error_state = :all_passing
          @slow_specs  = []
          @formatador  = Formatador.new
          @formatador.display_line
        end

        def example_started(example)
          super
          @start_time = Time.now
        end

        def example_passed(example)
          elapsed = Time.now - @start_time
          profile_example(example_group.description, example.description, elapsed)
          increment
        end

        # third param is optional, because earlier versions of rspec sent only two args
        def example_pending(example, message, pending_caller=nil)
          immediately_dump_pending(example.description, message, pending_caller)
          mark_error_state_pending
          increment
        end

        def example_failed(example, counter, failure)
          immediately_dump_failure(counter, failure)
          notify_failure(counter, failure)
          mark_error_state_failed
          increment
        end

        def start_dump
          @formatador.display_line("\n")
          report_slow_specs
        end

        def dump_failure(*args)
          # no-op; we summarized failures as we were running
        end

        def method_missing(sym, *args)
          # ignore
        end

        def notify(title, message, priority)
          title = title.gsub(/\s+/, ' ').gsub(/"/,'\"').gsub(/'/, "\'")
          message = message.gsub(/\s+/, ' ').gsub(/"/,'\"').gsub(/'/, "\'").gsub(/`/,'\`')
          notify_command = case RUBY_PLATFORM
          when /darwin/
            "test -x `which growlnotify` && growlnotify -n autotest -p #{priority} -m \"#{message}\" \"#{title}\""
          when /linux/
            "test -x `which notify-send` && notify-send \"#{title}\" \"#{message}\""
          end
          # puts notify_command # use this for debugging purposes
          system notify_command if notify_command
        end

        def notify_failure(counter, failure)
          notify failure.header, failure.exception.message, 2
        end

        # stolen and slightly modified from BaseTextFormatter#dump_failure
        def immediately_dump_failure(counter, failure)
          @formatador.redisplay("#{' ' * progress_bar.length}\n")
          @formatador.redisplay("[red]#{counter.to_s})[/]")
          @formatador.display_line("[red]#{failure.header}[/]")
          @formatador.indent do
            @formatador.display_line("[red]#{failure.exception.message}[/]")
            @formatador.display_line
            failure.exception.backtrace.each do |line|
              @formatador.display_line("[red]#{line}[/]")
            end
            @formatador.display_line
          end
        end

        # stolen and modified from BaseTextFormatter#dump_pending
        def immediately_dump_pending(desc, msg, called_from)
          @formatador.indent do
            @formatador.redisplay("#{' ' * progress_bar.length}\r")
            @formatador.display_line("[yellow]PENDING SPEC:[/] #{desc} (#{msg})\n")
          end
          # output.puts "  Called from #{called_from}" if called_from
        end

        def increment
          @current += 1
          @formatador.redisplay(progress_bar)
        end

        def mark_error_state_failed
          @error_state = :some_failed
        end

        def mark_error_state_pending
          @error_state = :some_pending unless @error_state == :some_failed
        end

        def progress_bar
          color = case @error_state
          when :some_failed
            'red'
          when :some_pending
            'yellow'
          else
            'green'
          end
          ratio = "#{(' ' * (@total.to_s.size - @current.to_s.size))}#{@current}/#{@total}"
          fraction = "[#{color}]#{(' ' * (@total.to_s.size - @current.to_s.size))}#{@current}/#{@total}[/]"
          percent  = @current.to_f / @total.to_f
          progress = "[_white_]|[/][#{color}][_#{color}_]#{'*' * (percent * 50).ceil}[/]#{' ' * (50 - (percent * 50).ceil)}[_white_]|[/]"
          microseconds = Time.now - @started_at
          minutes = (microseconds / 60).round.to_s
          seconds = (microseconds % 60).round.to_s
          elapsed = "#{minutes}:#{'0' if seconds.size < 2}#{seconds}"
          [fraction, progress, elapsed, ''].join('  ')
        end

        def profile_example(group, example, elapsed)
          @slow_specs = (@slow_specs + [[elapsed, group, example]]).sort.reverse[0, SLOW_SPEC_REPORT]
          print_warning_if_really_slow(group, example, elapsed)
        end
        
        def print_warning_if_really_slow(group, example, elapsed)
          if elapsed > SLOW_SPEC_THRESHOLD
            @formatador.indent do
              @formatador.redisplay("#{' ' * progress_bar.length}\r")
              @formatador.display_line("[yellow]SLOW SPEC (#{sprintf("%.4f", elapsed)})[/]: #{group} #{example}\n")
            end
          end
        end
        
        def report_slow_specs
          @formatador.display_line("[yellow]Top #{@slow_specs.size} slowest specs:[/]")
          @slow_specs.each do |elapsed, group, example|
            @formatador.display_line("[yellow]  #{yellow(sprintf('%.4f', elapsed))} #{group} #{example}[/]")
          end
        end

      end
    end
  end
end
