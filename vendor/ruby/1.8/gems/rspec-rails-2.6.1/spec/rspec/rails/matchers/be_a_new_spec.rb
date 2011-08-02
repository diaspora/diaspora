require "spec_helper"

describe "be_a_new matcher" do
  context "new record" do
    let(:record) do
      Class.new do
        def new_record?; true; end
      end.new
    end
    context "right class" do
      it "passes" do
        record.should be_a_new(record.class)
      end
    end
    context "wrong class" do
      it "fails" do
        record.should_not be_a_new(String)
      end
    end
  end

  context "existing record" do
    let(:record) do
      Class.new do
        def new_record?; false; end
      end.new
    end
    context "right class" do
      it "fails" do
        record.should_not be_a_new(record.class)
      end
    end
    context "wrong class" do
      it "fails" do
        record.should_not be_a_new(String)
      end
    end
  end

  describe "#with" do
    context "right class and new record" do
      let(:record) do
        Class.new do
          def initialize(attributes)
            @attributes = attributes
          end

          def attributes
            @attributes.stringify_keys
          end

          def new_record?; true; end
        end.new(:foo => 'foo', :bar => 'bar')
      end

      context "all attributes same" do
        it "passes" do
          record.should be_a_new(record.class).with(:foo => 'foo', :bar => 'bar')
        end
      end

      context "one attribute same" do
        it "passes" do
          record.should be_a_new(record.class).with(:foo => 'foo')
        end
      end

      context "no attributes same" do
        it "fails" do
          expect {
            record.should be_a_new(record.class).with(:zoo => 'zoo', :car => 'car')
          }.to raise_error(
            %Q(attributes {"zoo"=>"zoo", "car"=>"car"} were not set on #{record.inspect})
          )
        end
      end

      context "one attribute value not the same" do
        it "fails" do
          expect {
            record.should be_a_new(record.class).with(:foo => 'bar')
          }.to raise_error(
            %Q(attribute {"foo"=>"bar"} was not set on #{record.inspect})
          )
        end
      end
    end

    context "wrong class and existing record" do
      let(:record) do
        Class.new do
          def initialize(attributes)
            @attributes = attributes
          end

          def attributes
            @attributes.stringify_keys
          end

          def new_record?; false; end
        end.new(:foo => 'foo', :bar => 'bar')
      end

      context "all attributes same" do
        it "fails" do
          expect {
            record.should be_a_new(String).with(:foo => 'foo', :bar => 'bar')
          }.to raise_error(
            "expected #{record.inspect} to be a new String"
          )
        end
      end

      context "no attributes same" do
        it "fails" do
          expect {
            record.should be_a_new(String).with(:zoo => 'zoo', :car => 'car')
          }.to raise_error(
            "expected #{record.inspect} to be a new String and " +
            %Q(attributes {"zoo"=>"zoo", "car"=>"car"} were not set on #{record.inspect})
          )
        end
      end

      context "one attribute value not the same" do
        it "fails" do
          expect {
            record.should be_a_new(String).with(:foo => 'bar')
          }.to raise_error(
            "expected #{record.inspect} to be a new String and " +
            %Q(attribute {"foo"=>"bar"} was not set on #{record.inspect})
          )
        end
      end
    end
  end
end
