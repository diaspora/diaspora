// @license magnet:?xt=urn:btih:0b31508aeb0634b347b8270c7bee4d411b5d4109&dn=agpl-3.0.txt AGPL-v3-or-Later

// Mixin to provide date formatting and "createdAt" method
// other attributes can be accessed by calling this.timeOf("timestamp-field")
//  Requires:
//    this = model with "created_at" attribute
app.models.formatDateMixin = {
  timeOf: function(field) {
    return app.helpers.dateFormatter.parse(this.get(field)) / 1000;
  },

  createdAt: function() {
    return this.timeOf("created_at");
  }
};
// @license-end
