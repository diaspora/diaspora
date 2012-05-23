//= require ../views/post/small_frame

app.pages.Framer = app.views.Base.extend({
  templateName : "flow",

  id : "post-content",

  subviews : {
    ".flow-content" : "framerContent",
    ".flow-controls .controls" : "framerControls"
  },

  initialize : function(){
    this.model = app.frame
    if(!this.model.get("frame_name")) this.model.setFrameName()

    this.model.authorIsCurrentUser = function(){ return true }
    this.model.bind("sync", this.navigateNext, this)

    this.framerContent = new app.views.framerContent({model : this.model})
    this.framerControls = new app.views.framerControls({model : this.model})
  },

  unbind : function(){
    this.model.off()
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

app.views.framerContent = app.views.Base.extend({
  templateName : "framer-content",

  events : {
    "change input" : "setFormAttrs"
  },

  subviews : {
    ".preview" : "smallFrameView",
    ".template-picker" : 'templatePicker'
  },

  formAttrs : {
    "input.mood:checked" : "frame_name"
  },

  initialize : function(){
    this.model.bind("change:frame_name", this.render, this)
  },

  smallFrameView : function() {
    return new app.views.Post.EditableSmallFrame({model : this.model})
  },

  presenter : function() {
    var selectedFrame = this.model.get("frame_name")
      , templates = this.model.applicableTemplates();  //new app.models.Post.TemplatePicker(this.model).frameMoods;

    return _.extend(this.defaultPresenter(), {
      templates : _.map(templates, function(template) {
        return {
          name : template,
          checked : selectedFrame === template
        }
      })
    })
  }
});

app.views.Post.EditableSmallFrame = app.views.Post.SmallFrame.extend({
  events : {
    "keyup [contentEditable]" : "setFormAttrs"
  },

  formAttrs : {
    ".text-content p" : "text"
  },

  postRenderTemplate : function(){
    this.$(".text-content p").attr("contentEditable", true)
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
    ".aspect-selector" : "aspectsDropdown",
    ".service-selector" : "servicesSelector"
  },

  formAttrs : {
    "input.aspect_ids" : "aspect_ids[]",
    "input.services" : "services[]"
  },

  initialize : function(){
    this.aspectsDropdown = new app.views.AspectsDropdown({model:this.model});
    this.servicesSelector = new app.views.ServicesSelector({model:this.model});
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
