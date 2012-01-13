describe("app.views.LikesInfo", function(){
  beforeEach(function(){
    loginAs({id : -1, name: "alice", avatar : {small : "http://avatar.com/photo.jpg"}});

    Diaspora.I18n.loadLocale({stream : {
      likes : {
        zero : "<%= count %> Likes",
        one : "<%= count %> Like"}
      }
    })

    var posts = $.parseJSON(spec.readFixture("multi_stream_json"))["posts"];
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
})

