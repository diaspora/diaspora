#   Copyright (c) 2010, Diaspora Inc.  This file is
#   licensed under the Affero General Public License version 3.  See
#   the COPYRIGHT file.

class String
  def to_id
    BSON::ObjectId self
  end
end
class BSON::ObjectId
  def to_id
    self
  end
end
