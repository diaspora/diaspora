class Capybara::Driver::Celerity < Capybara::Driver::Base
  class Node < Capybara::Node
    def text
      node.text
    end

    def [](name)
      value = if name.to_sym == :class
        node.class_name
      else
        node.send(name.to_sym)
      end
      return value if value and not value.to_s.empty?
    end

    def value
      if tag_name == "select" and node.multiple?
        node.selected_options
      else
        super
      end
    end

    def set(value)
      node.set(value)
    end

    def select(option)
      node.select(option)
    rescue
      options = all(:xpath, "//option").map { |o| "'#{o.text}'" }.join(', ')
      raise Capybara::OptionNotFound, "No such option '#{option}' in this select box. Available options: #{options}"
    end

    def unselect(option)
      unless node.multiple?
        raise Capybara::UnselectNotAllowed, "Cannot unselect option '#{option}' from single select box."
      end

      # FIXME: couldn't find a clean way to unselect, so clear and reselect
      selected_options = node.selected_options
      if unselect_option  = selected_options.detect { |value| value == option } ||
                            selected_options.detect { |value| value.index(option) }
        node.clear
        (selected_options - [unselect_option]).each { |value| node.select_value(value) }
      else
        options = all(:xpath, "//option").map { |o| "'#{o.text}'" }.join(', ')
        raise Capybara::OptionNotFound, "No such option '#{option}' in this select box. Available options: #{options}"
      end
    end

    def click
      node.click
    end

    def drag_to(element)
      node.fire_event('mousedown')
      element.node.fire_event('mousemove')
      element.node.fire_event('mouseup')
    end

    def tag_name
      # FIXME: this might be the dumbest way ever of getting the tag name
      # there has to be something better...
      node.to_xml[/^\s*<([a-z0-9\-\:]+)/, 1]
    end

    def visible?
      node.visible?
    end

    def path
      node.xpath
    end

    def trigger(event)
      node.fire_event(event.to_s)
    end

  private

    def all_unfiltered(locator)
      noko_node = Nokogiri::HTML(driver.body).xpath(node.xpath).first
      all_nodes = noko_node.xpath(locator).map { |n| n.path }.join(' | ')
      driver.find(all_nodes)
    end

  end

  attr_reader :app, :rack_server

  def initialize(app)
    @app = app
    @rack_server = Capybara::Server.new(@app)
    @rack_server.boot if Capybara.run_server
  end

  def visit(path)
    browser.goto(url(path))
  end

  def current_url
    browser.url
  end

  def source
    browser.html
  end

  def body
    browser.document.as_xml
  end

  def response_headers
    browser.response_headers
  end

  def status_code
    browser.status_code
  end

  def find(selector)
    browser.elements_by_xpath(selector).map { |node| Node.new(self, node) }
  end

  def wait?; true; end

  def execute_script(script)
    browser.execute_script script
    nil
  end

  def evaluate_script(script)
    browser.execute_script "#{script}"
  end

  def browser
    unless @_browser
      require 'celerity'
      @_browser = ::Celerity::Browser.new(:browser => :firefox, :log_level => :off)
    end

    @_browser
  end

  def cleanup!
    browser.clear_cookies
  end

private

  def url(path)
    rack_server.url(path)
  end

end
