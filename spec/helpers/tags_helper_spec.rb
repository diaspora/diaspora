require 'spec_helper'

describe TagsHelper do
  describe '#looking_for_tag_link' do
    it 'returns nil if there is a @ in the query' do
      helper.stub(:search_query).and_return('foo@bar.com')
      helper.looking_for_tag_link.should be_nil
    end

    it 'returns nil if it normalizes to blank' do
      helper.stub(:search_query).and_return('++')
      helper.looking_for_tag_link.should be_nil
    end

    it 'returns a link to the tag otherwise' do
      helper.stub(:search_query).and_return('foo')
      helper.looking_for_tag_link.should include(helper.tag_link)
    end
  end
end
