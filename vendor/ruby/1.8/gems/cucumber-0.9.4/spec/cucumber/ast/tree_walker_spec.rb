require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')

module Cucumber::Ast
  describe TreeWalker do
    it "should visit features" do
      tw = TreeWalker.new(nil, [mock('listener', :before_visit_features => nil)])
      tw.should_not_receive(:warn)
      tw.visit_features(mock('features', :accept => nil))
    end
  end
end