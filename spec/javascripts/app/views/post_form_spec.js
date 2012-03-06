describe("app.views.PostForm", function(){
  beforeEach(function(){
    this.post = new app.models.Post();
    this.view = new app.views.PostForm({model : this.post})
  })

  it("renders", function(){
      this.view.render()
  })
})