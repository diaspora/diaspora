// @license magnet:?xt=urn:btih:0b31508aeb0634b347b8270c7bee4d411b5d4109&dn=agpl-3.0.txt AGPL-v3-or-Later

//= require jquery.autoSuggest.custom
app.views.TagFollowingList = app.views.Base.extend({

  templateName: "tag_following_list",

  className : "sub_nav",

  id : "tags_list",

  tagName : "ul",

  events: {
    "submit form": "createTagFollowing"
  },

  initialize : function(){
    this.collection.on("add", this.appendTagFollowing, this);
    this.collection.on("reset", this.postRenderTemplate, this);
  },

  postRenderTemplate : function() {
    this.collection.each(this.appendTagFollowing, this);
  },

  setupAutoSuggest : function() {
    this.$("input").autoSuggest("/tags", {
      selectedItemProp: "name",
      selectedValuesProp: "name",
      searchObjProps: "name",
      asHtmlID: "tags",
      neverSubmit: true,
      retrieveLimit: 10,
      selectionLimit: false,
      minChars: 2,
      keyDelay: 200,
      startText: "",
      emptyText: "no_results",
      selectionAdded: _.bind(this.suggestSelection, this)
    });

    this.$("input").bind('keydown', function(evt){
      if(evt.keyCode === 13 || evt.keyCode === 9 || evt.keyCode === 32){
        evt.preventDefault();
        if( $('li.as-result-item.active').length === 0 ){
          $('li.as-result-item').first().click();
        }
      }
    });
  },

  presenter : function() {
    return this.defaultPresenter();
  },

  suggestSelection : function(elem) {
    this.$(".tag_input").val($(elem[0]).text().substring(2));
    elem.remove();
    this.createTagFollowing();
  },

  createTagFollowing: function(evt) {
    if(evt){ evt.preventDefault(); }

    this.collection.create({"name":this.$(".tag_input").val()});
    this.$(".tag_input").val("");
    return this;
  },

  appendTagFollowing: function(tag) {
    this.$el.prepend(new app.views.TagFollowing({
      model: tag
    }).render().el);
  },

  hideFollowedTags: function() {
    this.$el.empty();
  },
});
// @license-end
