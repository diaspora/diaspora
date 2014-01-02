class BasePresenter
  attr_accessor :current_user

  def self.new(*args)
    return NilPresenter.new if args[0].nil?
    super *args
  end

  def self.as_collection(collection, method=:as_json, *args)
    collection.map{ |object| self.new(object, *args).send(method) }
  end

  def initialize(presentable, curr_user=nil)
    @presentable = presentable
    @current_user = curr_user
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
