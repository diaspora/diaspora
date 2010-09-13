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


class StatusMessage < Post
  
  xml_name :status_message
  xml_accessor :message

  key :message, String
  validates_presence_of :message
  
  
  def to_activity
        <<-XML
  <entry>
  <activity:verb>http://activitystrea.ms/schema/1.0/post</activity:verb>
  <title>#{self.message}</title>
  <link rel="alternate" type="text/html" href="#{person.url}status_messages/#{self.id}"/>
  <id>#{person.url}status_messages/#{self.id}</id>
  <published>#{self.created_at.xmlschema}</published>
  <updated>#{self.updated_at.xmlschema}</updated>
  </entry>
        XML
  end
  
  def latest_hash
    { :text => message}
  end
end

