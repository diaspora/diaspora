require File.dirname(__FILE__) + '/helper'

begin
fail LoadError, "rdiscount not available" if defined? JRuby
require 'rdiscount'

class MarkdownTest < Test::Unit::TestCase
  def markdown_app(&block)
    mock_app do
      set :views, File.dirname(__FILE__) + '/views'
      get '/', &block
    end
    get '/'
  end

  it 'renders inline markdown strings' do
    markdown_app { markdown '# Hiya' }
    assert ok?
    assert_equal "<h1>Hiya</h1>\n", body
  end

  it 'renders .markdown files in views path' do
    markdown_app { markdown :hello }
    assert ok?
    assert_equal "<h1>Hello From Markdown</h1>\n", body
  end

  it "raises error if template not found" do
    mock_app { get('/') { markdown :no_such_template } }
    assert_raise(Errno::ENOENT) { get('/') }
  end
end

rescue LoadError
  warn "#{$!.to_s}: skipping markdown tests"
end
