require 'spec_helper'

module RSpec
  module Mocks
    module ArgumentMatchers
      describe HashNotIncludingMatcher do
        
        it "describes itself properly" do
          HashNotIncludingMatcher.new(:a => 5).description.should == "hash_not_including(:a=>5)"
        end      

        describe "passing" do
          it "matches a hash without the specified key" do
            hash_not_including(:c).should == {:a => 1, :b => 2}
          end
          
          it "matches a hash with the specified key, but different value" do
            hash_not_including(:b => 3).should == {:a => 1, :b => 2}
          end
                    
          it "matches a hash without the specified key, given as anything()" do
            hash_not_including(:c => anything).should == {:a => 1, :b => 2}
          end

          it "matches an empty hash" do
            hash_not_including(:a).should == {}
          end
          
          it "matches a hash without any of the specified keys" do
            hash_not_including(:a, :b, :c).should == { :d => 7}
          end
          
        end
        
        describe "failing" do
          it "does not match a non-hash" do
            hash_not_including(:a => 1).should_not == 1
          end
          
          it "does not match a hash with a specified key" do
            hash_not_including(:b).should_not == {:b => 2}
          end
          
          it "does not match a hash with the specified key/value pair" do
            hash_not_including(:b => 2).should_not == {:a => 1, :b => 2}
          end
          
          it "does not match a hash with the specified key" do
            hash_not_including(:a, :b => 3).should_not == {:a => 1, :b => 2}
          end
          
          it "does not match a hash with one of the specified keys" do
            hash_not_including(:a, :b).should_not == {:b => 2}
          end
          
          it "does not match a hash with some of the specified keys" do
            hash_not_including(:a, :b, :c).should_not == {:a => 1, :b => 2}
          end
          
          it "does not match a hash with one key/value pair included" do
            hash_not_including(:a, :b, :c, :d => 7).should_not == { :d => 7}
          end
        end
      end
    end
  end
end
