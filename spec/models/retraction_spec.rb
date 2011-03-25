#   Copyright (c) 2010, Diaspora Inc.  This file is
#   licensed under the Affero General Public License version 3 or later.  See
#   the COPYRIGHT file.

require 'spec_helper'

describe Retraction do

  let(:user) { alice }
  let(:person) { Factory(:person) }
  let(:aspect) { user.aspects.create(:name => "Bruisers") }
  let!(:activation) { user.activate_contact(person, aspect) }
  let!(:post) { user.post :status_message, :text => "Destroy!", :to => aspect.id }

  describe 'serialization' do
    it 'should have a post id after serialization' do
      retraction = Retraction.for(post)
      xml = retraction.to_xml.to_s
      xml.include?(post.guid.to_s).should == true
    end
  end

  describe '#subscribers' do
    it 'returns the subscribers to the post for all objects other than person' do
      retraction = Retraction.for(post)
      obj = retraction.instance_variable_get(:@object)
      wanted_subscribers = obj.subscribers(user)
      obj.should_receive(:subscribers).with(user).and_return(wanted_subscribers)
      retraction.subscribers(user).map{|s| s.id}.should =~ wanted_subscribers.map{|s| s.id}
    end

    context 'hax' do
      it 'barfs if the type is a person, and subscribers instance varabile is not set' do
        retraction = Retraction.for(user)
        obj = retraction.instance_variable_get(:@object)

        proc{retraction.subscribers(user)}.should raise_error
      end

      it 'returns manually set subscribers' do
        retraction = Retraction.for(user)
        retraction.subscribers = "fooey"
        retraction.subscribers(user).should == 'fooey'
      end
    end
  end
end
