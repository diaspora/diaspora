describe("app.views.Feedback", function(){
  beforeEach(function(){
    window.current_user = app.user({name: "alice", avatar : {small : "http://avatar.com/photo.jpg"}});

    var posts = $.parseJSON(spec.readFixture("multi_stream_json"))["posts"];

    this.post = new app.models.Post(posts[2]);
    this.view = new app.views.Feedback({model: this.post});
  });

  it("has a like from the post", function(){
    var like = this.post.likes.models[0];

    expect(like).toBeDefined();
    expect(this.view.like).toBe(like);
  })

  it("rerends when the post is liked", function(){
    spyOn(this.view, "render")
    this.post.likes.trigger("add");
    expect(this.view.render);
  })

  it("rerends when the post is unliked", function(){
    spyOn(this.view, "render")
    this.view.like.trigger("destroy");
    expect(this.view.render);
  })

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
        this.link().click();
        expect(this.view.like).toBeNull();
      })

      // strange that this is failing... maybe we need to spy on Backbone.sync here?
      // it("destroys ths like when Unlike is clicked", function(){
        // spyOn(this.view.like, "destroy").andReturn($.noop());
        // this.link().click();
        // expect(this.view.like.destroy).toHaveBeenCalled()
      // });
    })

    context("when the user doesn't yet like the post", function(){
      beforeEach(function(){
        this.view.like = null;
        this.view.render();
      })

      it("the like action should be 'Like'", function(){
        expect(this.link().text()).toContain('Like');
      })

      it("likes the post when the link is clicked", function(){
        var like = { party : "time"}
        spyOn(this.post.likes, "create").andReturn(like);
        this.link().click()
        expect(this.view.like).toBe(like);
      })

      it("allows for unliking a just-liked post", function(){
        var like = new app.models.Like({id : 2});

        spyOn(this.post.likes, "create").andReturn(like);

        expect(this.link().text()).toContain('Like');
        this.link().click();

        spyOn(this.view.like, "destroy").andReturn($.noop());

        this.view.render();
        expect(this.link().text()).toContain('Unlike');

        this.link().click();

        this.view.render();
        expect(this.link().text()).toContain('Like');
      })
    })

    context("when the post is public", function(){
      beforeEach(function(){
        this.post.attributes.public = true
        this.view.render();
      })

      it("shows a reshare_action link", function(){
        expect($(this.view.el).html()).toContain('reshare_action')
      });
    })

    context("when the post is not public", function(){
      beforeEach(function(){
        this.post.attributes.public = false
        this.view.render();
      })

      it("shows a reshare_action link", function(){
        expect($(this.view.el).html()).not.toContain('reshare_action')
      });
    })

    context("when the current user owns the post", function(){
      beforeEach(function(){
        this.post.attributes.author = window.current_user
        this.post.attributes.public = true
        this.view.render();
      })

      it("does not display a reshare_action link", function(){
        expect($(this.view.el).html()).not.toContain('reshare_action')
      })
    })

    context("reshares", function(){
      beforeEach(function(){
        this.post.attributes.public = true
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

