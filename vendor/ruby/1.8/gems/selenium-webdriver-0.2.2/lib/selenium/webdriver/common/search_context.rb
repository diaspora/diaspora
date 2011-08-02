module Selenium
  module WebDriver
    module SearchContext

      FINDERS = {
        :class             => 'ClassName',
        :class_name        => 'ClassName',
        :css               => 'CssSelector',
        :id                => 'Id',
        :link              => 'LinkText',
        :link_text         => 'LinkText',
        :name              => 'Name',
        :partial_link_text => 'PartialLinkText',
        :tag_name          => 'TagName',
        :xpath             => 'Xpath',
      }

      #
      # Find the first element matching the given arguments.
      #
      # When using Element#find_element with :xpath, be aware that webdriver
      # follows standard conventions: a search prefixed with "//" will search
      # the entire document, not just the children of this current node. Use
      # ".//" to limit your search to the children of the receiving Element.
      #
      # @param [:class, :class_name, :css, :id, :link_text, :link, :partial_link_text, :name, :tag_name, :xpath] how
      # @param [String] what
      # @return [WebDriver::Element]
      #
      # @raise [NoSuchElementError] if the element doesn't exist
      #
      #

      def find_element(*args)
        how, what = extract_args(args)

        unless by = FINDERS[how.to_sym]
          raise ArgumentError, "cannot find element by #{how.inspect}"
        end

        meth = "findElementBy#{by}"
        what = what.to_s

        bridge.send meth, ref, what
      end

      #
      # Find all elements matching the given arguments
      #
      # @see SearchContext#find_element
      #
      # @param [:class, :class_name, :css, :id, :link_text, :link, :partial_link_text, :name, :tag_name, :xpath] how
      # @param [String] what
      # @return [Array<WebDriver::Element>]
      #

      def find_elements(*args)
        how, what = extract_args(args)

        unless by = FINDERS[how.to_sym]
          raise ArgumentError, "cannot find elements by #{how.inspect}"
        end

        meth = "findElementsBy#{by}"
        what = what.to_s

        bridge.send meth, ref, what
      end

      private

      def extract_args(args)
        case args.size
        when 2
          args
        when 1
          arg = args.first

          unless arg.respond_to?(:shift)
            raise ArgumentError, "expected #{arg.inspect}:#{arg.class} to respond to #shift"
          end

          # this will be a single-entry hash, so use #shift over #first or #[]
          arr = arg.dup.shift
          unless arr.size == 2
            raise ArgumentError, "expected #{arr.inspect} to have 2 elements"
          end

          arr
        else
          raise ArgumentError, "wrong number of arguments (#{args.size} for 2)"
        end
      end

    end # SearchContext
  end # WebDriver
end # Selenium
