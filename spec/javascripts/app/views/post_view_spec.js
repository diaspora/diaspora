describe("app.views.Post", function(){

  describe("#render", function(){
    beforeEach(function(){
      loginAs({name: "alice", avatar : {small : "http://avatar.com/photo.jpg"}});

      Diaspora.I18n.loadLocale({stream : {
        reshares : {
          one : "<%= count %> reshare",
          other : "<%= count %> reshares"
        }
      }})

      var posts = $.parseJSON(spec.readFixture("multi_stream_json"))["posts"];

      this.collection = new app.collections.Stream(posts);
      this.statusMessage = this.collection.models[0];
      this.reshare = this.collection.models[1];
    })

    it("displays a reshare count", function(){
      this.statusMessage.set({reshares_count : 2})
      var view = new app.views.Post({model : this.statusMessage}).render();

      expect(view.$(".post_initial_info").html()).toContain(Diaspora.I18n.t('stream.reshares', {count: 2}))
    })

    it("does not display a reshare count for 'zero'", function(){
      this.statusMessage.set({reshares_count : 0})
      var view = new app.views.Post({model : this.statusMessage}).render();

      expect(view.$(".post_initial_info").html()).not.toContain("0 Reshares")
    })


    context("embed_html", function(){
      it("provides oembed html from the model response", function(){
        this.statusMessage.set({"o_embed_cache" : {
          "data" : {
            "html" : "some html"
          }
        }})

        var view = new app.views.Content({model : this.statusMessage});
        expect(view.presenter().o_embed_html).toContain("some html")
      })

      it("does not provide oembed html from the model response if none is present", function(){
        this.statusMessage.set({"o_embed_cache" : null})

        var view = new app.views.Content({model : this.statusMessage});
        expect(view.presenter().o_embed_html).toBe("");
      })
    })

    context("user not signed in", function(){
      it("does not provide a Feedback view", function(){
        logout()
        var view = new app.views.Post({model : this.statusMessage}).render();
        expect(view.feedbackView()).toBeFalsy();
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
