class PostsFake
  attr_reader :people_hash, :post_fakes
  delegate :length, :each, :to_ary, :last, :to => :post_fakes

  def initialize(posts)
    author_ids = []
    posts.each do |p|
      author_ids << p.author_id
    end

    people = Person.where(:id => author_ids).includes(:profile)
    @people_hash = {}
    people.each{|person| @people_hash[person.id] = person}

    @post_fakes = posts.map do |post|
      f = Fake.new(post, self)
      f
    end
  end

  def models
    self.post_fakes.map{|a| a.model }
  end

  class Fake
    attr_reader :model
    def initialize(model, fakes_collection)
      @fakes_collection = fakes_collection
      @model = model
    end

    def id
      @model.id
    end

    def to_s
      @model.id.to_s
    end

    def author
      @fakes_collection.people_hash[@model.author_id]
    end

    def respond_to?(*args)
      super(*args) || model.respond_to?(*args)
    end

    def method_missing(method, *args)
      @model.send(method, *args)
    end
  end
end
