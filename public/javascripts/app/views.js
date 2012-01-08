app.views.Base =  Backbone.View.extend({
  presenter : function(){
    return this.defaultPresenter()
  },

  defaultPresenter : function(){
    var modelJson = this.model ? this.model.toJSON() : {}
    return _.extend(modelJson, app.user());
  },

  render : function() {
    this.renderTemplate()
    this.renderSubviews()
    this.renderPluginWidgets()

    return this
  },

  renderTemplate : function(){
    this.template = _.template($(this.template_name).html());
    var presenter = _.isFunction(this.presenter) ? this.presenter() : this.presenter
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
