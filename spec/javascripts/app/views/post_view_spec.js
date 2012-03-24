describe("app.views.Post", function(){

  describe("#render", function(){
    beforeEach(function(){
      loginAs({name: "alice", avatar : {small : "http://avatar.com/photo.jpg"}});

      Diaspora.I18n.loadLocale({stream : {
        reshares : {
          one : "<%= count %> reshare",
          other : "<%= count %> reshares"
        },
        likes : {
          zero : "<%= count %> Likes",
          one : "<%= count %> Like",
          other : "<%= count %> Likes"
        }
      }})

      var posts = $.parseJSON(spec.readFixture("stream_json"))["posts"];

      this.collection = new app.collections.Posts(posts);
      this.statusMessage = this.collection.models[0];
      this.reshare = this.collection.models[1];
    })

    context("reshare", function(){
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
    })

    context("likes", function(){
        it("displays a like count", function(){
          this.statusMessage.set({likes_count : 1})
          var view = new app.views.Post({model : this.statusMessage}).render();

          expect($(view.el).html()).toContain(Diaspora.I18n.t('stream.likes', {count: 1}))
        })
        it("does not display a like count for 'zero'", function(){
          this.statusMessage.set({likes_count : 0})
          var view = new app.views.Post({model : this.statusMessage}).render();

          expect($(view.el).html()).not.toContain("0 Likes")
        })
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

    context("user views their own post", function(){
      beforeEach(function(){
        this.statusMessage.set({ author: {
          id : app.user().id
        }});
        this.view = new app.views.Post({model : this.statusMessage}).render();
      })

      it("contains remove post", function(){
        expect(this.view.$(".remove_post")).toExist();
      })

      it("destroys the view when they delete a their post from the show page", function(){
        spyOn(window, "confirm").andReturn(true);

        this.view.$(".remove_post").click();

        expect(window.confirm).toHaveBeenCalled();
        expect(this.view).not.toExist();
      })
    })

    context("markdown rendering", function() {
      beforeEach(function() {
        // example from issue #2665
        this.evilUrl  = "http://www.bürgerentscheid-krankenhäuser.de";
        this.asciiUrl = "http://www.xn--brgerentscheid-krankenhuser-xkc78d.de";
      });

      it("correctly handles non-ascii characters in urls", function() {
        this.statusMessage.set({text: "<"+this.evilUrl+">"});
        var view = new app.views.Post({model : this.statusMessage}).render();

        expect($(view.el).html()).toContain(this.asciiUrl);
        expect($(view.el).html()).toContain(this.evilUrl);
      });

      it("doesn't break link texts for non-ascii urls", function() {
        var linkText = "check out this awesome link!";
        this.statusMessage.set({text: "["+linkText+"]("+this.evilUrl+")"});
        var view = new app.views.Post({model: this.statusMessage}).render();

        expect($(view.el).html()).toContain(this.asciiUrl);
        expect($(view.el).html()).toContain(linkText);
      });

      it("doesn't break reference style links for non-ascii urls", function() {
        var postContent = "blabla blab [my special link][1] bla blabla\n\n[1]: "+this.evilUrl+" and an optional title)";
        this.statusMessage.set({text: postContent});
        var view = new app.views.Post({model: this.statusMessage}).render();

        expect($(view.el).html()).not.toContain(this.evilUrl);
        expect($(view.el).html()).toContain(this.asciiUrl);
      });

      it("correctly handles images with non-ascii urls", function() {
        var postContent = "![logo](http://bündnis-für-krankenhäuser.de/wp-content/uploads/2011/11/cropped-logohp.jpg)";
        var niceImg = '"http://xn--bndnis-fr-krankenhuser-i5b27cha.de/wp-content/uploads/2011/11/cropped-logohp.jpg"';
        this.statusMessage.set({text: postContent});
        var view = new app.views.Post({model: this.statusMessage}).render();

        expect($(view.el).html()).toContain(niceImg);
      });

    });
  })
});
