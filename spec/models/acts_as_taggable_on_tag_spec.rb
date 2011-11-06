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

  describe ".normalize" do
    it "removes leading hash symbols" do
      ActsAsTaggableOn::Tag.normalize("#mytag").should == "mytag"
    end

    it "removes punctuation and whitespace" do
      {
        'node.js'                        => 'nodejs',
        '.dotatstart'                    => 'dotatstart',
        'you,inside'                     => 'youinside',
        'iam(parenthetical)'             => 'iamparenthetical',
        'imeanit?maybe'                  => 'imeanitmaybe',
        'imeanit!'                       => 'imeanit',
        'how about spaces'               => 'howaboutspaces',
        "other\twhitespace\n"            => 'otherwhitespace',
        'hash#inside'                    => 'hashinside',
        'f!u@n#k$y%-<c>^h&a*r(a)c{t}e[r]s' => 'funky-characters'
      }.each do |invalid, normalized|
        ActsAsTaggableOn::Tag.normalize(invalid).should == normalized
      end
    end

    it 'allows for love' do
      ActsAsTaggableOn::Tag.normalize("<3").should == "<3"
      ActsAsTaggableOn::Tag.normalize("#<3").should == "<3"
    end
  end
end
