RSpec::Matchers.define :be_new_record do
  match do |actual|
    !actual.persisted?
  end
end
