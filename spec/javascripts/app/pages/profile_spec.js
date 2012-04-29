describe("app.pages.Profile", function(){
  beforeEach(function(){
    this.guid = 'abcdefg123'
    app.page = this.page = new app.pages.Profile({personId :this.guid });
    this.stream = this.page.stream
  });

  it("fetches the profile of the user with the params from the router and assigns it as the model", function(){
    profile = new factory.profile()
    spyOn(app.models.Profile, 'findByGuid').andReturn(profile)
    var page =  new app.pages.Profile({personId : 'jarjabinkisthebest' })
    expect(app.models.Profile.findByGuid).toHaveBeenCalledWith('jarjabinkisthebest')
    expect(page.model).toBe(profile)
  })

  it("passes the model down to the post view", function(){
    expect(this.page.canvasView.model).toBeDefined()
    expect(this.page.canvasView.model).toBe(this.stream)
  });

  it("preloads the stream for the user", function(){
    spyOn(this.stream, "preload")
    new app.pages.Profile({stream : this.stream})
    expect(this.stream.preload).toHaveBeenCalled()
  })

  describe("rendering", function(){
    beforeEach(function(){
      this.post = factory.post()
      this.stream.add(this.post)
      this.page.toggleEdit()
      expect(this.page.editMode).toBeTruthy()
      this.page.render()
    });

    context("profile control pane", function(){
      it("shows the edit and create buttons if it's your profile", function() {
        spyOn(this.page, "isOwnProfile").andReturn(true)
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

  describe("isOwnProfile", function(){
    beforeEach(function(){
      this.user = new app.models.User(factory.author())
      this.page.personGUID = this.user.get("guid")
    })

    it("returns true if app.currentUser matches the current profile's user", function(){
      app.currentUser = this.user
      expect(this.page.isOwnProfile()).toBeTruthy()
    })

    it("returns false if app.currentUser does not match the current profile's user", function(){
      app.currentUser = new app.models.User(factory.author({guid : "nope!"}))
      expect(this.page.isOwnProfile()).toBeFalsy()
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
