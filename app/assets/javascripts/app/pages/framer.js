app.pages.Framer = app.views.Base.extend({
  templateName : "flow",

  id : "post-content",

  subviews : {
    ".flow-content" : "postView",
    ".flow-controls .controls" : "framerControls"
  },

  initialize : function(){
    this.model = app.frame
    if(!this.model.get("frame_name")) this.model.setFrameName()

    this.model.authorIsCurrentUser = function(){ return true }
    this.model.bind("change:frame_name", this.render, this)
    this.model.bind("sync", this.navigateNext, this)

    this.framerControls = new app.views.framerControls({model : this.model})
  },

  unbind : function(){
    this.model.off()
  },

  postView : function(){
    return new app.views.Post.SmallFrame({model : this.model})
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
    "click input.done" : "saveFrame",
    "click input.back" : "editFrame",
    "change input" : "setFormAttrs"
  },

  subviews:{
    ".template-picker":'templatePicker',
    ".aspect-selector":"aspectsDropdown",
    ".service-selector":"servicesSelector"
  },

  formAttrs : {
    "input.mood:checked" : "frame_name",
    "input.aspect_ids" : "aspect_ids[]",
    "input.services" : "services[]"
  },

  initialize : function(){
    this.aspectsDropdown = new app.views.AspectsDropdown({model:this.model});
    this.servicesSelector = new app.views.ServicesSelector({model:this.model});
  },

  presenter : function() {
    var selectedFrame = this.model.get("frame_name")
      , templates = app.models.Post.frameMoods //subtract re-implemented templates
    return _.extend(this.defaultPresenter(), {
      templates :_.map(templates, function(template) {
        return {
          name : template,
          checked : selectedFrame === template
        }
      })
    })
  },

  saveFrame : function(){
    this.$('button').prop('disabled', 'disabled').addClass('disabled')
    this.setFormAttrs()
    this.model.save()
  },

  editFrame : function(){
    app.router.renderPage(function(){return new app.pages.Composer({model : app.frame})})
    app.router.navigate("/posts/new")
  }
});
