require 'spec_helper'
describe OEmbedPresenter do
  before do
   @oembed = OEmbedPresenter.new(FactoryGirl.create(:status_message))
  end

  it 'is a hash' do
    @oembed.as_json.should be_a Hash
  end

  context 'required options from oembed spec' do
    it 'supports maxheight + maxwidth(required)' do
      oembed = OEmbedPresenter.new(FactoryGirl.create(:status_message), :maxwidth => 200, :maxheight => 300).as_json
      oembed[:width].should  == 200
      oembed[:height].should == 300
    end
  end

  describe '#iframe_html' do
    it 'passes the height options to post_iframe_url' do
      @oembed.should_receive(:post_iframe_url).with(instance_of(Fixnum), instance_of(Hash))
      @oembed.iframe_html
    end
  end

  describe '.id_from_url' do
    it 'takes a long post url and gives you the id' do
      OEmbedPresenter.id_from_url('http://localhost:400/posts/1').should == "1"
    end

    it 'takes a short post url and gives you the id' do
      OEmbedPresenter.id_from_url('http://localhost:400/p/1').should == "1"
    end
  end
end