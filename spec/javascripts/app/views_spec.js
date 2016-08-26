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
        spyOn($.fn, "timeago");
        this.view.render();
        expect($.fn.timeago).toHaveBeenCalled();
        expect($.fn.timeago.calls.mostRecent().object.selector).toBe("time");
      });

      it("initializes tooltips declared with the view's tooltipSelector property", function(){
        this.view.tooltipSelector = ".christopher_columbus, .barrack_obama, .block_user";

        spyOn($.fn, "tooltip");
        this.view.render();
        expect($.fn.tooltip.calls.mostRecent().object.selector).toBe(".christopher_columbus, .barrack_obama, .block_user");
      });

      it("applies infield labels", function(){
        spyOn($.fn, "placeholder");
        this.view.render();
        expect($.fn.placeholder).toHaveBeenCalled();
        expect($.fn.placeholder.calls.mostRecent().object.selector).toBe("input, textarea");
      });
    });
  });

  describe("#renderTemplate", function(){
    it("calls jQuery.placeholder() for inputs", function() {
      spyOn($.fn, "placeholder");
      this.view.renderTemplate();
      expect($.fn.placeholder).toHaveBeenCalled();
      expect($.fn.placeholder.calls.mostRecent().object.selector).toBe("input, textarea");
    });

    it("initializes autosize for textareas", function(){
      spyOn(window, "autosize");
      this.view.renderTemplate();
      expect(window.autosize).toHaveBeenCalled();
      expect(window.autosize.calls.mostRecent().args[0].selector).toBe("textarea");
    });
  });
});
