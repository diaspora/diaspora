// @license magnet:?xt=urn:btih:0b31508aeb0634b347b8270c7bee4d411b5d4109&dn=agpl-3.0.txt AGPL-v3-or-Later

app.views.Aspect = app.views.Base.extend({
  templateName: "aspect",

  tagName: "li",

  className: 'hoverable',

  events: {
    "click .aspect-item": "toggleAspect"
  },

  toggleAspect: function(evt) {
    if (evt) { evt.preventDefault(); }
    this.model.toggleSelected();

    app.router.aspects_stream();
  },

  presenter : function() {
    return _.extend(this.defaultPresenter(), {
      aspect : this.model
    });
  }
});
// @license-end
