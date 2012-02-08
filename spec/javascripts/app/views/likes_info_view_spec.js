describe("app.views.LikesInfo", function(){
  beforeEach(function(){
    loginAs({id : -1, name: "alice", avatar : {small : "http://avatar.com/photo.jpg"}});

    Diaspora.I18n.loadLocale({stream : {
      likes : {
        zero : "<%= count %> Likes",
        one : "<%= count %> Like"}
      }
    })

    var posts = $.parseJSON(spec.readFixture("explore_json"))["posts"];
    this.post = new app.models.Post(posts[0]); // post with a like
    this.view = new app.views.LikesInfo({model: this.post});
  });

  describe(".render", function(){
    it("displays a the like count if it is above zero", function() {
      this.view.render();

      expect($(this.view.el).text()).toContain(Diaspora.I18n.t('stream.likes', {count : this.view.model.get("likes_count")}))
    })

    it("does not display the like count if it is zero", function() {
      this.post.save({likes_count : 0});
      this.view.render();

      expect($(this.view.el).html().trim()).toBe("");
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

