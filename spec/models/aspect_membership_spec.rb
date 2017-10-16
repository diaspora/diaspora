# frozen_string_literal: true

#   Copyright (c) 2010-2011, Diaspora Inc.  This file is
#   licensed under the Affero General Public License version 3 or later.  See
#   the COPYRIGHT file.
#
describe AspectMembership, :type => :model do
  describe "#before_destroy" do
    let(:aspect) { alice.aspects.create(name: "two") }
    let(:contact) { alice.contact_for(bob.person) }
    let(:aspect_membership) { alice.aspects.where(name: "generic").first.aspect_memberships.first }

    before do
      allow(aspect_membership).to receive(:user).and_return(alice)
    end

    it "calls disconnect if its the last aspect for the contact" do
      expect(alice).to receive(:disconnect).with(contact)

      aspect_membership.destroy
    end

    it "does not call disconnect if its not the last aspect for the contact" do
      expect(alice).not_to receive(:disconnect)

      alice.add_contact_to_aspect(contact, aspect)
      aspect_membership.destroy
    end

    it "doesn't fail destruction if the user entry was deleted in prior" do
      aspect_membership.user.delete
      id = aspect_membership.id

      expect { AspectMembership.find(id).destroy }.not_to raise_error
      expect(AspectMembership.where(id: id)).not_to exist
    end
  end
end
