require 'spec_helper'

describe ActsAsTaggableOn::Tag, :type => :model do
  describe '.autocomplete' do
    before do
      @tag = ActsAsTaggableOn::Tag.create(:name => "cats")
    end
    it 'downcases the tag name' do
      expect(ActsAsTaggableOn::Tag.autocomplete("CATS")).to eq([@tag])

    end

    it 'does an end where on tags' do
      expect(ActsAsTaggableOn::Tag.autocomplete("CAT")).to eq([@tag])
    end
  end

  describe ".normalize" do
    it "removes leading hash symbols" do
      expect(ActsAsTaggableOn::Tag.normalize("#mytag")).to eq("mytag")
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
        expect(ActsAsTaggableOn::Tag.normalize(invalid)).to eq(normalized)
      end
    end

    it 'allows for love' do
      expect(ActsAsTaggableOn::Tag.normalize("<3")).to eq("<3")
      expect(ActsAsTaggableOn::Tag.normalize("#<3")).to eq("<3")
    end
  end
end
