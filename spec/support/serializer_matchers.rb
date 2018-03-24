# frozen_string_literal: true

# This file contains custom RSpec matchers for AMS.
# NOTE: It was developed for AMS v0.9 and the API might be changed in future, so that should be examined when moving
# between stable versions of AMS (e.g. 0.9 to 0.10, or 0.9 to a possible 1.0).

# This is a matcher that tests a ActiveModel Serializer derivatives to run a serializer for
# an association with expected properties and data.
#
# This matcher is expected to be used in unit testing of ActiveModel Serializer derivatives.
#
# It is mostly a wrapper around RSpec::Mocks::Matchers::Receive matcher with expectations based on
# ActiveModel::Serializer internal API knowledge.
# NOTE: this matcher uses knowledge of AMS internals
RSpec::Matchers.define :serialize_association do |association_name|
  match do |root_serializer_class|
    association = fetch_association(root_serializer_class, association_name)
    @serializer_from_options = association.serializer_from_options
    execute_receive_matcher_with(association)
  end

  # Sets expectation for a specific serializer class to be used for has_one association serialization
  chain :with_serializer, :association_serializer_class

  # Sets expectation for a specific serializer class to be user for has_many association serialization
  chain :with_each_serializer, :each_serializer_class

  # Sets expectation for actual data to be passed to the serializer of the association
  chain :with_object, :association_object
  alias_method :with_objects, :with_object

  private

  # subject is what comes from the expect method argument in usual notation.
  # So this method is equivalent of calling `expect(subject).to receive(:build_serializer)` but valid within a custom
  # RSpec matcher's match method.
  def execute_receive_matcher_with(subject)
    receive_matcher.matches?(subject)
  end

  def receive_matcher
    receive(:build_serializer).and_wrap_original do |original, object, options, &block|
      with_object_expectation(object)

      original.call(object, options, &block).tap do |serializer|
        expect(serializer).to be_an_instance_of(serializer_class) unless serializer_class.nil?
        expect(serializer).to serialize_each_with(each_serializer_class) unless each_serializer_class.nil?
      end
    end
  end

  def with_object_expectation(object)
    if association_object.is_a?(Array)
      if serializer_class == FlatMapArraySerializer
        expect(object.flat_map(&:to_a)).to match_array(association_object)
      else
        expect(object).to match_array(association_object)
      end
    elsif !association_object.nil?
      expect(object).to eq(association_object)
    end
  end

  def fetch_association(serializer_class, association_name)
    serializer_class._associations[association_name]
  end

  def serializer_class
    @serializer_class ||= pick_serializer_class
  end

  def pick_serializer_class
    return association_serializer_class unless association_serializer_class.nil?
    return @serializer_from_options unless @serializer_from_options.nil?
    return ActiveModel::ArraySerializer unless each_serializer_class.nil?
  end
end

# This serializer tests that ActiveModel::ArraySerializer uses specific serializer for each member object of the array.
# We could also set a mock expectation on each serializer, but it maybe overly complicated for our present
# requirements.
# NOTE: this matcher uses knowledge of AMS internals
RSpec::Matchers.define :serialize_each_with do |expected|
  match do |actual|
    actual.is_a?(ActiveModel::ArraySerializer) && actual.instance_variable_get("@each_serializer") == expected
  end
end
