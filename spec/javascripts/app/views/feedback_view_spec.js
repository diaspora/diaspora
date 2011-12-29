describe("app.views.Feedback", function(){
  beforeEach(function(){
    window.current_user = app.user({id : -1, name: "alice", avatar : {small : "http://avatar.com/photo.jpg"}});

    var posts = $.parseJSON(spec.readFixture("multi_stream_json"))["posts"];

    this.post = new app.models.Post(posts[2]);
    this.view = new app.views.Feedback({model: this.post});
  });

  describe(".render", function(){
    beforeEach(function(){
      this.link = function(){ return this.view.$(".like_action"); }
    })

    context("when the user likes the post", function(){
      beforeEach(function(){
        this.view.render();
      })

      it("the like action should be 'Unlike'", function(){
        expect(this.link().text()).toContain('Unlike');
      })

      it("removes like when Unlike is clicked", function() {
        var likeModel = new app.models.Like(this.view.model.get("user_like"));
        spyOn(this.view.model.likes, "get").andReturn(likeModel);
        spyOn(likeModel, "destroy");

        this.link().click();
        expect(likeModel.destroy).toHaveBeenCalled();
      })
    })

    context("when the user doesn't yet like the post", function(){
      beforeEach(function(){
        this.view.model.set({user_like : null});
        this.view.render();
      })

      it("contains a .like_action", function(){
        expect($(this.view.el).html()).toContain("like_action");
      })

      it("the like action should be 'Like'", function(){
        expect(this.link().text()).toContain('Like');
      })

      it("allows for unliking a just-liked post", function(){
        var like = new app.models.Like({id : 2});

        spyOn(this.post.likes, "create").andReturn(like);

        expect(this.link().text()).toContain('Like');
        this.link().click();

        this.view.render();
        expect(this.link().text()).toContain('Unlike');

        // spying + stubbing for destroy
        var likeModel = new app.models.Like(this.view.model.get("user_like"));
        spyOn(this.view.model.likes, "get").andReturn(likeModel);
        spyOn(likeModel, "destroy").andReturn(function(){
          this.view.model.set({user_like : null})
        });

        this.link().click();

        this.view.render();
        expect(this.link().text()).toContain('Like');
      })
    })

    context("when the post is public", function(){
      beforeEach(function(){
        this.post.attributes.public = true;
        this.view.render();
      })

      it("shows a reshare_action link", function(){
        expect($(this.view.el).html()).toContain('reshare_action')
      });

      it("does not show a reshare_action link if the original post has been deleted", function(){
        this.post.attributes.root = null
        this.view.render();

        expect($(this.view.el).html()).not.toContain('reshare_action');
      })
    })

    context("when the post is not public", function(){
      beforeEach(function(){
        this.post.attributes.public = false;
        this.post.attributes.root = {author : {name : "susan"}};
        this.view.render();
      })

      it("does not show a reshare_action link", function(){
        expect($(this.view.el).html()).not.toContain('reshare_action');
      });
    })

    context("when the current user owns the post", function(){
      beforeEach(function(){
        this.post.attributes.author = window.current_user;
        this.view.render();
      })

      it("does not display a reshare_action link", function(){
        this.post.attributes.public = false
        this.view.render();
        expect($(this.view.el).html()).not.toContain('reshare_action')
      })
    })

    context("reshares", function(){
      beforeEach(function(){
        this.post.attributes.public = true
        this.post.attributes.root = {author : {name : "susan"}};
        this.view.render();
      })

      it("displays a confirmation dialog", function(){
        spyOn(window, "confirm")

        this.view.$(".reshare_action").first().click();
        expect(window.confirm).toHaveBeenCalled();
      })

      it("creates a reshare if the confirmation dialog is accepted", function(){
        spyOn(window, "confirm").andReturn(true);

        expect(this.view.resharePost().constructor).toBe(app.models.Reshare);
      })
    })
  })
})

