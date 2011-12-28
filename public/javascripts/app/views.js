app.views.Base =  Backbone.View.extend({
  presenter : function(){
    return this.defaultPresenter()
  },

  defaultPresenter : function(){
    var modelJson = this.model ? this.model.toJSON() : {}
    return _.extend(modelJson, app.user());
  },

  render : function() {
    return this.renderTemplate().renderSubviews()
  },

  renderTemplate : function(){
    this.template = _.template($(this.template_name).html());
    var presenter = _.isFunction(this.presenter) ? this.presenter() : this.presenter
    $(this.el).html(this.template(presenter));
    this.postRenderTemplate();
    return this;
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

    return this
  }
})
