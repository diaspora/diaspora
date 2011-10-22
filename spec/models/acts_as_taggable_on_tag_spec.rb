require 'spec_helper' 

describe ActsAsTaggableOn::Tag do
  describe '.autocomplete' do
    before do 
      @tag = ActsAsTaggableOn::Tag.create(:name => "cats")
    end
    it 'downcases the tag name' do
      ActsAsTaggableOn::Tag.autocomplete("CATS").should == [@tag]

    end

    it 'does an end where on tags' do
      ActsAsTaggableOn::Tag.autocomplete("CAT").should == [@tag]
    end
  end
end
