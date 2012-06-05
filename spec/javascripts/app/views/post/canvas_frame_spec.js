describe("app.views.Post.CanvasFrame", function(){
  beforeEach(function(){
    this.model = factory.post({
      photos : [
        factory.photoAttrs({sizes : {
          large : "http://tieguy.org/me.jpg"
        },
          dimensions : {
            width : 100,
            height : 200 }
        }),
        factory.photoAttrs({sizes : {large : "http://whatthefuckiselizabethstarkupto.com/none_knows.gif"}}) //SIC
      ]
    })

    this.view = new app.views.Post.CanvasFrame({model : this.model})
  })

  context("images", function() {
    it("appends the correct dimensions to an image, given a model with an image", function(){
      var firstPhoto = this.model.get("photos")[0]

      this.view.SINGLE_COLUMN_WIDTH = 100
      expect(this.view.adjustedImageHeight(firstPhoto)).toBe(200)
      this.view.SINGLE_COLUMN_WIDTH = 200
      expect(this.view.adjustedImageHeight(firstPhoto)).toBe(400)
      this.view.SINGLE_COLUMN_WIDTH = 50
      expect(this.view.adjustedImageHeight(firstPhoto)).toBe(100)
    })
  })
});
