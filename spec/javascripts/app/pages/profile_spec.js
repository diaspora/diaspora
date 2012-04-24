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
      it("is shown", function() {
        spyOn(this.page, "isOwnProfile").andReturn(true)
        this.page.render()
        expect(this.page.$("#profile-controls .control").length).not.toBe(0)
      })

      it("is not shown", function() {
        spyOn(this.page, "isOwnProfile").andReturn(false)
        this.page.render()
        expect(this.page.$("#profile-controls .control").length).toBe(0)
      })
    })

    context("clicking fav", function(){
      beforeEach(function(){
        spyOn(this.post, 'toggleFavorite')
        spyOn($.fn, "isotope")
        this.page.$(".fav").click()
      })

      it("relayouts the page", function(){
        expect($.fn.isotope).toHaveBeenCalledWith("reLayout")
      })
      it("toggles the favorite status on the model", function(){
        expect(this.post.toggleFavorite).toHaveBeenCalled()
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
      this.page.model = this.user
    })

    it("returns true if app.currentUser matches the current profile's user", function(){
      app.currentUser = this.user
      expect(this.page.isOwnProfile()).toBeTruthy()
    })

    it("returns false if app.currentUser does not match the current profile's user", function(){
      app.currentUser = new app.models.User(factory.author({diaspora_id : "foo@foo.com"}))
      expect(this.page.isOwnProfile()).toBeFalsy()
    })
  })
});
