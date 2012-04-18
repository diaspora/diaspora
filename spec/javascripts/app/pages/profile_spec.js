describe("app.pages.Profile", function(){
  beforeEach(function(){
    this.page = new app.pages.Profile();
    this.stream = this.page.stream
  });

  it("passes the model down to the post view", function(){
    expect(this.page.canvasView.model).toBeDefined()
    expect(this.page.canvasView.model).toBe(this.stream)
  });

  it("fetches the stream for the user", function(){
    spyOn(this.stream, "fetch")
    new app.pages.Profile({model : this.stream})
    expect(this.stream.fetch).toHaveBeenCalled()
  })

  describe("rendering", function(){
    beforeEach(function(){
      this.page.render();
    });
  });
});
