require 'spec_helper'

describe "exist matcher" do
  context "when the object does not respond to #exist? or #exists?" do
    subject { mock }

    [:should, :should_not].each do |should_method|
      describe "#{should_method} exist" do
        it "raises an error" do
          expect {
            subject.send(should_method, exist)
          }.to raise_error(NoMethodError)
        end
      end
    end
  end

  [:exist?, :exists?].each do |predicate|
    context "when the object responds to ##{predicate}" do
      describe "should exist" do
        it "passes if #{predicate}" do
          mock(predicate => true).should exist
        end

        it "fails if not #{predicate}" do
          expect {
            mock(predicate => false).should exist
          }.to fail_with(/expected .* to exist/)
        end
      end

      describe "should not exist" do
        it "passes if not #{predicate}" do
          mock(predicate => false).should_not exist
        end

        it "fails if #{predicate}" do
          expect {
            mock(predicate => true).should_not exist
          }.to fail_with(/expected .* not to exist/)
        end
      end
    end
  end

  context "when the object responds to #exist? and #exists?" do
    context "when they both return falsey values" do
      subject { mock(:exist? => false, :exists? => nil) }

      describe "should_not exist" do
        it "passes" do
          subject.should_not exist
        end
      end

      describe "should exist" do
        it "fails" do
          expect {
            subject.should exist
          }.to fail_with(/expected .* to exist/)
        end
      end
    end

    context "when they both return truthy values" do
      subject { mock(:exist? => true, :exists? => "something true") }

      describe "should_not exist" do
        it "fails" do
          expect {
            subject.should_not exist
          }.to fail_with(/expected .* not to exist/)
        end
      end

      describe "should exist" do
        it "passes" do
          subject.should exist
        end
      end
    end

    context "when they return values with different truthiness" do
      subject { mock(:exist? => true, :exists? => false) }

      [:should, :should_not].each do |should_method|
        describe "#{should_method} exist" do
          it "raises an error" do
            expect {
              subject.send(should_method, exist)
            }.to raise_error(/#exist\? and #exists\? returned different values/)
          end
        end
      end
    end
  end

  it 'passes any provided arguments to the call to #exist?' do
    object = mock
    object.should_receive(:exist?).with(:foo, :bar) { true }

    object.should exist(:foo, :bar)
  end
end
