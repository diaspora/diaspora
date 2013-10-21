class BasePresenter
  def self.new(arg)
    return NilPresenter.new if arg.nil?
    super
  end

  def self.as_collection(collection, method=:as_json)
    collection.map{ |object| self.new(object).send(method) }
  end

  def initialize(presentable)
    @presentable = presentable
  end

  def method_missing(method, *args)
    @presentable.send(method, *args) if @presentable.respond_to?(method)
  end

  class NilPresenter
    def method_missing(method, *args)
      nil
    end
  end
end
