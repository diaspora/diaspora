describe("app.views.StreamPost", function(){
  beforeEach(function(){
    this.PostViewClass = app.views.StreamPost;

    var posts = $.parseJSON(spec.readFixture("stream_json"));
    this.collection = new app.collections.Posts(posts);
    this.statusMessage = this.collection.models[0];
    this.reshare = this.collection.models[1];
    app.stream = new app.models.Stream();
  });

  describe("events", function(){
    var _PostViewClass,
        authorId;

    beforeEach(function(){
      _PostViewClass = this.PostViewClass;
      authorId = this.statusMessage.get('author').id;
    });

    describe("remove posts for blocked person", function(){
      it("setup remove:author:posts:#{id} to #remove", function(){
        spyOn(_PostViewClass.prototype, 'remove');
        new _PostViewClass({model : this.statusMessage});
        app.events.trigger('person:block:'+authorId);
        expect(_PostViewClass.prototype.remove).toHaveBeenCalled();
      });
    });
  });

  describe("#render", function(){
    var o_embed_cache = {
      "data" : {
        "html" : "some html"
      }
    };

    var open_graph_cache = {
      "url": "http://example.com/articles/123",
      "title": "Example title",
      "description": "Test description",
      "image": "http://example.com/thumb.jpg",
      "ob_type": "article"
    };

    var open_graph_cache_extralong = {
      "url": "http://example.com/articles/123",
      "title": "Example title",
      "description": Array(62).join("Test description"), // 992 chars
      "image": "http://example.com/thumb.jpg",
      "ob_type": "article"
    };

    beforeEach(function(){
      loginAs({name: "alice", avatar : {small : "http://avatar.com/photo.jpg"}});
    });

    context("reshares", function(){
      it("displays a reshare count", function(){
        this.statusMessage.interactions.set({"reshares_count": 2});
        var view = new this.PostViewClass({model : this.statusMessage}).render();
        expect($(view.el).html()).toContain(Diaspora.I18n.t('stream.reshares', {count: 2}));
      });

      it("does not display a reshare count for 'zero'", function(){
        this.statusMessage.interactions.set({"reshares_count": 0});
        var view = new this.PostViewClass({model : this.statusMessage}).render();
        expect($(view.el).html()).not.toContain("0 Reshares");
      });
    });

    context("likes", function(){
      it("displays a like count", function(){
        this.statusMessage.interactions.set({likes_count : 1});
        var view = new this.PostViewClass({model : this.statusMessage}).render();
        expect($(view.el).html()).toContain(Diaspora.I18n.t('stream.likes', {count: 1}));
      });

      it("does not display a like count for 'zero'", function(){
        this.statusMessage.interactions.set({likes_count : 0});
        var view = new this.PostViewClass({model : this.statusMessage}).render();
        expect($(view.el).html()).not.toContain("0 Likes");
      });
    });

    context("embed_html", function(){
      it("provides oembed html from the model response", function(){
        this.statusMessage.set({"o_embed_cache" : o_embed_cache});

        var view = new app.views.StreamPost({model : this.statusMessage}).render();
        expect(view.$el.html()).toContain(o_embed_cache.data.html);
      });
    });

    context("og_html", function(){
      it("provides opengraph preview based on the model reponse", function(){
        this.statusMessage.set({"open_graph_cache" : open_graph_cache});

        var view = new app.views.StreamPost({model : this.statusMessage}).render();
        expect(view.$el.html()).toContain(open_graph_cache.title);
      });
      it("does not provide opengraph preview, when oembed is available", function(){
        this.statusMessage.set({
          "o_embed_cache" : o_embed_cache,
          "open_graph_cache" : open_graph_cache
        });

        var view = new app.views.StreamPost({model : this.statusMessage}).render();
        expect(view.$el.html()).not.toContain(open_graph_cache.title);
      });
      it("truncates long opengraph descriptions in stream view to be 250 chars or less", function() {
        this.statusMessage.set({"open_graph_cache" : open_graph_cache_extralong});

        var view = new app.views.StreamPost({model : this.statusMessage}).render();
        expect(view.$el.find('.og-description').html().length).toBeLessThan(251);
      });
    });

    context("user not signed in", function(){
      it("does not provide a Feedback view", function(){
        logout();
        var view = new this.PostViewClass({model : this.statusMessage}).render();
        expect(view.feedbackView()).toBeFalsy();
      });
    });

    context("NSFW", function(){
      beforeEach(function(){
        this.statusMessage.set({nsfw: true});
        this.view = new this.PostViewClass({model : this.statusMessage}).render();

        this.hiddenPosts = function(){
          return this.view.$(".media.shield-active .nsfw-shield");
        };
      });

      it("contains a shield element", function(){
        expect(this.hiddenPosts().length).toBe(1);
      });

      it("does not contain a shield element when nsfw is false", function(){
        this.statusMessage.set({nsfw: false});
        this.view.render();
        expect(this.hiddenPosts()).not.toExist();
      });

      context("showing a single post", function(){
        it("removes the shields when the post is clicked", function(){
          expect(this.hiddenPosts()).toExist();
          this.view.$(".nsfw-shield .show_nsfw_post").click();
          expect(this.hiddenPosts()).not.toExist();
        });
      });

      context("clicking the toggle nsfw link toggles it on the user", function(){
        it("calls toggleNsfw on the user", function(){
          spyOn(app.user(), "toggleNsfwState");
          this.view.$(".toggle_nsfw_state").first().click();
          expect(app.user().toggleNsfwState).toHaveBeenCalled();
        });
      });
    });

    context("user views their own post", function(){
      beforeEach(function(){
        this.statusMessage.set({ author: {
          id : app.user().id
        }});
        this.view = new this.PostViewClass({model : this.statusMessage}).render();
      });

      it("contains remove post", function(){
        expect(this.view.$(".remove_post")).toExist();
      });

      it("destroys the view when they delete a their post from the show page", function(){
        spyOn(window, "confirm").and.returnValue(true);

        this.view.$(".remove_post").click();

        expect(window.confirm).toHaveBeenCalled();
        expect(this.view.el).not.toBeInDOM();
      });
    });

  });
});
