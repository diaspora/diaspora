describe("App.views.Post", function(){

  describe("#render", function(){
    beforeEach(function(){
      // should be jasmine helper
      window.current_user = App.user({name: "alice", avatar : {small : "http://avatar.com/photo.jpg"}});

      var posts = $.parseJSON(spec.readFixture("multi_stream_json"))["posts"][0];
      spec.loadFixture("underscore_templates");

      this.collection = new App.Collections.Stream(posts);
      this.statusMessage = this.collection.models[0];

      this.view = new App.Views.Post({model : this.statusMessage}).render();
      this.statusElement = $(this.view.el)
    })

    context("comment clicking", function(){
      it("shows the status message in the content area", function(){
        console.log(this.statusElement);
        //expect(this.statusElement).toBe("hella infos yo!")
      })
    })

  })
})
