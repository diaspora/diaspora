# frozen_string_literal: true

require "integration/federation/federation_helper"

describe ArchiveImporter do
  describe "#import" do
    let(:target) { FactoryGirl.create(:user) }
    let(:archive_importer) {
      archive_importer = ArchiveImporter.new(archive_hash)
      archive_importer.user = target
      archive_importer
    }

    context "with tag following" do
      let(:archive_hash) {
        {
          "user" => {
            "profile"       => {
              "entity_data" => {
                "author" => "old_id@old_pod.nowhere"
              }
            },
            "followed_tags" => ["testtag"]
          }
        }
      }

      it "imports tag" do
        archive_importer.import
        expect(target.tag_followings.first.tag.name).to eq("testtag")
      end
    end

    context "with subscription" do
      let(:status_message) { FactoryGirl.create(:status_message) }
      let(:archive_hash) {
        {
          "user" => {
            "profile"            => {
              "entity_data" => {
                "author" => "old_id@old_pod.nowhere"
              }
            },
            "post_subscriptions" => [status_message.guid]
          }
        }
      }

      it "imports tag" do
        archive_importer.import
        expect(target.participations.first.target).to eq(status_message)
      end
    end

    context "with duplicates" do
      let(:archive_hash) {
        {
          "user" => {
            "auto_follow_back_aspect" => "Friends",
            "profile"                 => {
              "entity_data" => {
                "author" => "old_id@old_pod.nowhere"
              }
            },
            "contact_groups"          => [{
              "name"         => "Friends"
            }],
            "followed_tags"           => [target.tag_followings.first.tag.name],
            "post_subscriptions"      => [target.participations.first.target.guid]
          }
        }
      }

      before do
        DataGenerator.create(target, %i[tag_following subscription])
      end

      it "doesn't fail" do
        expect {
          archive_importer.import
        }.not_to raise_error
      end
    end

    context "with non-fetchable subscription" do
      let(:archive_hash) {
        {
          "user" => {
            "profile"            => {
              "entity_data" => {
                "author" => "old_id@old_pod.nowhere"
              }
            },
            "post_subscriptions" => ["XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX"]
          }
        }
      }

      before do
        stub_request(:get, %r{https*://old_pod\.nowhere/\.well-known/webfinger\?resource=acct:old_id@old_pod\.nowhere})
          .to_return(status: 404, body: "", headers: {})
        stub_request(:get, %r{https*://old_pod\.nowhere/\.well-known/host-meta})
          .to_return(status: 404, body: "", headers: {})
      end

      it "doesn't fail" do
        expect {
          archive_importer.import
        }.not_to raise_error
      end
    end
  end

  describe "#create_user" do
    let(:archive_importer) { ArchiveImporter.new(archive_hash) }
    let(:archive_hash) {
      {
        "user" => {
          "profile"                            => {
            "entity_data" => {
              "author"     => "old_id@old_pod.nowhere",
              "first_name" => "First",
              "last_name"  => "Last",
              "full_name"  => "Full Name",
              "image_url"  => "https://example.com/my_avatar.png",
              "bio"        => "I'm just a test account",
              "gender"     => "Robot",
              "birthday"   => "2006-01-01",
              "location"   => "diaspora* specs",
              "searchable" => false,
              "public"     => true,
              "nsfw"       => true,
              "tag_string" => "#diaspora #linux #partying"
            }
          },
          "email"                              => "user@example.com",
          "strip_exif"                         => false,
          "show_community_spotlight_in_stream" => false,
          "language"                           => "ru",
          "disable_mail"                       => false,
          "auto_follow_back"                   => true
        }
      }
    }

    it "creates user" do
      expect {
        archive_importer.create_user(username: "new_name", password: "123456")
      }.to change(User, :count).by(1)

      expect(archive_importer.user.email).to eq("user@example.com")
      expect(archive_importer.user.strip_exif).to eq(false)
      expect(archive_importer.user.show_community_spotlight_in_stream).to eq(false)
      expect(archive_importer.user.language).to eq("ru")
      expect(archive_importer.user.disable_mail).to eq(false)
      expect(archive_importer.user.auto_follow_back).to eq(true)
      expect(archive_importer.user.getting_started).to be_falsey

      expect(archive_importer.user.profile.first_name).to eq("First")
      expect(archive_importer.user.profile.last_name).to eq("Last")
      expect(archive_importer.user.profile.image_url).to eq("https://example.com/my_avatar.png")
      expect(archive_importer.user.profile.bio).to eq("I'm just a test account")
      expect(archive_importer.user.profile.gender).to eq("Robot")
      expect(archive_importer.user.profile.birthday).to eq(Date.new(2006, 1, 1))
      expect(archive_importer.user.profile.location).to eq("diaspora* specs")
      expect(archive_importer.user.profile.searchable).to eq(false)
      expect(archive_importer.user.profile.public_details).to eq(true)
      expect(archive_importer.user.profile.nsfw).to eq(true)
      expect(archive_importer.user.profile.tag_string).to eq("#diaspora #linux #partying")
    end
  end
end
