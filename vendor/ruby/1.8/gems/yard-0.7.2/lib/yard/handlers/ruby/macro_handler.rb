module YARD
  module Handlers
    module Ruby
      # Handles a macro (dsl-style method)
      class MacroHandler < Base
        include CodeObjects
        include MacroHandlerMethods
        handles method_call
        namespace_only
        
        IGNORE_METHODS = Hash[*%w(alias alias_method autoload attr attr_accessor 
          attr_reader attr_writer extend include public private protected 
          private_constant).map {|n| [n, true] }.flatten]
        
        process do
          globals.__attached_macros ||= {}
          if !globals.__attached_macros[caller_method]
            return if IGNORE_METHODS[caller_method]
            return if !statement.comments || statement.comments.empty?
          end
          
          @macro, @docstring = nil, Docstring.new(statement.comments)
          find_or_create_macro(@docstring)
          return if !@macro && !statement.comments_hash_flag && @docstring.tags.size == 0
          @docstring = expanded_macro_or_docstring
          name = method_name
          raise UndocumentableError, "method, missing name" if name.nil? || name.empty?
          tmp_scope = sanitize_scope
          tmp_vis = sanitize_visibility
          object = MethodObject.new(namespace, name, tmp_scope)
          register(object)
          object.visibility = tmp_vis
          object.dynamic = true
          object.signature = method_signature
          create_attribute_data(object)
        end
      end
    end
  end
end
