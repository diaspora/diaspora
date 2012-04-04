describe("app.views.Post.Wallpaper", function(){
  beforeEach(function(){
    this.post = factory.post({photos : [factory.photoAttrs({sizes :{large : "http://omgimabackground.com/wow.gif"}})]})
    this.view = new app.views.Post.Wallpaper({model : this.post})
  })

  describe("rendering", function(){
    it("has the image as the photo-fill", function(){
      this.view.render()
      expect(this.view.$(".photo-fill").data("img-src")).toBe("http://omgimabackground.com/wow.gif") //for the cuke
      expect(this.view.$(".photo-fill").css("background-image")).toMatch('http://omgimabackground.com/wow.gif')
    })
  })
})
