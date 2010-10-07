#   Copyright (c) 2010, Diaspora Inc.  This file is
#   licensed under the Affero General Public License version 3 or later.  See
#   the COPYRIGHT file.


class FbStatus
  include MongoMapper::Document

  key :graph_id, String
  key :author_id, String
  key :author_name, String
  key :message, String
  key :updated_time, Time

  timestamps!

  validates_presence_of :graph_id,:author_id,:author_name,:message,:updated_time

  def self.from_api(hash)
    #just keeping them in memory for now
    self.new(
                  :graph_id     => hash['id'],
                  :author_id    => hash['from']['id'],
                  :author_name  => hash['from']['name'],
                  :message      => hash['message'],
                  :updated_time => Time.parse(hash['updated_time'])
            )
  end

end

