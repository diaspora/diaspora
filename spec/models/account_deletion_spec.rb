#   Copyright (c) 2010-2011, Diaspora Inc.  This file is
#   licensed under the Affero General Public License version 3 or later.  See
#   the COPYRIGHT file.

require 'spec_helper'

describe AccountDeletion, :type => :model do
  let(:ad_new)    { AccountDeletion.new(person: alice.person) }
  let(:ad_create) { AccountDeletion.create(person: alice.person) }

  it 'assigns the diaspora_handle from the person object' do
    expect(ad_new.diaspora_handle).to eq(alice.person.diaspora_handle)
  end

  it 'fires a job after creation'do
    expect(Workers::DeleteAccount).to receive(:perform_async).with(anything)
    ad_create
  end

  describe "#perform!" do
    it 'creates a deleter' do
      expect(AccountDeleter).to receive(:new).with(alice.person.diaspora_handle).and_return(double(perform!: true))
      ad_new.perform!
    end

    it 'dispatches the account deletion if the user exists' do
      expect(ad_new).to receive(:dispatch)
      ad_new.perform!
    end

    it 'does not dispatch an account deletion for non-local people' do
      deletion = AccountDeletion.new(person: remote_raphael)
      expect(deletion).not_to receive(:dispatch)
      deletion.perform!
    end

    it 'marks an AccountDeletion as completed when successful' do
      ad_create.perform!
      expect(ad_create.reload.completed_at).not_to be_nil
    end
  end

  describe '#dispatch' do
    it 'creates a public postzord' do
      expect(Postzord::Dispatcher::Public).to receive(:new).and_return(double.as_null_object)
      ad_new.dispatch
    end
  end

  describe "#subscribers" do
    it 'includes all remote contacts' do
      alice.share_with(remote_raphael, alice.aspects.first)

      expect(ad_new.subscribers(alice)).to eq([remote_raphael])
    end

    it 'includes remote resharers' do
      sm = FactoryGirl.create( :status_message, public: true, author: alice.person)
      FactoryGirl.create( :reshare, author: remote_raphael, root: sm)
      FactoryGirl.create( :reshare, author: local_luke.person, root: sm)

      expect(ad_new.subscribers(alice)).to eq([remote_raphael])
    end
  end

  describe 'serialization' do
    let(:xml) { ad_new.to_xml.to_s }

    it 'should have a diaspora_handle' do
      expect(xml.include?(alice.person.diaspora_handle)).to eq(true)
    end

    it 'marshals the xml' do
      expect(AccountDeletion.from_xml(xml)).to be_valid
    end
  end
end
