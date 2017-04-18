// @license magnet:?xt=urn:btih:0b31508aeb0634b347b8270c7bee4d411b5d4109&dn=agpl-3.0.txt AGPL-v3-or-Later

app.views.Tags = app.views.Base.extend({
  initialize: function(opts) {
    if(app.publisher) {
      app.publisher.setText("#"+ opts.hashtagName + " ");
    }
    // add avatar fallback if it can't be loaded
    this.setupAvatarFallback($("#tags_show"));
  }
});
// @license-end
