describe("app.pages.Profile", function(){
  beforeEach(function(){
    this.guid = 'abcdefg123'
    this.profile = factory.profile({personId: this.guid})
    app.page = this.page = new app.pages.Profile({model : this.profile });
    this.stream = this.page.stream
  });

  it("fetches the profile of the user with the params from the router and assigns it as the model", function(){
    var profile = new factory.profile()
    spyOn(app.models.Profile, 'findByGuid').andReturn(profile)
    var page =  new app.pages.Profile({personId : 'jarjabinkisthebest' })
    expect(app.models.Profile.findByGuid).toHaveBeenCalledWith('jarjabinkisthebest')
    expect(page.model).toBe(profile)
  })

  it("passes the stream down to the canvas view", function(){
    expect(this.page.canvasView.model).toBeDefined()
    expect(this.page.canvasView.model).toBe(this.stream)
  });

  it("preloads the stream for the user", function(){
    spyOn(this.stream, "preload")

    window.preloads = {stream : JSON.stringify(["unicorns"]) }

    new app.pages.Profile({stream : this.stream})
    expect(this.stream.preload).toHaveBeenCalled()

    delete window.preloads //cleanup
  })

  describe("rendering", function(){
    context("with no posts", function(){
      beforeEach(function(){
        this.profile.set({"name" : "Alice Waters", person_id : "889"})
      })

      it("has a message that there are no posts", function(){
        this.page.render()
        expect(this.page.$("#canvas").text()).toBe("Alice Waters hasn't posted anything yet.")
      })

      it("tells you to post something if it's your profile", function(){
        this.profile.set({is_own_profile : true})
        this.page.render()
        expect(this.page.$("#canvas").text()).toBe("Make something to start the magic.")
      })
    })

    context("with a post", function(){
      beforeEach(function(){
        this.post = factory.post()
        this.stream.add(this.post)
        this.page.toggleEdit()
        expect(this.page.editMode).toBeTruthy()
        this.page.render()
      });

      context("profile control pane", function(){
        it("shows the edit and create buttons if it's your profile", function() {
          this.page.model.set({is_own_profile : true})
          this.page.render()
          expect(this.page.$("#profile-controls .control").length).toBe(2)
        })

        it("shows a follow button if showFollowButton returns true", function() {
          spyOn(this.page, "showFollowButton").andReturn(true)
          this.page.render()
          expect(this.page.$("#follow-button").length).toBe(1)
        })

        it("doesn't show a follow button if showFollowButton returns false", function() {
          spyOn(this.page, "showFollowButton").andReturn(false)
          this.page.render()
          expect(this.page.$("#follow-button").length).toBe(0)
        })
      })

      context("clicking fav", function(){
        beforeEach(function(){
          spyOn(this.post, 'toggleFavorite')
          spyOn($.fn, "isotope")
          this.page.$(".content").click()
        })

        it("relayouts the page", function(){
          expect($.fn.isotope).toHaveBeenCalledWith("reLayout")
        })

        it("toggles the favorite status on the model", function(){
          expect(this.post.toggleFavorite).toHaveBeenCalled()
        })
      })

      context("clicking delete", function(){
        beforeEach(function () {
          spyOn(window, "confirm").andReturn(true);
          this.page.render()
        })

        it("kills the model", function(){
          spyOn(this.post, "destroy")
          this.page.$(".canvas-frame:first a.delete").click()
          expect(this.post.destroy).toHaveBeenCalled()
        })

        it("removes the frame", function(){
          spyOn($.fn, "remove").andCallThrough()
          expect(this.page.$(".canvas-frame").length).toBe(1)
          this.page.$(".canvas-frame:first a.delete").click()
          waitsFor(function(){ return $.fn.remove.wasCalled })
          runs(function(){ expect(this.page.$(".canvas-frame").length).toBe(0) })
        })
      })
    })
  });

  describe("edit mode", function(){
    describe("toggle edit", function(){
      it("changes the page's global edit state", function(){
        expect(this.page.editMode).toBeFalsy()
        this.page.toggleEdit()
        expect(this.page.editMode).toBeTruthy()
      })

      it("changes the page's class to 'edit-mode'", function(){
        expect(this.page.$el).not.toHaveClass('edit-mode')
        this.page.toggleEdit()
        expect(this.page.$el).toHaveClass('edit-mode')
      })
    })
  })

  describe("followingEnabled", function(){
    /* for legacy beta testers */
    it("returns false if following_count is zero", function(){
      loginAs({following_count : 0})
      expect(this.page.followingEnabled()).toBeFalsy()
    })

    it("returns false if the user is not signed in", function(){
      logout()
      expect(this.page.followingEnabled()).toBeFalsy()
    })

    it("returns false if following_count is zero", function(){
      loginAs({following_count : 1})
      expect(this.page.followingEnabled()).toBeTruthy()
    })
  })

  describe("followingEnabled", function(){
    /* for legacy beta testers */
    it("returns false if following_count is zero", function(){
      app.currentUser.set({following_count : 0})
      expect(this.page.followingEnabled()).toBeFalsy()
    })

    it("returns false if following_count is zero", function(){
      app.currentUser.set({following_count : 1})
      expect(this.page.followingEnabled()).toBeTruthy()
    })
  })
});
