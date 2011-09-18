require 'pygments'
require 'fileutils'
require 'digest/md5'

PYGMENTS_CACHE_DIR = File.expand_path('../../.pygments-cache', __FILE__)
FileUtils.mkdir_p(PYGMENTS_CACHE_DIR)

module HighlightCode
  def highlight(str, lang)
    lang = 'ruby' if lang == 'ru'
    lang = 'objc' if lang == 'm'
    lang = 'perl' if lang == 'pl'
    lang = 'yaml' if lang == 'yml'
    str = pygments(str, lang).match(/<pre>(.+)<\/pre>/m)[1].to_s.gsub(/ *$/, '') #strip out divs <div class="highlight">
    tableize_code(str, lang)
  end

  def pygments(code, lang)
    if defined?(PYGMENTS_CACHE_DIR)
      path = File.join(PYGMENTS_CACHE_DIR, "#{lang}-#{Digest::MD5.hexdigest(code)}.html")
      if File.exist?(path)
        highlighted_code = File.read(path)
      else
        highlighted_code = Pygments.highlight(code, :lexer => lang, :formatter => 'html')
        File.open(path, 'w') {|f| f.print(highlighted_code) }
      end
    else
      highlighted_code = Pygments.highlight(code, :lexer => lang, :formatter => 'html')
    end
    highlighted_code
  end
  def tableize_code (str, lang = '')
    table = '<div class="highlight"><table><tr><td class="gutter"><pre class="line-numbers">'
    code = ''
    str.lines.each_with_index do |line,index|
      table += "<span class='line-number'>#{index+1}</span>\n"
      code  += "<span class='line'>#{line}</span>"
    end
    table += "</pre></td><td class='code'><pre><code class='#{lang}'>#{code}</code></pre></td></tr></table></div>"
  end
end
