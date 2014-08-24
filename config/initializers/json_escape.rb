# From http://jfire.io/blog/2012/04/30/how-to-securely-bootstrap-json-in-a-rails-view/
# Remove on Rails 4.1 update

class ActionView::Base
  def json_escape(s)
    result = s.to_s.gsub('/', '\/')
    s.html_safe? ? result.html_safe : result
  end

  alias j json_escape
end
