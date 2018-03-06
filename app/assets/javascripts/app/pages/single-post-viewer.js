// @license magnet:?xt=urn:btih:0b31508aeb0634b347b8270c7bee4d411b5d4109&dn=agpl-3.0.txt AGPL-v3-or-Later

app.pages.SinglePostViewer = app.views.Base.extend({
  templateName: "single-post-viewer",

  subviews: {
    "#single-post-content": "singlePostContentView",
    "#single-post-interactions": "singlePostInteractionsView"
  },

  initialize: function() {
    this.model = new app.models.Post(gon.post);
    this.initViews();
  },

  initViews: function() {
    this.singlePostContentView = new app.views.SinglePostContent({model: this.model});
    this.singlePostInteractionsView = new app.views.SinglePostInteractions({model: this.model});
    this.render();
  },

  postRenderTemplate: function() {
    if(this.model.get("title")){
      // formats title to html...
      var html_title = app.helpers.textFormatter(this.model.get("title"), this.model.get("mentioned_people"));
      //... and converts html to plain text
      document.title = $('<div>').html(html_title).text();
    }
  }
});
// @license-end
