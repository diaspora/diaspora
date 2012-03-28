describe("app.views.Post.Day", function(){
  beforeEach(function(){
    this.post = factory.post()
    this.view = new app.views.Post.Day({model : this.post})
  })

  describe("rendering", function(){
    it("is happy", function(){
      this.view.render()
    })

    describe("when the body is under 200 characters", function(){
      it("has class shortBody", function(){
        this.post.set({text : "Headline\nLol this is a short body"})
        this.view.render()
        expect(this.view.$("section.body")).toHaveClass("short_body")
      })
    })

    describe("when the body is over 200 characters", function(){
      it("has doesn't have headline", function(){
        this.post.set({text :"HEADLINE\nVegan bushwick tempor labore. Nulla seitan anim, aesthetic ex gluten-free viral" +
          "thundercats street art. Occaecat carles deserunt lomo messenger bag wes anderson. Narwhal cray selvage " +
          "dolor. Mixtape wes anderson american apparel, mustache readymade cred nulla squid veniam small batch id " +
          "cupidatat. Pork belly high life consequat, raw denim sint terry richardson seitan single-origin coffee " +
          "butcher. Sint yr fugiat cillum."
        })

        this.view.render()
        expect(this.view.$("section.body")).not.toHaveClass("short_body")
      })
    })
  })
})
