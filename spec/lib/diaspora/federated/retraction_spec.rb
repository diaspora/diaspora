#   Copyright (c) 2010-2011, Diaspora Inc.  This file is
#   licensed under the Affero General Public License version 3 or later.  See
#   the COPYRIGHT file.

require 'spec_helper'

describe Retraction do
  before do
    @aspect = alice.aspects.first
    alice.contacts.create(:person => eve.person, :aspects => [@aspect])
    @post = alice.post(:status_message, :public => true, :text => "Destroy!", :to => @aspect.id)
  end

  describe 'serialization' do
    it 'should have a post id after serialization' do
      retraction = described_class.for(@post)
      xml = retraction.to_xml.to_s
      expect(xml.include?(@post.guid.to_s)).to eq(true)
    end
  end

  describe '#subscribers' do
    context 'posts' do
      before do
        @retraction = described_class.for(@post)
        @obj = @retraction.instance_variable_get(:@object)
        @wanted_subscribers = @obj.subscribers(alice)
      end

      it 'returns the subscribers to the post for all objects other than person' do
        expect(@retraction.subscribers(alice).map(&:id)).to match_array(@wanted_subscribers.map(&:id))
      end

      it 'does not return the authors of reshares' do
        @post.reshares << FactoryGirl.build(:reshare, :root => @post, :author => bob.person)
        @post.save!

        @wanted_subscribers -= [bob.person]
        expect(@retraction.subscribers(alice).map(&:id)).to match_array(@wanted_subscribers.map(&:id))
      end
    end

    context 'setting subscribers' do
      it 'barfs if the type is a person, and subscribers instance varabile is not set' do
        retraction = described_class.for(alice)
        obj = retraction.instance_variable_get(:@object)

        expect {
          retraction.subscribers(alice)
        }.to raise_error
      end

      it 'returns manually set subscribers' do
        retraction = described_class.for(alice)
        retraction.subscribers = "fooey"
        expect(retraction.subscribers(alice)).to eq('fooey')
      end
    end
  end
end
