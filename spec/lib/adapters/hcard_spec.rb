#   Copyright (c) 2010-2011, Diaspora Inc.  This file is
#   licensed under the Affero General Public License version 3 or later.  See
#   the COPYRIGHT file.

require 'spec_helper'

describe Adapters::HCard do
  it 'should parse an hcard' do
    raw_hcard = hcard_response
    hcard = Adapters::HCard.build raw_hcard
    expect(hcard.last_name.include?("Hamiltom")).to be true
    expect(hcard.first_name.include?("Alex")).to be true
    expect(hcard.photo_full_url.include?("thumb_large")).to be true
    expect(hcard.photo_medium_url.include?("thumb_medium")).to be true
    expect(hcard.photo_small_url.include?("thumb_small")).to be true
    expect(hcard.url).to eq("http://localhost:3000/")
    expect(hcard.searchable).to eq("false")
  end
end
