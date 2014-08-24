require 'spec_helper'
describe Workers::GatherOpenGraphData do
  before do
    @ogsite_title = 'Homepage'
    @ogsite_type = 'website'
    @ogsite_image = '/img/something.png'
    @ogsite_url = 'http://www.we-support-open-graph.com'
    @ogsite_description = 'Homepage'

    @ogsite_body =
      "<html><head><title>#{@ogsite_title}</title>
      <meta property=\"og:title\" content=\"#{@ogsite_title}\"/>
      <meta property=\"og:type\" content=\"#{@ogsite_type}\" />
      <meta property=\"og:image\" content=\"#{@ogsite_image}\" />
      <meta property=\"og:url\" content=\"#{@ogsite_url}\" />
      <meta property=\"og:description\" content=\"#{@ogsite_description}\" />
      </head><body></body></html>"

    @no_open_graph_url = 'http://www.we-do-not-support-open-graph.com/index.html'

    @status_message = FactoryGirl.create(:status_message)

    stub_request(:get, @ogsite_url).to_return(:status => 200, :body => @ogsite_body)
    stub_request(:get, @no_open_graph_url).to_return(:status => 200, :body => '<html><body>hello there</body></html>')
  end

  describe '.perform' do
    it 'requests not data from the internet' do
      Workers::GatherOpenGraphData.new.perform(@status_message.id, @ogsite_url)

      a_request(:get, @ogsite_url).should have_been_made
    end

    it 'requests not data from the internet only once' do
      2.times do |n|
        Workers::GatherOpenGraphData.new.perform(@status_message.id, @ogsite_url)
      end

      a_request(:get, @ogsite_url).should have_been_made.times(1)
    end

    it 'creates one cache entry' do
      Workers::GatherOpenGraphData.new.perform(@status_message.id, @ogsite_url)

      ogc = OpenGraphCache.find_by_url(@ogsite_url)

      ogc.title.should == @ogsite_title
      ogc.ob_type.should == @ogsite_type
      ogc.image.should == @ogsite_url + @ogsite_image
      ogc.url.should == @ogsite_url
      ogc.description.should == @ogsite_description

      Workers::GatherOpenGraphData.new.perform(@status_message.id, @ogsite_url)
      OpenGraphCache.where(url: @ogsite_url).count.should == 1
    end

    it 'creates no cache entry for unsupported pages' do
      Workers::GatherOpenGraphData.new.perform(@status_message.id, @no_open_graph_url)

      OpenGraphCache.find_by_url(@no_open_graph_url).should be_nil
    end

    it 'gracefully handles a deleted post' do
      expect {
        Workers::GatherOpenGraphData.new.perform(0, @ogsite_url)
      }.to_not raise_error
    end
  end
end
