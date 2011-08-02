require File.dirname(__FILE__) + '/../spec_helper'

class FogAttributeTestModel < Fog::Model
  attribute :key_id, :aliases => "key", :squash => "id"
  attribute :time, :type => :time
end

describe 'Fog::Attributes' do

  describe ".attribute" do
    describe "squashing a value" do
      it "should accept squashed key as symbol" do
        data = {"key" => {:id => "value"}}
        model = FogAttributeTestModel.new
        model.merge_attributes(data)
        model.key_id.should == "value"
      end

      it "should accept squashed key as string" do
        data = {"key" => {"id" => "value"}}
        model = FogAttributeTestModel.new
        model.merge_attributes(data)
        model.key_id.should == "value"
      end
    end

    describe "when merging a time field" do
      it "should accept nil as a suitable setting" do
        data = {"time" => nil}
        model = FogAttributeTestModel.new
        model.merge_attributes(data)
        model.time.should be_nil
      end

      it "should accept empty string as a suitable setting" do
        data = {"time" => ""}
        model = FogAttributeTestModel.new
        model.merge_attributes(data)
        model.time.should == ""
      end

      it "should parse strings to get a Datetime" do
        test_time = Time.parse("2010-11-12T13:14:15")
        data = {"time" => test_time.to_s}
        model = FogAttributeTestModel.new
        model.merge_attributes(data)
        model.time.should == test_time
      end
    end
  end

end