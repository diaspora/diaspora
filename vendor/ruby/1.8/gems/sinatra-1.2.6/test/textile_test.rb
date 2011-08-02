require File.dirname(__FILE__) + '/helper'

begin
require 'redcloth'

class TextileTest < Test::Unit::TestCase
  def textile_app(&block)
    mock_app do
      set :views, File.dirname(__FILE__) + '/views'
      get '/', &block
    end
    get '/'
  end

  it 'renders inline textile strings' do
    textile_app { textile 'h1. Hiya' }
    assert ok?
    assert_equal "<h1>Hiya</h1>", body
  end

  it 'renders .textile files in views path' do
    textile_app { textile :hello }
    assert ok?
    assert_equal "<h1>Hello From Textile</h1>", body
  end

  it "raises error if template not found" do
    mock_app { get('/') { textile :no_such_template } }
    assert_raise(Errno::ENOENT) { get('/') }
  end
end

rescue LoadError
  warn "#{$!.to_s}: skipping textile tests"
end
