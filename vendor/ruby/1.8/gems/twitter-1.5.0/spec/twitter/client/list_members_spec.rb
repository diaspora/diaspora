require 'helper'

describe Twitter::Client do
  Twitter::Configuration::VALID_FORMATS.each do |format|
    context ".new(:format => '#{format}')" do
      before do
        @client = Twitter::Client.new(:format => format, :consumer_key => 'CK', :consumer_secret => 'CS', :oauth_token => 'OT', :oauth_token_secret => 'OS')
      end

      describe ".list_members" do

        context "with screen name" do

          before do
            stub_get("lists/members.#{format}").
              with(:query => {:owner_screen_name => 'sferik', :slug => 'presidents', :cursor => "-1"}).
              to_return(:body => fixture("users_list.#{format}"), :headers => {:content_type => "application/#{format}; charset=utf-8"})
          end

          it "should get the correct resource" do
            @client.list_members("sferik", "presidents")
            a_get("lists/members.#{format}").
              with(:query => {:owner_screen_name => 'sferik', :slug => 'presidents', :cursor => "-1"}).
              should have_been_made
          end

          it "should return the members of the specified list" do
            users_list = @client.list_members("sferik", "presidents")
            users_list.users.should be_an Array
            users_list.users.first.name.should == "Erik Michaels-Ober"
          end

        end

        context "with an Integer user_id passed" do

          before do
            stub_get("lists/members.#{format}").
              with(:query => {:owner_id => '12345678', :slug => 'presidents', :cursor => "-1"}).
              to_return(:body => fixture("users_list.#{format}"), :headers => {:content_type => "application/#{format}; charset=utf-8"})
          end

          it "should get the correct resource" do
            @client.list_members(12345678, 'presidents')
            a_get("lists/members.#{format}").
              with(:query => {:owner_id => '12345678', :slug => 'presidents', :cursor => "-1"}).
              should have_been_made
          end

        end

        context "without screen name" do

          before do
            @client.stub!(:get_screen_name).and_return('sferik')
            stub_get("lists/members.#{format}").
              with(:query => {:owner_screen_name => 'sferik', :slug => 'presidents', :cursor => "-1"}).
              to_return(:body => fixture("users_list.#{format}"), :headers => {:content_type => "application/#{format}; charset=utf-8"})
          end

          it "should get the correct resource" do
            @client.list_members("presidents")
            a_get("lists/members.#{format}").
              with(:query => {:owner_screen_name => 'sferik', :slug => 'presidents', :cursor => "-1"}).
              should have_been_made
          end

        end

      end

      describe ".list_add_member" do

        context "with screen name passed" do

          before do
            stub_post("lists/members/create.#{format}").
              with(:body => {:owner_screen_name => 'sferik', :slug => 'presidents', :user_id => "813286"}).
              to_return(:body => fixture("list.#{format}"), :headers => {:content_type => "application/#{format}; charset=utf-8"})
          end

          it "should get the correct resource" do
            @client.list_add_member("sferik", "presidents", 813286)
            a_post("lists/members/create.#{format}").
              with(:body => {:owner_screen_name => 'sferik', :slug => 'presidents', :user_id => "813286"}).
              should have_been_made
          end

          it "should return the list" do
            list = @client.list_add_member("sferik", "presidents", 813286)
            list.name.should == "presidents"
          end

        end

        context "with an Integer user_id passed" do

          before do
            stub_post("lists/members/create.#{format}").
              with(:body => {:owner_id => '12345678', :slug => 'presidents', :user_id => "813286"}).
              to_return(:body => fixture("users_list.#{format}"), :headers => {:content_type => "application/#{format}; charset=utf-8"})
          end

          it "should get the correct resource" do
            @client.list_add_member(12345678, 'presidents', 813286)
            a_post("lists/members/create.#{format}").
              with(:body => {:owner_id => '12345678', :slug => 'presidents', :user_id => "813286"}).
              should have_been_made
          end

        end

        context "with an Integer list_id passed" do

          before do
            stub_post("lists/members/create.#{format}").
              with(:body => {:owner_screen_name => 'sferik', :list_id => '12345678', :user_id => "813286"}).
              to_return(:body => fixture("users_list.#{format}"), :headers => {:content_type => "application/#{format}; charset=utf-8"})
          end

          it "should get the correct resource" do
            @client.list_add_member('sferik', 12345678, 813286)
            a_post("lists/members/create.#{format}").
              with(:body => {:owner_screen_name => 'sferik', :list_id => '12345678', :user_id => "813286"}).
              should have_been_made
          end

        end

        context "without screen name passed" do

          before do
            @client.stub!(:get_screen_name).and_return('sferik')
            stub_post("lists/members/create.#{format}").
              with(:body => {:owner_screen_name => 'sferik', :slug => 'presidents', :user_id => "813286"}).
              to_return(:body => fixture("list.#{format}"), :headers => {:content_type => "application/#{format}; charset=utf-8"})
          end

          it "should get the correct resource" do
            @client.list_add_member("presidents", 813286)
            a_post("lists/members/create.#{format}").
              with(:body => {:owner_screen_name => 'sferik', :slug => 'presidents', :user_id => "813286"}).
              should have_been_made
          end

        end

      end

      describe ".list_add_members" do

        context "with screen name passed" do

          before do
            stub_post("lists/members/create_all.#{format}").
              with(:body => {:owner_screen_name => 'sferik', :slug => 'presidents', :user_id => "813286,18755393"}).
              to_return(:body => fixture("list.#{format}"), :headers => {:content_type => "application/#{format}; charset=utf-8"})
          end

          it "should get the correct resource" do
            @client.list_add_members("sferik", "presidents", [813286, 18755393])
            a_post("lists/members/create_all.#{format}").
              with(:body => {:owner_screen_name => 'sferik', :slug => 'presidents', :user_id => "813286,18755393"}).
              should have_been_made
          end

          it "should return the list" do
            list = @client.list_add_members("sferik", "presidents", [813286, 18755393])
            list.name.should == "presidents"
          end

        end

        context "with an Integer user_id passed" do

          before do
            stub_post("lists/members/create_all.#{format}").
              with(:body => {:owner_id => '12345678', :slug => 'presidents', :user_id => "813286,18755393"}).
              to_return(:body => fixture("list.#{format}"), :headers => {:content_type => "application/#{format}; charset=utf-8"})
          end

          it "should get the correct resource" do
            @client.list_add_members(12345678, "presidents", [813286, 18755393])
            a_post("lists/members/create_all.#{format}").
              with(:body => {:owner_id => '12345678', :slug => 'presidents', :user_id => "813286,18755393"}).
              should have_been_made
          end

        end

        context "with an Integer list_id passed" do

          before do
            stub_post("lists/members/create_all.#{format}").
              with(:body => {:owner_screen_name => 'sferik', :list_id => '12345678', :user_id => "813286,18755393"}).
              to_return(:body => fixture("list.#{format}"), :headers => {:content_type => "application/#{format}; charset=utf-8"})
          end

          it "should get the correct resource" do
            @client.list_add_members('sferik', 12345678, [813286, 18755393])
            a_post("lists/members/create_all.#{format}").
              with(:body => {:owner_screen_name => 'sferik', :list_id => '12345678', :user_id => "813286,18755393"}).
              should have_been_made
          end

        end

        context "with a combination of member IDs and member screen names to add" do

          before do
            stub_post("lists/members/create_all.#{format}").
              with(:body => {:owner_screen_name => 'sferik', :slug => 'presidents', :user_id => "813286,18755393", :screen_name => "pengwynn,erebor"}).
              to_return(:body => fixture("list.#{format}"), :headers => {:content_type => "application/#{format}; charset=utf-8"})
          end

          it "should get the correct resource" do
            @client.list_add_members('sferik', 'presidents', [813286, 'pengwynn', 18755393, 'erebor'])
            a_post("lists/members/create_all.#{format}").
              with(:body => {:owner_screen_name => 'sferik', :slug => 'presidents', :user_id => "813286,18755393", :screen_name => "pengwynn,erebor"}).
              should have_been_made
          end

        end

        context "without screen name passed" do

          before do
            @client.stub!(:get_screen_name).and_return('sferik')
            stub_post("lists/members/create_all.#{format}").
              with(:body => {:owner_screen_name => 'sferik', :slug => 'presidents', :user_id => "813286,18755393"}).
              to_return(:body => fixture("list.#{format}"), :headers => {:content_type => "application/#{format}; charset=utf-8"})
          end

          it "should get the correct resource" do
            @client.list_add_members("presidents", [813286, 18755393])
            a_post("lists/members/create_all.#{format}").
              with(:body => {:owner_screen_name => 'sferik', :slug => 'presidents', :user_id => "813286,18755393"}).
              should have_been_made
          end

        end

      end

      describe ".list_remove_member" do

        context "with screen name passed" do

          before do
            stub_post("lists/members/destroy.#{format}").
              with(:body => {:owner_screen_name => 'sferik', :slug => 'presidents', :user_id => "813286"}).
              to_return(:body => fixture("list.#{format}"), :headers => {:content_type => "application/#{format}; charset=utf-8"})
          end

          it "should get the correct resource" do
            @client.list_remove_member("sferik", "presidents", 813286)
            a_post("lists/members/destroy.#{format}").
              with(:body => {:owner_screen_name => 'sferik', :slug => 'presidents', :user_id => "813286"}).
              should have_been_made
          end

          it "should return the list" do
            list = @client.list_remove_member("sferik", "presidents", 813286)
            list.name.should == "presidents"
          end

        end

        context "with an Integer user_id passed" do

          before do
            stub_post("lists/members/destroy.#{format}").
              with(:body => {:owner_id => '12345678', :slug => 'presidents', :user_id => "813286"}).
              to_return(:body => fixture("list.#{format}"), :headers => {:content_type => "application/#{format}; charset=utf-8"})
          end

          it "should get the correct resource" do
            @client.list_remove_member(12345678, "presidents", 813286)
            a_post("lists/members/destroy.#{format}").
              with(:body => {:owner_id => '12345678', :slug => 'presidents', :user_id => "813286"}).
              should have_been_made
          end

        end

        context "with an Integer list_id passed" do

          before do
            stub_post("lists/members/destroy.#{format}").
              with(:body => {:owner_screen_name => 'sferik', :list_id => '12345678', :user_id => "813286"}).
              to_return(:body => fixture("list.#{format}"), :headers => {:content_type => "application/#{format}; charset=utf-8"})
          end

          it "should get the correct resource" do
            @client.list_remove_member('sferik', 12345678, 813286)
            a_post("lists/members/destroy.#{format}").
              with(:body => {:owner_screen_name => 'sferik', :list_id => '12345678', :user_id => "813286"}).
              should have_been_made
          end

        end

        context "with a screen name to remove" do

          before do
            stub_post("lists/members/destroy.#{format}").
              with(:body => {:owner_screen_name => 'sferik', :slug => 'presidents', :screen_name => "erebor"}).
              to_return(:body => fixture("list.#{format}"), :headers => {:content_type => "application/#{format}; charset=utf-8"})
          end

          it "should get the correct resource" do
            @client.list_remove_member('sferik', 'presidents', 'erebor')
            a_post("lists/members/destroy.#{format}").
              with(:body => {:owner_screen_name => 'sferik', :slug => 'presidents', :screen_name => "erebor"}).
              should have_been_made
          end

        end

        context "without screen name passed" do

          before do
            @client.stub!(:get_screen_name).and_return('sferik')
            stub_post("lists/members/destroy.#{format}").
              with(:body => {:owner_screen_name => 'sferik', :slug => 'presidents', :user_id => "813286"}).
              to_return(:body => fixture("list.#{format}"), :headers => {:content_type => "application/#{format}; charset=utf-8"})
          end

          it "should get the correct resource" do
            @client.list_remove_member("presidents", 813286)
            a_post("lists/members/destroy.#{format}").
              with(:body => {:owner_screen_name => 'sferik', :slug => 'presidents', :user_id => "813286"}).
              should have_been_made
          end

        end

      end

      describe ".is_list_member?" do

        context "with screen name passed" do

          before do
            stub_get("lists/members/show.#{format}").
              with(:query => {:owner_screen_name => 'sferik', :slug => 'presidents', :user_id => '813286'}).
              to_return(:body => fixture("list.#{format}"), :headers => {:content_type => "application/#{format}; charset=utf-8"})
            stub_get("lists/members/show.#{format}").
              with(:query => {:owner_screen_name => 'sferik', :slug => 'presidents', :user_id => '65493023'}).
              to_return(:body => fixture("not_found.#{format}"), :status => 404, :headers => {:content_type => "application/#{format}; charset=utf-8"})
            stub_get("lists/members/show.#{format}").
              with(:query => {:owner_screen_name => 'sferik', :slug => 'presidents', :user_id => '12345678'}).
              to_return(:body => fixture("not_found.#{format}"), :status => 403, :headers => {:content_type => "application/#{format}; charset=utf-8"})
          end

          it "should get the correct resource" do
            @client.is_list_member?("sferik", "presidents", 813286)
            a_get("lists/members/show.#{format}").
              with(:query => {:owner_screen_name => 'sferik', :slug => 'presidents', :user_id => '813286'}).
              should have_been_made
          end

          it "should return true if user is a list member" do
            is_list_member = @client.is_list_member?("sferik", "presidents", 813286)
            is_list_member.should be_true
          end

          it "should return false if user is not a list member" do
            is_list_member = @client.is_list_member?("sferik", "presidents", 65493023)
            is_list_member.should be_false
          end

          it "should return false if user does not exist" do
            is_list_member = @client.is_list_member?("sferik", "presidents", 12345678)
            is_list_member.should be_false
          end

        end

        context "with an Integer owner_id passed" do

          before do
            stub_get("lists/members/show.#{format}").
              with(:query => {:owner_id => '12345678', :slug => 'presidents', :user_id => '813286'}).
              to_return(:body => fixture("list.#{format}"), :headers => {:content_type => "application/#{format}; charset=utf-8"})
          end

          it "should get the correct resource" do
            @client.is_list_member?(12345678, "presidents", 813286)
            a_get("lists/members/show.#{format}").
              with(:query => {:owner_id => '12345678', :slug => 'presidents', :user_id => '813286'}).
              should have_been_made
          end

        end

        context "with an Integer list_id passed" do

          before do
            stub_get("lists/members/show.#{format}").
              with(:query => {:owner_screen_name => 'sferik', :list_id => '12345678', :user_id => '813286'}).
              to_return(:body => fixture("list.#{format}"), :headers => {:content_type => "application/#{format}; charset=utf-8"})
          end

          it "should get the correct resource" do
            @client.is_list_member?('sferik', 12345678, 813286)
            a_get("lists/members/show.#{format}").
              with(:query => {:owner_screen_name => 'sferik', :list_id => '12345678', :user_id => '813286'}).
              should have_been_made
          end

        end

        context "with screen name passed for user_to_check" do

          before do
            stub_get("lists/members/show.#{format}").
              with(:query => {:owner_screen_name => 'sferik', :slug => 'presidents', :screen_name => 'erebor'}).
              to_return(:body => fixture("list.#{format}"), :headers => {:content_type => "application/#{format}; charset=utf-8"})
          end

          it "should get the correct resource" do
            @client.is_list_member?("sferik", "presidents", 'erebor')
            a_get("lists/members/show.#{format}").
              with(:query => {:owner_screen_name => 'sferik', :slug => 'presidents', :screen_name => 'erebor'}).
              should have_been_made
          end

        end

        context "without screen name passed" do

          before do
            @client.stub!(:get_screen_name).and_return('sferik')
            stub_get("lists/members/show.#{format}").
              with(:query => {:owner_screen_name => 'sferik', :slug => 'presidents', :user_id => '813286'}).
              to_return(:body => fixture("list.#{format}"), :headers => {:content_type => "application/#{format}; charset=utf-8"})
          end

          it "should get the correct resource" do
            @client.is_list_member?("presidents", 813286)
            a_get("lists/members/show.#{format}").
              with(:query => {:owner_screen_name => 'sferik', :slug => 'presidents', :user_id => '813286'}).
              should have_been_made
          end

        end

      end
    end
  end
end
