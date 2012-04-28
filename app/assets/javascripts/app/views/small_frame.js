//= require "./post_view"

app.views.SmallFrame = app.views.Post.extend({

  SINGLE_COLUMN_WIDTH : 265,
  DOUBLE_COLUMN_WIDTH : 560,

  className : "canvas-frame",

  templateName : "small-frame",

  events : {
    "click .content" : "favoritePost",
    "click .delete" : "killPost",
    "click .info" : "goToPost"
  },

  subviews : {
    '.embed-frame' : "oEmbedView"
  },

  oEmbedView : function(){
    return new app.views.OEmbed({model : this.model})
  },

  presenter : function(){
    //todo : we need to have something better for small frame text, probably using the headline() scenario.
    return _.extend(this.defaultPresenter(),
      {text : this.model && app.helpers.textFormatter(this.model.get("text"), this.model),
       adjustedImageHeight : this.adjustedImageHeight()})
  },

  initialize : function() {
    this.$el.addClass([this.dimensionsClass(), this.colorClass(), this.frameClass()].join(' '))
    return this;
  },

  postRenderTemplate : function() {
    this.$el.addClass([this.dimensionsClass(), this.colorClass(), this.frameClass()].join(' '))
  },

  frameClass : function(){
    var name = this.model.get("frame_name") || ""
    return name.toLowerCase()
  },

  colorClass : function() {
    var text = this.model.get("text")
      , baseClass = $.trim(text).length == 0 ? "no-text" : 'has-text';

    if(baseClass == "no-text" || this.model.get("photos").length > 0 || this.model.get("o_embed_cache")) { return baseClass }

    var randomColor = _.first(_.shuffle(['cyan', 'green', 'yellow', 'purple', 'lime-green', 'orange', 'red', 'turquoise', 'sand']));

    var textClass;
    if(text.length > 240) {
      textClass = "blog-text x2 width"
    } else if(text.length > 140) {
      textClass = randomColor
    } else if(text.length > 40) {
      textClass = randomColor
    } else {
      textClass =  "big-text " + randomColor
    }

    return [baseClass, textClass, "sticky-note"].join(" ")
  },

  dimensionsClass : function() {
    return (this.model.get("favorite")) ?  "x2 width height" : ""
  },

  adjustedImageHeight : function() {
    if(!this.model.get("photos")[0]) { return }

    var modifiers = [this.dimensionsClass(), this.colorClass()].join(' ')

    var firstPhoto = this.model.get("photos")[0]
      , width = (modifiers.search("x2") != -1 ? this.DOUBLE_COLUMN_WIDTH : this.SINGLE_COLUMN_WIDTH)
      , ratio = width / firstPhoto.dimensions.width;

    return(ratio * firstPhoto.dimensions.height)
  },

  favoritePost : function(evt) {
    if(evt) {
      /* follow links instead of faving the targeted post */
      if($(evt.target).is('a')) { return }

      evt.stopImmediatePropagation(); evt.preventDefault();
    }

    var prevDimension = this.dimensionsClass();
    this.model.toggleFavorite();

    this.$el.removeClass(prevDimension)
    this.render()

    app.page.stream.trigger("reLayout")
    //trigger moar relayouts in the case of images WHOA GROSS HAX
    _.delay(function(){app.page.stream.trigger("reLayout")}, 200)
    _.delay(function(){app.page.stream.trigger("reLayout")}, 500)
  },

  killPost : function(){
    this.destroyModel()
    _.delay(function(){app.page.stream.trigger("reLayout")}, 0)
  },

  goToPost : function(evt) {
    if(evt) { evt.stopImmediatePropagation(); }
    app.router.navigate(this.model.url(), true)
  }
});