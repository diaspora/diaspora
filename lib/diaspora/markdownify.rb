require 'erb'

module Diaspora
  module Markdownify
    class HTML < Redcarpet::Render::HTML
      attr_accessor :newlines, :specialchars, :youtube_maps, :vimeo_maps

      def initialize(options={})
        super

        @newlines     = options.fetch(:newlines, true)
        @specialchars = options.fetch(:specialchars, true)
        @youtube_maps = options[:youtube_maps]||{}
        @vimeo_maps   = options[:vimeo_maps] || {}
      end

      def autolink(link, type)
        return link if type == :email
        autolink_youtube(link) || autolink_vimeo(link) || autolink_simple(link)
      end

      def autolink_simple(link)

        # If there isn't *some* protocol, assume http
        if link !~ %r{^\w+://}
          link = "http://#{link}"
        end

        content = link.gsub(%r{^\w+://}, '')

        %Q{<a target="_blank" href="#{link}">#{content}</a>}
      end

      def autolink_vimeo(link)
        regex = %r{https?://(?:w{3}\.)?vimeo.com/(\d{6,})/?}
        if link =~ regex
          video_id = $1
          if @vimeo_maps[video_id]
            title = ERB::Util.h(CGI::unescape(@vimeo_maps[video_id]))
          else
            title = I18n.t 'application.helper.video_title.unknown'
          end
          return ' <a class="video-link" data-host="vimeo.com" data-video-id="' + 
            video_id + '" href="' + link + '" target="_blank">Vimeo: ' + title + '</a>'
        end
        return
      end

      def autolink_youtube(link)
        if link =~ YoutubeTitles::YOUTUBE_ID_REGEX
          video_id = $1
          anchor = $2 || ''

          if @youtube_maps[video_id]
            title = ERB::Util.h(CGI::unescape(@youtube_maps[video_id]))
          else
            title = I18n.t 'application.helper.video_title.unknown'
          end
          return ' <a class="video-link" data-host="youtube.com" data-video-id="' + 
            video_id + '" data-anchor="' + anchor + 
            '" href="'+ link + '" target="_blank">Youtube: ' + title + '</a>'
        end
        return
      end

      def block_code(text, language)
        "<pre><code>\n#{text}</code></pre>"
      end

      def double_emphasis(text)
        "<strong>#{text}</strong>"
      end

      def linebreak()
        "<br />"
      end

      def link(link, title, content)
        #hax
        content ||=''

        return autolink(link, 'url') if link == content 
        
        if link =~ Regexp.new(Regexp.escape(content))
          return autolink(link, 'url')
        end

        if link !~ %r{^\w+://}
          link = "http://#{link}"
        end

        tag = if title and content
                %Q{<a target="_blank" href="#{link}" title="#{title}">#{content}</a>}
              elsif content
                %Q{<a target="_blank" href="#{link}">#{content}</a>}
              else
                autolink(link, 'url')
              end
        return tag
      end

      def paragraph(text)
        #hax again... why is markdownify passing us nil?
        text ||=''

        if @newlines
          br = linebreak

          # in very clear cases, let newlines become <br /> tags
          # Grabbed from Github flavored Markdown
          text = text.gsub(/^[\w\<][^\n]*\n+/) do |x|
            x =~ /\n{2}/ ? x : (x = x.strip; x << br)
          end
        end
        return "<p>#{text}</p>"
      end

      def preprocess(full_document)
        entities = [
          ['&', '&amp;'],
          ['>', '&gt;'],
          ['<', '&lt;']
        ]
        entities.each do |original, replacement|
          full_document = full_document.gsub(original, replacement)
        end

        if @specialchars
          full_document = specialchars(full_document)
        end

        our_unsafe_chars = '()'
        full_document = full_document.gsub(%r{
          \[ \s*? ( [^ \] ]+ ) \s*? \]
          (?: 
            \( \s*? (\S+) \s*? (?: "([^"]+)" )? \) \s*? 
          )
        }xm) do |m|
          content = $1
          link = URI.escape($2, our_unsafe_chars)
          title = $3

          title_chunk = if title 
                          %W{" #{title}"} 
                        else 
                          '' 
                        end
          %Q{[#{content}](#{link}#{title_chunk})}
        end

        return full_document
      end



      def single_emphasis(text)
        "<em>#{text}</em>"
      end

      def specialchars(text)
        if @specialchars
          map = [
            ["&lt;3", "&hearts;"],
            ["&lt;-&gt;", "&#8596;"],
            ["-&gt;", "&rarr;"],
            ["&lt;-", "&larr;"],
            ["\.\.\.", "&hellip;"],
            ["(tm)", "&trade;"],
            ["(r)", "&reg;"],
            ["(c)", "&copy;"]
          ]
        end

        map.each do |mapping|
          text = text.gsub(mapping[0], mapping[1])
        end

        return text
      end


      def triple_emphasis(text)
        single_emphasis(double_emphasis(text))
      end

    end
  end
end
