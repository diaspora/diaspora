describe("app.views.StreamFaces", function(){
  beforeEach(function(){
    var rebeccaBlack = factory.author({name : "Rebecca Black", id : 1492})
    this.post1 = factory.post({author : rebeccaBlack})
    this.post2 = factory.post({author : factory.author({name : "John Stamos", id : 1987})})
    this.post3 = factory.post({author : factory.author({name : "Michelle Tanner", id : 1986})})
    this.post4 = factory.post({author : factory.author({name : "Barack Obama", id : 2000})})
    this.post5 = factory.post({author : factory.author({name : "Obie-won Kenobie", id : 2020})})
    this.post6 = factory.post({author : rebeccaBlack})
    this.post7 = factory.post({author : rebeccaBlack})

    this.stream = new app.collections.Stream([this.post1, this.post2, this.post3, this.post4, this.post5, this.post6, this.post7]);
    this.view = new app.views.StreamFaces({collection : this.stream})
  })

  it("should take them unique", function(){
    this.view.render()
    expect(this.view.people.length).toBe(5)
  })

  it("findsPeople when the collection changes", function(){
    this.stream.add(factory.post({author : factory.author({name : "Harriet Tubman"})}))
    expect(this.view.people.length).toBe(6)
  })


  describe(".render", function(){
    beforeEach(function(){
      this.view.render()
    })

    it("appends the people's avatars", function(){
      expect(this.view.$("img").length).toBe(5)
    })

    it("links to the people", function(){
      expect(this.view.$("a").length).toBe(5)
    })

    it("rerenders when people are added, but caps to 15 people", function(){
      var posts = _.map(_.range(20), function(){ return factory.post()})
      this.stream.reset(posts) //add 20 posts silently to the collection
      this.stream.add(factory.post) //trigger an update
      expect(this.view.$("img").length).toBe(15)
    })
  })
})
