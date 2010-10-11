#   Copyright (c) 2010, Diaspora Inc.  This file is
#   licensed under the Affero General Public License version 3 or later.  See
#   the COPYRIGHT file.

class String
  def to_id
    begin
      BSON::ObjectId self
    rescue
      nil
    end
  end
end
class BSON::ObjectId
  def to_id
    self
  end
end
