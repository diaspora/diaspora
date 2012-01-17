describe("app.views.ReshareFeedback", function(){
  beforeEach(function(){
    var posts = $.parseJSON(spec.readFixture("multi_stream_json"))["posts"];
    this.reshare = new app.models.Reshare(_.extend(posts[1], {public : true}));
    this.view = new app.views.ReshareFeedback({model : this.reshare }).render()
  })

  it("inherits from feedback view", function(){
    expect(this.view instanceof app.views.Feedback).toBeTruthy()
  })

  it("sets Up the root Post as the reshareable post", function(){
    expect(this.view.reshareablePost).toBe(this.reshare.rootPost())
  })

  it("reshares the rootPost", function(){
    spyOn(window, "confirm").andReturn(true);
    spyOn(this.reshare.rootPost(), "reshare")
    console.log(this.view.el)
    this.view.$(".reshare_action").first().click();
    expect(this.reshare.rootPost().reshare).toHaveBeenCalled();
  })

})
