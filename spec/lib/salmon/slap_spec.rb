require 'spec_helper'

describe Salmon::Slap do
  before do
    @post = alice.post(:status_message, :text => "hi", :to => alice.aspects.create(:name => "abcd").id)
    @created_salmon = Salmon::Slap.create_by_user_and_activity(alice, @post.to_diaspora_xml)
  end

  describe '#create' do
    it 'has data in the magic envelope' do
      expect(@created_salmon.magic_sig.data).not_to be nil
    end

    it 'has no parsed_data' do
      expect(@created_salmon.parsed_data).to be nil
    end

  end

  it 'works' do
    salmon_string = @created_salmon.xml_for(nil)
    salmon = Salmon::Slap.from_xml(salmon_string)
    expect(salmon.author).to eq(alice.person)
    expect(salmon.parsed_data).to eq(@post.to_diaspora_xml)
  end

  describe '#from_xml' do
    it 'procsses the header' do
      expect_any_instance_of(Salmon::Slap).to receive(:process_header)
      Salmon::Slap.from_xml(@created_salmon.xml_for(eve.person))
    end
  end

  describe "#process_header" do
    it 'sets the author id' do
      slap = Salmon::Slap.new
      slap.process_header(Nokogiri::XML(@created_salmon.plaintext_header))
      expect(slap.author_id).to eq(alice.diaspora_handle)
    end
  end

  describe '#author' do
    let(:xml)   {@created_salmon.xml_for(eve.person)}
    let(:parsed_salmon) { Salmon::Slap.from_xml(xml, alice)}

    it 'should reference a local author' do
      expect(parsed_salmon.author).to eq(alice.person)
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
      expect(parsed_salmon.author_id).to eq(alice.person.diaspora_handle)
    end

    it 'verifies the signature for the sender' do
      expect(parsed_salmon.verified_for_key?(alice.public_key)).to be true
    end

    it 'verifies the signature for the sender' do
      expect(parsed_salmon.verified_for_key?(FactoryGirl.create(:person).public_key)).to be false
    end

    it 'contains the original data' do
      expect(parsed_salmon.parsed_data).to eq(@post.to_diaspora_xml)
    end
  end

  describe "#xml_for" do
    before do
      @xml = @created_salmon.xml_for(eve.person)
    end
    
    it "has diaspora as the root" do
      doc = Nokogiri::XML(@xml)
      expect(doc.root.name).to eq("diaspora")
    end
    
    it "it has the descrypted header" do
      doc = Nokogiri::XML(@xml)
      expect(doc.search("header")).not_to be_blank
    end
    
    context "header" do

      it "it has author_id node " do
        doc = Nokogiri::XML(@xml)
        search = doc.search("header").search("author_id")
        expect(search.map(&:text)).to eq([alice.diaspora_handle])
      end

    end

    it "it has the magic envelope " do
      doc = Nokogiri::XML(@xml)
      expect(doc.find("/me:env")).not_to be_blank
    end
  end
end

