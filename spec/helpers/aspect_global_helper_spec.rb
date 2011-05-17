#   Copyright (c) 2010, Diaspora Inc.  This file is
#   licensed under the Affero General Public License version 3 or later.  See
#   the COPYRIGHT file.

require 'spec_helper'

describe AspectGlobalHelper do
  before do
    @user = alice
		@aspect1 = @user.aspects.first
		@aspect2 = @user.aspects.create(:name => "Crackers")
		@aspect3 = @user.aspects.create(:name => "Hackers")
		@aspect4 = @user.aspects.create(:name => "Phreaks")
  end

	describe "#aspect_badges" do
		before do
			@all_aspects = @user.aspects
		end

		it "returns a single badge for all aspects" do
			string = "<span class='aspect_badge single'>"
			string << link_to('All Aspects', aspects_path, :class => 'hard_aspect_link').html_safe
			string << "</span>"
			aspect_badges(@user.aspects).should == string
		end

		it "returns badges for individual aspects when aspects are changed" do
		    post = @user.post :status_message, :text => "hello", :to => @user.aspects
			@user.aspects.destroy(@user.aspects.find_by_name("Phreaks")[:id])
			@user.aspects.create(:name => "Geeks")
			some_aspects = [@aspect1, @aspect2, @aspect3]
			string = ""
			some_aspects.each do |aspect|
				string << "<span class='aspect_badge single'>"
				string << link_for_aspect(aspect).html_safe
				string << "</span>"
			end
			aspect_badges(post.aspects, :link => true).should == string
		end

		it "returns badges for individual aspects" do
			some_aspects = [@aspect2, @aspect3]
			string = ""
			some_aspects.each do |aspect|
				string << "<span class='aspect_badge single'>"
				string << link_for_aspect(aspect).html_safe
				string << "</span>"
			end	
			aspect_badges(some_aspects, :link => true).should == string
		end
	end
end
