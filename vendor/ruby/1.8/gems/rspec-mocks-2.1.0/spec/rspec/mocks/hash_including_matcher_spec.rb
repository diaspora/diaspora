require 'spec_helper'

module RSpec
  module Mocks
    module ArgumentMatchers
      describe HashIncludingMatcher do
        
        it "describes itself properly" do
          HashIncludingMatcher.new(:a => 1).description.should == "hash_including(:a=>1)"
        end      

        describe "passing" do
          it "matches the same hash" do
            hash_including(:a => 1).should == {:a => 1}
          end

          it "matches a hash with extra stuff" do
            hash_including(:a => 1).should == {:a => 1, :b => 2}
          end
          
          describe "when matching against other matchers" do
            it "matches an int against anything()" do
              hash_including(:a => anything, :b => 2).should == {:a => 1, :b => 2}
            end

            it "matches a string against anything()" do
              hash_including(:a => anything, :b => 2).should == {:a => "1", :b => 2}
            end
          end
          
          describe "when passed only keys or keys mixed with key/value pairs" do
            it "matches if the key is present" do
              hash_including(:a).should == {:a => 1, :b => 2}
            end
            
            it "matches if more keys are present" do
              hash_including(:a, :b).should == {:a => 1, :b => 2, :c => 3}
            end

            it "matches a string against a given key" do
              hash_including(:a).should == {:a => "1", :b => 2}
            end

            it "matches if passed one key and one key/value pair" do
              hash_including(:a, :b => 2).should == {:a => 1, :b => 2}
            end
            
            it "matches if passed many keys and one key/value pair" do
              hash_including(:a, :b, :c => 3).should == {:a => 1, :b => 2, :c => 3, :d => 4}
            end
            
            it "matches if passed many keys and many key/value pairs" do
              hash_including(:a, :b, :c => 3, :e => 5).should == {:a => 1, :b => 2, :c => 3, :d => 4, :e => 5}
            end
          end
        end
        
        describe "failing" do
          it "does not match a non-hash" do
            hash_including(:a => 1).should_not == 1
          end

          it "does not match a hash with a missing key" do
            hash_including(:a => 1).should_not == {:b => 2}
          end
          
          it "does not match a hash with a missing key" do
            hash_including(:a).should_not == {:b => 2}
          end
          
          it "does not match an empty hash with a given key" do
            hash_including(:a).should_not == {}
          end
          
          it "does not match a hash with a missing key when one pair is matching" do
            hash_including(:a, :b => 2).should_not == {:b => 2}
          end
          
          it "does not match a hash with an incorrect value" do
            hash_including(:a => 1, :b => 2).should_not == {:a => 1, :b => 3}
          end

          it "does not match when values are nil but keys are different" do
            hash_including(:a => nil).should_not == {:b => nil}
          end
        end
      end
    end
  end
end
