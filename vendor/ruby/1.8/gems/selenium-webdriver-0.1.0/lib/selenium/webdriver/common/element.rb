module Selenium
  module WebDriver
    class Element
      include Find

      attr_reader :bridge

      #
      # Creates a new Element
      #
      # @private
      #

      def initialize(bridge, id)
        @bridge, @id = bridge, id
      end

      def inspect
        '#<%s:0x%x id=%s tag_name=%s>' % [self.class, hash*2, @id.inspect, tag_name.inspect]
      end

      def ==(other)
        other.kind_of?(self.class) && bridge.elementEquals(self, other)
      end
      alias_method :eql?, :==

      def hash
        ref.hash
      end

      #
      # Click the element
      #

      def click
        bridge.clickElement @id
      end

      #
      # Get the tag name of this element
      #
      # @return [String]
      #

      def tag_name
        bridge.getElementTagName @id
      end

      #
      # Get the value of this element
      #
      # @return [String]
      #

      def value
        bridge.getElementValue @id
      end

      #
      # Get the value of a the given attribute of the element. Will return the current value, even if
      # this has been modified after the page has been loaded. More exactly, this method will return
      # the value of the given attribute, unless that attribute is not present, in which case the
      # value of the property with the same name is returned. If neither value is set, nil is
      # returned. The "style" attribute is converted as best can be to a text representation with a
      # trailing semi-colon. The following are deemed to be "boolean" attributes, and will
      # return either "true" or "false":
      #
      # async, autofocus, autoplay, checked, compact, complete, controls, declare, defaultchecked,
      # defaultselected, defer, disabled, draggable, ended, formnovalidate, hidden, indeterminate,
      # iscontenteditable, ismap, itemscope, loop, multiple, muted, nohref, noresize, noshade, novalidate,
      # nowrap, open, paused, pubdate, readonly, required, reversed, scoped, seamless, seeking,
      # selected, spellcheck, truespeed, willvalidate
      #
      # Finally, the following commonly mis-capitalized attribute/property names are evaluated as
      # expected:
      #
      # class, readonly
      #
      # @param [String]
      #   attribute name
      # @return [String,nil]
      #   attribute value
      #

      def attribute(name)
        bridge.getElementAttribute @id, name
      end

      #
      # Get the text content of this element
      #
      # @return [String]
      #

      def text
        bridge.getElementText @id
      end

      #
      # Send keystrokes to this element
      #
      # @param [String, Symbol, Array]
      #
      # Examples:
      #
      #     element.send_keys "foo"                     #=> value: 'foo'
      #     element.send_keys "tet", :arrow_left, "s"   #=> value: 'test'
      #     element.send_keys [:control, 'a'], :space   #=> value: ' '
      #
      # @see Keys::KEYS
      #

      def send_keys(*args)
        args.each do |arg|
          case arg
          when Symbol
            arg = Keys[arg]
          when Array
            arg = arg.map { |e| e.kind_of?(Symbol) ? Keys[e] : e }.join
            arg << Keys[:null]
          end

          bridge.sendKeysToElement(@id, arg.to_s)
        end
      end
      alias_method :send_key, :send_keys

      #
      # Clear this element
      #

      def clear
        bridge.clearElement @id
      end

      #
      # Is the element enabled?
      #
      # @return [Boolean]
      #

      def enabled?
        bridge.isElementEnabled @id
      end

      #
      # Is the element selected?
      #
      # @return [Boolean]
      #

      def selected?
        bridge.isElementSelected @id
      end

      #
      # Is the element displayed?
      #
      # @return [Boolean]
      #

      def displayed?
        bridge.isElementDisplayed @id
      end

      #
      # Select this element
      #

      def select
        bridge.setElementSelected @id
      end

      #
      # Submit this element
      #

      def submit
        bridge.submitElement @id
      end

      #
      # Toggle this element
      #

      def toggle
        bridge.toggleElement @id
      end

      #
      # Get the value of the given CSS property
      #

      def style(prop)
        bridge.getElementValueOfCssProperty @id, prop
      end

      #
      # Hover over this element. Not applicable to all browsers.
      #

      def hover
        bridge.hoverOverElement @id
      end

      #
      # Get the location of this element.
      #
      # @return [WebDriver::Point]
      #

      def location
        bridge.getElementLocation @id
      end

      #
      # Get the size of this element
      #
      # @return [WebDriver::Dimension]
      #

      def size
        bridge.getElementSize @id
      end

      #
      # Drag and drop this element
      #
      # @param [Integer] right_by
      #   number of pixels to drag right
      # @param [Integer] down_by
      #   number of pixels to drag down
      #

      def drag_and_drop_by(right_by, down_by)
        bridge.dragElement @id, right_by, down_by
      end

      #
      # Drag and drop this element on the given element
      #
      # @param [WebDriver::Element] other
      #

      def drag_and_drop_on(other)
        current_location = location()
        destination      = other.location

        right = destination.x - current_location.x
        down  = destination.y - current_location.y

        drag_and_drop_by right, down
      end

      #-------------------------------- sugar  --------------------------------

      #
      #   element.first(:id, 'foo')
      #

      alias_method :first, :find_element

      #
      #   element.all(:class, 'bar')
      #

      alias_method :all, :find_elements

      #
      #   element['class'] or element[:class] #=> "someclass"
      #
      alias_method :[], :attribute

      #
      # for Find and execute_script
      #
      # @private
      #

      def ref
        @id
      end

      #
      # Convert to a WebElement JSON Object for transmission over the wire.
      # @see http://code.google.com/p/selenium/wiki/JsonWireProtocol#Basic_Concepts_And_Terms
      #
      # @private
      #

      def to_json(*args)
        as_json.to_json(*args)
      end

      #
      # For Rails 3 - http://jonathanjulian.com/2010/04/rails-to_json-or-as_json/
      #
      # @private
      #

      def as_json(opts = nil)
        { :ELEMENT => @id }
      end

    end # Element
  end # WebDriver
end # Selenium
