class PostsFake
  attr_reader :people_hash, :post_fakes
  delegate :length, :each, :to_ary, :to => :post_fakes

  def initialize(posts)
    person_ids = []
    posts.each do |p|
      person_ids << p.person_id
      p.comments.each do |c|
        person_ids << c.person_id
      end
    end

    people = Person.where(:id => person_ids).includes(:profile)
    @people_hash = {}
    people.each{|person| @people_hash[person.id] = person}

    @post_fakes = posts.map do |post|
      f = Fake.new(post, self)
      f.comments = post.comments.map do |comment|
        Fake.new(comment, self)
      end
      f
    end
  end

  class Fake
    attr_accessor :comments
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

    def person
      @fakes_collection.people_hash[@model.person_id]
    end

    def method_missing(method, *args)
      @model.send(method, *args)
    end
  end
end
