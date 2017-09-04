# frozen_string_literal: true

describe OEmbedPresenter do
  before do
   @oembed = OEmbedPresenter.new(FactoryGirl.create(:status_message))
  end

  it 'is a hash' do
    expect(@oembed.as_json).to be_a Hash
  end

  context 'required options from oembed spec' do
    it 'supports maxheight + maxwidth(required)' do
      oembed = OEmbedPresenter.new(FactoryGirl.create(:status_message), :maxwidth => 200, :maxheight => 300).as_json
      expect(oembed[:width]).to  eq(200)
      expect(oembed[:height]).to eq(300)
    end
  end

  describe '#iframe_html' do
    it 'passes the height options to post_iframe_url' do
      expect(@oembed).to receive(:post_iframe_url).with(kind_of(Integer), instance_of(Hash))
      @oembed.iframe_html
    end
  end

  describe '.id_from_url' do
    it 'takes a long post url and gives you the id' do
      expect(OEmbedPresenter.id_from_url('http://localhost:400/posts/1')).to eq("1")
    end

    it 'takes a short post url and gives you the id' do
      expect(OEmbedPresenter.id_from_url('http://localhost:400/p/1')).to eq("1")
    end
  end
end
