describe("app.views.TagFollowingAction", function(){
  beforeEach(function(){
    app.tagFollowings = new app.collections.TagFollowings();
    this.tagName = "test_tag";
    this.view = new app.views.TagFollowingAction({tagName : this.tagName})
  })

  describe("render", function(){
    it("shows the output of followString", function(){
      spyOn(this.view, "tag_is_followed").and.returnValue(false)
      spyOn(this.view, "followString").and.returnValue("a_follow_string")
      expect(this.view.render().$('input').val()).toMatch(/^a_follow_string$/)
    })

    it("should have the extra classes if the tag is followed", function(){
      spyOn(this.view, "tag_is_followed").and.returnValue(true)
      expect(this.view.render().$('input').hasClass("red_on_hover")).toBe(true)
      expect(this.view.render().$('input').hasClass("in_aspects")).toBe(true)
    })
  })

  describe("tagAction", function(){
    it("toggles the tagFollowed from followed to unfollowed", function(){
      // first set the tag to followed
      var origModel = this.view.model;
      this.view.model.set("id", 3);

      expect(this.view.tag_is_followed()).toBe(true);
      spyOn(this.view.model, "destroy").and.callFake(_.bind(function(){
        // model.destroy leads to collection.remove, which is bound to getTagFollowing
        this.view.getTagFollowing();
      }, this) )
      this.view.tagAction();
      expect(origModel.destroy).toHaveBeenCalled()

      expect(this.view.tag_is_followed()).toBe(false);
    })


    it("toggles the tagFollowed from unfollowed to followed", function(){
      expect(this.view.tag_is_followed()).toBe(false);
      spyOn(app.tagFollowings, "create").and.callFake(function(model){
        // 'save' the model by giving it an id
        model.set("id", 3)
      })
      this.view.tagAction();
      expect(this.view.tag_is_followed()).toBe(true);
    })
  })
})
