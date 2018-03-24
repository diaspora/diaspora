# frozen_string_literal: true

describe ActsAsTaggableOn::Tag, :type => :model do
  subject(:tag) { ActsAsTaggableOn::Tag }

  describe ".autocomplete" do
    let!(:tag_cats) { tag.create(name: "cats") }

    it "downcases the tag name" do
      expect(tag.autocomplete("CATS")).to eq([tag_cats])
    end

    it "does an end where on tags" do
      expect(tag.autocomplete("CAT")).to eq([tag_cats])
    end

    it "sorts the results by name" do
      tag_cat = tag.create(name: "cat")
      tag_catt = tag.create(name: "catt")
      expect(tag.autocomplete("CAT")).to eq([tag_cat, tag_cats, tag_catt])
    end
  end

  describe ".normalize" do
    it "removes leading hash symbols" do
      expect(tag.normalize("#mytag")).to eq("mytag")
    end

    it "removes punctuation and whitespace" do
      {
        "node.js"                          => "nodejs",
        ".dotatstart"                      => "dotatstart",
        "you,inside"                       => "youinside",
        "iam(parenthetical)"               => "iamparenthetical",
        "imeanit?maybe"                    => "imeanitmaybe",
        "imeanit!"                         => "imeanit",
        "how about spaces"                 => "howaboutspaces",
        "other\twhitespace\n"              => "otherwhitespace",
        "hash#inside"                      => "hashinside",
        "f!u@n#k$y%-<c>^h&a*r(a)c{t}e[r]s" => "funky-characters"
      }.each do |invalid, normalized|
        expect(tag.normalize(invalid)).to eq(normalized)
      end
    end

    it "allows for love" do
      expect(tag.normalize("<3")).to eq("<3")
      expect(tag.normalize("#<3")).to eq("<3")
    end
  end
end
