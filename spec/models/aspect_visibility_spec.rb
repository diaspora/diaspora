# frozen_string_literal: true

describe AspectVisibility, type: :model do
  let(:status_message) { FactoryGirl.create(:status_message) }
  let(:aspect) { FactoryGirl.create(:aspect) }
  let(:status_message_in_aspect) { FactoryGirl.create(:status_message_in_aspect) }
  let(:photo_with_same_id) {
    Photo.find_by_id(status_message_in_aspect.id) || FactoryGirl.create(:photo, id: status_message_in_aspect.id)
  }

  describe ".create" do
    it "creates object when attributes are fine" do
      expect {
        AspectVisibility.create(shareable: status_message, aspect: aspect)
      }.to change(AspectVisibility, :count).by(1)
    end

    it "doesn't allow duplicating objects" do
      expect {
        AspectVisibility
          .create(shareable: status_message_in_aspect, aspect: status_message_in_aspect.aspects.first)
          .save!
      }.to raise_error(ActiveRecord::RecordInvalid)
    end

    it "makes difference between shareable types" do
      expect {
        AspectVisibility.create(shareable: photo_with_same_id, aspect: status_message_in_aspect.aspects.first).save!
      }.not_to raise_error
    end
  end
end
