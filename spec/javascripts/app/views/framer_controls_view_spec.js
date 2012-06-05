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

    it("does not disable the frame if it is invaild", function(){
      spyOn(this.view, 'inValidFrame').andReturn(true)      
      this.view.$("input.done").click();
      expect(this.view.$('input').prop('disabled')).toBeFalsy();
    });

    it("does not disable the frame if it is invaild", function(){
      spyOn(this.view.model, 'save')
      spyOn(this.view, 'inValidFrame').andReturn(true)      
      this.view.$("input.done").click();
      expect(this.view.model.save).not.toHaveBeenCalled()
    });
  })

describe("inValidFrame", function(){
    it("is invalid if the frame has no text or photos", function(){
      this.view.model = new factory.statusMessage({text: '', photos : []})
      expect(this.view.inValidFrame).toBeTruthy();
    })
  });
});
