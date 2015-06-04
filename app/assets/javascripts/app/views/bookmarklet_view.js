// @license magnet:?xt=urn:btih:0b31508aeb0634b347b8270c7bee4d411b5d4109&dn=agpl-3.0.txt AGPL-v3-or-Later

app.views.Bookmarklet = Backbone.View.extend({
  separator: "\n\n",

  initialize: function(opts) {
    // init a standalone publisher
    app.publisher = new app.views.Publisher({standalone: true});

    app.publisher.on("publisher:add", this._postSubmit, this);
    app.publisher.on("publisher:sync", this._postSuccess, this);
    app.publisher.on("publisher:error", this._postError, this);

    this.param_contents = opts;
  },

  render: function() {
    app.publisher.open();
    app.publisher.setText(this._publisherContent());

    return this;
  },

  _publisherContent: function() {
    var p = this.param_contents;
    if( p.content ) return p.content;

    var contents = "### " + p.title + this.separator;
    if( p.notes ) {
      var notes = p.notes.toString().replace(/(?:\r\n|\r|\n)/g, "\n> ");
      contents += "> " + notes + this.separator;
    }
    contents += p.url;
    return contents;
  },

  _postSubmit: function() {
    this.$("h4").text(Diaspora.I18n.t("bookmarklet.post_submit"));
  },

  _postSuccess: function() {
    this.$("h4").text(Diaspora.I18n.t("bookmarklet.post_success"));
    app.publisher.close();
    this.$("#publisher").addClass("hidden");
    _.delay(window.close, 2000);
  },

  _postError: function() {
    this.$("h4").text(Diaspora.I18n.t("bookmarklet.post_something"));
  }
});
// @license-end

