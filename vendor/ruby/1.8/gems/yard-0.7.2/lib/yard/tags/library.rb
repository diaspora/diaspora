module YARD
  module Tags
    # Holds all the registered meta tags. If you want to extend YARD and add
    # a new meta tag, you can do it in one of two ways.
    #
    # == Method #1
    # Use {Library.define_tag} to define a new tag by passing the tag name
    # and the factory method to use when creating the tag. These definitions will
    # be auto expanded into ruby code similar to what is shown in method #2. If you
    # do not provide a factory method to use, it will default to {DefaultFactory#parse_tag}
    # Example:
    #   define_tag "Parameter", :param, :with_types_and_name
    #   define_tag "Author", :author
    #
    # The first line will expand to the code:
    #   def param_tag(text) tag_factory.parse_tag_with_types_and_name(text) end
    #
    # The second line will expand to:
    #   def author_tag(text) tag_factory.parse_tag(text) end
    #
    # Note that +tag_factory+ is the factory object used to parse tags. This value
    # defaults to the {DefaultFactory} class and can be set by changing {Library.default_factory}.
    #
    # == Method #2
    # Write your own +tagname_tag+ method that takes the raw text as a parameter.
    # Example:
    #   def mytag_tag(text)
    #     # parse your tag contents here
    #   end
    #
    # This will allow you to use @mytag TEXT to add meta data to classes through
    # the docstring. You can use the {Library#factory} object to help parse standard
    # tag syntax.
    #
    # == Adding/Changing the Tag Syntax
    # If you have specialized tag parsing needs you can substitute the {#factory}
    # object with your own by setting {Library.default_factory= Library.default_factory}
    # to a new class with its own parsing methods before running YARD. This is useful
    # if you want to change the syntax of existing tags (@see, @since, etc.)
    #
    # @see DefaultFactory
    # @see Library.define_tag
    class Library
      class << self
        attr_reader :labels

        def instance
          @instance ||= new
        end

        def default_factory
          @default_factory ||= DefaultFactory.new
        end

        # Replace the factory object responsible for parsing tags by setting
        # this to an object (or class) that responds to +parse_TAGNAME+ methods
        # where +TAGNAME+ is the name of the tag.
        #
        # You should set this value before performing any source parsing with
        # YARD, otherwise your factory class will not be used.
        #
        # @example
        #   YARD::Tags::Library.default_factory = MyFactory
        #
        # @param [Class, Object] factory the factory that parses all tags
        #
        # @see DefaultFactory
        def default_factory=(factory)
          @default_factory = factory.is_a?(Class) ? factory.new : factory
        end

        # Returns the factory method used to parse the tag text for a specific tag
        #
        # @param [Symbol] tag the tag name
        # @return [Symbol] the factory method name for the tag
        # @return [Class<Tag>] the Tag class to use to parse the tag
        # @return [nil] if the tag is freeform text
        # @since 0.6.0
        def factory_method_for(tag)
          @factory_methods[tag]
        end

        # Sets the list of tags to display when rendering templates. The order of
        # tags in the list is also significant, as it represents the order that
        # tags are displayed in templates.
        #
        # You can use the {Array#place} to insert new tags to be displayed in
        # the templates at specific positions:
        #
        #   Library.visible_tags.place(:mytag).before(:return)
        #
        # @return [Array<Symbol>] a list of ordered tags
        # @since 0.6.0
        attr_accessor :visible_tags

        # Sets the list of tags that should apply to any children inside the
        # namespace they are defined in. For instance, a "@since" tag should
        # apply to all methods inside a module it is defined in. Transitive
        # tags can be overridden by directly defining a tag on the child object.
        #
        # @return [Array<Symbol>] a list of transitive tags
        # @since 0.6.0
        attr_accessor :transitive_tags

        # Sorts the labels lexically by their label name, often used when displaying
        # the tags.
        #
        # @return [Array<Symbol>, String] the sorted labels as an array of the tag name and label
        def sorted_labels
          labels.sort_by {|a| a.last.downcase }
        end

        # Convenience method to define a new tag using one of {Tag}'s factory methods, or the
        # regular {DefaultFactory#parse_tag} factory method if none is supplied.
        #
        # @param [#to_s] tag the tag name to create
        # @param [#to_s, Class<Tag>] meth the {Tag} factory method to call when
        #   creating the tag or the name of the class to directly create a tag for
        def define_tag(label, tag, meth = nil)
          if meth.is_a?(Class) && Tag > meth
            class_eval <<-eof, __FILE__, __LINE__
              def #{tag}_tag(text)
                #{meth}.new(#{tag.inspect}, text)
              end
            eof
          else
            class_eval <<-eof, __FILE__, __LINE__
              def #{tag}_tag(text)
                send_to_factory(#{tag.inspect}, #{meth.inspect}, text)
              end
            eof
          end

          @labels ||= SymbolHash.new(false)
          @labels.update(tag => label)
          @factory_methods ||= SymbolHash.new(false)
          @factory_methods.update(tag => meth)
          tag
        end
      end

      private

      def send_to_factory(tag_name, meth, text)
        meth = meth.to_s
        send_name = "parse_tag" + (meth.empty? ? "" : "_" + meth)
        if @factory.respond_to?(send_name)
          arity = @factory.method(send_name).arity
          @factory.send(send_name, tag_name, text)
        else
          raise NoMethodError, "Factory #{@factory.class_name} does not implement factory method :#{meth}."
        end
      end

      public

      # A factory class to handle parsing of tags, defaults to {default_factory}
      attr_accessor :factory

      def initialize(factory = Library.default_factory)
        self.factory = factory
      end

      define_tag "Abstract",           :abstract
      define_tag "API Visibility",     :api
      define_tag "Attribute (macro)",  :attribute,   :with_types
      define_tag "Attribute",          :attr,        :with_types_and_name
      define_tag "Attribute Getter",   :attr_reader, :with_types_and_name
      define_tag "Attribute Setter",   :attr_writer, :with_types_and_name
      define_tag "Author",             :author
      define_tag "Deprecated",         :deprecated
      define_tag "Example",            :example,     :with_title_and_text
      define_tag "End Grouping",       :endgroup
      define_tag "Grouping",           :group
      define_tag "Macro",              :macro,       :with_types_and_name
      define_tag "Method (macro)",     :method,      :with_title_and_text
      define_tag "Note",               :note
      define_tag "Options Hash",       :option,      :with_options
      define_tag "Overloads",          :overload,    OverloadTag
      define_tag "Parameters",         :param,       :with_types_and_name
      define_tag "Private",            :private
      define_tag "Raises",             :raise,       :with_types
      define_tag "Returns",            :return,      :with_types
      define_tag "Scope (macro)",      :scope
      define_tag "See Also",           :see,         :with_name
      define_tag "Since",              :since
      define_tag "Todo Item",          :todo
      define_tag "Version",            :version
      define_tag "Visibility (macro)", :visibility
      define_tag "Yields",             :yield,       :with_types
      define_tag "Yield Parameters",   :yieldparam,  :with_types_and_name
      define_tag "Yield Returns",      :yieldreturn, :with_types

      self.visible_tags = [:abstract, :deprecated, :note, :todo, :example, :overload,
        :param, :option, :yield, :yieldparam, :yieldreturn, :return, :raise,
        :see, :author, :since, :version]

      self.transitive_tags = [:since, :api]
    end
  end
end
