app.views.Aspect = app.views.Base.extend({
  templateName: "aspect",

  tagName: "li",

  presenter : function() {
    return _.extend(this.defaultPresenter(), {
      aspect : this.model
    })
  }
});
