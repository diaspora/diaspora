#   Copyright (c) 2010, Diaspora Inc.  This file is
#   licensed under the Affero General Public License version 3 or later.  See
#   the COPYRIGHT file.

require 'spec_helper'

describe PeopleController do
  render_views

  let(:user) { Factory(:user) }
  let!(:aspect) { user.aspects.create(:name => "lame-os") }

  before do
    sign_in :user, user
  end

  it "index should yield search results for substring of person name" do
    eugene = Factory.create(:person, :profile => {:first_name => "Eugene", :last_name => "w"})
    get :index, :q => "Eu"
    assigns[:people].should include eugene
  end

  it 'should go to the current_user show page' do
    get :show, :id => user.person.id
  end

  it "doesn't error out on an invalid id" do
    get :show, :id => 'delicious'
  end

  it "doesn't error out on a nonexistent person" do
    get :show, :id => user.id
  end

  describe '#update' do
    context 'with a profile photo set' do
      it "doesn't overwrite the profile photo when an empty string is passed in" do
        user.person.profile.image_url = "http://tom.joindiaspora.com/images/user/tom.jpg"
        user.person.profile.save
        
        params = {"profile"=> 
                   {"image_url"  => "",
                    "last_name"  => user.person.profile.last_name,
                    "first_name" => user.person.profile.first_name}}

        image_url = user.person.profile.image_url
        put("update", :id => user.person.id, "person" => params)

        user.person.reload
        user.person.profile.image_url.should == image_url
      end

      it "doesn't prepend (https?://) if already present in image_url" do
        params = {:profile=> 
                   {:image_url  => "https://google.com/image.png",
                    :last_name  => user.person.profile.last_name,
                    :first_name => user.person.profile.first_name}}

        put("update", :id => user.person.id, "person" => params)

        user.person.reload
        user.person.profile.image_url.should == params[:profile][:image_url]
      end

    end
  end

end
