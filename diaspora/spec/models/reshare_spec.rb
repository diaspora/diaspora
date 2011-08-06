require 'spec_helper'

describe Reshare do
  include ActionView::Helpers::UrlHelper
  include Rails.application.routes.url_helpers
  def controller
    mock()
  end


  it 'has a valid Factory' do
    Factory(:reshare).should be_valid
  end

  it 'requires root' do
    reshare = Factory.build(:reshare, :root => nil)
    reshare.should_not be_valid
  end

  it 'require public root' do
    Factory.build(:reshare, :root => Factory.build(:status_message, :public => false)).should_not be_valid
  end

  it 'forces public' do
    Factory(:reshare, :public => false).public.should be_true
  end

  describe "#receive" do
    before do
      @reshare = Factory.create(:reshare, :root => Factory(:status_message, :author => bob.person, :public => true))
      @root = @reshare.root
      @reshare.receive(@root.author.owner, @reshare.author)
    end

    it 'increments the reshare count' do
      @root.resharers.count.should == 1
    end

    it 'adds the resharer to the re-sharers of the post' do
      @root.resharers.should include(@reshare.author)
    end
  end

  describe "XML" do
    before do
      @reshare = Factory(:reshare)
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

      context 'remote' do
        before do
          @root_object = @reshare.root
          @root_object.delete
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

          response = mock
          response.stub(:body).and_return(@root_object.to_diaspora_xml)

          Faraday.default_connection.should_receive(:get).with(@original_author.url + public_post_path(:guid => @root_object.guid, :format => "xml")).and_return(response)
          Reshare.from_xml(@xml)
        end

        context 'saving the post' do
          before do
            response = mock
            response.stub(:body).and_return(@root_object.to_diaspora_xml)
            Faraday.default_connection.stub(:get).with(@reshare.root.author.url + public_post_path(:guid => @root_object.guid, :format => "xml")).and_return(response)
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

            different_person = Factory.create(:person)

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
