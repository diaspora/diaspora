RSpec::Matchers.constants.each do |c|
  if Class === (klass = RSpec::Matchers.const_get(c))
    if klass.public_instance_methods.any? {|m| ['failure_message_for_should',:failure_message_for_should].include?(m)}
      klass.class_eval do
        alias_method :failure_message, :failure_message_for_should
      end
    end
    if klass.public_instance_methods.any? {|m| ['failure_message_for_should_not',:failure_message_for_should_not].include?(m)}
      klass.class_eval do
        alias_method :negative_failure_message, :failure_message_for_should_not
      end
    end
  end
end
