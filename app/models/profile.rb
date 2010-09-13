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


class Profile
  include MongoMapper::EmbeddedDocument
  require 'lib/diaspora/webhooks'
  include Diaspora::Webhooks
  include ROXML

  xml_reader :person_id
  xml_accessor :first_name
  xml_accessor :last_name
  xml_accessor :image_url

  key :first_name, String
  key :last_name,  String
  key :image_url,  String

  validates_presence_of :first_name, :last_name

  def person_id
    self._parent_document.id
  end
  
  def person
    self._parent_document
  end

end
