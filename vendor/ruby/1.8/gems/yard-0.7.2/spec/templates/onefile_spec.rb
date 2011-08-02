require File.dirname(__FILE__) + '/spec_helper'

class StringSerializer < YARD::Serializers::Base
  attr_accessor :files, :string
  def initialize(files, string)
    @files = files
    @string = string
  end
  
  def serialize(object, data)
    files << object
    string << data
  end
end

describe YARD::Templates::Engine.template(:default, :onefile) do
  before { Registry.clear }

  it "should render html" do
    files = []
    string = ''
    YARD.parse_string <<-eof
      class A
        # Foo method
        # @return [String]
        def foo; end
        
        # Bar method
        # @return [Numeric]
        def bar; end
      end
    eof
    readme = CodeObjects::ExtraFileObject.new('README', 
      "# This is a code comment\n\n# Top of file\n\n\nclass C; end")
    Templates::Engine.generate Registry.all(:class), 
      :serializer => StringSerializer.new(files, string),
      :onefile => true, :format => :html, :readme => readme, :files => [readme,
        CodeObjects::ExtraFileObject.new('LICENSE', 'This is a license!')
      ]
    files.should == ['index.html']
    string.should include("This is a code comment")
    string.should include("This is a license!")
    string.should include("Class: A")
    string.should include("Foo method")
    string.should include("Bar method")
  end
end
