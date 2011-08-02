require 'stringio'
require 'fileutils'
require 'gherkin'
require 'gherkin/formatter/pretty_formatter'
require 'gherkin/formatter/json_formatter'
require 'gherkin/json_parser'

module PrettyPlease
  
  def pretty_machinery(gherkin, feature_path)
    io        = StringIO.new
    formatter = Gherkin::Formatter::PrettyFormatter.new(io, true, false)
    parser    = Gherkin::Parser::Parser.new(formatter, true)
    parse(parser, gherkin, feature_path)
    io.string
  end

  def json_machinery(gherkin, feature_path)
    json                = StringIO.new
    json_formatter      = Gherkin::Formatter::JSONFormatter.new(json)
    gherkin_parser      = Gherkin::Parser::Parser.new(json_formatter, true)
    parse(gherkin_parser, gherkin, feature_path)

    io                  = StringIO.new
    pretty_formatter    = Gherkin::Formatter::PrettyFormatter.new(io, true, false)
    json_parser         = Gherkin::JSONParser.new(pretty_formatter, pretty_formatter)
    json_parser.parse(json.string, "#{feature_path}.json", 0)
    
    io.string
  end
  
  def parse(parser, gherkin, feature_path)
    begin
      parser.parse(gherkin, feature_path, 0)
    rescue => e
      if e.message =~ /Lexing error/
        FileUtils.mkdir "tmp" unless File.directory?("tmp")
        written_path = "tmp/#{File.basename(feature_path)}"
        File.open(written_path, "w") {|io| io.write(gherkin)}
        e.message << "\nSee #{written_path}"
      end
      raise e
    end
  end
end

World(PrettyPlease)

Given /^I have Cucumber's source code next to Gherkin's$/ do
  @cucumber_home = File.dirname(__FILE__) + '/../../../cucumber'
  raise "No Cucumber source in #{@cucumber_home}" unless File.file?(@cucumber_home + '/bin/cucumber')
end

Given /^I find all of the \.feature files$/ do
  @feature_paths = Dir["#{@cucumber_home}/**/*.feature"].sort
end

When /^I send each prettified original through the "([^"]*)" machinery$/ do |machinery|
  @error = false
  @feature_paths.each do |feature_path|
    begin
      next if feature_path =~ /iso-8859-1\.feature/
      original = pretty_machinery(IO.read(feature_path), feature_path)
      via_machinery = self.__send__("#{machinery}_machinery", original, feature_path)
      via_machinery.should == original
    rescue RSpec::Expectations::ExpectationNotMetError => e
      announce "=========="
      announce feature_path
      if(e.message =~ /(@@.*)/m)
        announce $1
        @error = true
      else
        announce "Identical, except for newlines"
      end
    rescue => e
      e.message << "\nFatal error happened when parsing #{feature_path}."
      raise e
    end
  end
end

Then /^the machinery output should be identical to the prettified original$/ do
  raise "Some features didn't make it through the machinery" if @error
end
