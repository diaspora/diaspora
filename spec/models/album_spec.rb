#   Copyright (c) 2010, Diaspora Inc.  This file is
#   licensed under the Affero General Public License version 3.  See
#   the COPYRIGHT file.

require 'spec_helper'

describe Album do
  let(:user) { Factory.create(:user) }
  let(:person) { user.person }
  let(:aspect) { user.aspect(:name => "Foo") }
  let(:album) { user.post(:album, :name => "test collection", :to => aspect.id) }

  it 'is valid' do
    album.should be_valid
  end

  it 'validates presence of a name' do
    album.name = nil
    album.should_not be_valid
  end

  it 'has many photos' do
    album.associations[:photos].type == :many
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

  describe '#to_xml' do
    let(:doc) { album.to_xml }
    it 'has a name' do
      doc.at_xpath('./name').text.should == album.name
    end

    it 'has an id' do
      doc.at_xpath('./_id').text.should == album.id.to_s
    end

    it 'includes the person' do
      doc.at_xpath('./person/_id').text.should == album.person.id.to_s
    end
  end
end
