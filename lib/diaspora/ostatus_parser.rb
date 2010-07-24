module Diaspora
  module OStatusParser
    def self.find_hub(xml)
      xml = Nokogiri::HTML(xml) if xml.is_a? String
      xml.xpath('//link[@rel="hub"]').first.attribute("href").value
    end

    def self.process(xml)
      doc = Nokogiri::HTML(xml)
      author_hash = parse_author(doc)

      author_hash[:hub] = find_hub(doc) 
      entry_hash = parse_entry(doc)

      author = Author.instantiate(author_hash)
      author.ostatus_posts.create(entry_hash) unless entry_hash[:message] == 0
    end

    def self.parse_author(doc)
      doc = Nokogiri::HTML(doc) if doc.is_a? String
      author = {} 
      author[:service] = parse_service(doc)
      author[:feed_url] = parse_feed_url(doc)
      author[:avatar_thumbnail] = parse_avatar_thumbnail(doc)
      author[:username] = parse_username(doc)
      author[:profile_url] = parse_profile_url(doc)
      author
    end

    def self.parse_entry(doc)
      doc = Nokogiri::HTML(doc) if doc.is_a? String
      entry = {}
      entry[:message] = parse_message(doc)
      entry[:permalink] = parse_permalink(doc)
      entry[:published_at] = parse_published_at(doc)
      entry[:updated_at] = parse_updated_at(doc)
      entry
    end


    ##author###
    def self.parse_service(doc)
      doc.xpath('//generator').each{|x| return x.inner_html}
    end

    def self.parse_feed_url(doc)
      doc.xpath('//id').each{|x| return x.inner_html}
    end

    def self.parse_avatar_thumbnail(doc)
        doc.xpath('//logo').each{|x| return x.inner_html}
    end

    def self.parse_username(doc)
      doc.xpath('//author/name').each{|x| return x.inner_html}
    end

    def self.parse_profile_url(doc)
      doc.xpath('//author/uri').each{|x| return x.inner_html}
    end


    #entry##
    def self.parse_message(doc)
      doc.xpath('//entry/title').each{|x| return x.inner_html}
    end

    def self.parse_permalink(doc)
      doc.xpath('//entry/id').each{|x| return x.inner_html}
    end

    def self.parse_published_at(doc)
      doc.xpath('//entry/published').each{|x| return x.inner_html}
    end

    def self.parse_updated_at(doc)
      doc.xpath('//entry/updated').each{|x| return x.inner_html}
    end 
  end
end