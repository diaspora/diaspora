require 'spec_helper'
require 'youtube_titles'
describe YoutubeTitles do
  before do
    @video_id = "ABYnqp-bxvg"
    @url="http://www.youtube.com/watch?v=#{@video_id}&a=GxdCwVVULXdvEBKmx_f5ywvZ0zZHHHDU&list=ML&playnext=1"
    @api_path = "/feeds/api/videos/#{@video_id}?v=2"
  end
  include YoutubeTitles
  describe '#youtube_title_for' do
    before do
      @expected_title = "UP & down & UP & down &amp;"
      @mock_http = mock("http")
      Net::HTTP.stub!(:new).with('gdata.youtube.com', 80).and_return(@mock_http)
    end
    it 'gets a youtube title corresponding to an id' do
      @mock_http.should_receive(:get).with(@api_path, nil).and_return(
        [nil, "Foobar <title>#{@expected_title}</title> hallo welt <asd><dasdd><a>dsd</a>"])
      youtube_title_for(@video_id).should == @expected_title
    end
    it 'returns a fallback for videos with no title' do
      @mock_http.should_receive(:get).with(@api_path, nil).and_return(
        [nil, "Foobar #{@expected_title}</title> hallo welt <asd><dasdd><a>dsd</a>"])
      youtube_title_for(@video_id).should == I18n.t('application.helper.video_title.unknown')
    end
  end
  describe 'serialization and marshalling' do
    before do
      @expected_title = '""Procrastination"" Tales Of Mere Existence'
      mock_http = mock("http")
      Net::HTTP.stub!(:new).with('gdata.youtube.com', 80).and_return(mock_http)
      mock_http.should_receive(:get).with(@api_path, nil).and_return(
        [nil, "Foobar <title>#{@expected_title}</title> hallo welt <asd><dasdd><a>dsd</a>"])
      @post = Factory.create(:status_message, :message => @url)
    end
    it 'can be re-marshalled' do
      lambda {
        StatusMessage.find(@post.id).youtube_titles
      }.should_not raise_error
    end
  end
end
