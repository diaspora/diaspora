module YARD
  module CodeObjects
    # A MacroObject represents a docstring defined through +@macro NAME+ and can be
    # reused by specifying the tag +@macro NAME+. You can also provide the
    # +attached+ type flag to the macro definition to have it attached to the
    # specific DSL method so it will be implicitly reused.
    # 
    # Macros are fully described in the {file:docs/Tags.md#macros Tags Overview}
    # document.
    # 
    # @example Creating a basic named macro
    #   # @macro prop
    #   # @method $1(${3-})
    #   # @return [$2] the value of the $0
    #   property :foo, String, :a, :b
    #   
    #   # @macro prop
    #   property :bar, Numeric, :value
    # 
    # @example Creating a macro that is attached to the method call
    #   # @macro [attach] prop2
    #   # @method $1(value)
    #   property :foo
    #   
    #   # Extra data added to docstring
    #   property :bar
    class MacroObject < Base
      MACRO_MATCH = /(\\)?\$(?:\{(-?\d+|\*)(-)?(-?\d+)?\}|(-?\d+|\*))/

      class << self
        # Creates a new macro and fills in the relevant properties.
        # @param [String] macro_name the name of the macro, must be unique.
        # @param [String] data the data the macro should expand when re-used
        # @param [CodeObjects::Base] method_object an object to attach this
        #   macro to. If supplied, {#attached?} will be true
        # @return [MacroObject] the newly created object
        def create(macro_name, data, method_object = nil)
          obj = new(:root, macro_name)
          obj.macro_data = data
          obj.method_object = method_object
          obj
        end
    
        # Finds a macro using +macro_name+
        # @return [MacroObject] if a macro is found
        # @return [nil] if there is no registered macro by that name
        def find(macro_name)
          Registry.at('.macro.' + macro_name.to_s)
        end
      
        # Parses a given docstring and determines if the macro is "new" or
        # not. If the macro has $variable names or if it has a @macro tag
        # with the [new] or [attached] flag, it is considered new. 
        # 
        # If a new macro is found, the macro is created and registered. Otherwise
        # the macro name is searched and returned. If a macro is not found,
        # nil is returned.
        # 
        # @param [CodeObjects::Base] method_object an optional method to attach
        #   the macro to. Only used if the macro is being created, otherwise
        #   this argument is ignored.
        # @return [MacroObject] the newly created or existing macro, depending
        #   on whether the @macro tag was a new tag or not.
        # @return [nil] if the +data+ has no macro tag or if the macro is
        #   not new and no macro by the macro name is found.
        def find_or_create(data, method_object = nil)
          docstring = Docstring === data ? data : Docstring.new(data)
          return unless docstring.tag(:macro)
          return unless name = macro_name(docstring)
          if new_macro?(docstring)
            method_object = nil unless attached_macro?(docstring, method_object)
            create(name, macro_data(docstring), method_object)
          else
            find(name)
          end
        end
        alias create_docstring find_or_create
        
        # Expands +macro_data+ using the interpolation parameters.
        # 
        # Interpolation rules:
        # * $0, $1, $2, ... = the Nth parameter in +call_params+
        # * $* = the full statement source (excluding block)
        # * Also supports $\{N-M} ranges, as well as negative indexes on N or M
        # * Use \$ to escape the variable name in a macro.
        # 
        # @macro [new] macro.expand
        #   @param [Array<String>] call_params the method name and parameters
        #     to the method call. These arguments will fill \$0-N
        #   @param [String] full_source the full source line (excluding block) 
        #     interpolated as \$*
        #   @param [String] block_source Currently unused. Will support 
        #     interpolating the block data as a variable.
        #   @return [String] the expanded macro data
        # @param [String] macro_data the macro data to expand (taken from {#macro_data})
        def expand(macro_data, call_params = [], full_source = '', block_source = '')
          macro_data = macro_data.all if macro_data.is_a?(Docstring)
          macro_data.gsub(MACRO_MATCH) do
            escape, first, last, rng = $1, $2 || $5, $4, $3 ? true : false
            next $&[1..-1] if escape
            if first == '*'
              last ? $& : full_source
            else
              first_i = first.to_i
              last_i = (last ? last.to_i : call_params.size)
              last_i = first_i unless rng
              params = call_params[first_i..last_i]
              params ? params.join(", ") : ''
            end
          end
        end

        # Applies a macro on a docstring by creating any macro data inside of
        # the docstring first. Equivalent to calling {find_or_create} and {apply_macro}
        # on the new macro object.
        # 
        # @param [Docstring] docstring the docstring to create a macro out of
        # @macro macro.expand
        # @see find_or_create
        def apply(docstring, call_params = [], full_source = '', block_source = '', method_object = nil)
          macro = find_or_create(docstring, method_object)
          apply_macro(macro, docstring, call_params, full_source, block_source)
        end

        # Applies a macro to a docstring, interpolating the macro's data on the
        # docstring and appending any extra local docstring data that was in
        # the original +docstring+ object.
        # 
        # @param [MacroObject] macro the macro object
        # @macro macro.expand
        def apply_macro(macro, docstring, call_params = [], full_source = '', block_source = '')
          docstring = Docstring.new(docstring) unless Docstring === docstring
          data = []
          data << macro.expand(call_params, full_source, block_source) if macro
          if !macro && new_macro?(docstring)
            data << expand(macro_data(docstring), call_params, full_source, block_source)
          end
          data << nonmacro_data(docstring)
          data.join("\n").strip
        end

        private
      
        def new_macro?(docstring)
          if docstring.tag(:macro) 
            if types = docstring.tag(:macro).types
              return true if types.include?('new') || types.include?('attach')
            end
            if docstring.all =~ MACRO_MATCH
              return true
            end
          end
          false
        end
        
        def attached_macro?(docstring, method_object)
          return false if method_object.nil?
          return false if docstring.tag(:macro).types.nil?
          docstring.tag(:macro).types.include?('attach')
        end
        
        def macro_name(docstring)
          docstring.tag(:macro).name
        end
        
        def macro_data(docstring)
          new_docstring = docstring.dup
          new_docstring.delete_tags(:macro)
          tag_text = docstring.tag(:macro).text
          if !tag_text || tag_text.strip.empty?
            new_docstring.to_raw.strip
          else
            tag_text
          end
        end
        
        def nonmacro_data(docstring)
          if new_macro?(docstring)
            text = docstring.tag(:macro).text
            return '' if !text || text.strip.empty?
          end
          new_docstring = docstring.dup
          new_docstring.delete_tags(:macro)
          new_docstring.to_raw
        end
      end
    
      # @return [String] the macro data stored on the object
      attr_accessor :macro_data
      
      # @return [CodeObjects::Base] the method object that this macro is
      #   attached to.
      attr_accessor :method_object
    
      # @return [Boolean] whether this macro is attached to a method
      def attached?; method_object ? true : false end
      def path; '.macro.' + name.to_s end
      def sep; '.' end
      
      # Expands the macro using 
      # @param [Array<String>] call_params a list of tokens that are passed
      #   to the method call
      # @param [String] full_source the full method call (not including the block)
      # @param [String] block_source the source passed in the block of the method
      #   call, if there is a block.
      # @example Expanding a Macro
      #   macro.expand(%w(property foo bar), 'property :foo, :bar', '') #=>
      #     "...macro data interpolating this line of code..."
      # @see expand
      def expand(call_params = [], full_source = '', block_source = '')
        self.class.expand(macro_data, call_params, full_source, block_source)
      end
    end
  end
end