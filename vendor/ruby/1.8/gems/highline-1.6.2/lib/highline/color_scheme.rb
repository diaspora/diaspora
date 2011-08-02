#!/usr/local/bin/ruby -w

# color_scheme.rb
#
# Created by Jeremy Hinegardner on 2007-01-24
# Copyright 2007.  All rights reserved
#
# This is Free Software.  See LICENSE and COPYING for details

class HighLine
  #
  # ColorScheme objects encapsulate a named set of colors to be used in the
  # HighLine.colors() method call.  For example, by applying a ColorScheme that
  # has a <tt>:warning</tt> color then the following could be used:
  #
  #   colors("This is a warning", :warning)
  #
  # A ColorScheme contains named sets of HighLine color constants. 
  #
  # Example: Instantiating a color scheme, applying it to HighLine,
  #          and using it:
  #
  #   ft = HighLine::ColorScheme.new do |cs|
  #          cs[:headline]        = [ :bold, :yellow, :on_black ]
  #          cs[:horizontal_line] = [ :bold, :white ]
  #          cs[:even_row]        = [ :green ]
  #          cs[:odd_row]         = [ :magenta ]
  #        end 
  #
  #   HighLine.color_scheme = ft
  #   say("<%= color('Headline', :headline) %>")
  #   say("<%= color('-'*20, :horizontal_line) %>")
  #   i = true
  #   ("A".."D").each do |row|
  #      if i then
  #        say("<%= color('#{row}', :even_row ) %>")
  #      else
  #        say("<%= color('#{row}', :odd_row) %>")
  #      end 
  #      i = !i
  #   end
  #
  #
  class ColorScheme 
    #
    # Create an instance of HighLine::ColorScheme. The customization can
    # happen as a passed in Hash or via the yielded block.  Key's are
    # converted to <tt>:symbols</tt> and values are converted to HighLine
    # constants.
    #
    def initialize( h = nil )
      @scheme = Hash.new
      load_from_hash(h) unless h.nil?
      yield self if block_given?
    end

    # Load multiple colors from key/value pairs.
    def load_from_hash( h )
      h.each_pair do |color_tag, constants|
        self[color_tag] = constants
      end
    end

    # Does this color scheme include the given tag name?
    def include?( color_tag )
      @scheme.keys.include?(to_symbol(color_tag))
    end

    # Allow the scheme to be accessed like a Hash.
    def []( color_tag )
      @scheme[to_symbol(color_tag)]
    end

    # Allow the scheme to be set like a Hash.
    def []=( color_tag, constants )
      @scheme[to_symbol(color_tag)] = constants.map { |c| to_constant(c) }
    end

    private

    # Return a normalized representation of a color name.
    def to_symbol( t )
      t.to_s.downcase
    end

    # Return a normalized representation of a color setting.
    def to_constant( v )
      v = v.to_s if v.is_a?(Symbol)
      if v.is_a?(String) then
        HighLine.const_get(v.upcase)
      else
        v
      end
    end
  end

  # A sample ColorScheme.
  class SampleColorScheme < ColorScheme
    # 
    # Builds the sample scheme with settings for <tt>:critical</tt>,
    # <tt>:error</tt>, <tt>:warning</tt>, <tt>:notice</tt>, <tt>:info</tt>,
    # <tt>:debug</tt>, <tt>:row_even</tt>, and <tt>:row_odd</tt> colors.
    # 
    def initialize( h = nil )
      scheme = {
        :critical => [ :yellow, :on_red  ],
        :error    => [ :bold,   :red     ],
        :warning  => [ :bold,   :yellow  ],
        :notice   => [ :bold,   :magenta ],
        :info     => [ :bold,   :cyan    ],
        :debug    => [ :bold,   :green   ],
        :row_even => [ :cyan    ],
        :row_odd  => [ :magenta ]
      }
      super(scheme)
    end
  end
end
