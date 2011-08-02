require 'tilt/template'

module Tilt
  # Discount Markdown implementation. See:
  # http://github.com/rtomayko/rdiscount
  #
  # RDiscount is a simple text filter. It does not support +scope+ or
  # +locals+. The +:smart+ and +:filter_html+ options may be set true
  # to enable those flags on the underlying RDiscount object.
  class RDiscountTemplate < Template
    self.default_mime_type = 'text/html'

    ALIAS = {
      :escape_html => :filter_html,
      :smartypants => :smart
    }

    FLAGS = [:smart, :filter_html, :smartypants, :escape_html]

    def flags
      FLAGS.select { |flag| options[flag] }.map { |flag| ALIAS[flag] || flag }
    end

    def self.engine_initialized?
      defined? ::RDiscount
    end

    def initialize_engine
      require_template_library 'rdiscount'
    end

    def prepare
      @engine = RDiscount.new(data, *flags)
      @output = nil
    end

    def evaluate(scope, locals, &block)
      @output ||= @engine.to_html
    end
  end

  # Upskirt Markdown implementation. See:
  # https://github.com/tanoku/redcarpet
  #
  # Compatible to RDiscount
  class RedcarpetTemplate < RDiscountTemplate
    self.default_mime_type = 'text/html'

    def self.engine_initialized?
      defined? ::RedcarpetCompat
    end

    def initialize_engine
      require_template_library 'redcarpet'
    end

    def prepare
      @engine = RedcarpetCompat.new(data, *flags)
      @output = nil
    end
  end

  # BlueCloth Markdown implementation. See:
  # http://deveiate.org/projects/BlueCloth/
  class BlueClothTemplate < Template
    self.default_mime_type = 'text/html'

    def self.engine_initialized?
      defined? ::BlueCloth
    end

    def initialize_engine
      require_template_library 'bluecloth'
    end

    def prepare
      @engine = BlueCloth.new(data, options)
      @output = nil
    end

    def evaluate(scope, locals, &block)
      @output ||= @engine.to_html
    end
  end

  # Maruku markdown implementation. See:
  # http://maruku.rubyforge.org/
  class MarukuTemplate < Template
    def self.engine_initialized?
      defined? ::Maruku
    end

    def initialize_engine
      require_template_library 'maruku'
    end

    def prepare
      @engine = Maruku.new(data, options)
      @output = nil
    end

    def evaluate(scope, locals, &block)
      @output ||= @engine.to_html
    end
  end

  # Kramdown Markdown implementation. See:
  # http://kramdown.rubyforge.org/
  class KramdownTemplate < Template
    DUMB_QUOTES = [39, 39, 34, 34]

    def self.engine_initialized?
      defined? ::Kramdown
    end

    def initialize_engine
      require_template_library 'kramdown'
    end

    def prepare
      options[:smart_quotes] = DUMB_QUOTES unless options[:smartypants]
      @engine = Kramdown::Document.new(data, options)
      @output = nil
    end

    def evaluate(scope, locals, &block)
      @output ||= @engine.to_html
    end
  end
end

