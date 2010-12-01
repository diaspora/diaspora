require File.expand_path(File.join(File.dirname(__FILE__), '..', 'spec_helper'))

class CustomParser < HTTParty::Parser; end

describe HTTParty::Parser do
  describe ".SupportedFormats" do
    it "returns a hash" do
      HTTParty::Parser::SupportedFormats.should be_instance_of(Hash)
    end
  end

  describe ".call" do
    it "generates an HTTParty::Parser instance with the given body and format" do
      HTTParty::Parser.should_receive(:new).with('body', :plain).and_return(stub(:parse => nil))
      HTTParty::Parser.call('body', :plain)
    end

    it "calls #parse on the parser" do
      parser = mock('Parser')
      parser.should_receive(:parse)
      HTTParty::Parser.stub(:new => parser)
      parser = HTTParty::Parser.call('body', :plain)
    end
  end

  describe ".formats" do
    it "returns the SupportedFormats constant" do
      HTTParty::Parser.formats.should == HTTParty::Parser::SupportedFormats
    end

    it "returns the SupportedFormats constant for subclasses" do
      class MyParser < HTTParty::Parser
        SupportedFormats = {"application/atom+xml" => :atom}
      end
      MyParser.formats.should == {"application/atom+xml" => :atom}
    end
  end

  describe ".format_from_mimetype" do
    it "returns a symbol representing the format mimetype" do
      HTTParty::Parser.format_from_mimetype("text/plain").should == :plain
    end

    it "returns nil when the mimetype is not supported" do
      HTTParty::Parser.format_from_mimetype("application/atom+xml").should be_nil
    end
  end

  describe ".supported_formats" do
    it "returns a unique set of supported formats represented by symbols" do
      HTTParty::Parser.supported_formats.should == HTTParty::Parser::SupportedFormats.values.uniq
    end
  end

  describe ".supports_format?" do
    it "returns true for a supported format" do
      HTTParty::Parser.stub(:supported_formats => [:json])
      HTTParty::Parser.supports_format?(:json).should be_true
    end

    it "returns false for an unsupported format" do
      HTTParty::Parser.stub(:supported_formats => [])
      HTTParty::Parser.supports_format?(:json).should be_false
    end
  end

  describe "#parse" do
    before do
      @parser = HTTParty::Parser.new('body', :json)
    end

    it "attempts to parse supported formats" do
      @parser.stub(:supports_format? => true)
      @parser.should_receive(:parse_supported_format)
      @parser.parse
    end

    it "returns the unparsed body when the format is unsupported" do
      @parser.stub(:supports_format? => false)
      @parser.parse.should == @parser.body
    end

    it "returns nil for an empty body" do
      @parser.stub(:body => '')
      @parser.parse.should be_nil
    end

    it "returns nil for a nil body" do
      @parser.stub(:body => nil)
      @parser.parse.should be_nil
    end
  end

  describe "#supports_format?" do
    it "utilizes the class method to determine if the format is supported" do
      HTTParty::Parser.should_receive(:supports_format?).with(:json)
      parser = HTTParty::Parser.new('body', :json)
      parser.send(:supports_format?)
    end
  end

  describe "#parse_supported_format" do
    it "calls the parser for the given format" do
      parser = HTTParty::Parser.new('body', :json)
      parser.should_receive(:json)
      parser.send(:parse_supported_format)
    end

    context "when a parsing method does not exist for the given format" do
      it "raises an exception" do
        parser = HTTParty::Parser.new('body', :atom)
        expect do
          parser.send(:parse_supported_format)
        end.to raise_error(NotImplementedError, "HTTParty::Parser has not implemented a parsing method for the :atom format.")
      end

      it "raises a useful exception message for subclasses" do
        parser = CustomParser.new('body', :atom)
        expect do
          parser.send(:parse_supported_format)
        end.to raise_error(NotImplementedError, "CustomParser has not implemented a parsing method for the :atom format.")
      end
    end
  end

  context "parsers" do
    subject do
      HTTParty::Parser.new('body', nil)
    end

    it "parses xml with Crack" do
      Crack::XML.should_receive(:parse).with('body')
      subject.send(:xml)
    end

    it "parses json with Crack" do
      Crack::JSON.should_receive(:parse).with('body')
      subject.send(:json)
    end

    it "parses yaml" do
      YAML.should_receive(:load).with('body')
      subject.send(:yaml)
    end

    it "parses html by simply returning the body" do
      subject.send(:html).should == 'body'
    end

    it "parses plain text by simply returning the body" do
      subject.send(:plain).should == 'body'
    end
  end
end
