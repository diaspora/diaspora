require 'spec_helper'

# Specs in this file have access to a helper object that includes
# the ResharesHelper. For example:
#
# describe ResharesHelper do
#   describe "string concat" do
#     it "concats two strings with spaces" do
#       helper.concat_strings("this","that").should == "this that"
#     end
#   end
# end
describe ResharesHelper do
  include StreamHelper

  describe 'reshare_link' do
    it 'does not display a reshare for a post that does not exist' do
      reshare = Factory.build(:reshare, :root => nil)
      lambda {
        reshare_link(reshare)
      }.should_not raise_error
    end
  end
end
