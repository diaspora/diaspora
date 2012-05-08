app.models.Photo = Backbone.Model.extend(_.extend({}, app.models.formatDateMixin, {
  urlRoot : "/photos",

  initialize : function() {},

}));
