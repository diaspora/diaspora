class Object
  def id
    raise "You have called id on a non-ActiveRecord object."
  end
end
