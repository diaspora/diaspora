module Diaspora
  module OStatusParser

    def self.process(xml)
      doc = Nokogiri::HTML(xml)
      author_hash = parse_author(doc)

      author_hash[:hub] = self.hub(doc) 
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


    def self.hub(xml)
      xml = Nokogiri::HTML(xml) if xml.is_a? String
      xml.xpath('//link[@rel="hub"]').first.attribute("href").value
    end

    # Author #########################
    def self.service(doc)
      self.contents(doc.xpath('//generator'))
    end

    def self.feed_url(doc)
      self.contents(doc.xpath('//id'))
    end

    def self.avatar_thumbnail(doc)
      self.contents(doc.xpath('//logo'))
    end

    def self.username(doc)
      self.contents(doc.xpath('//author/name'))
    end

    def self.profile_url(doc)
      self.contents(doc.xpath('//author/uri'))
    end

    # Entry ##########################
    def self.message(doc)
      self.contents(doc.xpath('//entry/title'))
    end

    def self.permalink(doc)
      self.contents(doc.xpath('//entry/id'))
    end

    def self.published_at(doc)
      self.contents(doc.xpath('//entry/published'))
    end

    def self.updated_at(doc)
      self.contents(doc.xpath('//entry/updated'))
    end 


    def self.contents(xpath)
      xpath.each{|x| return x.inner_html}
    end

  end
end
