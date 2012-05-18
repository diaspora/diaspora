app.pages.Framer = app.views.Base.extend({
  templateName : "flow",

  id : "post-content",

  subviews : {
    ".flow-content" : "postView",
    ".flow-controls .controls" : "framerControls"
  },

  initialize : function(){
    this.model = app.frame
    this.model.authorIsCurrentUser = function(){ return true }

    this.model.bind("change", this.render, this)
    this.model.bind("sync", this.navigateNext, this)

    this.framerControls = new app.views.framerControls({model : this.model})
  },

  unbind : function(){
    this.model.off()
  },

  postView : function(){
    return new app.views.SmallFrame({model : this.model})
  },

  navigateNext : function(){
    if(parent.location.pathname == '/new_bookmarklet') {
      this.bookmarkletNavigation()
    } else {
      this.defaultNavigation()
    }
  },

  bookmarkletNavigation : function() {
    parent.close()
  },

  defaultNavigation : function() {
    var url = app.currentUser.expProfileUrl()
    app.router.navigate(url, {trigger: true, replace: true})
  }
});

app.views.framerControls = app.views.Base.extend({
  templateName : 'framer-controls',

  events : {
    "click button.done" : "saveFrame",
    "click button.back" : "editFrame"
  },

  subviews : {
    ".template-picker" : 'templatePicker'
  },

  initialize : function(){
    this.templatePicker = new app.views.TemplatePicker({model: this.model})
  },

  saveFrame : function(){
    this.$('button').prop('disabled', 'disabled').addClass('disabled')
    this.model.save()
  },

  editFrame : function(){
    app.router.renderPage(function(){return new app.pages.Composer({model : app.frame})})
    app.router.navigate("/posts/new")
  }
});
