# frozen_string_literal: true

describe PublisherHelper, type: :helper do
  describe "#public_selected?" do
    it "returns true when the selected_aspects contains 'public'" do
      expect(helper.public_selected?(["public"])).to be_truthy
    end

    it "returns true when the publisher is set to public" do
      @stream = double(publisher: double(public: true))
      expect(helper.public_selected?(alice.aspects.to_a)).to be_truthy
    end

    it "returns false when the selected_aspects does not contain 'public' and the publisher is not public" do
      @stream = double(publisher: double(public: false))
      expect(helper.public_selected?(alice.aspects.to_a)).to be_falsey
    end

    it "returns false when the selected_aspects does not contain 'public' and there is no stream" do
      expect(helper.public_selected?(alice.aspects.to_a)).to be_falsey
    end
  end

  describe "#all_aspects_selected?" do
    it "returns true when the selected_aspects are the same size as all_aspects from the user" do
      expect(helper).to receive(:all_aspects).twice.and_return(alice.aspects.to_a)
      expect(helper.all_aspects_selected?(alice.aspects.to_a)).to be_truthy
    end

    it "returns false when not all aspects are selected" do
      alice.aspects.create(name: "other")
      expect(helper).to receive(:all_aspects).twice.and_return(alice.aspects.to_a)
      expect(helper.all_aspects_selected?([alice.aspects.first])).to be_falsey
    end

    it "returns false when the user does not have aspects" do
      expect(helper).to receive(:all_aspects).and_return([])
      expect(helper.all_aspects_selected?(alice.aspects.to_a)).to be_falsey
    end

    it "returns false when the publisher is set to public" do
      @stream = double(publisher: double(public: true))
      expect(helper).to receive(:all_aspects).twice.and_return(alice.aspects.to_a)
      expect(helper.all_aspects_selected?(alice.aspects.to_a)).to be_falsey
    end
  end

  describe "#aspect_selected?" do
    before do
      alice.aspects.create(name: "other")
      allow(helper).to receive(:all_aspects).and_return(alice.aspects.to_a)
    end

    it "returns true when the selected_aspects contains the aspect" do
      expect(helper.aspect_selected?(alice.aspects.first, [alice.aspects.first])).to be_truthy
    end

    it "returns false when the selected_aspects does not contain the aspect" do
      expect(helper.aspect_selected?(alice.aspects.first, [alice.aspects.second])).to be_falsey
    end

    it "returns false when all aspects are selected" do
      expect(helper.aspect_selected?(alice.aspects.first, alice.aspects.to_a)).to be_falsey
    end

    it "returns false when the publisher is set to public" do
      @stream = double(publisher: double(public: true))
      expect(helper.aspect_selected?(alice.aspects.first, [alice.aspects.first])).to be_falsey
    end
  end
end
