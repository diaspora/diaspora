app.views.PostForm = app.views.Base.extend({
  templateName : "post-form",

  initialize : function(){
    console.log("In the form")
  },

  postRenderTemplate: function(){
    console.log("I'm getting rendered")
  }

});