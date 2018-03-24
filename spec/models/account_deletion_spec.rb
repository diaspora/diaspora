# frozen_string_literal: true

#   Copyright (c) 2010-2011, Diaspora Inc.  This file is
#   licensed under the Affero General Public License version 3 or later.  See
#   the COPYRIGHT file.

describe AccountDeletion, type: :model do
  let(:account_deletion) { AccountDeletion.new(person: alice.person) }

  it "assigns the diaspora_handle from the person object" do
    expect(account_deletion.diaspora_handle).to eq(alice.person.diaspora_handle)
  end

  it "fires a job after creation" do
    expect(Workers::DeleteAccount).to receive(:perform_async).with(anything)
    AccountDeletion.create(person: alice.person)
  end

  describe "#perform!" do
    it "creates a deleter" do
      expect(AccountDeleter).to receive(:new).with(alice.person).and_return(double(perform!: true))
      account_deletion.perform!
    end

    it "dispatches the account deletion if the user exists" do
      dispatcher = double
      expect(Diaspora::Federation::Dispatcher::Public).to receive(:new).and_return(dispatcher)
      expect(dispatcher).to receive(:dispatch)

      account_deletion.perform!
    end

    it "does not dispatch an account deletion for non-local people" do
      deletion = AccountDeletion.new(person: remote_raphael)
      expect(Diaspora::Federation::Dispatcher).not_to receive(:build)
      deletion.perform!
    end

    it "marks an AccountDeletion as completed when successful" do
      deletion = AccountDeletion.create(person: alice.person)
      deletion.perform!
      expect(deletion.reload.completed_at).not_to be_nil
    end
  end

  describe "#subscribers" do
    it "includes all remote contacts" do
      alice.share_with(remote_raphael, alice.aspects.first)

      expect(account_deletion.subscribers).to eq([remote_raphael])
    end

    it "includes remote resharers" do
      status_message = FactoryGirl.create(:status_message, public: true, author: alice.person)
      FactoryGirl.create(:reshare, author: remote_raphael, root: status_message)
      FactoryGirl.create(:reshare, author: local_luke.person, root: status_message)

      expect(account_deletion.subscribers).to eq([remote_raphael])
    end
  end
end
