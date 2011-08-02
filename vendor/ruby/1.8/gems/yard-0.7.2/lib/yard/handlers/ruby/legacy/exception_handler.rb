# (see Ruby::ExceptionHandler)
class YARD::Handlers::Ruby::Legacy::ExceptionHandler < YARD::Handlers::Ruby::Legacy::Base
  handles /\Araise(\s|\()/

  process do
    return unless owner.is_a?(MethodObject) # Only methods yield
    return if owner.has_tag?(:raise)

    if klass = statement.tokens.to_s[/^raise[\(\s]*(#{NAMESPACEMATCH})\s*(?:\)|,|\s(?:if|unless|until)|;|(?:(?:\.|\:\:)\s*)?new|$)/, 1]
      owner.docstring.add_tag YARD::Tags::Tag.new(:raise, '', klass)
    end
  end
end