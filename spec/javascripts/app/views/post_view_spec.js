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

      var posts = $.parseJSON(spec.readFixture("stream_json"))["posts"];

      this.collection = new app.collections.Posts(posts);
      this.statusMessage = this.collection.models[0];
      this.reshare = this.collection.models[1];
    })

    it("displays a reshare count", function(){
      this.statusMessage.set({reshares_count : 2})
      var view = new app.views.Post({model : this.statusMessage}).render();

      expect($(view.el).html()).toContain(Diaspora.I18n.t('stream.reshares', {count: 2}))
    })

    it("does not display a reshare count for 'zero'", function(){
      this.statusMessage.set({reshares_count : 0})
      var view = new app.views.Post({model : this.statusMessage}).render();

      expect($(view.el).html()).not.toContain("0 Reshares")
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
      beforeEach(function(){
        this.statusMessage.set({nsfw: true});
        this.view = new app.views.Post({model : this.statusMessage}).render();

        this.hiddenPosts = function(){
           return this.view.$(".nsfw-shield")
         }
      });

      it("contains a shield element", function(){
        expect(this.hiddenPosts().length).toBe(1)
      });

      it("does not contain a shield element when nsfw is false", function(){
        this.statusMessage.set({nsfw: false});
        this.view.render();
        expect(this.hiddenPosts()).not.toExist();
      })

      context("showing a single post", function(){
        it("removes the shields when the post is clicked", function(){
          expect(this.hiddenPosts()).toExist();
          this.view.$(".nsfw-shield .show_nsfw_post").click();
          expect(this.hiddenPosts()).not.toExist();
        });
      });

      context("clicking the toggle nsfw link toggles it on the user", function(){
        it("calls toggleNsfw on the user", function(){
          spyOn(app.user(), "toggleNsfwState")
          this.view.$(".toggle_nsfw_state").first().click();
          expect(app.user().toggleNsfwState).toHaveBeenCalled();
        });
      })
    })
  })
});
