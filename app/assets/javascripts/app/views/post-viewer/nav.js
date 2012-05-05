app.views.PostViewerNav = app.views.Base.extend({
  templateName: "post-viewer/nav",

  postRenderTemplate : function() {
    var mappings = {"#forward" : "next_post",
                    "#back" : "previous_post"};

    _.each(mappings, function(attribute, selector){
      this.setArrow(this.$(selector), this.model.get(attribute))
    }, this);
  },

  setArrow : function(arrow, loc) {
    loc ? arrow.attr('href', loc) : arrow.remove()
  }
});