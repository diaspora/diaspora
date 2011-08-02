module Gherkin
  module Formatter
    # Defines aliases for ANSI coloured output. Default colours can be overridden by defining
    # a <tt>GHERKIN_COLORS</tt> variable in your shell, very much like how you can
    # tweak the familiar POSIX command <tt>ls</tt> with
    # $LSCOLORS: http://linux-sxs.org/housekeeping/lscolors.html
    #
    # The colours that you can change are:
    #
    # <tt>undefined</tt>::     defaults to <tt>yellow</tt>
    # <tt>pending</tt>::       defaults to <tt>yellow</tt>
    # <tt>pending_arg</tt>::   defaults to <tt>yellow,bold</tt>
    # <tt>executing</tt>::     defaults to <tt>grey</tt>
    # <tt>executing_arg</tt>:: defaults to <tt>grey,bold</tt>
    # <tt>failed</tt>::        defaults to <tt>red</tt>
    # <tt>failed_arg</tt>::    defaults to <tt>red,bold</tt>
    # <tt>passed</tt>::        defaults to <tt>green</tt>
    # <tt>passed_arg</tt>::    defaults to <tt>green,bold</tt>
    # <tt>outline</tt>::       defaults to <tt>cyan</tt>
    # <tt>outline_arg</tt>::   defaults to <tt>cyan,bold</tt>
    # <tt>skipped</tt>::       defaults to <tt>cyan</tt>
    # <tt>skipped_arg</tt>::   defaults to <tt>cyan,bold</tt>
    # <tt>comment</tt>::       defaults to <tt>grey</tt>
    # <tt>tag</tt>::           defaults to <tt>cyan</tt>
    #
    # For instance, if your shell has a black background and a green font (like the
    # "Homebrew" settings for OS X' Terminal.app), you may want to override passed
    # steps to be white instead of green. Examples:
    #
    #   export GHERKIN_COLORS="passed=white"
    #   export GHERKIN_COLORS="passed=white,bold:passed_arg=white,bold,underline"
    #
    # (If you're on Windows, use SET instead of export).
    # To see what colours and effects are available, just run this in your shell:
    #
    #   ruby -e "require 'rubygems'; require 'term/ansicolor'; puts Term::ANSIColor.attributes"
    #
    # Although not listed, you can also use <tt>grey</tt>
    module AnsiEscapes
      COLORS = {
        'black'   => "\e[30m",
        'red'     => "\e[31m",
        'green'   => "\e[32m",
        'yellow'  => "\e[33m",
        'blue'    => "\e[34m",
        'magenta' => "\e[35m",
        'cyan'    => "\e[36m",
        'white'   => "\e[37m",
        'grey'    => "\e[90m",
        'bold'    => "\e[1m"
      }

      ALIASES = Hash.new do |h,k|
        if k.to_s =~ /(.*)_arg/
          h[$1] + ',bold'
        end
      end.merge({
        'undefined' => 'yellow',
        'pending'   => 'yellow',
        'executing' => 'grey',
        'failed'    => 'red',
        'passed'    => 'green',
        'outline'   => 'cyan',
        'skipped'   => 'cyan',
        'comments'  => 'grey',
        'tag'       => 'cyan'
      })

      if ENV['GHERKIN_COLORS'] # Example: export GHERKIN_COLORS="passed=red:failed=yellow"
        ENV['GHERKIN_COLORS'].split(':').each do |pair|
          a = pair.split('=')
          ALIASES[a[0]] = a[1]
        end
      end

      ALIASES.keys.each do |key|
        define_method(key) do
          ALIASES[key].split(',').map{|color| COLORS[color]}.join('')
        end

        define_method("#{key}_arg") do
          ALIASES["#{key}_arg"].split(',').map{|color| COLORS[color]}.join('')
        end
      end
      
      def reset
        "\e[0m"
      end

      def up(n)
        "\e[#{n}A"
      end
    end
  end
end
