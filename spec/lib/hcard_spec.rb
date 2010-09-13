#    Copyright 2010 Diaspora Inc.
#
#    This file is part of Diaspora.
#
#    Diaspora is free software: you can redistribute it and/or modify
#    it under the terms of the GNU Affero General Public License as published by
#    the Free Software Foundation, either version 3 of the License, or
#    (at your option) any later version.
#
#    Diaspora is distributed in the hope that it will be useful,
#    but WITHOUT ANY WARRANTY; without even the implied warranty of
#    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#    GNU Affero General Public License for more details.
#
#    You should have received a copy of the GNU Affero General Public License
#    along with Diaspora.  If not, see <http://www.gnu.org/licenses/>.
#



require File.dirname(__FILE__) + '/../spec_helper'
require File.dirname(__FILE__) + '/../../lib/hcard'

describe HCard do
  it 'should retreive and parse an hcard' do
    f = Redfinger.finger('tom@tom.joindiaspora.com')
    hcard = HCard.find f.hcard.first[:href]
    hcard[:family_name].include?("Hamiltom").should be true
    hcard[:given_name].include?("Alex").should be true
    hcard[:url].should  == "http://tom.joindiaspora.com/"
  end
end
