#   Copyright (c) 2010-2011, Diaspora Inc.  This file is
#   licensed under the Affero General Public License version 3 or later.  See
#   the COPYRIGHT file.

require 'spec_helper'

describe ApplicationHelper do
  before do
    @user = alice
    @person = Factory(:person)
  end

  describe "#contacts_link" do
    before do
      def current_user
        @current_user
      end
    end

    it 'links to community spotlight' do
      @current_user = Factory(:user)
      contacts_link.should == community_spotlight_path
    end

    it 'links to contacts#index' do
      @current_user = alice
      contacts_link.should == contacts_path
    end
  end

  describe "#all_services_connected?" do
    before do
      AppConfig[:configured_services] = [1, 2, 3]

      def current_user
        @current_user
      end
      @current_user = alice
    end

    it 'returns true if all networks are connected' do
      3.times { |t| @current_user.services << Factory.build(:service) }
      all_services_connected?.should be_true
    end

    it 'returns false if not all networks are connected' do
      @current_user.services.delete_all
      all_services_connected?.should be_false
    end
  end
end
