app.pages.Framer = app.views.Base.extend({
  templateName : "framer",

  events : {
    "click button.done" : "saveFrame"
  },

  saveFrame : function(){
    console.log(app.frame.toJSON(), app.frame)
    app.frame.save()
  }
})