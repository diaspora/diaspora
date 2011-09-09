require 'spec_helper'

describe Salmon::Slap do

  before do
    @post = alice.post(:status_message, :text => "hi", :to => alice.aspects.create(:name => "abcd").id)
    @created_salmon = Salmon::Slap.create(alice, @post.to_diaspora_xml)
  end

  it 'works' do
    salmon_string = @created_salmon.xml_for(nil)
    salmon = Salmon::Slap.parse(salmon_string)
    salmon.author.should == alice.person
    salmon.parsed_data.should == @post.to_diaspora_xml
  end
end
