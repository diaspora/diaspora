require File.dirname(__FILE__) + '/../spec_helper'
 
describe PeopleController do
  render_views
  before do
    @user = Factory.create(:user, :profile => Profile.new( :first_name => "bob", :last_name => "smith"))
    request.env['warden'] = mock_model(Warden, :authenticate? => @user, :authenticate! => @user, :authenticate => @user)

    sign_in :user, @user   
  end

  it "index should yield search results for substring of person name" do
    friend_one = Factory.create(:person)
    friend_two = Factory.create(:person)
    friend_three = Factory.create(:person)
    friend_four = Factory.create(:person)

    friend_one.profile.first_name = "Robert"
    friend_one.profile.last_name = "Grimm"
    friend_one.profile.save

    friend_two.profile.first_name = "Eugene"
    friend_two.profile.last_name = "Weinstein"
    friend_two.save

    friend_three.profile.first_name = "Yevgeniy"
    friend_three.profile.last_name = "Dodis"
    friend_three.save

    friend_four.profile.first_name = "Casey"
    friend_four.profile.last_name = "Grippi"
    friend_four.save


    puts Person.friends.count

    get :index, :q => "Eu"


    assigns[:people].include?(friend_two).should == true
    assigns[:people].include?(friend_one).should == false
    assigns[:people].include?(friend_three).should == false
    assigns[:people].include?(friend_four).should == false

    get :index, :q => "Wei"
    assigns[:people].include?(friend_two).should == true
    assigns[:people].include?(friend_one).should == false
    assigns[:people].include?(friend_three).should == false
    assigns[:people].include?(friend_four).should == false

    get :index, :q => "Gri"
    assigns[:people].include?(friend_one).should == true
    assigns[:people].include?(friend_four).should == true
    assigns[:people].include?(friend_two).should == false
    assigns[:people].include?(friend_three).should == false

    get :index
    assigns[:people].should == Person.friends.all
  end

end
