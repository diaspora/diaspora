require 'spec_helper'
require 'active_support/rescuable' # needed for Ruby 1.9.1
require 'action_controller'
require 'view_helpers/view_example_group'
require 'will_paginate/view_helpers/action_view'
require 'will_paginate/collection'

ActionView::Base.send(:include, WillPaginate::ViewHelpers::ActionView)

Routes = ActionDispatch::Routing::RouteSet.new

Routes.draw do
  match 'dummy/page/:page' => 'dummy#index'
  match 'dummy/dots/page.:page' => 'dummy#dots'
  match 'ibocorp(/:page)' => 'ibocorp#index',
        :constraints => { :page => /\d+/ }, :defaults => { :page => 1 }

  match ':controller(/:action(/:id(.:format)))'
end

describe WillPaginate::ViewHelpers::ActionView do
  before(:each) do
    @assigns = {}
    @controller = DummyController.new
    @request = @controller.request
    @template = '<%= will_paginate collection, options %>'
  end
  
  attr_reader :assigns, :controller, :request
  
  def render(locals)
    @view = ActionView::Base.new([], @assigns, @controller)
    @view.request = @request
    @view.singleton_class.send(:include, @controller._routes.url_helpers)
    @view.render(:inline => @template, :locals => locals)
  end
  
  ## basic pagination ##
  
  it "should render" do
    paginate do |pagination|
      assert_select 'a[href]', 3 do |elements|
        validate_page_numbers [2,3,2], elements
        assert_select elements.last, ':last-child', "Next &#8594;"
      end
      assert_select 'span', 1
      assert_select 'span.disabled:first-child', '&#8592; Previous'
      assert_select 'em', '1'
      pagination.first.inner_text.should == '&#8592; Previous 1 2 3 Next &#8594;'
    end
  end

  it "should render nothing when there is only 1 page" do
    paginate(:per_page => 30).should be_empty
  end

  it "should paginate with options" do
    paginate({ :page => 2 }, :class => 'will_paginate', :previous_label => 'Prev', :next_label => 'Next') do
      assert_select 'a[href]', 4 do |elements|
        validate_page_numbers [1,1,3,3], elements
        # test rel attribute values:
        assert_select elements[1], 'a', '1' do |link|
          link.first['rel'].should == 'prev start'
        end
        assert_select elements.first, 'a', "Prev" do |link|
          link.first['rel'].should == 'prev start'
        end
        assert_select elements.last, 'a', "Next" do |link|
          link.first['rel'].should == 'next'
        end
      end
      assert_select 'em', '2'
    end
  end

  it "should paginate using a custom renderer class" do
    paginate({}, :renderer => AdditionalLinkAttributesRenderer) do
      assert_select 'a[default=true]', 3
    end
  end

  it "should paginate using a custom renderer instance" do
    renderer = WillPaginate::ViewHelpers::LinkRenderer.new
    def renderer.gap() '<span class="my-gap">~~</span>' end
    
    paginate({ :per_page => 2 }, :inner_window => 0, :outer_window => 0, :renderer => renderer) do
      assert_select 'span.my-gap', '~~'
    end
    
    renderer = AdditionalLinkAttributesRenderer.new(:title => 'rendered')
    paginate({}, :renderer => renderer) do
      assert_select 'a[title=rendered]', 3
    end
  end

  it "should have classnames on previous/next links" do
    paginate do |pagination|
      assert_select 'span.disabled.previous_page:first-child'
      assert_select 'a.next_page[href]:last-child'
    end
  end
  
  it "should warn about :prev_label being deprecated" do
    lambda {
      paginate({ :page => 2 }, :prev_label => 'Deprecated') do
        assert_select 'a[href]:first-child', 'Deprecated'
      end
    }.should have_deprecation
  end

  it "should match expected markup" do
    paginate
    expected = <<-HTML
      <div class="pagination"><span class="previous_page disabled">&#8592; Previous</span>
      <em>1</em>
      <a href="/foo/bar?page=2" rel="next">2</a>
      <a href="/foo/bar?page=3">3</a>
      <a href="/foo/bar?page=2" class="next_page" rel="next">Next &#8594;</a></div>
    HTML
    expected.strip!.gsub!(/\s{2,}/, ' ')
    expected_dom = HTML::Document.new(expected).root
    
    html_document.root.should == expected_dom
  end
  
  it "should output escaped URLs" do
    paginate({:page => 1, :per_page => 1, :total_entries => 2},
             :page_links => false, :params => { :tag => '<br>' })
    
    assert_select 'a[href]', 1 do |links|
      query = links.first['href'].split('?', 2)[1]
      query.split('&amp;').sort.should == %w(page=2 tag=%3Cbr%3E)
    end
  end
  
  ## advanced options for pagination ##

  it "should be able to render without container" do
    paginate({}, :container => false)
    assert_select 'div.pagination', 0, 'main DIV present when it shouldn\'t'
    assert_select 'a[href]', 3
  end

  it "should be able to render without page links" do
    paginate({ :page => 2 }, :page_links => false) do
      assert_select 'a[href]', 2 do |elements|
        validate_page_numbers [1,3], elements
      end
    end
  end

  it "should have magic HTML ID for the container" do
    paginate do |div|
      div.first['id'].should be_nil
    end
    
    # magic ID
    paginate({}, :id => true) do |div|
      div.first['id'].should == 'fixnums_pagination'
    end
    
    # explicit ID
    paginate({}, :id => 'custom_id') do |div|
      div.first['id'].should == 'custom_id'
    end
  end

  ## other helpers ##
  
  it "should render a paginated section" do
    @template = <<-ERB
      <%= paginated_section collection, options do %>
        <%= content_tag :div, '', :id => "developers" %>
      <% end %>
    ERB
    
    paginate
    assert_select 'div.pagination', 2
    assert_select 'div.pagination + div#developers', 1
  end
  
  ## parameter handling in page links ##
  
  it "should preserve parameters on GET" do
    request.params :foo => { :bar => 'baz' }
    paginate
    assert_links_match /foo\[bar\]=baz/
  end
  
  it "should not preserve parameters on POST" do
    request.post
    request.params :foo => 'bar'
    paginate
    assert_no_links_match /foo=bar/
  end
  
  it "should add additional parameters to links" do
    paginate({}, :params => { :foo => 'bar' })
    assert_links_match /foo=bar/
  end
  
  it "should add anchor parameter" do
    paginate({}, :params => { :anchor => 'anchor' })
    assert_links_match /#anchor$/
  end
  
  it "should remove arbitrary parameters" do
    request.params :foo => 'bar'
    paginate({}, :params => { :foo => nil })
    assert_no_links_match /foo=bar/
  end
    
  it "should override default route parameters" do
    paginate({}, :params => { :controller => 'baz', :action => 'list' })
    assert_links_match %r{\Wbaz/list\W}
  end
  
  it "should paginate with custom page parameter" do
    paginate({ :page => 2 }, :param_name => :developers_page) do
      assert_select 'a[href]', 4 do |elements|
        validate_page_numbers [1,1,3,3], elements, :developers_page
      end
    end    
  end
  
  it "should paginate with complex custom page parameter" do
    request.params :developers => { :page => 2 }
    
    paginate({ :page => 2 }, :param_name => 'developers[page]') do
      assert_select 'a[href]', 4 do |links|
        assert_links_match /\?developers\[page\]=\d+$/, links
        validate_page_numbers [1,1,3,3], links, 'developers[page]'
      end
    end
  end

  it "should paginate with custom route page parameter" do
    request.symbolized_path_parameters.update :controller => 'dummy', :action => nil
    paginate :per_page => 2 do
      assert_select 'a[href]', 6 do |links|
        assert_links_match %r{/page/(\d+)$}, links, [2, 3, 4, 5, 6, 2]
      end
    end
  end

  it "should paginate with custom route with dot separator page parameter" do
    request.symbolized_path_parameters.update :controller => 'dummy', :action => 'dots'
    paginate :per_page => 2 do
      assert_select 'a[href]', 6 do |links|
        assert_links_match %r{/page\.(\d+)$}, links, [2, 3, 4, 5, 6, 2]
      end
    end
  end

  it "should paginate with custom route and first page number implicit" do
    request.symbolized_path_parameters.update :controller => 'ibocorp', :action => nil
    paginate :page => 2, :per_page => 2 do
      assert_select 'a[href]', 7 do |links|
        assert_links_match %r{/ibocorp(?:/(\d+))?$}, links, [nil, nil, 3, 4, 5, 6, 3]
      end
    end
    # Routes.recognize_path('/ibocorp/2').should == {:page=>'2', :action=>'index', :controller=>'ibocorp'}
    # Routes.recognize_path('/ibocorp/foo').should == {:action=>'foo', :controller=>'ibocorp'}
  end

  ## internal hardcore stuff ##

  it "should be able to guess the collection name" do
    collection = mock
    collection.expects(:total_pages).returns(1)
    
    @template = '<%= will_paginate options %>'
    controller.controller_name = 'developers'
    assigns['developers'] = collection
    
    paginate(nil)
  end
  
  it "should fail if the inferred collection is nil" do
    @template = '<%= will_paginate options %>'
    controller.controller_name = 'developers'
    
    lambda {
      paginate(nil)
    }.should raise_error(ActionView::TemplateError, /@developers/)
  end
end

class AdditionalLinkAttributesRenderer < WillPaginate::ViewHelpers::LinkRenderer
  def initialize(link_attributes = nil)
    super()
    @additional_link_attributes = link_attributes || { :default => 'true' }
  end

  def link(text, target, attributes = {})
    super(text, target, attributes.merge(@additional_link_attributes))
  end
end

class DummyController
  attr_reader :request
  attr_accessor :controller_name
  
  include ActionController::UrlFor
  include Routes.url_helpers
  
  def initialize
    @request = DummyRequest.new
  end

  def params
    @request.params
  end
end

class IbocorpController < DummyController
end

class DummyRequest
  attr_accessor :symbolized_path_parameters
  
  def initialize
    @get = true
    @params = {}
    @symbolized_path_parameters = { :controller => 'foo', :action => 'bar' }
  end
  
  def get?
    @get
  end

  def post
    @get = false
  end

  def relative_url_root
    ''
  end
  
  def script_name
    ''
  end

  def params(more = nil)
    @params.update(more) if more
    @params
  end
  
  def host_with_port
    'example.com'
  end
  
  def protocol
    'http:'
  end
end
