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
      body : app.helpers.textFormatter(model.body(), model)
    })
  },

  photoViewer : function(){
    return new app.views.PhotoViewer({ model : this.model })
  },
});

app.views.Post.Day = app.views.Post.Mood.extend({
  mood : "newspaper"
})

app.views.Post.Newspaper = app.views.Post.Mood.extend({
  mood : "newspaper"
})

app.views.Post.Wallpaper = app.views.Post.Mood.extend({
  mood : "newspaper",
})