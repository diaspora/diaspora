module Capybara
  module Searchable
    def find(*args)
      all(*args).first
    end

    def find_field(locator)
      find(:xpath, XPath.field(locator))
    end
    alias_method :field_labeled, :find_field

    def find_link(locator)
      find(:xpath, XPath.link(locator))
    end

    def find_button(locator)
      find(:xpath, XPath.button(locator))
    end

    def find_by_id(id)
      find(:css, "##{id}")
    end

    def all(*args)
      options = if args.last.is_a?(Hash) then args.pop else {} end
      if args[1].nil?
        kind, locator = Capybara.default_selector, args.first
      else
        kind, locator = args
      end
      locator = XPath.from_css(locator) if kind == :css

      results = all_unfiltered(locator)

      if options[:text]
        options[:text] = Regexp.escape(options[:text]) unless options[:text].kind_of?(Regexp)
        results = results.select { |n| n.text.match(options[:text]) }
      end

      if options[:visible] or Capybara.ignore_hidden_elements
        results = results.select { |n| n.visible? }
      end

      results
    end

    private

    def all_unfiltered(locator)
      raise "Must be overridden"
    end

  end
end
