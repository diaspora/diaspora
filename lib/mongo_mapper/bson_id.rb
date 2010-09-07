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
