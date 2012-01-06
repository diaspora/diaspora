describe("app.views.Post", function(){

  describe("#render", function(){
    beforeEach(function(){
      window.current_user = app.user({name: "alice", avatar : {small : "http://avatar.com/photo.jpg"}});

      Diaspora.I18n.loadLocale({stream : {
        reshares : {
          one : "<%= count %> reshare",
          few : "<%= count %> reshares"
        }
      }})

      var posts = $.parseJSON(spec.readFixture("multi_stream_json"))["posts"];

      this.collection = new app.collections.Stream(posts);
      this.statusMessage = this.collection.models[0];
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

    it("should markdownify the post's text", function(){
      this.statusMessage.set({text: "I have three Belly Buttons"})
      spyOn(window.markdown, "toHTML")
      new app.views.Post({model : this.statusMessage}).render();
      expect(window.markdown.toHTML).toHaveBeenCalledWith("I have three Belly Buttons")
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
