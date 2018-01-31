# frozen_string_literal: true

describe Publisher do
  before do
    @publisher = Publisher.new(alice)
  end

  describe "#prefill" do
    it 'defaults to nothing' do
      expect(@publisher.prefill).to be_blank
    end

    it 'is settable' do
      expect(Publisher.new(alice, :prefill => "party!").prefill).to eq("party!")
    end
  end

  %w(open public).each do |property|
    describe "##{property}" do
      it 'defaults to closed' do
        expect(@publisher.send("#{property}".to_sym)).to be_falsey
      end

      it 'listens to the opts' do
        expect(Publisher.new(alice, property.to_sym => true).send("#{property}".to_sym)).to be true
      end
    end
  end

end
