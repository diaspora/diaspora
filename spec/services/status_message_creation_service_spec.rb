# frozen_string_literal: true

describe StatusMessageCreationService do
  describe "#create" do
    let(:aspect) { alice.aspects.first }
    let(:text) { "I'm writing tests" }
    let(:params) {
      {
        status_message: {text: text},
        aspect_ids:     [aspect.id.to_s]
      }
    }

    it "returns the created StatusMessage" do
      status_message = StatusMessageCreationService.new(alice).create(params)
      expect(status_message).to_not be_nil
      expect(status_message.text).to eq(text)
    end

    context "with aspect_ids" do
      it "creates aspect_visibilities for the StatusMessages" do
        alice.aspects.create(name: "another aspect")

        status_message = StatusMessageCreationService.new(alice).create(params)
        expect(status_message.aspect_visibilities.map(&:aspect)).to eq([aspect])
      end

      it "does not create aspect_visibilities if the post is public" do
        status_message = StatusMessageCreationService.new(alice).create(params.merge(public: true))
        expect(status_message.aspect_visibilities).to be_empty
      end
    end

    context "with public" do
      it "it creates a private StatusMessage by default" do
        status_message = StatusMessageCreationService.new(alice).create(params)
        expect(status_message.public).to be_falsey
      end

      it "it creates a private StatusMessage" do
        status_message = StatusMessageCreationService.new(alice).create(params.merge(public: false))
        expect(status_message.public).to be_falsey
      end

      it "it creates a public StatusMessage" do
        status_message = StatusMessageCreationService.new(alice).create(params.merge(public: true))
        expect(status_message.public).to be_truthy
      end
    end

    context "with location" do
      it "it creates a location" do
        location_params = {location_address: "somewhere", location_coords: "1,2"}
        status_message = StatusMessageCreationService.new(alice).create(params.merge(location_params))
        location = status_message.location
        expect(location.address).to eq("somewhere")
        expect(location.lat).to eq("1")
        expect(location.lng).to eq("2")
      end

      it "does not add a location without location params" do
        status_message = StatusMessageCreationService.new(alice).create(params)
        expect(status_message.location).to be_nil
      end
    end

    context "with poll" do
      it "it creates a poll" do
        poll_params = {poll_question: "something?", poll_answers: %w(yes no maybe)}
        status_message = StatusMessageCreationService.new(alice).create(params.merge(poll_params))
        poll = status_message.poll
        expect(poll.question).to eq("something?")
        expect(poll.poll_answers.size).to eq(3)
        poll_answers = poll.poll_answers.map(&:answer)
        expect(poll_answers).to include("yes")
        expect(poll_answers).to include("no")
        expect(poll_answers).to include("maybe")
      end

      it "does not add a poll without poll params" do
        status_message = StatusMessageCreationService.new(alice).create(params)
        expect(status_message.poll).to be_nil
      end
    end

    context "with photos" do
      let(:photo1) {
        alice.build_post(:photo, pending: true, user_file: File.open(photo_fixture_name), to: aspect.id).tap(&:save!)
      }
      let(:photo2) {
        alice.build_post(:photo, pending: true, user_file: File.open(photo_fixture_name), to: aspect.id).tap(&:save!)
      }
      let(:photo_ids) { [photo1.id.to_s, photo2.id.to_s] }

      it "it attaches all photos" do
        status_message = StatusMessageCreationService.new(alice).create(params.merge(photos: photo_ids))
        photos = status_message.photos
        expect(photos.size).to eq(2)
        expect(photos.map(&:id).map(&:to_s)).to match_array(photo_ids)
      end

      it "does not attach photos without photos param" do
        status_message = StatusMessageCreationService.new(alice).create(params)
        expect(status_message.photos).to be_empty
      end

      context "with aspect_ids" do
        it "it marks the photos as non-public if the post is non-public" do
          status_message = StatusMessageCreationService.new(alice).create(params.merge(photos: photo_ids))
          status_message.photos.each do |photo|
            expect(photo.public).to be_falsey
          end
        end

        it "creates aspect_visibilities for the Photo" do
          alice.aspects.create(name: "another aspect")

          status_message = StatusMessageCreationService.new(alice).create(params.merge(photos: photo_ids))
          status_message.photos.each do |photo|
            expect(photo.aspect_visibilities.map(&:aspect)).to eq([aspect])
          end
        end

        it "does not create aspect_visibilities if the post is public" do
          status_message = StatusMessageCreationService.new(alice).create(params.merge(photos: photo_ids, public: true))
          status_message.photos.each do |photo|
            expect(photo.aspect_visibilities).to be_empty
          end
        end

        it "sets pending to false on any attached photos" do
          status_message = StatusMessageCreationService.new(alice).create(params.merge(photos: photo_ids))
          status_message.photos.each do |photo|
            expect(photo.reload.pending).to be_falsey
          end
        end
      end

      context "with public" do
        it "it marks the photos as public if the post is public" do
          status_message = StatusMessageCreationService.new(alice).create(params.merge(photos: photo_ids, public: true))
          status_message.photos.each do |photo|
            expect(photo.public).to be_truthy
          end
        end

        it "sets pending to false on any attached photos" do
          status_message = StatusMessageCreationService.new(alice).create(params.merge(photos: photo_ids, public: true))
          status_message.photos.each do |photo|
            expect(photo.reload.pending).to be_falsey
          end
        end
      end
    end

    context "dispatch" do
      it "dispatches the StatusMessage" do
        expect(alice).to receive(:dispatch_post).with(instance_of(StatusMessage), hash_including(service_types: []))
        StatusMessageCreationService.new(alice).create(params)
      end

      it "dispatches the StatusMessage to services" do
        expect(alice).to receive(:dispatch_post)
          .with(instance_of(StatusMessage),
                hash_including(service_types: array_including(%w(Services::Facebook Services::Twitter))))
        StatusMessageCreationService.new(alice).create(params.merge(services: %w(twitter facebook)))
      end

      context "with mention" do
        let(:text) { text_mentioning(eve) }

        # this is only required until changes from #6818 are deployed on every pod
        it "filters out mentions from text attribute" do
          status_message = StatusMessageCreationService.new(alice).create(params)
          expect(status_message.text).not_to include(eve.diaspora_handle)
        end
      end
    end
  end
end
