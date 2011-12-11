describe("App.views.Stream", function(){

  describe("#render", function(){
    beforeEach(function(){
      // should be jasmine helper
      window.current_user = App.user({name: "alice", avatar : {small : "http://avatar.com"}});

      //hella hax
      spec.loadFixture("multi_stream_json");
      var posts = $.parseJSON($("#jasmine_content").html())["posts"]
      spec.loadFixture("underscore_templates");

      this.collection = new App.Collections.Stream(posts)
      this.statusMessage = this.collection.models[0];
      // this.picture = new App.Models.Post({post_type : "ActivityStreams::Photo", image_url : "http://amazonks.com/pretty_picture_lol.gif"});

      this.view = new App.Views.Stream({collection : this.collection});
      this.view.render();
      this.statusElement = $(this.view.$("#" + this.statusMessage.get("guid")));
      //this.pictureElement = $(this.view.$("#" + this.picture.get("guid")));
    })

    context("when rendering a Status Mesasage", function(){
      it("shows the status message in the content area", function(){
        expect($.trim(this.statusElement.find(".content p.post-text").text())).toBe("hella infos yo!")
      })
    })

    // context("when rendering a Picture", function(){
    //   it("shows the picture in the content area", function(){
    //     expect(this.streamElement.find(".post-content img").attr("src")).toBe("http://amazonks.com/pretty_picture_lol.gif")
    //   })
    // })
  })
})
