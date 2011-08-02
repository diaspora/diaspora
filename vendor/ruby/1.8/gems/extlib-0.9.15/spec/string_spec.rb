require 'spec_helper'
require 'extlib/string'

describe String, "#to_const_string" do
  it "swaps slashes with ::" do
    "foo/bar".to_const_string.should == "Foo::Bar"
  end

  it "replaces snake_case with CamelCase" do
    "foo/bar/baz_bat".to_const_string.should == "Foo::Bar::BazBat"
  end

  it "leaves constant string as is" do
    "Merb::Test".to_const_string.should == "Merb::Test"
  end
end



describe String, "#to_const_path" do
  it "swaps :: with slash" do
    "Foo::Bar".to_const_path.should == "foo/bar"
  end

  it "snake_cases string" do
    "Merb::Test::ViewHelper".to_const_path.should == "merb/test/view_helper"
  end

  it "leaves slash-separated snake case string as is" do
    "merb/test/view_helper".to_const_path.should == "merb/test/view_helper"
  end
end



describe String, "#camel_case" do
  it "handles lowercase without underscore" do
    "merb".camel_case.should == "Merb"
  end

  it "handles lowercase with 1 underscore" do
    "merb_core".camel_case.should == "MerbCore"
  end

  it "handles lowercase with more than 1 underscore" do
    "so_you_want_contribute_to_merb_core".camel_case.should == "SoYouWantContributeToMerbCore"
  end

  it "handles lowercase with more than 1 underscore in a row" do
    "__python__is__like__this".camel_case.should == "PythonIsLikeThis"
  end

  it "handle first capital letter with underscores" do
    "Python__Is__Like__This".camel_case.should == "PythonIsLikeThis"
  end

  it "leaves CamelCase as is" do
    "TestController".camel_case.should == "TestController"
  end
end



describe String, "#snake_case" do
  it "lowercases one word CamelCase" do
    "Merb".snake_case.should == "merb"
  end

  it "makes one underscore snake_case two word CamelCase" do
    "MerbCore".snake_case.should == "merb_core"
  end

  it "handles CamelCase with more than 2 words" do
    "SoYouWantContributeToMerbCore".snake_case.should == "so_you_want_contribute_to_merb_core"
  end

  it "handles CamelCase with more than 2 capital letter in a row" do
    "CNN".snake_case.should == "cnn"
    "CNNNews".snake_case.should == "cnn_news"
    "HeadlineCNNNews".snake_case.should == "headline_cnn_news"
    "NameACRONYM".snake_case.should == "name_acronym"
  end

  it "does NOT change one word lowercase" do
    "merb".snake_case.should == "merb"
  end

  it "leaves snake_case as is" do
    "merb_core".snake_case.should == "merb_core"
  end
end



describe String, "#escape_regexp" do
  it "escapes all * in a string" do
    "*and*".escape_regexp.should == "\\*and\\*"
  end

  it "escapes all ? in a string" do
    "?and?".escape_regexp.should == "\\?and\\?"
  end

  it "escapes all { in a string" do
    "{and{".escape_regexp.should == "\\{and\\{"
  end

  it "escapes all } in a string" do
    "}and}".escape_regexp.should == "\\}and\\}"
  end

  it "escapes all . in a string" do
    ".and.".escape_regexp.should == "\\.and\\."
  end

  it "escapes all regexp special characters used in a string" do
    "*?{}.".escape_regexp.should == "\\*\\?\\{\\}\\."
  end
end



describe String, "#unescape_regexp" do
  it "unescapes all \\* in a string" do
    "\\*and\\*".unescape_regexp.should == "*and*"
  end

  it "unescapes all \\? in a string" do
    "\\?and\\?".unescape_regexp.should == "?and?"
  end

  it "unescapes all \\{ in a string" do
    "\\{and\\{".unescape_regexp.should == "{and{"
  end

  it "unescapes all \\} in a string" do
    "\\}and\\}".unescape_regexp.should == "}and}"
  end

  it "unescapes all \\. in a string" do
    "\\.and\\.".unescape_regexp.should == ".and."
  end

  it "unescapes all regexp special characters used in a string" do
    "\\*\\?\\{\\}\\.".unescape_regexp.should == "*?{}."
  end
end



describe String, "#/" do
  it "concanates operands with File::SEPARATOR" do
    ("merb" / "core").should == "merb#{File::SEPARATOR}core"
  end
end


require 'rbconfig'
describe String, "#relative_path_from" do
  it "uses other operand as base for path calculation" do
    site_dir = Config::CONFIG["sitedir"]

    two_levels_up = site_dir.split(File::SEPARATOR)
    2.times { two_levels_up.pop } # remove two deepest directories
    two_levels_up = two_levels_up.join(File::SEPARATOR)

    two_levels_up.relative_path_from(site_dir).should == "../.."
  end
end


describe String, ".translate" do
  before(:each) do
    String.stub!(:translations).and_return({ "on snakes and rubies" => "a serpenti e rubini" })
  end

  it 'looks up for translation in translations dictionary' do
    String.translate("on snakes and rubies").should == "a serpenti e rubini"
  end

  it 'returns string that has no translations as it is' do
    String.translate("shapes").should == "shapes"
    String.translate("kalopsia").should == "kalopsia"
    String.translate("holding on to nothing").should == "holding on to nothing"
  end
end

describe String, ".t" do
  before(:each) do
    String.stub!(:translations).and_return({ '%s must not be blank' => "%s moet ingevuld worden",
                                             'username' => 'gebruikersnaam',
                                             '%s must be between %s and %s characters long' => '%s moet tussen %s en %s tekens lang zijn'})
  end

  it 'looks up for translation in translations dictionary and translates parameters as well' do
    "%s must not be blank".t(:username).should == "gebruikersnaam moet ingevuld worden"
    "%s must not be blank".t('username').should == "gebruikersnaam moet ingevuld worden"
    "%s must be between %s and %s characters long".t(:password, 5, 9).should == "password moet tussen 5 en 9 tekens lang zijn"
  end

  it 'returns string that has no translations as it is' do
    "password".t.should == "password"
  end

  it 'should not translate when freezed' do
    "%s must not be blank".t('username'.freeze).should == "username moet ingevuld worden"
  end
end

describe String, ".translations" do
  before(:each) do

  end

  it 'returns empty hash by default' do
    String.translations.should == {}
  end

  it 'returns @translations if set' do
    pending "is it @translations on metaclass or @@translations? leaving it out for now"
  end
end
