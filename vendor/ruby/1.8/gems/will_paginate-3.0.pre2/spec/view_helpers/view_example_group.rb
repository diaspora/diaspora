require 'action_dispatch/testing/assertions'

class ViewExampleGroup < Spec::Example::ExampleGroup
  
  include ActionDispatch::Assertions::SelectorAssertions
  
  def assert(value, message)
    raise message unless value
  end
  
  def paginate(collection = {}, options = {}, &block)
    if collection.instance_of? Hash
      page_options = { :page => 1, :total_entries => 11, :per_page => 4 }.merge(collection)
      collection = [1].paginate(page_options)
    end

    locals = { :collection => collection, :options => options }

    @render_output = render(locals)
    @html_document = nil
    
    if block_given?
      classname = options[:class] || WillPaginate::ViewHelpers.pagination_options[:class]
      assert_select("div.#{classname}", 1, 'no main DIV', &block)
    end
    
    @render_output
  end
  
  def html_document
    @html_document ||= HTML::Document.new(@render_output, true, false)
  end
  
  def response_from_page_or_rjs
    html_document.root
  end
  
  def validate_page_numbers(expected, links, param_name = :page)
    param_pattern = /\W#{Regexp.escape(param_name.to_s)}=([^&]*)/
    
    links.map { |e|
      e['href'] =~ param_pattern
      $1 ? $1.to_i : $1
    }.should == expected
  end

  def assert_links_match(pattern, links = nil, numbers = nil)
    links ||= assert_select 'div.pagination a[href]' do |elements|
      elements
    end

    pages = [] if numbers
    
    links.each do |el|
      el['href'].should =~ pattern
      if numbers
        el['href'] =~ pattern
        pages << ($1.nil?? nil : $1.to_i)
      end
    end

    pages.should == numbers if numbers
  end

  def assert_no_links_match(pattern)
    assert_select 'div.pagination a[href]' do |elements|
      elements.each do |el|
        el['href'] !~ pattern
      end
    end
  end
  
  def build_message(message, pattern, *args)
    built_message = pattern.dup
    for value in args
      built_message.sub! '?', value.inspect
    end
    built_message
  end
  
end

Spec::Example::ExampleGroupFactory.register(:view_helpers, ViewExampleGroup)

module HTML
  Node.class_eval do
    def inner_text
      children.map(&:inner_text).join('')
    end
  end
  
  Text.class_eval do
    def inner_text
      self.to_s
    end
  end

  Tag.class_eval do
    def inner_text
      childless?? '' : super
    end
  end
end
