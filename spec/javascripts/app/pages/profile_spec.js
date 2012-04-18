describe("app.pages.Profile", function(){
  beforeEach(function(){
    this.guid = 'abcdefg123'
    this.page = new app.pages.Profile({personId :this.guid });
    this.stream = this.page.stream
  });

//  xit("passes the model down to the post view", function(){
//    expect(this.page.canvasView.model).toBeDefined()
//    expect(this.page.canvasView.model).toBe(this.stream)
//  });

  it("fetches the profile of the user with the params from the router", function(){
    profile = new factory.profile()
    spyOn(app.models.Profile, 'findByGuid').andReturn(profile)
    var page =  new app.pages.Profile({personId : 'jarjabinkisthebest' })
    expect(app.models.Profile.findByGuid).toHaveBeenCalledWith('jarjabinkisthebest')
    expect(page.model).toBe(profile)
  })

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
});
