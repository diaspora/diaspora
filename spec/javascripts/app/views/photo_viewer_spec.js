describe("app.views.PhotoViewer", function(){
  beforeEach(function(){
    this.model = factory.post({
      photos : [
        factory.photoAttrs({sizes : {large : "http://tieguy.org/me.jpg"}}),
        factory.photoAttrs({sizes : {large : "http://whatthefuckiselizabethstarkupto.com/none_knows.gif"}}) //SIC
      ]
    })
    this.view = new app.views.PhotoViewer({model : this.model})
  })

  describe("rendering", function(){
    it("should have an image for each photoAttr on the model", function(){
      this.view.render()
      expect(this.view.$("img").length).toBe(2)
      expect(this.view.$("img[src='http://tieguy.org/me.jpg']")).toExist()
    })
  })
})