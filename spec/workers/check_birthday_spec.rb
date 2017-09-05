# frozen_string_literal: true

describe Workers::CheckBirthday do
  let(:birthday_profile) { bob.profile }
  let(:contact1) { alice.contact_for(bob.person) }
  let(:contact2) { eve.contact_for(bob.person) }

  before do
    Timecop.freeze(Time.zone.local(1999, 9, 9))
    birthday_profile.update_attributes(birthday: "1990-09-09")
    allow(Notifications::ContactsBirthday).to receive(:notify)
  end

  after do
    Timecop.return
  end

  it "calls notify method for the birthday person's contacts" do
    Workers::CheckBirthday.new.perform
    expect(Notifications::ContactsBirthday).to have_received(:notify).with(contact1, [])
    expect(Notifications::ContactsBirthday).to have_received(:notify).with(contact2, [])
  end

  it "does nothing if the birthday does not exist" do
    birthday_profile.update_attributes(birthday: nil)
    Workers::CheckBirthday.new.perform
    expect(Notifications::ContactsBirthday).not_to have_received(:notify)
  end

  it "does nothing if the person's birthday is not today" do
    birthday_profile.update_attributes(birthday: "1988-04-15")
    Workers::CheckBirthday.new.perform
    expect(Notifications::ContactsBirthday).not_to have_received(:notify)
  end

  it "does not call notify method if a person is not a contact of the birthday person" do
    contact2.destroy
    Workers::CheckBirthday.new.perform
    expect(Notifications::ContactsBirthday).to have_received(:notify).with(contact1, [])
    expect(Notifications::ContactsBirthday).not_to have_received(:notify).with(contact2, [])
  end

  it "does not call notify method if a contact user is not :receiving from the birthday person" do
    contact2.update_attributes(receiving: false)
    Workers::CheckBirthday.new.perform
    expect(Notifications::ContactsBirthday).to have_received(:notify).with(contact1, [])
    expect(Notifications::ContactsBirthday).not_to have_received(:notify).with(contact2, [])
  end

  it "does not call notify method if a birthday person is not :sharing with the contact user" do
    contact2.update_attributes(sharing: false)
    Workers::CheckBirthday.new.perform
    expect(Notifications::ContactsBirthday).to have_received(:notify).with(contact1, [])
    expect(Notifications::ContactsBirthday).not_to have_received(:notify).with(contact2, [])
  end
end
