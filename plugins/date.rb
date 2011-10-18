module Octopress
  module Date

    # Returns a datetime if the input is a string
    def datetime(date)
      if date.class == String
        date = Time.parse(date)
      end
      date
    end

    # Returns an ordidinal date eg July 22 2007 -> July 22nd 2007
    def ordinalize(date)
      date = datetime(date)
      "#{date.strftime('%b')} #{ordinal(date.strftime('%e').to_i)}, #{date.strftime('%Y')}"
    end

    # Returns an ordinal number. 13 -> 13th, 21 -> 21st etc.
    def ordinal(number)
      if (11..13).include?(number.to_i % 100)
        "#{number}<span>th</span>"
      else
        case number.to_i % 10
        when 1; "#{number}<span>st</span>"
        when 2; "#{number}<span>nd</span>"
        when 3; "#{number}<span>rd</span>"
        else    "#{number}<span>th</span>"
        end
      end
    end

  end
end


module Jekyll

  class Post
    include Octopress::Date

    attr_accessor :date_formatted

    # Convert this post into a Hash for use in Liquid templates.
    #
    # Returns <Hash>
    def to_liquid
      format = self.site.config['date_format']
      if format.nil? || format.empty? || format == "ordinal"
        date_formatted = ordinalize(self.date)
      else
        date_formatted = self.date.strftime(format)
      end

      self.data.deep_merge({
        "title"          => self.data["title"] || self.slug.split('-').select {|w| w.capitalize! || w }.join(' '),
        "url"            => self.url,
        "date"           => self.date,
        # Monkey patch
        "date_formatted" => date_formatted,
        "id"             => self.id,
        "categories"     => self.categories,
        "next"           => self.next,
        "previous"       => self.previous,
        "tags"           => self.tags,
        "content"        => self.content })
    end

  end
end