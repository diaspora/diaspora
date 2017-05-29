module JasmineFixtureGeneration
   # update js/css/image paths so page
   # so application looks and behaves as in application 
   def update_path input
      regex = { 
        :js_regex => /\/assets\/[^'"]*?\.js['"]/,
        :css_regex => /\/assets\/[^'"]*?\.css['"]/,
        :img_regex => /\/assets\/[^'"]*?\.(:?gif|png|jpg|jpeg|tif)['"]/
      }   
  
      line = input
  
      if regex[:css_regex].match input
        puts "#{input} matches  #{regex[:css_regex]}"
        line = input.gsub(/\/assets\//, '../../app/assets/stylesheets/')
      elsif regex[:img_regex].match input
        line = input.gsub(/\/assets\//, '../../app/assets/images/')
      elsif regex[:js_regex].match input
        line = input.gsub(/\/assets\//, '../../app/assets/javascripts/')
      end 
      line
    end 

  #
  # Saves the markup to a fixture file using the given name
  def save_fixture(markup, name, fixture_path=nil )
    fixture_path = Rails.root.join('tmp', 'js_dom_fixtures') unless fixture_path
    Dir.mkdir(fixture_path) unless File.exists?(fixture_path)

    fixture_file = fixture_path.join("#{name}.fixture.html")
    File.open(fixture_file, 'w') do |file|
      markups = []
      markup.split('>').each do |line|
        markups.push( update_path( line ) )
      end
      file.puts(markups.join('>'))
    end
  end

  # From the controller spec response body, extracts html identified
  # by the css selector.
  def html_for(selector)
    doc = Nokogiri::HTML(response.body)

    remove_third_party_scripts(doc)
    content = doc.css(selector).first.to_s

    return convert_body_tag_to_div(content)
  end

  # Remove scripts such as Google Analytics to avoid running them
  # when we load into the dom during js specs.
  def remove_third_party_scripts(doc)
    scripts = doc.at('#third-party-scripts')
    scripts.remove if scripts
  end

  # Many of our css and jQuery selectors rely on a class attribute we
  # normally embed in the <body>. For example:
  #
  # <body class="workspaces show">
  #
  # Here we convert the body tag to a div so that we can load it into
  # the document running js specs without embedding a <body> within a <body>.
  def convert_body_tag_to_div(markup)
    return markup.gsub("<body", '<div').gsub("</body>", "</div>")
  end
end

RSpec::Rails::ControllerExampleGroup.class_eval do
  include JasmineFixtureGeneration
end

RSpec::Rails::HelperExampleGroup.class_eval do
  include JasmineFixtureGeneration
end
