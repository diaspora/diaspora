require 'spec_helper'
require 'stringio'

describe RSpec::Core::Formatters::Helpers do
  let(:helper) { helper = Object.new.extend(RSpec::Core::Formatters::Helpers) }

  describe "format seconds" do
    context "sub second times" do
      it "returns 5 digits of precision" do
        helper.format_seconds(0.000006).should == "0.00001"
      end

      it "strips off trailing zeroes beyond sub-second precision" do
        helper.format_seconds(0.020000).should == "0.02"
      end

      context "0" do
        it "strips off trailing zeroes" do
          helper.format_seconds(0.00000000001).should == "0"
        end
      end

      context "> 1" do
        it "strips off trailing zeroes" do
          helper.format_seconds(1.00000000001).should == "1"
        end
      end
    end

    context "second and greater times" do

      it "returns 2 digits of precision" do
        helper.format_seconds(50.330340).should == "50.33"
      end

      it "returns human friendly elasped time" do
        helper.format_seconds(50.1).should == "50.1"
        helper.format_seconds(5).should == "5"
        helper.format_seconds(5.0).should == "5"
      end

    end
  end


end
