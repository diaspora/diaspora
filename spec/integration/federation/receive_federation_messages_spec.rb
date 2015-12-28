require "spec_helper"
require "integration/federation/federation_helper"
require "integration/federation/shared_receive_relayable"
require "integration/federation/shared_receive_retraction"

describe Workers::ReceiveEncryptedSalmon do
  it "treats sharing request receive correctly" do
    entity = FactoryGirl.build(:request_entity, recipient_id: alice.diaspora_handle)

    expect(Diaspora::Fetcher::Public).to receive(:queue_for)
    Workers::ReceiveEncryptedSalmon.new.perform(alice.id, generate_xml(entity, remote_user_on_pod_c, alice))

    new_contact = alice.contacts.find {|c| c.person.diaspora_handle == remote_user_on_pod_c.diaspora_handle }
    expect(new_contact).not_to be_nil
    expect(new_contact.sharing).to eq(true)
  end

  it "doesn't save the status message if there is no sharing" do
    entity = FactoryGirl.build(:status_message_entity, diaspora_id: remote_user_on_pod_b.diaspora_handle, public: false)
    Workers::ReceiveEncryptedSalmon.new.perform(alice.id, generate_xml(entity, remote_user_on_pod_b, alice))

    expect(StatusMessage.exists?(guid: entity.guid)).to be(false)
  end

  describe "with messages which require sharing" do
    before do
      contact = alice.contacts.find_or_initialize_by(person_id: remote_user_on_pod_b.person.id)
      contact.sharing = true
      contact.save
    end

    it "treats status message receive correctly" do
      entity = FactoryGirl.build(:status_message_entity,
                                 diaspora_id: remote_user_on_pod_b.diaspora_handle, public: false)
      Workers::ReceiveEncryptedSalmon.new.perform(alice.id, generate_xml(entity, remote_user_on_pod_b, alice))

      expect(StatusMessage.exists?(guid: entity.guid)).to be(true)
    end

    it "doesn't accept status message with wrong signature" do
      expect(remote_user_on_pod_b).to receive(:encryption_key).and_return(OpenSSL::PKey::RSA.new(1024))

      entity = FactoryGirl.build(:status_message_entity,
                                 diaspora_id: remote_user_on_pod_b.diaspora_handle, public: false)
      Workers::ReceiveEncryptedSalmon.new.perform(alice.id, generate_xml(entity, remote_user_on_pod_b, alice))

      expect(StatusMessage.exists?(guid: entity.guid)).to be(false)
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
                let(:target_object) { FactoryGirl.create(target.to_sym, author: remote_user_on_pod_b.person) }
                let(:entity_name) { "#{retraction_entity_name}_entity".to_sym }
              end
            end
          end
        end
      end
    end

    describe "with messages which require a status to operate on" do
      let(:local_message) { FactoryGirl.create(:status_message, author: alice.person) }
      let(:remote_message) { FactoryGirl.create(:status_message, author: remote_user_on_pod_b.person) }

      %w(comment like participation).each do |entity|
        context "with #{entity}" do
          it_behaves_like "it deals correctly with a relayable" do
            let(:entity_name) { "#{entity}_entity".to_sym }
            let(:klass) { entity.camelize.constantize }
          end
        end
      end

      describe "retractions for relayable objects" do
        let(:sender) { remote_user_on_pod_b }

        %w(
          retraction
          signed_retraction
          relayable_retraction
        ).each do |retraction_entity_name|
          context "with #{retraction_entity_name}" do
            context "with comment" do
              it_behaves_like "it retracts object" do
                # case for to-upstream federation
                let(:entity_name) { "#{retraction_entity_name}_entity".to_sym }
                let(:target_object) {
                  FactoryGirl.create(:comment, author: remote_user_on_pod_b.person, post: local_message)
                }
              end

              it_behaves_like "it retracts object" do
                # case for to-downsteam federation
                let(:entity_name) { "#{retraction_entity_name}_entity".to_sym }
                let(:target_object) {
                  FactoryGirl.create(:comment, author: remote_user_on_pod_c.person, post: remote_message)
                }
              end
            end

            context "with like" do
              it_behaves_like "it retracts object" do
                # case for to-upstream federation
                let(:entity_name) { "#{retraction_entity_name}_entity".to_sym }
                let(:target_object) {
                  FactoryGirl.create(:like, author: remote_user_on_pod_b.person, target: local_message)
                }
              end

              it_behaves_like "it retracts object" do
                # case for to-downsteam federation
                let(:entity_name) { "#{retraction_entity_name}_entity".to_sym }
                let(:target_object) {
                  FactoryGirl.create(:like, author: remote_user_on_pod_c.person, target: remote_message)
                }
              end
            end
          end
        end
      end
    end
  end
end
