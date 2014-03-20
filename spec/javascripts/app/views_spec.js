describe("app.views.Base", function(){
  describe("#render", function(){
    beforeEach(function(){
      var staticTemplateClass = app.views.Base.extend({ templateName : "static-text" })

      this.model = new Backbone.Model({text : "model attributes are in the default presenter"})
      this.view = new staticTemplateClass({model: this.model})
      this.view.render()
    })

    it("renders the template with the presenter", function(){
      expect($(this.view.el).text().trim()).toBe("model attributes are in the default presenter")
    })

    it("it evaluates the presenter every render", function(){
      this.model.set({text : "OMG It's a party" })
      this.view.render()
      expect($(this.view.el).text().trim()).toBe("OMG It's a party")
    })

    context("subViewRendering", function(){
      beforeEach(function(){
        var viewClass =  app.views.Base.extend({
            templateName : "static-text",
            subviews : {
              ".subview1": "subview1",
              ".subview2": "createSubview2"
            },

            initialize : function(){
              this.subview1 = stubView("OMG First Subview")
            },

            presenter: {
              text : "this comes through on the original render"
            },

            postRenderTemplate : function(){
              $(this.el).append("<div class=subview1/>")
              $(this.el).append("<div class=subview2/>")
            },

            createSubview2 : function(){
              return stubView("furreal this is the Second Subview")
            }
        })

        this.view = new viewClass().render()
      })

      it("repsects the respects the template rendered with the presenter", function(){
        expect(this.view.$('.text').text().trim()).toBe("this comes through on the original render")
      })

      it("renders subviews from views that are properties of the object", function(){
        expect(this.view.$('.subview1').text().trim()).toBe("OMG First Subview")
      })

      it("renders the sub views from functions", function(){
        expect(this.view.$('.subview2').text().trim()).toBe("furreal this is the Second Subview")
      })
    })

    context("calling out to third party plugins", function(){
      it("replaces .time with relative time ago in words", function(){
        spyOn($.fn, "timeago")
        this.view.render()
        expect($.fn.timeago).toHaveBeenCalled()
        expect($.fn.timeago.calls.mostRecent().object.selector).toBe("time")
      })


      it("initializes tooltips declared with the view's tooltipSelector property", function(){
        this.view.tooltipSelector = ".christopher_columbus, .barrack_obama, .block_user"

        spyOn($.fn, "tooltip")
        this.view.render()
        expect($.fn.tooltip.calls.mostRecent().object.selector).toBe(".christopher_columbus, .barrack_obama, .block_user")
      })
    })
  })
})
