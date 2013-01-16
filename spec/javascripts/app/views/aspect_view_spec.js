describe("app.views.Aspect", function(){
  beforeEach(function(){
    this.aspect = new app.models.Aspect({ name: 'Acquaintances', selected: true });
    this.view = new app.views.Aspect({ model: this.aspect });
  });

  describe("render", function(){
    beforeEach(function(){
      this.view.render();
    });

    it('should show the aspect selected', function(){
      expect(this.view.$el.hasClass('active')).toBeTruthy();
    });

    it('should show the name of the aspect', function(){
      expect(this.view.$('a.aspect_selector').text()).toMatch('Acquaintances');
    });

    describe('selecting aspects', function(){
      beforeEach(function(){
        app.router = new app.Router();
        spyOn(app.router, 'aspects_stream');
        spyOn(this.view, 'toggleAspect').andCallThrough();
        this.view.delegateEvents();
      });

      it('it should deselect the aspect', function(){
        this.view.$('a.aspect_selector').trigger('click');
        expect(this.view.toggleAspect).toHaveBeenCalled();
        expect(this.view.$el.hasClass('active')).toBeFalsy();
        expect(app.router.aspects_stream).toHaveBeenCalled();
      });

      it('should call #toggleSelected on the model', function(){
        spyOn(this.aspect, 'toggleSelected');
        this.view.$('a.aspect_selector').trigger('click');
        expect(this.aspect.toggleSelected).toHaveBeenCalled();
      });
    });
  });
});
