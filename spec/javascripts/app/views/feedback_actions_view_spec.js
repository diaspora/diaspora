describe("app.views.FeedbackActions", function(){
  beforeEach(function(){
    loginAs({id : -1, name: "alice", avatar : {small : "http://avatar.com/photo.jpg"}});

    this.post = new app.models.Post({
      "author": {
        "diaspora_id": "alice@localhost:3000"
      },
      "post_type": "Reshare",
      "public": true,
      "root": {
        "author":{"diaspora_id": null}
      }
    })

    this.view = new app.views.PostViewerFeedback({model: this.post})
  });

  describe("FeedbackActions", function(){
    it("reshares a post", function(){

      spyOn(window, "confirm").andReturn(true)
      spyOn(this.view.model.interactions, "reshare")

      this.view.render()

      this.view.$('.reshare').click()

      expect(this.view.model.interactions.reshare.callCount).toBe(1)
      expect(window.confirm.callCount).toBe(1)
    });

    it('cancels a reshare confirmation ', function(){
      spyOn(window, "confirm").andReturn(false)
      spyOn(this.view.model.interactions, "reshare")

      this.view.render()

      this.view.$('.reshare').click()

      expect(this.view.model.interactions.reshare).not.toHaveBeenCalled();
    });

    it("likes a post", function(){
      
      spyOn(this.view.model.interactions, "toggleLike")

      this.view.render()

      this.view.$('.like').click()

      expect(this.view.model.interactions.toggleLike.callCount).toBe(1)
    })
  })
})
