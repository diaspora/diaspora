describe("App.views.Feedback", function(){
  beforeEach(function(){
    window.current_user = App.user({name: "alice", avatar : {small : "http://avatar.com/photo.jpg"}});

    var posts = $.parseJSON(spec.readFixture("multi_stream_json"))["posts"];

    this.post = new App.Models.Post(posts[2]);
    this.view = new App.Views.Feedback({model: this.post});
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

      it("destroys ths like when Unlike is clicked", function(){
        spyOn(this.view.like, "destroy")
        this.link().click();
        expect(this.view.like.destroy).toHaveBeenCalled()
      });

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
    })
  })
})

