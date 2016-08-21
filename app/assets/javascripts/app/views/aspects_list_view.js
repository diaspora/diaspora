// @license magnet:?xt=urn:btih:0b31508aeb0634b347b8270c7bee4d411b5d4109&dn=agpl-3.0.txt AGPL-v3-or-Later

app.views.AspectsList = app.views.Base.extend({
  templateName: 'aspects-list',

  el: '#aspects_list',

  events: {
    "click .toggle_selector" : "toggleAll"
  },

  subviews : {
    "#newAspectContainer" : "aspectCreateView"
  },

  initialize: function() {
    this.collection.on("change", this.toggleSelector, this);
    this.collection.on("aspectStreamFetched", this.updateAspectList, this);
    app.events.on("aspect:create", function(id) { window.location = "/contacts?a_id=" + id });
  },

  aspectCreateView: function() {
    return new app.views.AspectCreate();
  },

  postRenderTemplate: function() {
    this.collection.each(this.appendAspect, this);
    this.toggleSelector();
  },

  appendAspect: function(aspect) {
    $("#aspects_list > .hoverable:last").before(new app.views.Aspect({
      model: aspect, attributes: {'data-aspect_id': aspect.get('id')}
    }).render().el);
  },

  toggleAll: function(evt) {
    if (evt) { evt.preventDefault(); }

    if (this.collection.allSelected()) {
      this.collection.deselectAll();
    } else {
      this.collection.selectAll();
    }

    this.toggleSelector();
    app.router.aspects_stream();
  },

  toggleSelector: function() {
    var selector = this.$('a.toggle_selector');
    if (this.collection.allSelected()) {
      selector.text(Diaspora.I18n.t('aspect_navigation.deselect_all'));
    } else {
      selector.text(Diaspora.I18n.t('aspect_navigation.select_all'));
    }
  },

  updateAspectList: function() {
    this.collection.each(function(aspect) {
      var element = this.$("li[data-aspect_id="+aspect.get("id")+"]");
      if (aspect.get("selected")) {
        element.find(".entypo-check").addClass("selected");
      } else {
        element.find(".entypo-check").removeClass("selected");
      }
    });
  },

  hideAspectsList: function() {
    this.$el.empty();
  }
});
// @license-end
