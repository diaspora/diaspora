app.views.Base =  Backbone.View.extend({
  presenter : function(){
    return this.defaultPresenter()
  },

  setupRenderEvents : function(){
    this.model.bind('remove', this.remove, this);
    this.model.bind('change', this.render, this);
  },

  defaultPresenter : function(){
    var modelJson = this.model ? this.model.toJSON() : {}
    return _.extend(modelJson, {current_user: app.user()});
  },

  render : function() {
    this.renderTemplate()
    this.renderSubviews()
    this.renderPluginWidgets()

    return this
  },

  renderTemplate : function(){
    var templateHTML //don't forget to regenerate your jasmine fixtures ;-)
    var presenter = _.isFunction(this.presenter) ? this.presenter() : this.presenter

    if(this.legacyTemplate) {
      templateHTML = $(this.template_name).html();
      this.template = _.template(templateHTML);
    } else {
      window.templateCache = window.templateCache || {}
      templateHTML = $("#" + this.templateName + "-template").html(); //don't forget to regenerate your jasmine fixtures ;-)
      this.template = templateCache[this.templateName] = templateCache[this.templateName] || Handlebars.compile(templateHTML);
    }

    $(this.el).html(this.template(presenter));
    this.postRenderTemplate();
  },

  postRenderTemplate : $.noop, //hella callbax yo

  renderSubviews : function(){
    var self = this;
    _.each(this.subviews, function(property, selector){
      var view = _.isFunction(self[property]) ? self[property]() : self[property]
      if(view) {
        self.$(selector).html(view.render().el)
        view.delegateEvents();
      }
    })
  },

  renderPluginWidgets : function() {
    this.$(this.tooltipSelector).twipsy();
    this.$("time").timeago();
  }
})
