# frozen_string_literal: true

describe GonHelper, type: :helper do
  include_context :gon

  describe "#gon_load_contact" do
    let(:contact) { FactoryGirl.build(:contact) }
    let(:current_user) { contact.user }
    let(:another_contact) { FactoryGirl.build(:contact, user: current_user) }

    before do
      RequestStore.store[:gon] = Gon::Request.new(controller.request.env)
      Gon.preloads = {}
    end

    it "calls appropriate presenter" do
      expect_any_instance_of(ContactPresenter).to receive(:full_hash_with_person)
      gon_load_contact(contact)
    end

    shared_examples "contacts loading" do
      it "loads contacts to gon" do
        gon_load_contact(contact)
        gon_load_contact(another_contact)
        expect(Gon.preloads[:contacts].count).to eq(2)
      end

      it "avoids duplicates" do
        gon_load_contact(contact)
        gon_load_contact(contact)
        expect(Gon.preloads[:contacts].count).to eq(1)
      end
    end

    context "with non-persisted contacts" do
      include_examples "contacts loading"
    end

    context "with persisted contacts" do
      before do
        contact.save!
        another_contact.save!
      end

      include_examples "contacts loading"
    end
  end
end
