describe("App.views.Stream", function(){

  describe("#render", function(){
    beforeEach(function(){
      // should be jasmine helper
      window.current_user = App.user({name: "alice", avatar : {small : "http://avatar.com/photo.jpg"}});

      var posts = $.parseJSON(spec.readFixture("multi_stream_json"))["posts"];
      spec.loadFixture("underscore_templates");

      this.collection = new App.Collections.Stream(posts);
      this.statusMessage = this.collection.models[0];
      this.reshare = this.collection.models[1];

      this.view = new App.Views.Stream({collection : this.collection});
      this.view.render();
      this.statusElement = $(this.view.$("#" + this.statusMessage.get("guid")));
      this.reshareElement = $(this.view.$("#" + this.reshare.get("guid")));
    })

    context("when rendering a Status Mesasage", function(){
      it("shows the status message in the content area", function(){
        expect(this.statusElement.find(".post-content p").text()).toContain("jimmy's 2 whales")
      })
    })
  })
})
