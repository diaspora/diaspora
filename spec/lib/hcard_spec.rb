#   Copyright (c) 2010-2011, Diaspora Inc.  This file is
#   licensed under the Affero General Public License version 3 or later.  See
#   the COPYRIGHT file.

require 'spec_helper'

describe HCard do
  it 'should parse an hcard' do
    raw_hcard = hcard_response 
    hcard = HCard.build raw_hcard
    hcard[:family_name].include?("Hamiltom").should be true
    hcard[:given_name].include?("Alex").should be true
    hcard[:photo].include?("thumb_large").should be true
    hcard[:photo_medium].include?("thumb_medium").should be true
    hcard[:photo_small].include?("thumb_small").should be true
    hcard[:url].should == "http://localhost:3000/"
    hcard[:searchable].should == "false"
  end
end
