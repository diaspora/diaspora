#   Copyright (c) 2010, Diaspora Inc.  This file is
#   licensed under the Affero General Public License version 3 or later.  See
#   the COPYRIGHT file.

require 'spec_helper'

describe Album do
  let(:user) { make_user }
  let(:person) { user.person }
  let(:aspect) { user.aspects.create(:name => "Foo") }
  let(:album) { user.post(:album, :name => "test collection", :to => aspect.id) }

  it 'is valid' do
    album.should be_valid
  end

  it 'validates presence of a name' do
    album.name = nil
    album.should_not be_valid
  end

  it 'has many photos' do
    album.associations[:photos].type.should == :many
  end

  it 'should be mutable' do
    post = user.post :album, :name => "hello", :to => aspect.id
    post.mutable?.should == true   
  end

  it 'has a diaspora_handle' do
    album.diaspora_handle.should == user.diaspora_handle
  end

  context 'when an album has two attached images' do
    before do
      2.times do
        photo = Factory.build(:photo, :person => person, :album => album)
        album.photos << photo
      end
    end

    context 'when the album is deleted' do
      it 'removes all child photos' do
        expect{ album.destroy }.to change(Photo, :count).from(2).to(0)
      end
    end
  end

  context 'traversing photos' do
    let(:attrs)    { {:person => person, :album => album} }
    let!(:photo_1) { Factory(:photo, attrs.merge(:created_at => 2.days.ago)) }
    let!(:photo_2) { Factory(:photo, attrs.merge(:created_at => 1.day.ago)) }
    let!(:photo_3) { Factory(:photo, attrs.merge(:created_at => Time.now)) }

    describe '#next_photo' do
      it 'returns the next photo' do
        album.next_photo(photo_1).id.should == photo_2.id
      end

      it 'returns the first photo when given the last photo in the album' do
        album.next_photo(photo_3).id.should == photo_1.id
      end
    end

    describe '#prev_photo' do
      it 'returns the previous photo' do
        album.prev_photo(photo_2).id.should == photo_1.id
      end

      it 'returns the last photo when given the first photo in the album' do
        album.prev_photo(photo_1).id.should == photo_3.id
      end
    end
  end

  describe 'serialization' do
    it 'has a diaspora_handle' do
      album.to_diaspora_xml.include?(user.diaspora_handle).should be_true
    end
  end

end
