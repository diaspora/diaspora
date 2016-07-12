// @license magnet:?xt=urn:btih:0b31508aeb0634b347b8270c7bee4d411b5d4109&dn=agpl-3.0.txt AGPL-v3-or-Later

app.collections.AspectSelections = Backbone.Collection.extend({
  model: app.models.AspectSelection,

  selectedGetAttribute: function(attribute) {
    return _.pluck(_.filter(this.toJSON(), function(a) {
      return a.selected;
    }), attribute);
  },

  allSelected: function() {
    return this.length === _.filter(this.toJSON(), function(a) { return a.selected; }).length;
  },

  selectAll: function() {
    this.map(function(a) { a.set({"selected": true}); });
  },

  deselectAll: function() {
    this.map(function(a) { a.set({"selected": false}); });
  },

  toSentence: function() {
    var separator = Diaspora.I18n.t("comma") + " ";
    var pattern = new RegExp(Diaspora.I18n.t("comma") + "\\s([^" + Diaspora.I18n.t("comma") + "]+)$");
    return this.selectedGetAttribute("name").join(separator).replace(pattern, " " + Diaspora.I18n.t("and") + " $1")
      || Diaspora.I18n.t("my_aspects");
  }
});
// @license-end
