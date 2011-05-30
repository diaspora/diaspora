#custom filters for Octopress

module OctopressFilters
  def exerpt(input, url, url_text="Reade more&hellip;", permalink_text=false)
    if input.index(/<!--\s?more\s?-->/i)
      input.split(/<!--\s?more\s?-->/i)[0] + "<p><a href='#{url}'>#{url_text}</a></p>"
    elsif permalink_text
      input + "<p><a href='#{url}'>#{permalink_text}</a></p>"
    else
      input
    end
  end
  def full_urls(input, url='')
    input.gsub /(\s+(href|src)\s*=\s*["|']{1})(\/[^\"'>]+)/ do
      $1+url+$3
    end
  end
  def search_url(input)
    input.gsub /(http:\/\/)(\S+)/ do
      $2
    end
  end
  def smart_quotes(input)
    require 'rubypants'
    RubyPants.new(input).to_html
  end
  def titlecase(input)
    require 'titlecase'
    input.titlecase
  end
  def datetime(date)
    if date.class == String
      date = Time.parse(date)
    end
    date
  end
  def ordinalize(date)
    date = datetime(date)
    "#{date.strftime('%B')} #{ordinal(date.strftime('%e').to_i)}, #{date.strftime('%Y')}"
  end
  def ordinal(number)
    if (11..13).include?(number.to_i % 100)
      "#{number}<span>th</span>"
    else
      case number.to_i % 10
      when 1; "#{number}<span>st</span>"
      when 2; "#{number}<span>nd<span>"
      when 3; "#{number}<span>rd</span>"
      else    "#{number}<span>th</span>"
      end
    end
  end
  #YearlyPost = Struct.new('YearlyPost', :year, :posts)
  def yearly_posts(site)
    #site.posts.reverse.group_by { |p| p.date.strftime("%Y") }.map { |k,v| YearlyPost.new(k,v) }
    site
  end
end
Liquid::Template.register_filter OctopressFilters

