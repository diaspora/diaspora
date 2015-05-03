#   Copyright (c) 2010-2011, Diaspora Inc.  This file is
#   licensed under the Affero General Public License version 3 or later.  See
#   the COPYRIGHT file.

require 'spec_helper'

describe HCard do
  it 'should parse an hcard' do
    raw_hcard = hcard_response 
    hcard = HCard.build raw_hcard
    expect(hcard[:family_name].include?("Hamiltom")).to be true
    expect(hcard[:given_name].include?("Alex")).to be true
    expect(hcard[:photo].include?("thumb_large")).to be true
    expect(hcard[:photo_medium].include?("thumb_medium")).to be true
    expect(hcard[:photo_small].include?("thumb_small")).to be true
    expect(hcard[:url]).to eq("http://localhost:3000/")
    expect(hcard[:searchable]).to eq("false")
  end
end
