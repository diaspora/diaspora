#   Copyright (c) 2010, Diaspora Inc.  This file is
#   licensed under the Affero General Public License version 3 or later.  See
#   the COPYRIGHT file.

#package :mongo, :provides => :database do
#  description 'Mongodb'
#  version '1.4.3'
#  source "http://downloads.mongodb.org/src/mongodb-src-r#{version}.tar.gz"
#end

package :mongodb, :provides => :database do
  description 'Mongodb binary.'
  version '1.6.3'
  binary "http://fastdl.mongodb.org/linux/mongodb-linux-x86_64-static-legacy-#{version}.tgz" do
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
