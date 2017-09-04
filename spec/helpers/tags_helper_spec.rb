# frozen_string_literal: true

describe TagsHelper, :type => :helper do
  describe '#looking_for_tag_link' do
    it 'returns nil if there is a @ in the query' do
      allow(helper).to receive(:search_query).and_return('foo@bar.com')
      expect(helper.looking_for_tag_link).to be_nil
    end

    it 'returns nil if it normalizes to blank' do
      allow(helper).to receive(:search_query).and_return('++')
      expect(helper.looking_for_tag_link).to be_nil
    end

    it 'returns a link to the tag otherwise' do
      allow(helper).to receive(:search_query).and_return('foo')
      expect(helper.looking_for_tag_link).to include(helper.tag_link('foo'))
    end
  end
end
