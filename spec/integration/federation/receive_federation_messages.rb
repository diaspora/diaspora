require "spec_helper"
require "diaspora_federation/test"
require "integration/federation/federation_messages_generation"
require "integration/federation/shared_receive_relayable"
require "integration/federation/shared_receive_retraction"

describe Workers::ReceiveEncryptedSalmon do
  before do
    @user = alice
    allow(User).to receive(:find) { |id|
      @user if id == @user.id
    }

    @remote_user = FactoryGirl.build(:user) # user on pod B
    @remote_user2 = FactoryGirl.build(:user) # user on pod C

    allow_any_instance_of(DiasporaFederation::Discovery::Discovery)
      .to receive(:webfinger) {|instance|
        [@remote_user, @remote_user2].find {|user| user.diaspora_handle == instance.diaspora_id }.person.webfinger
      }
    allow_any_instance_of(DiasporaFederation::Discovery::Discovery)
      .to receive(:hcard) {|instance|
        [@remote_user, @remote_user2].find {|user| user.diaspora_handle == instance.diaspora_id }.person.hcard
      }

    @remote_person = Person.find_or_fetch_by_identifier(@remote_user.diaspora_handle)
    @remote_person2 = Person.find_or_fetch_by_identifier(@remote_user2.diaspora_handle)
  end

  it "treats sharing request recive correctly" do
    entity = FactoryGirl.build(:request_entity, recipient_id: @user.diaspora_handle)

    expect(Diaspora::Fetcher::Public).to receive(:queue_for).exactly(1).times

    Workers::ReceiveEncryptedSalmon.new.perform(@user.id, generate_xml(entity, @remote_user, @user))

    expect(@user.contacts.count).to eq(2)
    new_contact = @user.contacts.order(created_at: :asc).last
    expect(new_contact).not_to be_nil
    expect(new_contact.sharing).to eq(true)
    expect(new_contact.person.diaspora_handle).to eq(@remote_user.diaspora_handle)
  end

  it "doesn't save the status message if there is no sharing" do
    Workers::ReceiveEncryptedSalmon.new.perform(@user.id, generate_status_message)

    expect(StatusMessage.exists?(guid: @entity.guid)).to be(false)
  end

  describe "with messages which require sharing" do
    before do
      @remote_person = Person.find_or_fetch_by_identifier(@remote_user.diaspora_handle)
      contact = @user.contacts.find_or_initialize_by(person_id: @remote_person.id)
      contact.sharing = true
      contact.save
    end

    it "treats status message receive correctly" do
      Workers::ReceiveEncryptedSalmon.new.perform(@user.id, generate_status_message)

      expect(StatusMessage.exists?(guid: @entity.guid)).to be(true)
    end

    it "doesn't accept status message with wrong signature" do
      Workers::ReceiveEncryptedSalmon.new.perform(@user.id, generate_forged_status_message)

      expect(StatusMessage.exists?(guid: @entity.guid)).to be(false)
    end

    describe "retractions for non-relayable objects" do
      %w(
        retraction
        signed_retraction
      ).each do |retraction_entity_name|
        context "with #{retraction_entity_name}" do
          %w(status_message photo).each do |target|
            context "with #{target}" do
              it_behaves_like "it retracts non-relayable object" do
                let(:target_object) { FactoryGirl.create(target.to_sym, author: @remote_person) }
                let(:entity_name) { "#{retraction_entity_name}_entity".to_sym }
              end
            end
          end
        end
      end
    end

    describe "with messages which require a status to operate on" do
      before do
        @local_message = FactoryGirl.create(:status_message, author: @user.person)
        @remote_message = FactoryGirl.create(:status_message, author: @remote_person)
      end

      %w(comment like participation).each do |entity|
        context "with #{entity}" do
          it_behaves_like "it deals correctly with a relayable" do
            let(:entity_name) { "#{entity}_entity".to_sym }
            let(:klass) { entity.camelize.constantize }
          end
        end
      end

      describe "retractions for relayable objects" do
        %w(
          retraction
          signed_retraction
          relayable_retraction
        ).each do |retraction_entity_name|
          context "with #{retraction_entity_name}" do
            context "with comment" do
              it_behaves_like "it retracts relayable object" do
                # case for to-upstream federation
                let(:entity_name) { "#{retraction_entity_name}_entity".to_sym }
                let(:target_object) { FactoryGirl.create(:comment, author: @remote_person, post: @local_message) }
                let(:sender) { @remote_user }
              end

              it_behaves_like "it retracts relayable object" do
                # case for to-downsteam federation
                let(:target_object) { FactoryGirl.create(:comment, author: @remote_person2, post: @remote_message) }
                let(:entity_name) { "#{retraction_entity_name}_entity".to_sym }
                let(:sender) { @remote_user }
              end
            end

            context "with like" do
              it_behaves_like "it retracts relayable object" do
                # case for to-upstream federation
                let(:entity_name) { "#{retraction_entity_name}_entity".to_sym }
                let(:target_object) { FactoryGirl.create(:like, author: @remote_person, target: @local_message) }
                let(:sender) { @remote_user }
              end

              it_behaves_like "it retracts relayable object" do
                # case for to-downsteam federation
                let(:target_object) { FactoryGirl.create(:like, author: @remote_person2, target: @remote_message) }
                let(:entity_name) { "#{retraction_entity_name}_entity".to_sym }
                let(:sender) { @remote_user }
              end
            end
          end
        end
      end
    end
  end
end
