#   Copyright (c) 2010, Diaspora Inc.  This file is
#   licensed under the Affero General Public License version 3 or later.  See
#   the COPYRIGHT file.

require 'spec_helper'

describe Retraction do
  before do
    @aspect = alice.aspects.first
    alice.contacts.create(:person => eve.person, :aspects => [@aspect])
    @post = alice.post :status_message, :text => "Destroy!", :to => @aspect.id
  end

  describe 'serialization' do
    it 'should have a post id after serialization' do
      retraction = Retraction.for(@post)
      xml = retraction.to_xml.to_s
      xml.include?(@post.guid.to_s).should == true
    end
  end

  describe '#subscribers' do
    it 'returns the subscribers to the post for all objects other than person' do
      retraction = Retraction.for(@post)
      obj = retraction.instance_variable_get(:@object)
      wanted_subscribers = obj.subscribers(alice)
      obj.should_receive(:subscribers).with(alice).and_return(wanted_subscribers)
      retraction.subscribers(alice).map{|s| s.id}.should =~ wanted_subscribers.map{|s| s.id}
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
