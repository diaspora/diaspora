// @license magnet:?xt=urn:btih:0b31508aeb0634b347b8270c7bee4d411b5d4109&dn=agpl-3.0.txt AGPL-v3-or-Later

app.views.PhotoViewer = app.views.Base.extend({
  templateName : "photo-viewer",

  presenter : function(){
    return { photos : this.model.get("photos") } //json array of attributes, not backbone models, yet.
  }
});
// @license-end

