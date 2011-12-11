describe("App.views.Stream", function(){

  describe("#render", function(){
    beforeEach(function(){
      //hella hax
      spec.loadFixture("multi_stream_json") 
      var fixtureStream = $.parseJSON($("#jasmine_content").html())

      this.statusMessage = new App.Models.Post(fixtureStream["posts"][0] );
      // this.picture = new App.Models.Post({post_type : "ActivityStreams::Photo", image_url : "http://amazonks.com/pretty_picture_lol.gif"});

      this.collection = new App.Collections.Stream([this.statusMessage]);
      this.view = new App.Views.Stream({collection : this.collection});
      this.view.render();
      this.statusElement = $(this.view.$("#" + this.statusMessage.get("guid")));
      //this.pictureElement = $(this.view.$("#" + this.picture.get("guid")));
    })

    context("when rendering a Status Mesasage", function(){
      it("shows the status message in the content area", function(){
        // we need to load the underscore templates here, otherwise our views won't render!
        expect(this.statusElement.find(".post-content p")).toBe("hella infos yo!")
      })
    })

    // context("when rendering a Picture", function(){
    //   it("shows the picture in the content area", function(){
    //     expect(this.streamElement.find(".post-content img").attr("src")).toBe("http://amazonks.com/pretty_picture_lol.gif")
    //   })
    // })
  })
})
