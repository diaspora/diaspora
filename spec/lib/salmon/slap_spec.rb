require 'spec_helper'

describe Salmon::Slap do
  before do
    @post = alice.post(:status_message, :text => "hi", :to => alice.aspects.create(:name => "abcd").id)
    @created_salmon = Salmon::Slap.create_by_user_and_activity(alice, @post.to_diaspora_xml)
  end

  describe '#create' do
    it 'has data in the magic envelope' do
      @created_salmon.magic_sig.data.should_not be nil
    end

    it 'has no parsed_data' do
      @created_salmon.parsed_data.should be nil
    end

  end

  it 'works' do
    salmon_string = @created_salmon.xml_for(nil)
    salmon = Salmon::Slap.from_xml(salmon_string)
    salmon.author.should == alice.person
    salmon.parsed_data.should == @post.to_diaspora_xml
  end

  describe '#from_xml' do
    it 'procsses the header' do
      Salmon::Slap.any_instance.should_receive(:process_header)
      Salmon::Slap.from_xml(@created_salmon.xml_for(eve.person))
    end
  end

  describe "#process_header" do
    it 'sets the author id' do
      slap = Salmon::Slap.new
      slap.process_header(Nokogiri::XML(@created_salmon.plaintext_header))
      slap.author_id.should == alice.diaspora_handle
    end
  end

  describe '#author' do
    let(:xml)   {@created_salmon.xml_for(eve.person)}
    let(:parsed_salmon) { Salmon::Slap.from_xml(xml, alice)}

    it 'should reference a local author' do
      parsed_salmon.author.should == alice.person
    end

    it 'should fail if no author is found' do
      parsed_salmon.author_id = 'tom@tom.joindiaspora.com'
      expect {
        parsed_salmon.author.public_key
      }.to raise_error "did you remember to async webfinger?"
    end
  end

  context 'marshaling' do
    let(:xml)   {@created_salmon.xml_for(eve.person)}
    let(:parsed_salmon) { Salmon::Slap.from_xml(xml)}

    it 'should parse out the authors diaspora_handle' do
      parsed_salmon.author_id.should == alice.person.diaspora_handle
    end

    it 'verifies the signature for the sender' do
      parsed_salmon.verified_for_key?(alice.public_key).should be_true
    end

    it 'verifies the signature for the sender' do
      parsed_salmon.verified_for_key?(FactoryGirl.create(:person).public_key).should be_false
    end

    it 'contains the original data' do
      parsed_salmon.parsed_data.should == @post.to_diaspora_xml
    end
  end

  describe "#xml_for" do
    before do
      @xml = @created_salmon.xml_for(eve.person)
    end
    
    it "has diaspora as the root" do
      doc = Nokogiri::XML(@xml)
      doc.root.name.should == "diaspora"
    end
    
    it "it has the descrypted header" do
      doc = Nokogiri::XML(@xml)
      doc.search("header").should_not be_blank
    end
    
    context "header" do

      it "it has author_id node " do
        doc = Nokogiri::XML(@xml)
        search = doc.search("header").search("author_id")
        search.map(&:text).should == [alice.diaspora_handle]
      end

    end

    it "it has the magic envelope " do
      doc = Nokogiri::XML(@xml)
      doc.find("/me:env").should_not be_blank
    end
  end
end

