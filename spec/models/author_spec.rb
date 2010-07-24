require File.dirname(__FILE__) + '/../spec_helper'

include Diaspora::OStatusParser

describe Author do

  it 'should create from ostatus compliant xml from the parser' do
    xml_path = File.dirname(__FILE__) + '/../fixtures/identica_feed.atom'
    xml = File.open(xml_path).read

    Author.count.should == 0
    Diaspora::OStatusParser.process(xml)
    Author.count.should == 1
  end

end
