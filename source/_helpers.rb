gem 'activesupport', ">= 2.3.2"
require 'active_support'
require 'rubypants'

module Helpers
  module EscapeHelper
    HTML_ESCAPE = { '&' => '&amp; ',  '>' => '&gt;',   '<' => '&lt;', '"' => '&quot;' }
    JSON_ESCAPE = { '&' => '\u0026 ', '>' => '\u003E', '<' => '\u003C' }
    
    # A utility method for escaping HTML tag characters.
    # This method is also aliased as <tt>h</tt>.
    #
    # In your ERb templates, use this method to escape any unsafe content. For example:
    #   <%=h @person.name %>
    #
    # ==== Example:
    #   puts html_escape("is a > 0 & a < 10?")
    #   # => is a &gt; 0 &amp; a &lt; 10?
    def html_escape(html)
      html.to_s.gsub(/[&"><]/) { |special| HTML_ESCAPE[special] }
    end
    def escape_once(html)
      html.to_s.gsub(/[\"><]|&(?!([a-zA-Z]+|(#\d+));)/) { |special| HTML_ESCAPE[special] }
    end
    alias h escape_once
    
    # A utility method for escaping HTML entities in JSON strings.
    # This method is also aliased as <tt>j</tt>.
    #
    # In your ERb templates, use this method to escape any HTML entities:
    #   <%=j @person.to_json %>
    #
    # ==== Example:
    #   puts json_escape("is a > 0 & a < 10?")
    #   # => is a \u003E 0 \u0026 a \u003C 10?
    def json_escape(s)
      s.to_s.gsub(/[&"><]/) { |special| JSON_ESCAPE[special] }
    end
    
    alias j json_escape
  end
  include EscapeHelper
  
  module ParamsHelper
    def params
      @params ||= begin
        q = request.query.dup
        q.each { |(k,v)| q[k.to_s.intern] = v }
        q
      end
    end
  end
  include ParamsHelper
  
  module TagHelper
    def content_tag(name, content, html_options={})
      %{<#{name}#{html_attributes(html_options)}>#{content}</#{name}>}
    end
    
    def tag(name, html_options={})
      %{<#{name}#{html_attributes(html_options)} />}
    end
    
    def image_tag(src, html_options = {})
      tag(:img, html_options.merge({:src=>src}))
    end
    
    def javascript_tag(content = nil, html_options = {})
      content_tag(:script, javascript_cdata_section(content), html_options.merge(:type => "text/javascript"))
    end
    
    def link_to(name, href, html_options = {})
      html_options = html_options.stringify_keys
      confirm = html_options.delete("confirm")
      onclick = "if (!confirm('#{html_escape(confirm)}')) return false;" if confirm
      content_tag(:a, name, html_options.merge(:href => href, :onclick=>onclick))
    end
    
    def link_to_function(name, *args, &block)
      html_options = {}
      html_options = args.pop if args.last.is_a? Hash
      function = args[0] || ''
      onclick = "#{"#{html_options[:onclick]}; " if html_options[:onclick]}#{function}; return false;"
      href = html_options[:href] || '#'
      content_tag(:a, name, html_options.merge(:href => href, :onclick => onclick))
    end
    
    private
    
      def cdata_section(content)
        "<![CDATA[#{content}]]>"
      end
      
      def javascript_cdata_section(content) #:nodoc:
        "\n//#{cdata_section("\n#{content}\n//")}\n"
      end
      
      def html_attributes(options)
        unless options.blank?
          attrs = []
          options.each_pair do |key, value|
            if value == true
              attrs << %(#{key}="#{key}") if value
            else
              attrs << %(#{key}="#{value}") unless value.nil?
            end
          end
          " #{attrs.sort * ' '}" unless attrs.empty?
        end
      end
  end
  include TagHelper
  
  # My added helpers
  
  def to_html_email(address)
    email = string_to_html(address)
    "<a href=\"#{string_to_html('mailto:')}#{email}\">#{email}</a>"
  end

  def string_to_html(s)
    s.strip.unpack("C*").map{|ch| "&#" + ch.to_s + ";" }.to_s
  end
  
  def show_part (file)
    data = ''
    f = File.open(Dir.pwd+"/source/"+file)
    f.each_line do |line|
      data += line
    end
    data
  end
  
  def shorten_words (string, word_limit = 25)
    words = string.split(/\s/)
    if words.size >= word_limit
      words[0,(word_limit-1)].join(" ") + '&hellip;'
    else 
      string
    end
  end
  
  def shorten (string, char_limit = 55)
    chars = string.scan(/.{1,1}/)
    if chars.size >= char_limit
      chars[0,(char_limit-1)].join + '&hellip;'
    else
      "blah2"
    end
  end
  
  def absolute_url(input, url)
    input.gsub(/(href|src)(\s*=\s*)(["'])(\/.*?)\3/) { $1 + $2 + $3 + url + $4 + $3 }
  end
  
  def rp(input)
    RubyPants.new(input).to_html
  end
  def style_amp(input)
    input.gsub(" & "," <span class='amp'>&</span> ")
  end
  
  module PartialsHelper
    
    # A very hackish way to handle partials.  We'll go with it till it breaks...
    def include(partial_name)
      file_ext = partial_name[(partial_name.index('.') + 1)..partial_name.length]
      contents = IO.read("_includes/#{partial_name}")
      case file_ext
      when 'haml'
        Haml::Engine.new(contents).render(binding)
      when 'textile'
        RedCloth.new(contents).to_html
      when 'markdown'
        RDiscount.new(contents).to_html
      else
        contents
      end
    end
  end
  
  include PartialsHelper
end

class String
  def titlecase
    small_words = %w(a an and as at but by en for if in of on or the to v v. via vs vs.)
    
    x = split(" ").map do |word|
      # note: word could contain non-word characters!
      # downcase all small_words, capitalize the rest
      small_words.include?(word.gsub(/\W/, "").downcase) ? word.downcase! : word.smart_capitalize!
      word
    end
    # capitalize first and last words
    x.first.to_s.smart_capitalize!
    x.last.to_s.smart_capitalize!
    # small words after colons are capitalized
    x.join(" ").gsub(/:\s?(\W*#{small_words.join("|")}\W*)\s/) { ": #{$1.smart_capitalize} " }
  end
  
  def titlecase!
    replace(titlecase)
  end
  
  def smart_capitalize
    # ignore any leading crazy characters and capitalize the first real character
    if self =~ /^['"\(\[']*([a-z])/
      i = index($1)
      x = self[i,self.length]
      # word with capitals and periods mid-word are left alone
      self[i,1] = self[i,1].upcase unless x =~ /[A-Z]/ or x =~ /\.\w+/
    end
    self
  end
  
  def smart_capitalize!
    replace(smart_capitalize)
  end
end