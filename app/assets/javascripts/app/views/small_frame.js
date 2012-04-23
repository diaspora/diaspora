app.views.SmallFrame = app.views.Base.extend({

  className : "canvas-frame",

  templateName : "small-frame",

  events : {
    "click .fav" : "favoritePost",
    "click .content" : "goToPost"
  },

  presenter : function(){
    //todo : we need to have something better for small frame text, probably using the headline() scenario.
    return _.extend(this.defaultPresenter(),
      {text : this.model && app.helpers.textFormatter(this.model.get("text"), this.model)})
  },

  postRenderTemplate : function() {
    this.$el.addClass(this.dimensionsClass() + " " + this.colorClass())
  },

  colorClass : function() {
    var text = this.model.get("text");
    if(text == "" || this.model.get("photos").length > 0) { return "" }
    var randomColor = _.first(_.shuffle(['cyan', 'green', 'yellow', 'purple', 'lime-green', 'orange', 'red', 'turquoise', 'sand']));
    randomColor += " sticky-note"
    
    if(text.length > 240) {
      return "blog-text x2 width"
    } else if(text.length > 140) {
      return randomColor
    } else if(text.length > 50) {
      return randomColor
    } else {
      return "big-text " + randomColor
    }
  },


  dimensionsClass : function() {
    /* by default, make it big if it's a fav */
    if(this.model.get("favorite")) { return "x2 width height" }

    var firstPhoto = this.model.get("photos")[0]
      , className = "photo ";

    if(!firstPhoto ||
      (firstPhoto && !firstPhoto.dimensions.height || !firstPhoto.dimensions.width)) { return "" }

    if(this.model.get("o_embed_cache")) {
      return("x2 width")
    }
    return ''
    return(className + ratio(firstPhoto.dimensions))

    function ratio(dimensions) {
      var ratio = (dimensions.width / dimensions.height)

      if(ratio > 1.5) {
        return "x2 width"
      } else if(ratio < 0.75) {
        return "x2 height"
      } else {
        if(ratio > 1) {
          return "scale-vertical"
        } else {
          return "scale-horizontal"
        }
      }
    }
  },

  favoritePost : function(evt) {
    if(evt) { evt.stopImmediatePropagation(); evt.preventDefault() }

    var prevDimension = this.dimensionsClass();
    this.model.toggleFavorite();

    this.$el.removeClass(prevDimension)
    this.render()

    app.page.stream.trigger("reLayout")
  },

  goToPost : function() {
    app.router.navigate(this.model.url(), true)
  }
});