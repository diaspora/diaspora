require "spec_helper"

shared_examples_for "it ignores existing object received twice" do |klass, method|
  it "return nil if the #{klass} already exists" do
    expect(Diaspora::Federation::Receive.public_send(method, entity)).not_to be_nil
    expect(Diaspora::Federation::Receive.public_send(method, entity)).to be_nil
  end

  it "does not change anything if the #{klass} already exists" do
    Diaspora::Federation::Receive.public_send(method, entity)

    expect_any_instance_of(klass).not_to receive(:create_or_update)

    Diaspora::Federation::Receive.public_send(method, entity)
  end
end
