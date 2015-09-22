require "spec_helper"

describe Reshare, type: :model do
  it "has a valid Factory" do
    expect(FactoryGirl.build(:reshare)).to be_valid
  end

  it "requires root" do
    reshare = FactoryGirl.build(:reshare, root: nil)
    expect(reshare).not_to be_valid
  end

  it "require public root" do
    reshare = FactoryGirl.build(:reshare, root: FactoryGirl.create(:status_message, public: false))
    expect(reshare).not_to be_valid
    expect(reshare.errors[:base]).to include("Only posts which are public may be reshared.")
  end

  it "forces public" do
    expect(FactoryGirl.create(:reshare, public: false).public).to be true
  end

  describe "#root_diaspora_id" do
    let(:reshare) { create(:reshare, root: FactoryGirl.build(:status_message, author: bob.person, public: true)) }

    it "should return the root diaspora id" do
      expect(reshare.root_diaspora_id).to eq(bob.person.diaspora_handle)
    end

    it "should be nil if no root found" do
      reshare.root = nil
      expect(reshare.root_diaspora_id).to be_nil
    end
  end

  describe "#receive" do
    let(:receive_reshare) { @reshare.receive(@root.author.owner, @reshare.author) }

    before do
      @reshare = FactoryGirl.create(:reshare, root:
                 FactoryGirl.build(:status_message, author: bob.person, public: true))
      @root = @reshare.root
    end

    it "increments the reshare count" do
      receive_reshare
      expect(@root.resharers.count).to eq(1)
    end

    it "adds the resharer to the re-sharers of the post" do
      receive_reshare
      expect(@root.resharers).to include(@reshare.author)
    end
    it "does not error if the root author has a contact for the resharer" do
      bob.share_with @reshare.author, bob.aspects.first
      expect {
        Timeout.timeout(5) do
          receive_reshare # This doesn't ever terminate on my machine before it was fixed.
        end
      }.not_to raise_error
    end
  end

  describe "#nsfw" do
    let(:sfw) { build(:status_message, author: alice.person, public: true) }
    let(:nsfw) { build(:status_message, author: alice.person, public: true, text: "This is #nsfw") }
    let(:sfw_reshare) { build(:reshare, root: sfw) }
    let(:nsfw_reshare) { build(:reshare, root: nsfw) }

    it "deletates #nsfw to the root post" do
      expect(sfw_reshare.nsfw).not_to be true
      expect(nsfw_reshare.nsfw).to be_truthy
    end
  end

  describe "#poll" do
    let(:root_post) { create(:status_message_with_poll, public: true) }
    let(:reshare) { create(:reshare, root: root_post) }

    it "contains root poll" do
      expect(reshare.poll).to eq root_post.poll
    end
  end

  describe "#notification_type" do
    let(:status_message) { build(:status_message, author: alice.person, public: true) }
    let(:reshare) { build(:reshare, root: status_message) }

    it "does not return anything for non-author of the original post" do
      expect(reshare.notification_type(bob, reshare.author)).to be_nil
    end

    it "returns 'Reshared' for the original post author" do
      expect(reshare.notification_type(alice, reshare.author)).to eq(Notifications::Reshared)
    end

    it "does not error out if the root was deleted" do
      reshare.root = nil
      expect {
        reshare.notification_type(alice, reshare.author)
      }.to_not raise_error
    end
  end

  describe "#absolute_root" do
    before do
      @status_message = FactoryGirl.build(:status_message, author: alice.person, public: true)
      reshare_1 = FactoryGirl.build(:reshare, root: @status_message)
      reshare_2 = FactoryGirl.build(:reshare, root: reshare_1)
      @reshare_3 = FactoryGirl.build(:reshare, root: reshare_2)

      status_message = FactoryGirl.create(:status_message, author: alice.person, public: true)
      reshare_1 = FactoryGirl.create(:reshare, root: status_message)
      @of_deleted = FactoryGirl.build(:reshare, root: reshare_1)
      status_message.destroy
      reshare_1.reload
    end

    it "resolves root posts to the top level" do
      expect(@reshare_3.absolute_root).to eq(@status_message)
    end

    it "can handle deleted reshares" do
      expect(@of_deleted.absolute_root).to be_nil
    end

    it "is used everywhere" do
      expect(@reshare_3.message).to eq @status_message.message
      expect(@of_deleted.message).to be_nil
      expect(@reshare_3.photos).to eq @status_message.photos
      expect(@of_deleted.photos).to be_empty
      expect(@reshare_3.o_embed_cache).to eq @status_message.o_embed_cache
      expect(@of_deleted.o_embed_cache).to be_nil
      expect(@reshare_3.open_graph_cache).to eq @status_message.open_graph_cache
      expect(@of_deleted.open_graph_cache).to be_nil
      expect(@reshare_3.mentioned_people).to eq @status_message.mentioned_people
      expect(@of_deleted.mentioned_people).to be_empty
      expect(@reshare_3.nsfw).to eq @status_message.nsfw
      expect(@of_deleted.nsfw).to be_nil
      expect(@reshare_3.address).to eq @status_message.location.try(:address)
      expect(@of_deleted.address).to be_nil
    end
  end

  describe "XML" do
    let(:reshare) { build(:reshare) }
    let(:xml) { reshare.to_xml.to_s }

    context "serialization" do
      it "serializes root_diaspora_id" do
        expect(xml).to include("root_diaspora_id")
        expect(xml).to include(reshare.author.diaspora_handle)
      end

      it "serializes root_guid" do
        expect(xml).to include("root_guid")
        expect(xml).to include(reshare.root.guid)
      end
    end

    context "marshalling" do
      let(:root_object) { reshare.root }

      context "local" do
        let(:original_author) { reshare.root.author }

        it "marshals the guid" do
          expect(Reshare.from_xml(xml).root_guid).to eq(root_object.guid)
        end

        it "fetches the root post from root_guid" do
          expect(Reshare.from_xml(xml).root).to eq(root_object)
        end

        it "fetches the root author from root_diaspora_id" do
          expect(Reshare.from_xml(xml).root.author).to eq(original_author)
        end
      end

      describe "destroy" do
        it "allows you to destroy the reshare if the root post is missing" do
          reshare
          reshare.root = nil

          expect {
            reshare.destroy
          }.to_not raise_error
        end
      end

      context "remote" do
        before do
          # root_object = reshare.root
          root_object.delete
          @response = double
          allow(@response).to receive(:status).and_return(200)
          allow(@response).to receive(:success?).and_return(true)
        end

        it "fetches the root author from root_diaspora_id" do
          @original_profile = reshare.root.author.profile.dup
          reshare.root.author.profile.delete
          @original_author = reshare.root.author.dup
          reshare.root.author.delete

          @original_author.profile = @original_profile

          expect(Person).to receive(:find_or_fetch_by_identifier).and_return(@original_author)

          allow(@response).to receive(:body).and_return(root_object.to_diaspora_xml)

          expect(Faraday.default_connection).to receive(:get).with(
            URI.join(
              @original_author.url,
              Rails.application.routes.url_helpers.short_post_path(
                root_object.guid,
                format: "xml"
              )
            )
          ).and_return(@response)
          Reshare.from_xml(xml)
        end

        context "fetching post" do
          it "raises if the post is not found" do
            allow(@response).to receive(:status).and_return(404)
            expect(Faraday.default_connection).to receive(:get).and_return(@response)

            expect {
              Reshare.from_xml(xml)
            }.to raise_error(Diaspora::PostNotFetchable)
          end

          it "raises if there's another error receiving the post" do
            allow(@response).to receive(:status).and_return(500)
            allow(@response).to receive(:success?).and_return(false)
            expect(Faraday.default_connection).to receive(:get).and_return(@response)

            expect {
              Reshare.from_xml(xml)
            }.to raise_error RuntimeError
          end
        end

        context "saving the post" do
          before do
            allow(@response).to receive(:body).and_return(root_object.to_diaspora_xml)
            allow(Faraday.default_connection).to receive(:get).with(
              URI.join(
                reshare.root.author.url,
                Rails.application.routes.url_helpers.short_post_path(
                  root_object.guid,
                  format: "xml"
                )
              )
            ).and_return(@response)
          end

          it "fetches the root post from root_guid" do
            root = Reshare.from_xml(xml).root

            %i(text guid diaspora_handle type public).each do |attr|
              expect(root.send(attr)).to eq(reshare.root.send(attr))
            end
          end

          it "correctly saves the type" do
            expect(Reshare.from_xml(xml).root.reload.type).to eq("StatusMessage")
          end

          it "correctly sets the author" do
            @original_author = reshare.root.author
            expect(Reshare.from_xml(xml).root.reload.author.reload).to eq(@original_author)
          end

          it "verifies that the author of the post received is the same as the author in the reshare xml" do
            @original_author = reshare.root.author.dup
            xml = reshare.to_xml.to_s

            different_person = FactoryGirl.build(:person)
            expect(Person).to receive(:find_or_fetch_by_identifier).and_return(different_person)

            allow(different_person).to receive(:url).and_return(@original_author.url)

            expect {
              Reshare.from_xml(xml)
            }.to raise_error /^Diaspora ID \(.+\) in the root does not match the Diaspora ID \(.+\) specified in the reshare!$/
          end
        end
      end
    end
  end

  describe "#post_location" do
    let(:status_message) { build(:status_message, text: "This is a status_message", author: bob.person, public: true) }
    let(:reshare) { create(:reshare, root: status_message) }

    context "with location" do
      let(:location) { build(:location) }

      it "should deliver address and coordinates" do
        status_message.location = location
        expect(reshare.post_location).to include(address: location.address, lat: location.lat, lng: location.lng)
      end
    end

    context "without location" do
      it "should deliver empty address and coordinates" do
        expect(reshare.post_location[:address]).to be_nil
        expect(reshare.post_location[:lat]).to be_nil
        expect(reshare.post_location[:lng]).to be_nil
      end
    end
  end
end
