require 'spec_helper'

describe Reshare do
  include ActionView::Helpers::UrlHelper
  include Rails.application.routes.url_helpers
  def controller
    mock()
  end


  it 'has a valid Factory' do
    FactoryGirl.build(:reshare).should be_valid
  end

  it 'requires root' do
    reshare = FactoryGirl.build(:reshare, :root => nil)
    reshare.should_not be_valid
  end

  it 'require public root' do
    reshare = FactoryGirl.build(:reshare, :root => FactoryGirl.create(:status_message, :public => false))
    reshare.should_not be_valid
    reshare.errors[:base].should include('Only posts which are public may be reshared.')
  end

  it 'forces public' do
    FactoryGirl.create(:reshare, :public => false).public.should be_true
  end

  describe "#receive" do
    let(:receive) {@reshare.receive(@root.author.owner, @reshare.author)}
    before do
      @reshare = FactoryGirl.create(:reshare, :root => FactoryGirl.build(:status_message, :author => bob.person, :public => true))
      @root = @reshare.root
    end

    it 'increments the reshare count' do
      receive
      @root.resharers.count.should == 1
    end

    it 'adds the resharer to the re-sharers of the post' do
      receive
      @root.resharers.should include(@reshare.author)
    end
    it 'does not error if the root author has a contact for the resharer' do
      bob.share_with @reshare.author, bob.aspects.first
      proc {
        Timeout.timeout(5) do
          receive #This doesn't ever terminate on my machine before it was fixed.
        end
      }.should_not raise_error
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
      @sfw_reshare.nsfw.should_not be_true
      @nsfw_reshare.nsfw.should be_true
    end
  end

  describe '#notification_type' do
    before do
      sm = FactoryGirl.build(:status_message, :author => alice.person, :public => true)
      @reshare = FactoryGirl.build(:reshare, :root => sm)
    end
    it 'does not return anything for non-author of the original post' do
      @reshare.notification_type(bob, @reshare.author).should be_nil
    end

    it 'returns "Reshared" for the original post author' do
      @reshare.notification_type(alice, @reshare.author).should == Notifications::Reshared
    end
  end

  describe '#absolute_root' do
    before do
      @sm = FactoryGirl.build(:status_message, :author => alice.person, :public => true)
      rs1 = FactoryGirl.build(:reshare, :root=>@sm)
      rs2 = FactoryGirl.build(:reshare, :root=>rs1)
      @rs3 = FactoryGirl.build(:reshare, :root=>rs2)
    end

    it 'resolves root posts to the top level' do
      @rs3.absolute_root.should == @sm
    end
  end

  describe "XML" do
    before do
      @reshare = FactoryGirl.build(:reshare)
      @xml = @reshare.to_xml.to_s
    end

    context 'serialization' do
      it 'serializes root_diaspora_id' do
        @xml.should include("root_diaspora_id")
        @xml.should include(@reshare.author.diaspora_handle)
      end

      it 'serializes root_guid' do
        @xml.should include("root_guid")
        @xml.should include(@reshare.root.guid)
      end
    end

    context 'marshalling' do
      context 'local' do
        before do
          @original_author = @reshare.root.author
          @root_object = @reshare.root
        end

        it 'marshals the guid' do
          Reshare.from_xml(@xml).root_guid.should == @root_object.guid
        end

        it 'fetches the root post from root_guid' do
          Reshare.from_xml(@xml).root.should == @root_object
        end

        it 'fetches the root author from root_diaspora_id' do
          Reshare.from_xml(@xml).root.author.should == @original_author
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
          @response = mock
          @response.stub(:status).and_return(200)
          @response.stub(:success?).and_return(true)
        end

        it 'fetches the root author from root_diaspora_id' do
          @original_profile = @reshare.root.author.profile.dup
          @reshare.root.author.profile.delete
          @original_author = @reshare.root.author.dup
          @reshare.root.author.delete

          @original_author.profile = @original_profile

          wf_prof_mock = mock
          wf_prof_mock.should_receive(:fetch).and_return(@original_author)
          Webfinger.should_receive(:new).and_return(wf_prof_mock)
          
          @response.stub(:body).and_return(@root_object.to_diaspora_xml)

          Faraday.default_connection.should_receive(:get).with(@original_author.url + short_post_path(@root_object.guid, :format => "xml")).and_return(@response)
          Reshare.from_xml(@xml)
        end

        context "fetching post" do
          it "doesn't error out if the post is not found" do
            @response.stub(:status).and_return(404)
            Faraday.default_connection.should_receive(:get).and_return(@response)
            
            expect {
              Reshare.from_xml(@xml)
            }.to_not raise_error
          end
          
          it "raises if there's another error receiving the post" do
            @response.stub(:status).and_return(500)
            @response.stub(:success?).and_return(false)
            Faraday.default_connection.should_receive(:get).and_return(@response)
            
            expect {
              Reshare.from_xml(@xml)
            }.to raise_error RuntimeError
          end
        end

        context 'saving the post' do
          before do
            @response.stub(:body).and_return(@root_object.to_diaspora_xml)
            Faraday.default_connection.stub(:get).with(@reshare.root.author.url + short_post_path(@root_object.guid, :format => "xml")).and_return(@response)
          end

          it 'fetches the root post from root_guid' do
            root = Reshare.from_xml(@xml).root

            [:text, :guid, :diaspora_handle, :type, :public].each do |attr|
              root.send(attr).should == @reshare.root.send(attr)
            end
          end

          it 'correctly saves the type' do
            Reshare.from_xml(@xml).root.reload.type.should == "StatusMessage"
          end

          it 'correctly sets the author' do
            @original_author = @reshare.root.author
            Reshare.from_xml(@xml).root.reload.author.reload.should == @original_author
          end

          it 'verifies that the author of the post received is the same as the author in the reshare xml' do
            @original_author = @reshare.root.author.dup
            @xml = @reshare.to_xml.to_s

            different_person = FactoryGirl.build(:person)

            wf_prof_mock = mock
            wf_prof_mock.should_receive(:fetch).and_return(different_person)
            Webfinger.should_receive(:new).and_return(wf_prof_mock)

            different_person.stub(:url).and_return(@original_author.url)

            lambda{
              Reshare.from_xml(@xml)
            }.should raise_error /^Diaspora ID \(.+\) in the root does not match the Diaspora ID \(.+\) specified in the reshare!$/
          end
        end
      end
    end
  end
end
