require File.expand_path(File.dirname(__FILE__) + "/../spec_helper")

describe Typhoeus::HydraMock do
  it "should mark all responses as mocks" do
    response = Typhoeus::Response.new(:mock => false)
    response.should_not be_mock

    mock = Typhoeus::HydraMock.new("http://localhost", :get)
    mock.and_return(response)

    mock.response.should be_mock
    response.should be_mock
  end

  describe "stubbing response values" do
    before(:each) do
      @stub = Typhoeus::HydraMock.new('http://localhost:3000', :get)
    end

    describe "with a single response" do
      it "should always return that response" do
        response = Typhoeus::Response.new
        @stub.and_return(response)

        5.times do
          @stub.response.should == response
        end
      end
    end

    describe "with multiple responses" do
      it "should return consecutive responses in the array, then keep returning the last one" do
        responses = []
        3.times do |i|
          responses << Typhoeus::Response.new(:body => "response #{i}")
        end

        # Stub 3 consecutive responses.
        @stub.and_return(responses)

        0.upto(2) do |i|
          @stub.response.should == responses[i]
        end

        5.times do
          @stub.response.should == responses.last
        end
      end
    end
  end

  describe "#matches?" do
    describe "basic matching" do
      it "should not match if the HTTP verbs are different" do
        request = Typhoeus::Request.new("http://localhost:3000",
                                        :method => :get)
        mock = Typhoeus::HydraMock.new("http://localhost:3000", :post)
        mock.matches?(request).should be_false
      end
    end

    describe "matching on ports" do
      it "should handle default port 80 sanely" do
        mock = Typhoeus::HydraMock.new('http://www.example.com:80/', :get,
                                       :headers => { 'user-agent' => 'test' })
        request = Typhoeus::Request.new('http://www.example.com/',
                                        :method => :get,
                                        :user_agent => 'test')
        mock.matches?(request).should be_true
      end

      it "should handle default port 443 sanely" do
        mock = Typhoeus::HydraMock.new('https://www.example.com:443/', :get,
                                       :headers => { 'user-agent' => 'test' })
        request = Typhoeus::Request.new('https://www.example.com/',
                                        :method => :get,
                                        :user_agent => 'test')
        mock.matches?(request).should be_true
      end
    end


    describe "any HTTP verb" do
      it "should match any verb" do
        mock = Typhoeus::HydraMock.new("http://localhost:3000", :any,
                                       :headers => { 'user-agent' => 'test' })
        [:get, :post, :delete, :put].each do |verb|
          request = Typhoeus::Request.new("http://localhost:3000",
                                          :method => verb,
                                          :user_agent => 'test')
          mock.matches?(request).should be_true
        end
      end
    end

    describe "header matching" do
      def request(options = {})
        Typhoeus::Request.new("http://localhost:3000", options.merge(:method => :get))
      end

      def mock(options = {})
        Typhoeus::HydraMock.new("http://localhost:3000", :get, options)
      end

      context 'when no :headers option is given' do
        subject { mock }

        it "matches regardless of whether or not the request has headers" do
          subject.matches?(request(:headers => nil)).should be_true
          subject.matches?(request(:headers => {})).should be_true
          subject.matches?(request(:headers => { 'a' => 'b' })).should be_true
        end
      end

      [nil, {}].each do |value|
        context "for :headers => #{value.inspect}" do
          subject { mock(:headers => value) }

          it "matches when the request has no headers" do
            subject.matches?(request(:headers => nil)).should be_true
            subject.matches?(request(:headers => {})).should be_true
          end

          it "does not match when the request has headers" do
            subject.matches?(request(:headers => { 'a' => 'b' })).should be_false
          end
        end
      end

      context 'for :headers => [a hash]' do
        it 'does not match if the request has no headers' do
          m = mock(:headers => { 'A' => 'B', 'C' => 'D' })

          m.matches?(request).should be_false
          m.matches?(request(:headers => nil)).should be_false
          m.matches?(request(:headers => {})).should be_false
        end

        it 'does not match if the request lacks any of the given headers' do
          mock(
            :headers => { 'A' => 'B', 'C' => 'D' }
          ).matches?(request(
            :headers => { 'A' => 'B' }
          )).should be_false
        end

        it 'does not match if any of the specified values are different from the request value' do
          mock(
            :headers => { 'A' => 'B', 'C' => 'D' }
          ).matches?(request(
            :headers => { 'A' => 'B', 'C' => 'E' }
          )).should be_false
        end

        it 'matches if the given hash is exactly equal to the request headers' do
          mock(
            :headers => { 'A' => 'B', 'C' => 'D' }
          ).matches?(request(
            :headers => { 'A' => 'B', 'C' => 'D' }
          )).should be_true
        end

        it 'matches even if the request has additional headers not specified in the mock' do
          mock(
            :headers => { 'A' => 'B', 'C' => 'D' }
          ).matches?(request(
            :headers => { 'A' => 'B', 'C' => 'D', 'E' => 'F' }
          )).should be_true
        end

        it 'matches even if the casing of the header keys is different between the mock and request' do
          mock(
            :headers => { 'A' => 'B', 'c' => 'D' }
          ).matches?(request(
            :headers => { 'a' => 'B', 'C' => 'D' }
          )).should be_true
        end

        it 'matches if the mocked values are regexes and match the request values' do
          mock(
            :headers => { 'A' => /foo/, }
          ).matches?(request(
            :headers => { 'A' => 'foo bar' }
          )).should be_true
        end

        it 'does not match if the mocked values are regexes and do not match the request values' do
          mock(
            :headers => { 'A' => /foo/, }
          ).matches?(request(
            :headers => { 'A' => 'bar' }
          )).should be_false
        end

        context 'when a header is specified as an array' do
          it 'matches when the request header has the same array' do
            mock(
              :headers => { 'Accept' => ['text/html', 'text/plain'] }
            ).matches?(request(
              :headers => { 'Accept' => ['text/html', 'text/plain'] }
            )).should be_true
          end

          it 'matches when the request header is a single value and the mock array has the same value' do
            mock(
              :headers => { 'Accept' => ['text/html'] }
            ).matches?(request(
              :headers => { 'Accept' => 'text/html' }
            )).should be_true
          end

          it 'matches even when the request header array is ordered differently' do
            mock(
              :headers => { 'Accept' => ['text/html', 'text/plain'] }
            ).matches?(request(
              :headers => { 'Accept' => ['text/plain', 'text/html'] }
            )).should be_true
          end

          it 'does not match when the request header array lacks a value' do
            mock(
              :headers => { 'Accept' => ['text/html', 'text/plain'] }
            ).matches?(request(
              :headers => { 'Accept' => ['text/plain'] }
            )).should be_false
          end

          it 'does not match when the request header array has an extra value' do
            mock(
              :headers => { 'Accept' => ['text/html', 'text/plain'] }
            ).matches?(request(
              :headers => { 'Accept' => ['text/html', 'text/plain', 'application/xml'] }
            )).should be_false
          end

          it 'does not match when the request header is not an array' do
            mock(
              :headers => { 'Accept' => ['text/html', 'text/plain'] }
            ).matches?(request(
              :headers => { 'Accept' => 'text/html' }
            )).should be_false
          end
        end
      end
    end

    describe "post body matching" do
      it "should not bother matching on body if we don't turn the option on" do
        request = Typhoeus::Request.new("http://localhost:3000",
                                        :method => :get,
                                        :user_agent => 'test',
                                        :body => "fdsafdsa")
        mock = Typhoeus::HydraMock.new("http://localhost:3000", :get,
                                       :headers => { 'user-agent' => 'test' })
        mock.matches?(request).should be_true
      end

      it "should match nil correctly" do
        request = Typhoeus::Request.new("http://localhost:3000",
                                        :method => :get,
                                        :body => "fdsafdsa")
        mock = Typhoeus::HydraMock.new("http://localhost:3000", :get,
                                       :body => nil)
        mock.matches?(request).should be_false
      end

      it "should not match if the bodies do not match" do
        request = Typhoeus::Request.new("http://localhost:3000",
                                        :method => :get,
                                        :body => "ffdsadsafdsa")
        mock = Typhoeus::HydraMock.new("http://localhost:3000", :get,
                                       :body => 'fdsafdsa')
        mock.matches?(request).should be_false
      end

      it "should match on optional body parameter" do
        request = Typhoeus::Request.new("http://localhost:3000",
                                        :method => :get,
                                        :user_agent => 'test',
                                        :body => "fdsafdsa")
        mock = Typhoeus::HydraMock.new("http://localhost:3000", :get,
                                       :body => 'fdsafdsa',
                                       :headers => {
                                         'User-Agent' => 'test'
                                       })
        mock.matches?(request).should be_true
      end

      it "should regex match" do
        request = Typhoeus::Request.new("http://localhost:3000/whatever/fdsa",
                                        :method => :get,
                                        :user_agent => 'test')
        mock = Typhoeus::HydraMock.new(/fdsa/, :get,
                                       :headers => { 'user-agent' => 'test' })
        mock.matches?(request).should be_true
      end
    end
  end
end

