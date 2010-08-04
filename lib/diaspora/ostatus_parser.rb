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

    def self.author(doc)
      doc = Nokogiri::HTML(doc) if doc.is_a? String
      author = {} 
      author[:service]          = self.service(doc)
      author[:feed_url]         = self.feed_url(doc)
      author[:avatar_thumbnail] = self.avatar_thumbnail(doc)
      author[:username]         = self.username(doc)
      author[:profile_url]      = self.profile_url(doc)
      author
    end

    def self.entry(doc)
      doc = Nokogiri::HTML(doc) if doc.is_a? String
      entry = {}
      entry[:message]           = self.message(doc)
      entry[:permalink]         = self.permalink(doc)
      entry[:published_at]      = self.published_at(doc)
      entry[:updated_at]        = self.updated_at(doc)
      entry
    end


    ##author###
    def self.service(doc)
      doc.xpath('//generator').each{|x| return x.inner_html}
    end

    def self.feed_url(doc)
      doc.xpath('//id').each{|x| return x.inner_html}
    end

    def self.avatar_thumbnail(doc)
        doc.xpath('//logo').each{|x| return x.inner_html}
    end

    def self.username(doc)
      doc.xpath('//author/name').each{|x| return x.inner_html}
    end

    def self.profile_url(doc)
      doc.xpath('//author/uri').each{|x| return x.inner_html}
    end


    #entry##
    def self.message(doc)
      doc.xpath('//entry/title').each{|x| return x.inner_html}
    end

    def self.permalink(doc)
      doc.xpath('//entry/id').each{|x| return x.inner_html}
    end

    def self.published_at(doc)
      doc.xpath('//entry/published').each{|x| return x.inner_html}
    end

    def self.updated_at(doc)
      doc.xpath('//entry/updated').each{|x| return x.inner_html}
    end 

  end
end
