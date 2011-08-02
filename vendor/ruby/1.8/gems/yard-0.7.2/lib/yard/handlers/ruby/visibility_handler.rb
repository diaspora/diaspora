# Handles 'private', 'protected', and 'public' calls.
class YARD::Handlers::Ruby::VisibilityHandler < YARD::Handlers::Ruby::Base
  handles method_call(:private)
  handles method_call(:protected)
  handles method_call(:public)
  namespace_only

  process do
    return if (ident = statement.jump(:ident)) == statement
    case statement.type
    when :var_ref
      self.visibility = ident.first
    when :fcall, :command
      statement[1].traverse do |node|
        case node.type
        when :symbol; source = node.first.source
        when :string_content; source = node.source
        else next
        end
        MethodObject.new(namespace, source, scope) {|o| o.visibility = ident.first }
      end
    end
  end
end