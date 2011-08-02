RSpec::Matchers.define :be_a_new do |model_klass|
  match do |actual|
    actual.is_a?(model_klass) && actual.new_record? && attributes_match?(actual)
  end

  chain :with do |expected_attributes|
    attributes.merge!(expected_attributes)
  end

  failure_message_for_should do |actual|
    [].tap do |message|
      unless actual.is_a?(model_klass) && actual.new_record? 
        message << "expected #{actual.inspect} to be a new #{model_klass.inspect}"
      end
      unless attributes_match?(actual)
        if unmatched_attributes.size > 1
          message << "attributes #{unmatched_attributes.inspect} were not set on #{actual.inspect}"
        else
          message << "attribute #{unmatched_attributes.inspect} was not set on #{actual.inspect}"
        end
      end
    end.join(' and ')
  end

  def attributes
    @attributes ||= {}
  end

  def attributes_match?(actual)
    attributes.stringify_keys.all? do |key, value|
      actual.attributes[key].eql?(value)
    end
  end

  def unmatched_attributes
    attributes.stringify_keys.reject do |key, value|
      actual.attributes[key].eql?(value)
    end
  end
end
