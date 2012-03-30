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
      headline : model.headline(),
      body : model.body()
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

app.views.Post.Wallpaper = app.views.Post.Mood.extend({
  mood : "wallpaper",
  templateName : "wallpaper-mood"
})
