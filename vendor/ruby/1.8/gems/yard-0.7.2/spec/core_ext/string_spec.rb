require File.dirname(__FILE__) + '/../spec_helper'

#described_in_docs String, '#camelcase'
#described_in_docs String, '#underscore'

describe String do
  describe '#shell_split' do
    it "should split simple non-quoted text" do
      "a b c".shell_split.should == %w(a b c)
    end
    
    it "should split double quoted text into single token" do
      'a "b c d" e'.shell_split.should == ["a", "b c d", "e"]
    end
    
    it "should split single quoted text into single token" do
      "a 'b c d' e".shell_split.should == ["a", "b c d", "e"]
    end
    
    it "should handle escaped quotations in quotes" do
      "'a \\' b'".shell_split.should == ["a ' b"]
    end
    
    it "should handle escaped quotations outside quotes" do
      "\\'a 'b'".shell_split.should == %w('a b)
    end
    
    it "should handle escaped backslash" do
      "\\\\'a b c'".shell_split.should == ['\a b c']
    end
    
    it "should handle any whitespace as space" do
      text = "foo\tbar\nbaz\r\nfoo2 bar2"
      text.shell_split.should == %w(foo bar baz foo2 bar2)
    end

    it "should handle complex input" do
      text = "hello \\\"world \"1 2\\\" 3\" a 'b \"\\\\\\'' c"
      text.shell_split.should == ["hello", "\"world", "1 2\" 3", "a", "b \"\\'", "c"]
    end
  end
end