describe("app.views.Stream", function(){

  describe("#render", function(){
    beforeEach(function(){
      // should be jasmine helper
      window.current_user = app.user({name: "alice", avatar : {small : "http://avatar.com/photo.jpg"}});

      var posts = $.parseJSON(spec.readFixture("multi_stream_json"))["posts"];

      this.collection = new app.collections.Stream(posts);
      this.statusMessage = this.collection.models[0];
      this.reshare = this.collection.models[1];

      this.view = new app.views.Stream({collection : this.collection});

      // do this manually because we've moved loadMore into render??
      this.view.render();
      _.each(this.view.collection.models, function(post){
        this.view.addPost(post);
      }, this);

      this.statusElement = $(this.view.$("#" + this.statusMessage.get("guid")));
      this.reshareElement = $(this.view.$("#" + this.reshare.get("guid")));
    })

    context("when rendering a Status Mesasage", function(){
      it("shows the status message in the content area", function(){
        expect(this.statusElement.find(".post-content p").text()).toContain("you're gonna love this")
      })
    })
  })
})
