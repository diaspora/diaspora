#   Copyright (c) 2010, Diaspora Inc.  This file is
#   licensed under the Affero General Public License version 3 or later.  See
#   the COPYRIGHT file.

require 'spec_helper'
require File.join(Rails.root, 'lib/hcard')


describe HCard do
  it 'should retreive and parse an hcard' do
    stub_success("tom@tom.joindiaspora.com")
    f = Redfinger.finger('tom@tom.joindiaspora.com')
    hcard = HCard.find f.hcard.first[:href]
    hcard[:family_name].include?("Hamiltom").should be true
    hcard[:given_name].include?("Alex").should be true
    hcard[:url].should  == "http://tom.joindiaspora.com/"
  end
end
