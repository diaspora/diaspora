# frozen_string_literal: true

describe Workers::GatherOpenGraphData do
  before do
    @ogsite_title = 'Homepage'
    @ogsite_type = 'website'
    @ogsite_image = 'http://www.we-support-open-graph.com/img/something.png'
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

    @oglong_title = "D" * 256
    @oglong_url = 'http://www.we-are-too-long.com'
    @oglong_body =
      "<html><head><title>#{@oglong_title}</title>
      <meta property=\"og:title\" content=\"#{@oglong_title}\"/>
      <meta property=\"og:type\" content=\"#{@ogsite_type}\" />
      <meta property=\"og:image\" content=\"#{@ogsite_image}\" />
      <meta property=\"og:url\" content=\"#{@oglong_url}\" />
      <meta property=\"og:description\" content=\"#{@ogsite_description}\" />
      </head><body></body></html>"

    @no_open_graph_url = 'http://www.we-do-not-support-open-graph.com/index.html'

    @status_message = FactoryGirl.create(:status_message)

    stub_request(:head, @ogsite_url).to_return(status: 200, body: "", headers: {'Content-Type' => 'text/html; utf-8'})
    stub_request(:get, @ogsite_url).to_return(status: 200, body: @ogsite_body, headers: {'Content-Type' => 'text/html; utf-8'})
    stub_request(:head, @no_open_graph_url).to_return(status: 200, body: "", headers: {'Content-Type' => 'text/html; utf-8'})
    stub_request(:get, @no_open_graph_url).to_return(:status => 200, :body => '<html><head><title>Hi</title><body>hello there</body></html>', headers: {'Content-Type' => 'text/html; utf-8'})
    stub_request(:head, @oglong_url).to_return(status: 200, body: "", headers: {'Content-Type' => 'text/html; utf-8'})
    stub_request(:get, @oglong_url).to_return(status: 200, body: @oglong_body, headers: {'Content-Type' => 'text/html; utf-8'})

  end

  describe '.perform' do
    it 'requests not data from the internet' do
      Workers::GatherOpenGraphData.new.perform(@status_message.id, @ogsite_url)

      expect(a_request(:get, @ogsite_url)).to have_been_made
    end

    it 'requests not data from the internet only once' do
      2.times do |n|
        Workers::GatherOpenGraphData.new.perform(@status_message.id, @ogsite_url)
      end

      expect(a_request(:get, @ogsite_url)).to have_been_made.times(1)
    end

    it 'creates one cache entry' do
      Workers::GatherOpenGraphData.new.perform(@status_message.id, @ogsite_url)

      ogc = OpenGraphCache.find_by_url(@ogsite_url)

      expect(ogc.title).to eq(@ogsite_title)
      expect(ogc.ob_type).to eq(@ogsite_type)
      expect(ogc.image).to eq(@ogsite_image)
      expect(ogc.url).to eq(@ogsite_url)
      expect(ogc.description).to eq(@ogsite_description)

      Workers::GatherOpenGraphData.new.perform(@status_message.id, @ogsite_url)
      expect(OpenGraphCache.where(url: @ogsite_url).count).to eq(1)
    end

    it 'creates no cache entry for unsupported pages' do
      Workers::GatherOpenGraphData.new.perform(@status_message.id, @no_open_graph_url)

      expect(OpenGraphCache.find_by_url(@no_open_graph_url)).to be_nil
    end

    it 'gracefully handles a deleted post' do
      expect {
        Workers::GatherOpenGraphData.new.perform(0, @ogsite_url)
      }.to_not raise_error
    end
    it 'truncates + inserts titles that are too long' do
      Workers::GatherOpenGraphData.new.perform(@status_message.id, @oglong_url)
      ogc = OpenGraphCache.find_by_url(@oglong_url)
      expect(ogc).to be_truthy
      expect(ogc.title.length).to be <= 255
    end
  end
end
