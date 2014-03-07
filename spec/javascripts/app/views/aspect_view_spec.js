describe("app.views.Aspect", function(){
  beforeEach(function(){
    this.aspect = factory.aspect({selected:true});
    this.view = new app.views.Aspect({ model: this.aspect });
  });

  describe("render", function(){
    beforeEach(function(){
      this.view.render();
    });

    it('should show the aspect selected', function(){
      expect(this.view.$el.children('.icons-check_yes_ok').hasClass('selected')).toBeTruthy();
    });

    it('should show the name of the aspect', function(){
      expect(this.view.$el.children('a.selectable').text()).toMatch(this.aspect.get('name'));
    });

    describe('selecting aspects', function(){
      beforeEach(function(){
        app.router = new app.Router();
        spyOn(app.router, 'aspects_stream');
        spyOn(this.view, 'toggleAspect').and.callThrough();
        this.view.delegateEvents();
      });

      it('it should deselect the aspect', function(){
        this.view.$el.children('a.selectable').trigger('click');
        expect(this.view.toggleAspect).toHaveBeenCalled();
        expect(this.view.$el.children('.icons-check_yes_ok').hasClass('selected')).toBeFalsy();
        expect(app.router.aspects_stream).toHaveBeenCalled();
      });

      it('should call #toggleSelected on the model', function(){
        spyOn(this.aspect, 'toggleSelected');
        this.view.$el.children('a.selectable').trigger('click');
        expect(this.aspect.toggleSelected).toHaveBeenCalled();
      });
    });
  });
});
