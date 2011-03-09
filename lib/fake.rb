class PostsFake
  attr_reader :people_hash, :post_fakes
  delegate :length, :each, :to_ary, :to => :post_fakes

  def initialize(posts)
    author_ids = []
    posts.each do |p|
      author_ids << p.author_id
      p.comments.each do |c|
        author_ids << c.author_id
      end
    end

    people = Person.where(:id => author_ids).includes(:profile)
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

    def author
      @fakes_collection.people_hash[@model.author_id]
    end

    def method_missing(method, *args)
      @model.send(method, *args)
    end
  end
end
