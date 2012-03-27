class BasePresenter
  def self.as_collection(collection)
    collection.map{|object| self.new(object).as_json}
  end
end
