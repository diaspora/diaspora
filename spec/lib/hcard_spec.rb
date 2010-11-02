#   Copyright (c) 2010, Diaspora Inc.  This file is
#   licensed under the Affero General Public License version 3 or later.  See
#   the COPYRIGHT file.

require 'spec_helper'
require File.join(Rails.root, 'lib/hcard')

describe HCard do
  it 'should parse an hcard' do
    raw_hcard = hcard_response 
    hcard = HCard.build raw_hcard
    hcard[:family_name].include?("Hamiltom").should be true
    hcard[:given_name].include?("Alex").should be true
    hcard[:photo].include?("tom.jpg").should be true
    hcard[:url].should  == "http://tom.joindiaspora.com/"
  end
end
