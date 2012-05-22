//= require ../post_view
app.views.Post.Mood = app.views.Post.extend({
  templateName : "mood",
  className : "post loaded",
  tagName : "article",
  subviews : { "section.photo_viewer" : "photoViewer" },

  initialize : function(){
    $(this.el).addClass(this.mood)
  },

  presenter : function(){
    var model = this.model
    return _.extend(this.defaultPresenter(), {
      headline : $(app.helpers.textFormatter(model.headline(), model)).html(),
      body : app.helpers.textFormatter(model.body(), model)
    })
  },

  photoViewer : function(){
    return new app.views.PhotoViewer({ model : this.model })
  },

  postRenderTemplate : function(){
    if(this.model.body().length < 200){
      this.$('section.body').addClass('short_body');
    }
  }
});

app.views.Post.Day = app.views.Post.Mood.extend({
  mood : "day"
})

app.views.Post.Night = app.views.Post.Mood.extend({
  mood : "night"
})

app.views.Post.Newspaper = app.views.Post.Mood.extend({
  mood : "newspaper"
})

app.views.Post.Wallpaper = app.views.Post.Mood.extend({
  mood : "wallpaper",
  templateName : "wallpaper-mood",


  presenter : function(){
    var backgroundPhoto = _.first(this.model.get("photos") || [])
    return _.extend(app.views.Post.Mood.prototype.presenter.call(this), {
      backgroundUrl : backgroundPhoto && backgroundPhoto.sizes.large
    })
  }
})

app.views.Post.Typist = app.views.Post.Mood.extend({
  mood : "typist"
})

app.views.Post.Vanilla = app.views.Post.Mood.extend({
  mood : "vanilla"
})

app.views.Post.Fridge = app.views.Post.Mood.extend({
  mood : "fridge"
})