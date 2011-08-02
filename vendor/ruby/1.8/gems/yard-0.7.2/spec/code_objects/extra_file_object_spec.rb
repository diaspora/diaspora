require File.dirname(__FILE__) + '/spec_helper'

describe YARD::CodeObjects::ExtraFileObject do
  describe '#initialize' do
    it "should attempt to read contents from filesystem if contents=nil" do
      File.should_receive(:read).with('file.txt').and_return('')
      ExtraFileObject.new('file.txt')
    end
    
    it "should raise Errno::ENOENT if contents=nil and file does not exist" do
      lambda { ExtraFileObject.new('file.txt') }.should raise_error(Errno::ENOENT)
    end
    
    it "should not attempt to read from disk if contents are provided" do
      ExtraFileObject.new('file.txt', 'CONTENTS')
    end
    
    it "should set filename to filename" do
      file = ExtraFileObject.new('a/b/c/file.txt', 'CONTENTS')
      file.filename.should == "a/b/c/file.txt"
    end
    
    it "should parse out attributes at top of the file" do
      file = ExtraFileObject.new('file.txt', "# @title X\n# @some_attribute Y\nFOO BAR")
      file.attributes[:title].should == "X"
      file.attributes[:some_attribute].should == "Y"
      file.contents.should == "FOO BAR"
    end
    
    it "should allow whitespace prior to '#' marker when parsing attributes" do
      file = ExtraFileObject.new('file.txt', " \t # @title X\nFOO BAR")
      file.attributes[:title].should == "X"
      file.contents.should == "FOO BAR"
    end
    
    it "should parse out old-style #!markup shebang format" do
      file = ExtraFileObject.new('file.txt', "#!foobar\nHello")
      file.attributes[:markup].should == "foobar"
    end
    
    it "should not parse old-style #!markup if any whitespace is found" do
      file = ExtraFileObject.new('file.txt', " #!foobar\nHello")
      file.attributes[:markup].should be_nil
      file.contents.should == " #!foobar\nHello"
    end
    
    it "should not parse out attributes if there are newlines prior to attributes" do
      file = ExtraFileObject.new('file.txt', "\n# @title\nFOO BAR")
      file.attributes.should be_empty
      file.contents.should == "\n# @title\nFOO BAR"
    end
    
    it "should set contents to data after attributes" do
      file = ExtraFileObject.new('file.txt', "# @title\nFOO BAR")
      file.contents.should == "FOO BAR"
    end
    
    it "should preserve newlines" do
      file = ExtraFileObject.new('file.txt', "FOO\r\nBAR\nBAZ")
      file.contents.should == "FOO\r\nBAR\nBAZ"
    end
    
    it "should not include newlines in attribute data" do
      file = ExtraFileObject.new('file.txt', "# @title FooBar\r\nHello world")
      file.attributes[:title].should == "FooBar"
    end
    
    it "should force encoding to @encoding attribute if present" do
      log.should_not_receive(:warn)
      data = "# @encoding sjis\nFOO"
      data.force_encoding('binary')
      file = ExtraFileObject.new('file.txt', data)
      file.contents.encoding.to_s.should == 'Shift_JIS'
    end if RUBY19

    it "should warn if @encoding is invalid" do
      log.should_receive(:warn).with("Invalid encoding `INVALID' in file.txt")
      data = "# @encoding INVALID\nFOO"
      encoding = data.encoding
      file = ExtraFileObject.new('file.txt', data)
      file.contents.encoding.should == encoding
    end if RUBY19
    
    it "should ignore encoding in 1.8.x (or encoding-unaware platforms)" do
      log.should_not_receive(:warn)
      file = ExtraFileObject.new('file.txt', "# @encoding INVALID\nFOO")
    end if RUBY18
    
    it "should attempt to re-parse data as 8bit ascii if parsing fails" do
      log.should_not_receive(:warn)
      str = "\xB0"
      str.force_encoding('utf-8') if str.respond_to?(:force_encoding)
      file = ExtraFileObject.new('file.txt', str)
      file.contents.should == "\xB0"
    end
  end
  
  describe '#name' do
    it "should be set to basename (not extension) of filename" do
      file = ExtraFileObject.new('file.txt', '')
      file.name.should == 'file'
    end
  end
  
  describe '#title' do
    it "should return @title attribute if present" do
      file = ExtraFileObject.new('file.txt', '# @title FOO')
      file.title.should == 'FOO'
    end
    
    it "should return #name if no @title attribute exists" do
      file = ExtraFileObject.new('file.txt', '')
      file.title.should == 'file'
    end
  end
  
  describe '#==' do
    it "should define equality on filename alone" do
      file1 = ExtraFileObject.new('file.txt', 'A')
      file2 = ExtraFileObject.new('file.txt', 'B')
      file1.should == file2
      file1.should be_eql(file2)
      file1.should be_equal(file2)

      # Another way to test the equality interface
      a = [file1]
      a |= [file2]
      a.size.should == 1
    end
    
  end
end
