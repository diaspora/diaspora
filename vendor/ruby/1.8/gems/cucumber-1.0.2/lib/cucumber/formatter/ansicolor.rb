begin
  require 'term/ansicolor'
rescue LoadError
  require 'rubygems'
  require 'term/ansicolor'
end
require 'cucumber/platform'

if Cucumber::IRONRUBY
	begin
		require 'iron-term-ansicolor'
	rescue LoadError
		STDERR.puts %{*** WARNING: You must "igem install iron-term-ansicolor" to get coloured ouput in on IronRuby}
	end
end

if Cucumber::WINDOWS_MRI
  unless ENV['ANSICON']
    STDERR.puts %{*** WARNING: You must use ANSICON 1.31 or higher (http://adoxa.110mb.com/ansicon) to get coloured output on Windows}
    Term::ANSIColor.coloring = false
  end
end

Term::ANSIColor.coloring = false if !STDOUT.tty? && !ENV.has_key?('AUTOTEST')

module Cucumber
  module Formatter
    # Defines aliases for coloured output. You don't invoke any methods from this
    # module directly, but you can change the output colours by defining
    # a <tt>CUCUMBER_COLORS</tt> variable in your shell, very much like how you can
    # tweak the familiar POSIX command <tt>ls</tt> with
    # <a href="http://mipsisrisc.com/rambling/2008/06/27/lscolorsls_colors-now-with-linux-support/">$LSCOLORS/$LS_COLORS</a>
    #
    # The colours that you can change are:
    #
    # * <tt>undefined</tt>     - defaults to <tt>yellow</tt>
    # * <tt>pending</tt>       - defaults to <tt>yellow</tt>
    # * <tt>pending_param</tt> - defaults to <tt>yellow,bold</tt>
    # * <tt>failed</tt>        - defaults to <tt>red</tt>
    # * <tt>failed_param</tt>  - defaults to <tt>red,bold</tt>
    # * <tt>passed</tt>        - defaults to <tt>green</tt>
    # * <tt>passed_param</tt>  - defaults to <tt>green,bold</tt>
    # * <tt>outline</tt>       - defaults to <tt>cyan</tt>
    # * <tt>outline_param</tt> - defaults to <tt>cyan,bold</tt>
    # * <tt>skipped</tt>       - defaults to <tt>cyan</tt>
    # * <tt>skipped_param</tt> - defaults to <tt>cyan,bold</tt>
    # * <tt>comment</tt>       - defaults to <tt>grey</tt>
    # * <tt>tag</tt>           - defaults to <tt>cyan</tt>
    #
    # For instance, if your shell has a black background and a green font (like the
    # "Homebrew" settings for OS X' Terminal.app), you may want to override passed
    # steps to be white instead of green. Examples:
    #
    #   export CUCUMBER_COLORS="passed=white"
    #   export CUCUMBER_COLORS="passed=white,bold:passed_param=white,bold,underline"
    #
    # (If you're on Windows, use SET instead of export).
    # To see what colours and effects are available, just run this in your shell:
    #
    #   ruby -e "require 'rubygems'; require 'term/ansicolor'; puts Term::ANSIColor.attributes"
    #
    # Although not listed, you can also use <tt>grey</tt>
    module ANSIColor
      include Term::ANSIColor

      ALIASES = Hash.new do |h,k|
        if k.to_s =~ /(.*)_param/
          h[$1] + ',bold'
        end
      end.merge({
        'undefined' => 'yellow',
        'pending'   => 'yellow',
        'failed'    => 'red',
        'passed'    => 'green',
        'outline'   => 'cyan',
        'skipped'   => 'cyan',
        'comment'   => 'grey',
        'tag'       => 'cyan'
      })

      if ENV['CUCUMBER_COLORS'] # Example: export CUCUMBER_COLORS="passed=red:failed=yellow"
        ENV['CUCUMBER_COLORS'].split(':').each do |pair|
          a = pair.split('=')
          ALIASES[a[0]] = a[1]
        end
      end

      ALIASES.each do |method, color|
        unless method =~ /.*_param/
          code = <<-EOF
          def #{method}(string=nil, &proc)
            #{ALIASES[method].split(",").join("(") + "(string, &proc" + ")" * ALIASES[method].split(",").length}
          end
          # This resets the colour to the non-param colour
          def #{method}_param(string=nil, &proc)
            #{ALIASES[method+'_param'].split(",").join("(") + "(string, &proc" + ")" * ALIASES[method+'_param'].split(",").length} + #{ALIASES[method].split(",").join(' + ')}
          end
          EOF
          eval(code)
        end
      end
      
      def self.define_grey #:nodoc:
        begin
          gem 'genki-ruby-terminfo'
          require 'terminfo'
          case TermInfo.default_object.tigetnum("colors")
          when 0
            raise "Your terminal doesn't support colours"
          when 1
            ::Term::ANSIColor.coloring = false
            alias grey white
          when 2..8
            alias grey white
          else
            define_real_grey
          end
        rescue Exception => e
          if e.class.name == 'TermInfo::TermInfoError'
            STDERR.puts "*** WARNING ***"
            STDERR.puts "You have the genki-ruby-terminfo gem installed, but you haven't set your TERM variable."
            STDERR.puts "Try setting it to TERM=xterm-256color to get grey colour in output"
            STDERR.puts "\n"
            alias grey white
          else
            define_real_grey
          end
        end
      end
      
      def self.define_real_grey #:nodoc:
        def grey(m) #:nodoc:
          if ::Term::ANSIColor.coloring?
            "\e[90m#{m}\e[0m"
          else
            m
          end
        end
      end
      
      define_grey

      def cukes(n)
        ("(::) " * n).strip
      end

      def green_cukes(n)
        blink(green(cukes(n)))
      end

      def red_cukes(n)
        blink(red(cukes(n)))
      end

      def yellow_cukes(n)
        blink(yellow(cukes(n)))
      end
    end
  end
end
