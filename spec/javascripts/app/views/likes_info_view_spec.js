describe("app.views.LikesInfo", function(){
  beforeEach(function(){
    loginAs({id : -1, name: "alice", avatar : {small : "http://avatar.com/photo.jpg"}});
    var posts = $.parseJSON(spec.readFixture("stream_json"));
    this.post = new app.models.Post(posts[0]); // post with a like
    this.view = new app.views.LikesInfo({model: this.post});
  });

  describe(".render", function(){
    it("displays a the like count if it is above zero", function() {
      spyOn(this.view.model.interactions, "likesCount").and.returnValue(3);
      this.view.render();
      expect($(this.view.el).find(".expand-likes").length).toBe(1);
    });

    it("does not display the like count if it is zero", function() {
      spyOn(this.view.model.interactions, "likesCount").and.returnValue(0);
      this.view.render();
      expect($(this.view.el).html().trim()).toBe("");
    });

    it("fires on a model change", function(){
      spyOn(this.view, "postRenderTemplate");
      this.view.model.interactions.likes.trigger("change");
      expect(this.view.postRenderTemplate).toHaveBeenCalled();
    });
  });

  describe("showAvatars", function(){
    it("calls fetch on the model's like collection", function() {
      spyOn(this.post.interactions.likes, "fetch").and.callThrough();
      this.view.showAvatars();
      expect(this.post.interactions.likes.fetch).toHaveBeenCalled();
    });

    it("triggers 'change' on the likes collection", function() {
      spyOn(this.post.interactions.likes, "trigger");
      this.view.showAvatars();
      jasmine.Ajax.requests.mostRecent().respondWith({status: 200, responseText: "{\"id\": 1}"});
      expect(this.post.interactions.likes.trigger).toHaveBeenCalledWith("change");
    });

    it("sets 'displayAvatars' to true", function(){
      this.view.displayAvatars = false;
      this.view.showAvatars();
      expect(this.view.displayAvatars).toBeTruthy();
    });
  });
});
