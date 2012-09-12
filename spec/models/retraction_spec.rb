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
      retraction = Retraction.for(@post)
      xml = retraction.to_xml.to_s
      xml.include?(@post.guid.to_s).should == true
    end
  end

  describe '#subscribers' do
    context 'posts' do
      before do
        @retraction = Retraction.for(@post)
        @obj = @retraction.instance_variable_get(:@object)
        @wanted_subscribers = @obj.subscribers(alice)
      end

      it 'returns the subscribers to the post for all objects other than person' do
        @retraction.subscribers(alice).map(&:id).should =~ @wanted_subscribers.map(&:id)
      end

      it 'does not return the authors of reshares' do
        @post.reshares << FactoryGirl.build(:reshare, :root => @post, :author => bob.person)
        @post.save!

        @wanted_subscribers -= [bob.person]
        @retraction.subscribers(alice).map(&:id).should =~ @wanted_subscribers.map(&:id)
      end
    end

    context 'setting subscribers' do
      it 'barfs if the type is a person, and subscribers instance varabile is not set' do
        retraction = Retraction.for(alice)
        obj = retraction.instance_variable_get(:@object)

        lambda {
          retraction.subscribers(alice)
        }.should raise_error
      end

      it 'returns manually set subscribers' do
        retraction = Retraction.for(alice)
        retraction.subscribers = "fooey"
        retraction.subscribers(alice).should == 'fooey'
      end
    end
  end
end
