require 'spec_helper'

describe Reshare, :type => :model do
  include Rails.application.routes.url_helpers

  it 'has a valid Factory' do
    expect(FactoryGirl.build(:reshare)).to be_valid
  end

  it 'requires root' do
    reshare = FactoryGirl.build(:reshare, :root => nil)
    expect(reshare).not_to be_valid
  end

  it 'require public root' do
    reshare = FactoryGirl.build(:reshare, :root => FactoryGirl.create(:status_message, :public => false))
    expect(reshare).not_to be_valid
    expect(reshare.errors[:base]).to include('Only posts which are public may be reshared.')
  end

  it 'forces public' do
    expect(FactoryGirl.create(:reshare, :public => false).public).to be true
  end

  describe "#receive" do
    let(:receive_reshare) { @reshare.receive(@root.author.owner, @reshare.author) }

    before do
      @reshare = FactoryGirl.create(:reshare, :root => FactoryGirl.build(:status_message, :author => bob.person, :public => true))
      @root = @reshare.root
    end

    it 'increments the reshare count' do
      receive_reshare
      expect(@root.resharers.count).to eq(1)
    end

    it 'adds the resharer to the re-sharers of the post' do
      receive_reshare
      expect(@root.resharers).to include(@reshare.author)
    end
    it 'does not error if the root author has a contact for the resharer' do
      bob.share_with @reshare.author, bob.aspects.first
      expect {
        Timeout.timeout(5) do
          receive_reshare #This doesn't ever terminate on my machine before it was fixed.
        end
      }.not_to raise_error
    end
  end

  describe '#nsfw' do
    before do
      sfw  = FactoryGirl.build(:status_message, :author => alice.person, :public => true)
      nsfw = FactoryGirl.build(:status_message, :author => alice.person, :public => true, :text => "This is #nsfw")
      @sfw_reshare = FactoryGirl.build(:reshare, :root => sfw)
      @nsfw_reshare = FactoryGirl.build(:reshare, :root => nsfw)
    end

    it 'deletates #nsfw to the root post' do
      expect(@sfw_reshare.nsfw).not_to be true
      expect(@nsfw_reshare.nsfw).to be_truthy
    end
  end

  describe '#notification_type' do
    before do
      sm = FactoryGirl.build(:status_message, :author => alice.person, :public => true)
      @reshare = FactoryGirl.build(:reshare, :root => sm)
    end
    it 'does not return anything for non-author of the original post' do
      expect(@reshare.notification_type(bob, @reshare.author)).to be_nil
    end

    it 'returns "Reshared" for the original post author' do
      expect(@reshare.notification_type(alice, @reshare.author)).to eq(Notifications::Reshared)
    end

    it 'does not error out if the root was deleted' do
      @reshare.root = nil
      expect {
        @reshare.notification_type(alice, @reshare.author)
      }.to_not raise_error
    end
  end

  describe '#absolute_root' do
    before do
      @sm = FactoryGirl.build(:status_message, :author => alice.person, :public => true)
      rs1 = FactoryGirl.build(:reshare, :root=>@sm)
      rs2 = FactoryGirl.build(:reshare, :root=>rs1)
      @rs3 = FactoryGirl.build(:reshare, :root=>rs2)

     sm = FactoryGirl.create(:status_message, :author => alice.person, :public => true)
     rs1 = FactoryGirl.create(:reshare, :root => sm)
     @of_deleted = FactoryGirl.build(:reshare, :root => rs1)
     sm.destroy
     rs1.reload
    end

    it 'resolves root posts to the top level' do
      expect(@rs3.absolute_root).to eq(@sm)
    end

    it 'can handle deleted reshares' do
      expect(@of_deleted.absolute_root).to be_nil
    end

    it 'is used everywhere' do
      expect(@rs3.message).to eq @sm.message
      expect(@of_deleted.message).to be_nil
      expect(@rs3.photos).to eq @sm.photos
      expect(@of_deleted.photos).to be_empty
      expect(@rs3.o_embed_cache).to eq @sm.o_embed_cache
      expect(@of_deleted.o_embed_cache).to be_nil
      expect(@rs3.open_graph_cache).to eq @sm.open_graph_cache
      expect(@of_deleted.open_graph_cache).to be_nil
      expect(@rs3.mentioned_people).to eq @sm.mentioned_people
      expect(@of_deleted.mentioned_people).to be_empty
      expect(@rs3.nsfw).to eq @sm.nsfw
      expect(@of_deleted.nsfw).to be_nil
      expect(@rs3.address).to eq @sm.location.try(:address)
      expect(@of_deleted.address).to be_nil
    end
  end

  describe "XML" do
    before do
      @reshare = FactoryGirl.build(:reshare)
      @xml = @reshare.to_xml.to_s
    end

    context 'serialization' do
      it 'serializes root_diaspora_id' do
        expect(@xml).to include("root_diaspora_id")
        expect(@xml).to include(@reshare.author.diaspora_handle)
      end

      it 'serializes root_guid' do
        expect(@xml).to include("root_guid")
        expect(@xml).to include(@reshare.root.guid)
      end
    end

    context 'marshalling' do
      context 'local' do
        before do
          @original_author = @reshare.root.author
          @root_object = @reshare.root
        end

        it 'marshals the guid' do
          expect(Reshare.from_xml(@xml).root_guid).to eq(@root_object.guid)
        end

        it 'fetches the root post from root_guid' do
          expect(Reshare.from_xml(@xml).root).to eq(@root_object)
        end

        it 'fetches the root author from root_diaspora_id' do
          expect(Reshare.from_xml(@xml).root.author).to eq(@original_author)
        end
      end

      describe 'destroy' do
        it 'allows you to destroy the reshare if the root post is missing' do
          reshare = FactoryGirl.build(:reshare)
          reshare.root = nil

          expect{
            reshare.destroy
          }.to_not raise_error
        end
      end

      context 'remote' do
        before do
          @root_object = @reshare.root
          @root_object.delete
          @response = double
          allow(@response).to receive(:status).and_return(200)
          allow(@response).to receive(:success?).and_return(true)
        end

        it 'fetches the root author from root_diaspora_id' do
          @original_profile = @reshare.root.author.profile.dup
          @reshare.root.author.profile.delete
          @original_author = @reshare.root.author.dup
          @reshare.root.author.delete

          @original_author.profile = @original_profile

          wf_prof_double = double
          expect(wf_prof_double).to receive(:fetch).and_return(@original_author)
          expect(Webfinger).to receive(:new).and_return(wf_prof_double)

          allow(@response).to receive(:body).and_return(@root_object.to_diaspora_xml)

          expect(Faraday.default_connection).to receive(:get).with(@original_author.url + short_post_path(@root_object.guid, :format => "xml")).and_return(@response)
          Reshare.from_xml(@xml)
        end

        context "fetching post" do
          it "raises if the post is not found" do
            allow(@response).to receive(:status).and_return(404)
            expect(Faraday.default_connection).to receive(:get).and_return(@response)

            expect {
              Reshare.from_xml(@xml)
            }.to raise_error(Diaspora::PostNotFetchable)
          end

          it "raises if there's another error receiving the post" do
            allow(@response).to receive(:status).and_return(500)
            allow(@response).to receive(:success?).and_return(false)
            expect(Faraday.default_connection).to receive(:get).and_return(@response)

            expect {
              Reshare.from_xml(@xml)
            }.to raise_error RuntimeError
          end
        end

        context 'saving the post' do
          before do
            allow(@response).to receive(:body).and_return(@root_object.to_diaspora_xml)
            allow(Faraday.default_connection).to receive(:get).with(@reshare.root.author.url + short_post_path(@root_object.guid, :format => "xml")).and_return(@response)
          end

          it 'fetches the root post from root_guid' do
            root = Reshare.from_xml(@xml).root

            [:text, :guid, :diaspora_handle, :type, :public].each do |attr|
              expect(root.send(attr)).to eq(@reshare.root.send(attr))
            end
          end

          it 'correctly saves the type' do
            expect(Reshare.from_xml(@xml).root.reload.type).to eq("StatusMessage")
          end

          it 'correctly sets the author' do
            @original_author = @reshare.root.author
            expect(Reshare.from_xml(@xml).root.reload.author.reload).to eq(@original_author)
          end

          it 'verifies that the author of the post received is the same as the author in the reshare xml' do
            @original_author = @reshare.root.author.dup
            @xml = @reshare.to_xml.to_s

            different_person = FactoryGirl.build(:person)

            wf_prof_double = double
            expect(wf_prof_double).to receive(:fetch).and_return(different_person)
            expect(Webfinger).to receive(:new).and_return(wf_prof_double)

            allow(different_person).to receive(:url).and_return(@original_author.url)

            expect{
              Reshare.from_xml(@xml)
            }.to raise_error /^Diaspora ID \(.+\) in the root does not match the Diaspora ID \(.+\) specified in the reshare!$/
          end
        end
      end
    end
  end
end
