describe("app.views.Post", function(){

  describe("#render", function(){
    beforeEach(function(){
      // should be jasmine helper
      window.current_user = app.user({name: "alice", avatar : {small : "http://avatar.com/photo.jpg"}});

      var posts = $.parseJSON(spec.readFixture("multi_stream_json"))["posts"][0];

      this.collection = new app.collections.Stream(posts);
      this.statusMessage = this.collection.models[0];
    })

    it("displays a reshare count", function(){
      this.statusMessage.set({reshares_count : 2})
      var view = new app.views.Post({model : this.statusMessage}).render();
      var statusElement = $(view.el)

      expect(statusElement.html()).toContain("2 reshares")
    })

    it("does not display a reshare count for 'zero'", function(){
      this.statusMessage.set({reshares_count : 0})
      var view = new app.views.Post({model : this.statusMessage}).render();
      var statusElement = $(view.el)

      expect(statusElement.html()).not.toContain("0 reshares")
    })

    context("user not signed in", function(){
      it("does not provide a Feedback view", function(){
        window.current_user = app.user(null);

        var view = new app.views.Post({model : this.statusMessage}).render();
        expect(view.feedbackView).toBeNull();
      })
    })

    context("NSFW", function(){
      it("contains a shield element", function(){
        this.statusMessage.set({text : "this is safe for work. #sfw"});

        var view = new app.views.Post({model : this.statusMessage}).render();
        var statusElement = $(view.el)

        expect(statusElement.find(".shield").html()).toBeNull();
      })

      it("does not contain a shield element", function(){
        this.statusMessage.set({text : "nudie magazine day! #nsfw"});

        var view = new app.views.Post({model : this.statusMessage}).render();
        var statusElement = $(view.el)

        expect(statusElement.find(".shield").html()).toNotBe(null);
      })
    })
  })
})
