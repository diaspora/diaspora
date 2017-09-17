# frozen_string_literal: true

shared_examples_for "it is mentions container" do
  let(:people) { [alice, bob, eve].map(&:person) }
  let(:test_string) {
    "@{Raphael; #{people[0].diaspora_handle}} can mention people like @{Ilya; #{people[1].diaspora_handle}}"\
    "can mention people like @{Daniel; #{people[2].diaspora_handle}}"
  }
  let(:target) { FactoryGirl.build(described_class.to_s.underscore.to_sym, text: test_string, author: alice.person) }
  let(:target_persisted) {
    target.save!
    target
  }

  describe ".before_create" do
    it "backports mention syntax to old syntax" do
      text = "mention @{#{people[0].diaspora_handle}} text"
      expected_text = "mention @{#{people[0].name}; #{people[0].diaspora_handle}} text"
      obj = FactoryGirl.build(described_class.to_s.underscore.to_sym, text: text, author: alice.person)
      obj.save
      expect(obj.text).to eq(expected_text)
    end

    it "doesn't backport mention syntax if author is not local" do
      text = "mention @{#{people[0].diaspora_handle}} text"
      obj = FactoryGirl.build(described_class.to_s.underscore.to_sym, text: text, author: remote_raphael)
      obj.save
      expect(obj.text).to eq(text)
    end
  end

  describe ".after_create" do
    it "calls create_mentions" do
      expect(target).to receive(:create_mentions).and_call_original
      target.save
    end
  end

  describe "#create_mentions" do
    it "creates a mention for everyone mentioned in the message" do
      people.each do |person|
        expect(target.mentions).to receive(:find_or_create_by).with(person_id: person.id)
      end
      target.create_mentions
    end

    it "does not barf if it gets called twice" do
      expect {
        target_persisted.create_mentions
      }.to_not raise_error
    end
  end

  describe "#mentioned_people" do
    it "returns the mentioned people if non-persisted" do
      expect(target.mentioned_people).to match_array(people)
    end

    it "returns the mentioned people if persisted" do
      expect(target_persisted.mentioned_people).to match_array(people)
    end
  end
end
