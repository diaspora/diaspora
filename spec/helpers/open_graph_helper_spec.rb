# frozen_string_literal: true

describe OpenGraphHelper, :type => :helper do

  describe 'og_html' do
    scenarios = {
      "article" => {
        "url" => "http://opengraph-enabled-site.com/articles/1332-scientists-discover-new-planet",
        "image" => "http://opengraph-enabled-site.com/images/1332-lead.jpg",
        "title" => "Scientists discover new planet",
        "description" => "A new planet was found yesterday"
      },
    }

    scenarios.each do |type, data|
      specify 'for type "'+type+'"' do
        cache =  OpenGraphCache.new(:url => data['url'])
        cache.ob_type = type
        cache.image = data['image']
        cache.title = data['title']
        cache.description = data['description']

        formatted = og_html(cache)

        expect(formatted).to match(/#{data['url']}/)
        expect(formatted).to match(/#{data['title']}/)
        expect(formatted).to match(/#{data['image']}/)
        expect(formatted).to match(/#{data['description']}/)
      end
    end
  end
end
