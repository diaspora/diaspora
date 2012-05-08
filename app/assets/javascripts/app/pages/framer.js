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
    this.model.bind("sync", this.navigateToShow, this)

    this.framerControls = new app.views.framerControls({model : this.model})
  },

  postView : function(){
    return app.views.Post.showFactory(this.model)
  },

  navigateToShow : function(){
    app.router.navigate(app.currentUser.expProfileUrl(), {trigger: true, replace: true})
  }
})

app.views.framerControls = app.views.Base.extend({
  templateName : 'framer-controls',

  events : {
    "click button.done" : "saveFrame"
  },

  subviews : {
    ".template-picker" : 'templatePicker'
  },

  initialize : function(){
    this.templatePicker = new app.views.TemplatePicker({ model: this.model })
  },

  saveFrame : function(){
    this.$('button').prop('disabled', 'disabled')
    this.$('button').addClass('disabled')
    // this is gross hack to make this action work in the iframe version and not iframe version.
    var callback = {}
    var parentDoc = parent;

    if(parentDoc.location.pathname != '/framer'){
      callback = {success : function(){ parentDoc.closeIFrame() }}
    }

    this.model.save({}, callback)
  }
});

//crazy hack for model publisher.
function closeIFrame(){
  location = "/people/" + app.currentUser.get("guid")
};