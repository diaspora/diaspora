require 'test_helper'

class CrackTest < Test::Unit::TestCase
  context "snake_case" do
    should "lowercases one word CamelCase" do
      "Merb".snake_case.should == "merb"
    end

    should "makes one underscore snake_case two word CamelCase" do
      "MerbCore".snake_case.should == "merb_core"
    end

    should "handles CamelCase with more than 2 words" do
      "SoYouWantContributeToMerbCore".snake_case.should == "so_you_want_contribute_to_merb_core"
    end

    should "handles CamelCase with more than 2 capital letter in a row" do
      "CNN".snake_case.should == "cnn"
      "CNNNews".snake_case.should == "cnn_news"
      "HeadlineCNNNews".snake_case.should == "headline_cnn_news"
    end

    should "does NOT change one word lowercase" do
      "merb".snake_case.should == "merb"
    end

    should "leaves snake_case as is" do
      "merb_core".snake_case.should == "merb_core"
    end
  end
end