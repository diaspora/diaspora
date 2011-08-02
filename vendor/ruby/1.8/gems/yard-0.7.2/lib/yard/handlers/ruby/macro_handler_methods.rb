module YARD
  module Handlers
    module Ruby
      module MacroHandlerMethods
        include CodeObjects
        include Parser
        
        def find_or_create_macro(docstring)
          return @macro if @macro
          return if @macro = super(docstring)

          # Look for implicit macros
          (globals.__attached_macros[caller_method] || []).each do |macro|
            namespace.inheritance_tree.each do |obj|
              break(@macro = macro) if obj == macro.method_object.namespace
            end
          end
        end
        
        def expanded_macro_or_docstring
          return @docstring unless @macro
          all_params = ([caller_method] + call_params).compact
          data = MacroObject.apply_macro(@macro, @docstring, all_params, statement.source)
          Docstring.new(data)
        end
        
        def expand_macro(object, macro)
          if @docstring
            object.docstring = @docstring
            object.docstring.tags.each do |tag|
              tag.object = object if tag.respond_to?(:object=)
            end
          else
            super(object, macro)
          end
        end
        
        def sanitize_scope
          tmp_scope = @docstring.tag(:scope) ? @docstring.tag(:scope).text : ''
          %w(class instance).include?(tmp_scope) ? tmp_scope.to_sym : scope
        end

        def sanitize_visibility
          vis = @docstring.tag(:visibility) ? @docstring.tag(:visibility).text : ''
          %w(public protected private).include?(vis) ? vis.to_sym : visibility
        end

        def create_attribute_data(object)
          return unless object.docstring.tag(:attribute)
          ensure_loaded!(namespace)
          clean_name = object.name.to_s.sub(/=$/, '')
          namespace.attributes[object.scope][clean_name] ||= SymbolHash[:read => nil, :write => nil]
          if attribute_readable?
            namespace.attributes[object.scope][clean_name][:read] = object
          end
          if attribute_writable?
            if object.name.to_s[-1,1] == '='
              writer = object
            else
              writer = MethodObject.new(namespace, object.name.to_s + '=', object.scope)
              register(writer)
              writer.signature = "def #{object.name}=(value)"
              writer.visibility = object.visibility
              writer.dynamic = true
            end
            namespace.attributes[object.scope][clean_name][:write] = writer
          end
        end
        
        def method_name
          name = nil
          [:method, :attribute, :overload].each do |tag_name|
            if tag = @docstring.tag(tag_name)
              name = tag.send(tag_name == :attribute ? :text : :name).to_s
              if tag_name == :method && name =~ /\(|\s/
                overload = Tags::OverloadTag.new(:overload, name)
                @docstring.add_tag(overload)
              end
              break
            end
          end
          name = nil if name =~ /\A\s*\Z/
          name ||= call_params.first
          return unless name
          if name =~ /\A\s*([^\(; \t]+)/
            name = $1
          end
          if @docstring.tag(:attribute) && !attribute_readable?
            name = name + '='
          end
          name
        end

        def method_signature
          if @docstring.tag(:method)
            name = @docstring.tag(:method).name
          elsif @docstring.tag(:overload)
            name = @docstring.tag(:overload).signature
          elsif @docstring.tag(:attribute)
            name = @docstring.tag(:attribute).text
            name += '=(value)' if !attribute_readable?
          else
            name = method_name
          end
          name = nil if name =~ /\A\s*\Z/
          name ||= call_params.first
          name =~ /^def\b/ ? name : "def #{name}"
        end

        private

        def attribute_writable?
          if @docstring.tag(:attribute) 
            types = @docstring.tag(:attribute).types
            return types ? types.join.include?('w') : true
          end
          false
        end

        def attribute_readable?
          if @docstring.tag(:attribute) 
            types = @docstring.tag(:attribute).types
            return types ? (types.join =~ /(?!w)r/ ? true : false) : true
          end
          false
        end
      end
    end
  end
end