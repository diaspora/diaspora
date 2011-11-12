require 'spec_helper'

describe Diaspora::Markdownify::HTML do
  describe '#autolink' do
    before do
      @html = Diaspora::Markdownify::HTML.new
    end

    it 'makes all of the links open in a new tab' do
      markdownified = @html.autolink("http://joindiaspora.com", nil)
      doc = Nokogiri.parse(markdownified)

      link = doc.css("a")

      link.attr("target").value.should == "_blank"
    end

    context 'given a cached short URL expansion' do
      before do
        @expansion = Factory.create(
          :short_url_expansion,
          :url_short => 'http://bit.ly/uehqyK',
          :url_expanded => 'https://diasp0ra.ca/'
        )
      end

      it 'expands third-party shortened URLs' do
        markdownified = @html.autolink('http://bit.ly/uehqyK', nil)
        markdownified.should == %{<a href="https://diasp0ra.ca/" target="_blank" title="https://diasp0ra.ca/">http://bit.ly/uehqyK</a>}
      end
    end

    context 'given a third-party shortened URL which is not cached' do
      before do
        ShortUrlExpansion.find_by_url_short('http://bit.ly/ttQqRi').should be_nil
      end

      context 'and the third-party service is working' do
        context 'and the short URL redirects once' do
          before do
            @shortened_urls = [
              'http://bit.ly/ttQqRi',
              'http://j.mp/ttQqRi',
              'http://goo.gl/vrm41',
              'http://is.gd/lmmKoe',
              'http://tinyurl.com/c5ydjlp',
            ]
            @shortened_urls.each do |url_short|
              stub_request( :get, url_short ).to_return(
                :status => 301,
                :headers => { 'Location' => 'http://www.whatisdiaspora.com/', },
                :body => "some html here"
              )
            end

            stub_request( :get, 'http://www.whatisdiaspora.com/' ).to_return(
              :status => 200,
              :body => "abc"
            )
          end

          it 'caches URL expansions' do
            markdownified = @html.autolink('http://bit.ly/ttQqRi', nil)
            ShortUrlExpansion.find_by_url_short('http://bit.ly/ttQqRi').should_not be_nil
          end

          it 'expands third-party shortened URLs' do
            @shortened_urls.each do |url_short|
              markdownified = @html.autolink(url_short, nil)
              markdownified.should == %{<a href="http://www.whatisdiaspora.com/" target="_blank" title="http://www.whatisdiaspora.com/">#{url_short}</a>}
            end
          end

        end

        context 'and the short URL redirects "too many" times' do
          before do
            stub_request( :get, 'http://bit.ly/a' ).to_return(
              :status => 301,
              :headers => { 'Location' => 'http://bit.ly/b', },
              :body => "some html here"
            )

            stub_request( :get, 'http://bit.ly/b' ).to_return(
              :status => 301,
              :headers => { 'Location' => 'http://bit.ly/c', },
              :body => "some html here"
            )

            stub_request( :get, 'http://bit.ly/c' ).to_return(
              :status => 301,
              :headers => { 'Location' => 'http://bit.ly/a', },
              :body => "some html here"
            )
          end

          it 'leaves the third-party shortened URL alone' do
            markdownified = @html.autolink('http://bit.ly/a', nil)
            markdownified.should == %{<a href="http://bit.ly/a" target="_blank">http://bit.ly/a</a>}

            markdownified = @html.autolink('http://bit.ly/b', nil)
            markdownified.should == %{<a href="http://bit.ly/b" target="_blank">http://bit.ly/b</a>}

            markdownified = @html.autolink('http://bit.ly/c', nil)
            markdownified.should == %{<a href="http://bit.ly/c" target="_blank">http://bit.ly/c</a>}
          end
        end
      end

      context 'and the third-party service is down' do
        before do
          Net::HTTP.should_receive(:start).and_raise Timeout::Error
        end

        it 'leaves the third-party shortened URL alone' do
          markdownified = @html.autolink('http://bit.ly/ttQqRi', nil)
          markdownified.should == %{<a href="http://bit.ly/ttQqRi" target="_blank">http://bit.ly/ttQqRi</a>}
        end
      end
    end
  end
end
