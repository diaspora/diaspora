describe("app.views.Comment", function(){
  beforeEach(function(){
    this.comment = factory.comment()
    this.view = new app.views.Comment({model : this.comment})
  })

  describe("render", function(){
    it("has a delete link if the author is the current user", function(){
      loginAs(this.comment.get("author"))
      expect(this.view.render().$('.delete').length).toBe(1)
    })

    it("doesn't have a delete link if the author is not the current user", function(){
      loginAs(_.extend(this.comment.get("author"), {diaspora_id : "notbob@bob.com"})
      expect(this.view.render().$('.delete').length).toBe(0)
    })

    it("doesn't have a delete link if the user is logged out", function(){
      logout()
      expect(this.view.render().$('.delete').length).toBe(0)
    })
  })

  describe("ownComment", function(){
    it("returns true if the author diaspora_id == the current user's diaspora_id", function(){
      loginAs(this.comment.get("author"))
      expect(this.view.ownComment()).toBe(true)
    })

    it("returns false if the author diaspora_id != the current user's diaspora_id", function(){
      loginAs(_.extend(this.comment.get("author"), {diaspora_id : "notbob@bob.com"})
      expect(this.view.ownComment()).toBe(false);
    })

    it("returns false if the user is not logged in", function(){
      logout()
      expect(this.view.ownComment()).toBe(false);
    })
  })
})
