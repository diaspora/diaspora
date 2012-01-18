describe("app.views.Feedback", function(){
  beforeEach(function(){
   loginAs({id : -1, name: "alice", avatar : {small : "http://avatar.com/photo.jpg"}});

    Diaspora.I18n.loadLocale({stream : {
      'like' : "Like",
      'unlike' : "Unlike",
      'public' : "Public",
      'limited' : "Limted"
    }})

    var posts = $.parseJSON(spec.readFixture("multi_stream_json"))["posts"];

    this.post = new app.models.Post(posts[0]);
    this.view = new app.views.Feedback({model: this.post});
  });


  describe(".render", function(){
    beforeEach(function(){
      this.link = function(){ return this.view.$(".like_action"); }
      this.view.render();
    })

    context("likes", function(){
      it("calls 'toggleLike' on the target post", function(){
        this.view.render();
        spyOn(this.post, "toggleLike");

        this.link().click();
        expect(this.post.toggleLike).toHaveBeenCalled();
      })

      context("when the user likes the post", function(){
        it("the like action should be 'Unlike'", function(){
          expect(this.link().text()).toContain(Diaspora.I18n.t('stream.unlike'))
        })
      })


      context("when the user doesn't yet like the post", function(){
        beforeEach(function(){
          this.view.model.set({user_like : null});
          this.view.render();
        })

        it("the like action should be 'Like'", function(){
          expect(this.link().text()).toContain(Diaspora.I18n.t('stream.like'))
        })

        it("allows for unliking a just-liked post", function(){
          expect(this.link().text()).toContain(Diaspora.I18n.t('stream.like'))

          this.link().click();
          expect(this.link().text()).toContain(Diaspora.I18n.t('stream.unlike'))

          this.link().click();
          expect(this.link().text()).toContain(Diaspora.I18n.t('stream.like'))
        })
      })
    })

    context("when the post is public", function(){
      beforeEach(function(){
        this.post.attributes.public = true;
        this.view.render();
      })

      it("shows 'Public'", function(){
        expect($(this.view.el).html()).toContain(Diaspora.I18n.t('stream.public'))
      })

      it("shows a reshare_action link", function(){
        expect($(this.view.el).html()).toContain('reshare_action')
      });

      it("does not show a reshare_action link if the original post has been deleted", function(){
        this.post.set({post_type : "Reshare", root : null})
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

      it("shows 'Limited'", function(){
        expect($(this.view.el).html()).toContain(Diaspora.I18n.t('stream.limited'))
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
  })

  describe("resharePost", function(){
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

    it("reshares the model", function(){
      spyOn(window, "confirm").andReturn(true);
      spyOn(this.view.model.reshare(), "save")
      this.view.$(".reshare_action").first().click();
      expect(this.view.model.reshare().save).toHaveBeenCalled();
    })
  })
})

