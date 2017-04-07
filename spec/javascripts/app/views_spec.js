describe("app.views.Base", function(){
  beforeEach(function(){
    var StaticTemplateClass = app.views.Base.extend({ templateName : "static-text" });
    this.model = new Backbone.Model({text : "model attributes are in the default presenter"});
    this.view = new StaticTemplateClass({model: this.model});
  });

  describe("#render", function(){
    beforeEach(function(){
      this.view.render();
    });

    it("throws an exception if no templateName was provided", function() {
      expect(function() {
        new app.views.Base().render();
      }).toThrow(new Error("No templateName set, set to false to ignore."));
    });

    it("does not throw an exception if templateName is set to false", function() {
      var ViewClass = app.views.Base.extend({
        templateName: false
      });

      new ViewClass().render();
    });

    it("throws an exception if an invalid templateName was provided", function() {
      expect(function() {
        var ViewClass = app.views.Base.extend({
          templateName: "noiamnotavalidtemplate"
        });

        new ViewClass().render();
      }).toThrow(new Error("Invalid templateName provided: noiamnotavalidtemplate"));
    });

    it("renders the template with the presenter", function(){
      expect($(this.view.el).text().trim()).toBe("model attributes are in the default presenter");
    });

    it("it evaluates the presenter every render", function(){
      this.model.set({text : "OMG It's a party" });
      this.view.render();
      expect($(this.view.el).text().trim()).toBe("OMG It's a party");
    });

    context("subViewRendering", function(){
      beforeEach(function(){
        var viewClass =  app.views.Base.extend({
            templateName : "static-text",
            subviews : {
              ".subview1": "subview1",
              ".subview2": "createSubview2"
            },

            initialize : function(){
              this.subview1 = stubView("OMG First Subview");
            },

            presenter: {
              text : "this comes through on the original render"
            },

            postRenderTemplate : function(){
              $(this.el).append("<div class=subview1/>");
              $(this.el).append("<div class=subview2/>");
            },

            createSubview2 : function(){
              return stubView("furreal this is the Second Subview");
            }
        });

        this.view = new viewClass().render();
      });

      it("respects the template rendered with the presenter", function(){
        expect(this.view.$('.text').text().trim()).toBe("this comes through on the original render");
      });

      it("renders subviews from views that are properties of the object", function(){
        expect(this.view.$('.subview1').text().trim()).toBe("OMG First Subview");
      });

      it("renders the sub views from functions", function(){
        expect(this.view.$('.subview2').text().trim()).toBe("furreal this is the Second Subview");
      });

      context("with nested matching elements", function() {
        var subviewInstance;

        beforeEach(function() {
          var counter = 0;
          var Subview = app.views.Base.extend({
            templateName: "static-text",

            className: "subview1", // making the internal view's div class match to the external one

            presenter: function() {
              return {text: "rendered " + ++counter + " times"};
            }
          });

          this.view.templateName = false; // this is also important specification for the test below
          this.view.subview1 = function() {
            subviewInstance = new Subview();
            return subviewInstance;
          };
        });

        it("properly handles nested selectors case", function() {
          this.view.render();
          this.view.render();
          subviewInstance.render();
          expect(this.view.$(".subview1 .subview1").text()).toBe("rendered 3 times");
        });
      });
    });

    context("calling out to third party plugins", function() {
      it("replaces .time with relative time ago in words", function() {
        this.view.templateName = false;
        spyOn($.fn, "timeago");
        this.view.$el.append("<time/>");
        this.view.render();
        expect($.fn.timeago).toHaveBeenCalled();
        expect($.fn.timeago.calls.mostRecent().object.first().is("time")).toBe(true);
      });

      it("initializes tooltips declared with the view's tooltipSelector property", function(){
        this.view.templateName = false;
        this.view.tooltipSelector = ".christopher_columbus, .barrack_obama, .block_user";
        this.view.$el.append("<div class='christopher_columbus barrack_obama block_user'/>");

        spyOn($.fn, "tooltip");
        this.view.render();
        expect(
          $.fn.tooltip.calls.mostRecent().object.is(".christopher_columbus, .barrack_obama, .block_user")
        ).toBe(true);
      });
    });
  });

  describe("#renderTemplate", function(){
    beforeEach(function() {
      this.view.$el.htmlOriginal = this.view.$el.html;
      spyOn(this.view.$el, "html").and.callFake(function() {
        this.htmlOriginal("<input><textarea/></input>");
        return this;
      });
    });

    it("calls jQuery.placeholder() for inputs", function() {
      spyOn($.fn, "placeholder");
      this.view.renderTemplate();
      expect($.fn.placeholder).toHaveBeenCalled();
      expect($.fn.placeholder.calls.mostRecent().object.is("input, textarea")).toBe(true);
    });

    it("initializes autosize for textareas", function(){
      spyOn(window, "autosize");
      this.view.renderTemplate();
      expect(window.autosize).toHaveBeenCalled();
      expect(window.autosize.calls.mostRecent().args[0].is("textarea")).toBe(true);
    });

    it("calls setupAvatarFallback", function() {
      spyOn(this.view, "setupAvatarFallback");
      this.view.renderTemplate();
      expect(this.view.setupAvatarFallback).toHaveBeenCalled();
    });
  });
});
