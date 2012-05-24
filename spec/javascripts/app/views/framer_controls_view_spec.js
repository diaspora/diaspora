describe("app.views.framerControls", function(){
  beforeEach(function(){
    loginAs(factory.user())
    this.post = new factory.statusMessage({frame_name: undefined});
    this.view = new app.views.framerControls({model : this.post})
  })

describe("rendering", function(){
    beforeEach(function(){
      this.view.render();
    });

    it("disables the buttons when you click the X", function(){
      this.view.$("input.done").click();
      expect(this.view.$('input').prop('disabled')).toBeTruthy();
    });
  })
});
