describe("app.views.LikesInfo", function(){
  beforeEach(function(){
    loginAs({id : -1, name: "alice", avatar : {small : "http://avatar.com/photo.jpg"}});

    Diaspora.I18n.loadLocale({stream : {
      pins : {
        zero : "<%= count %> Pins",
        one : "<%= count %> Pin"}
      }
    })

    var posts = $.parseJSON(spec.readFixture("stream_json"));
    this.post = new app.models.Post(posts[0]); // post with a like
    this.view = new app.views.LikesInfo({model: this.post});
  });

  describe(".render", function(){
    it("displays a the like count if it is above zero", function() {
      this.view.render();
      this.view.model.set({"likes_count" : 1})

      expect($(this.view.el).find(".expand_likes").length).toBe(1)
    })

    it("does not display the like count if it is zero", function() {
      this.post.save({likes_count : 0});
      this.view.render();

      expect($(this.view.el).html().trim()).toBe("");
    })

    it("fires on a model change", function(){
      spyOn(this.view, "postRenderTemplate")
      this.view.model.trigger('expandedLikes')
      expect(this.view.postRenderTemplate).toHaveBeenCalled()
    })
  })

  describe("showAvatars", function(){
    beforeEach(function(){
      spyOn(this.post.likes, "fetch").andCallThrough()
    })

    it("calls fetch on the model's like collection", function(){
      this.view.showAvatars();
      expect(this.post.likes.fetch).toHaveBeenCalled();
    })

    it("sets the fetched response to the model's likes", function(){
      //placeholder... not sure how to test done functionalty here
    })

    it("re-renders the view", function(){
      //placeholder... not sure how to test done functionalty here
    })
  })
})

