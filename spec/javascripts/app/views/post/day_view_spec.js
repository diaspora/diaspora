describe("app.views.Post.Day", function(){
  beforeEach(function(){
    this.post = factory.post()
    this.view = new app.views.Post.Day({model : this.post})
  })

  describe("rendering", function(){
    it("is happy", function(){
      this.view.render()
    })

    describe("when the text is under 140 characters", function(){
      it("has class headline", function(){
        this.post.set({text : "Lol this is a short headline"})
        this.view.render()
        expect(this.view.$("section.text")).toHaveClass("headline")
      })
    })

    describe("when the text is over 140 characters", function(){
      it("has doesn't have headline", function(){
        this.post.set({text :"Vegan bushwick tempor labore. Nulla seitan anim, aesthetic ex gluten-free viral" +
          "thundercats street art. Occaecat carles deserunt lomo messenger bag wes anderson. Narwhal cray selvage " +
          "dolor. Mixtape wes anderson american apparel, mustache readymade cred nulla squid veniam small batch id " +
          "cupidatat. Pork belly high life consequat, raw denim sint terry richardson seitan single-origin coffee " +
          "butcher. Sint yr fugiat cillum."
        })

        this.view.render()
        expect(this.view.$("section.text")).not.toHaveClass("headline")
      })
    })
  })
})