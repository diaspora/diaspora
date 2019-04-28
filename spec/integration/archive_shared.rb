# frozen_string_literal: true

def expect_person_fetch(diaspora_id, public_key)
  expect(DiasporaFederation::Discovery::Discovery).to receive(:new).with(diaspora_id) {
    double.tap {|instance|
      expect(instance).to receive(:fetch_and_save) {
        attributes = {diaspora_handle: diaspora_id}
        attributes[:serialized_public_key] = public_key if public_key.present?
        FactoryGirl.create(:person, attributes)
      }
    }
  }
end
