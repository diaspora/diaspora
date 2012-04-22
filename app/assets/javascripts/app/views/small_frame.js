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

    if(text.length > 240) {
      return "purple x2 width"
    } else if(text.length > 140) {
      return "green"
    } else if(text.length > 50) {
      return "cyan"
    } else {
      return "yellow"
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

    if(this.model.get("favorite")) {
      this.model.save({favorite : false})
    } else {
      this.model.save({favorite : true})
      this.$el.addClass("x2 width height")
    }
  },

  goToPost : function() {
    app.router.navigate(this.model.url(), true)
  }
});