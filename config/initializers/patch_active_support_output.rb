# this is a temp monkey patch to suppress errors in rails 3.1
# it was fixed in 3.2, but it does not look like they are going to backport
# see: https://github.com/rails/rails/issues/3927
class ERB
  module Util
    def html_escape(s)
      s = s.to_s
      if s.html_safe?
        s
      else
        silence_warnings { s.gsub(/[&"><]/n) { |special| HTML_ESCAPE[special] }.html_safe }
      end
    end
  end
end

