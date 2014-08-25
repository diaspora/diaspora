#   Copyright (c) 2010-2011, Diaspora Inc.  This file is
#   licensed under the Affero General Public License version 3 or later.  See
#   the COPYRIGHT file.

require 'spec_helper'

describe MobileHelper, :type => :helper do
  
  describe "#aspect_select_options" do
    it "adds an all option to the list of aspects" do
      # options_from_collection_for_select(@aspects, "id", "name", @aspect.id)
      
      n = FactoryGirl.create(:aspect)
      
      options = aspect_select_options([n], n).split('\n')
      expect(options.first).to match(/All/)
    end
  end
end