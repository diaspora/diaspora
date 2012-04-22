describe("app.pages.Profile", function(){
  beforeEach(function(){
    this.guid = 'abcdefg123'
    this.page = new app.pages.Profile({personId :this.guid });
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

  it("fetches the stream for the user", function(){
    spyOn(this.stream, "fetch")
    new app.pages.Profile({stream : this.stream})
    expect(this.stream.fetch).toHaveBeenCalled()
  })

  describe("rendering", function(){
    beforeEach(function(){
      this.page.render();
    });
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
});
