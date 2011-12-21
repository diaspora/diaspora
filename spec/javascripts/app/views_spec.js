describe("App.Views.Base", function(){
  function stubView(text){
    var stubClass = Backbone.View.extend({
      render : function(){
        $(this.el).html(text)
      return this
      }
    })

    return new stubClass
  }

  describe("#render", function(){
    beforeEach(function(){
      var staticTemplateClass = App.Views.Base.extend({ template_name : "#static-text-template" })

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
        var viewClass =  App.Views.Base.extend({
            template_name : "#static-text-template",
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
              console.log($(this.el).html())
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
  })
})
