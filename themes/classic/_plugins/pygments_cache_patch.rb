#
# Author: Raimonds Simanovskis, http://blog.rayapps.com/
# Source URL: https://github.com/rsim/blog.rayapps.com/blob/master/_plugins/pygments_cache_patch.rb
#

require 'fileutils'
require 'digest/md5'

PYGMENTS_CACHE_DIR = File.expand_path('../../_code_cache', __FILE__)
FileUtils.mkdir_p(PYGMENTS_CACHE_DIR)

Jekyll::HighlightBlock.class_eval do
  def render_pygments(context, code)
    if defined?(PYGMENTS_CACHE_DIR)
      path = File.join(PYGMENTS_CACHE_DIR, "#{@lang}-#{Digest::MD5.hexdigest(code)}.html")
      if File.exist?(path)
        highlighted_code = File.read(path)
      else
        highlighted_code = Albino.new(code, @lang).to_s(@options)
        File.open(path, 'w') {|f| f.print(highlighted_code) }
      end
    else
      highlighted_code = Albino.new(code, @lang).to_s(@options)
    end
    output = add_code_tags(highlighted_code, @lang)
    output = context["pygments_prefix"] + output if context["pygments_prefix"]
    output = output + context["pygments_suffix"] if context["pygments_suffix"]
    output
  end
end
