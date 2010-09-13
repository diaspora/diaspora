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



#package :mongo, :provides => :database do
#  description 'Mongodb'
#	version '1.4.3'
#	source "http://downloads.mongodb.org/src/mongodb-src-r#{version}.tar.gz"
#end

package :mongodb, :provides => :database do
  description 'Mongodb debian package.'
	version '1.4.3'

  binary "http://downloads.mongodb.org/linux/mongodb-linux-x86_64-static-legacy-#{version}.tgz" do
		post :install, "ln -s -f /usr/local/bin/mongodb-linux-x86_64-static-#{version}/bin/mongod /usr/bin/mongod"  
	end
end

package :mongo_driver do
  description 'Ruby mongo database driver'
  gem 'mongo'
	gem 'bson'
	gem 'bson_ext'
	requires :rubygems
end
