// @license magnet:?xt=urn:btih:0b31508aeb0634b347b8270c7bee4d411b5d4109&dn=agpl-3.0.txt AGPL-v3-or-Later
app.views.Search = app.views.SearchBase.extend({
  events: {
    "focusin #q": "toggleSearchActive",
    "focusout #q": "toggleSearchActive",
    "keypress #q": "inputKeypress"
  },

  initialize: function(){
    this.searchFormAction = this.$el.attr("action");
    app.views.SearchBase.prototype.initialize.call(this, {typeaheadElement: this.getTypeaheadElement()});
    this.bindMoreSelectionEvents();
    this.getTypeaheadElement().on("typeahead:select", this.suggestionSelected);
  },

  /**
   * This bind events to unselect all results when leaving the menu
   */
  bindMoreSelectionEvents: function(){
    var self = this;
    var onleave = function(){
      self.$(".tt-cursor").removeClass("tt-cursor");
    };

    this.getTypeaheadElement().on("typeahead:render", function(){
      self.$(".tt-menu").off("mouseleave", onleave);
      self.$(".tt-menu").on("mouseleave", onleave);
    });
  },

  getTypeaheadElement: function(){
    return this.$("#q");
  },

  toggleSearchActive: function(evt){
    // jQuery produces two events for focus/blur (for bubbling)
    // don't rely on which event arrives first, by allowing for both variants
    var isActive = (_.indexOf(["focus","focusin"], evt.type) !== -1);
    $(evt.target).toggleClass("active", isActive);
  },

  inputKeypress: function(evt){
    if(evt.which === 13 && $(".tt-suggestion.tt-cursor").length === 0){
      $(evt.target).closest("form").submit();
    }
  },

  suggestionSelected: function(evt, datum){
    window.location = datum.url;
  }
});
// @license-ends
