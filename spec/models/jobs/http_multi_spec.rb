require 'spec_helper'

describe Jobs::HttpMulti do
  before do
    @urls = ['example.org/things/on/fire', 'http://google.com/']
    @body = '<xml>California</xml>'

    @hydra = Typhoeus::Hydra.new
    @response = Typhoeus::Response.new(:code => 200, :headers => "", :body => "", :time => 0.2)
    @failed_response = Typhoeus::Response.new(:code => 504, :headers => "", :body => "", :time => 0.2)

  end

  it 'POSTs to more than one URL' do
    @urls.each do |url|
      @hydra.stub(:post, url).and_return(@response)
    end

    @hydra.should_receive(:queue).twice
    @hydra.should_receive(:run).once
    Typhoeus::Hydra.stub!(:new).and_return(@hydra)

    Jobs::HttpMulti.perform(@urls, @body)
  end

  it 'retries' do
    url = @urls[0]

    @hydra.stub(:post, url).and_return(@failed_response)

    Typhoeus::Hydra.stub!(:new).and_return(@hydra)

    Resque.should_receive(:enqueue).with(Jobs::HttpMulti, [url], @body, 1).once
    Jobs::HttpMulti.perform([url], @body)
  end

  it 'max retries' do
    url = @urls[0]

    @hydra.stub(:post, url).and_return(@failed_response)

    Typhoeus::Hydra.stub!(:new).and_return(@hydra)

    Resque.should_not_receive(:enqueue)
    Jobs::HttpMulti.perform([url], @body, 3)
  end
end
