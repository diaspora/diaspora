app.views.SmallFrame = app.views.Base.extend({

  className : "canvas-frame",

  templateName : "small-frame",

  events : {
    "click .content" : "goToPost"
  },

  presenter : function(){
    //todo : we need to have something better for small frame text, probably using the headline() scenario.
    return _.extend(this.defaultPresenter(),
      {text : this.model && app.helpers.textFormatter(this.model.get("text"), this.model)})
  },

  postRenderTemplate : function() {
    this.$el.addClass(this.dimensionsClass())
  },

  dimensionsClass : function() {
    var firstPhoto = this.model.get("photos")[0]
      , className = "photo ";

    if(!firstPhoto ||
      (firstPhoto && !firstPhoto.dimensions.height || !firstPhoto.dimensions.width)) { return className }

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

//  textClass : function(){
//    var textLength = this.model.get("text").length
//      , baseClass = "text ";
//
//    if(textLength <= 20){
//      return baseClass + "extra-small"
//    } else if(textLength <= 140) {
//      return baseClass + "small"
//    } else if(textLength <= 500) {
//      return baseClass + "medium"
//    } else {
//      return baseClass + "large"
//    }
//  },
//
//  photoClass : function(){
//    var photoCount = this.model.get('photos').length
//      , baseClass  = "photo ";
//
//    if(photoCount == 0 ) {
//      return ""
//    } else if(photoCount == 1){
//      return baseClass + 'one'
//    } else if(photoCount == 2 ) {
//      return baseClass + 'two'
//    } else {
//      return baseClass + 'many'
//    }
//  },

  goToPost : function() {
    app.router.navigate(this.model.url(), true)
  }
});