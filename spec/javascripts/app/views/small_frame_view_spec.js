describe("app.views.SmallFrame", function(){
  beforeEach(function(){
    this.model = factory.post({
      photos : [
        factory.photoAttrs({sizes : {large : "http://tieguy.org/me.jpg"}}),
        factory.photoAttrs({sizes : {large : "http://whatthefuckiselizabethstarkupto.com/none_knows.gif"}}) //SIC
      ]
    })
    this.view = new app.views.SmallFrame({model : this.model})
  })

  describe("rendering", function(){
    beforeEach(function(){
      this.view.render()
    });
  })

  describe("photos", function() {
    // ratio pending...
  })
});