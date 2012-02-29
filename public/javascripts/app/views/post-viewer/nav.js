app.views.PostViewerNav = app.views.Base.extend({

  templateName: "post-viewer/nav",

  events : {
    "click a" : "pjax"
  },

  postRenderTemplate : function() {
    var mappings = {"#forward" : "next_post",
                    "#back" : "previous_post"};

    _.each(mappings, function(attribute, selector){
      this.setArrow(this.$(selector), this.model.get(attribute))
    }, this);
  },

  setArrow : function(arrow, loc) {
    loc ? arrow.attr('href', loc) : arrow.remove()
  },

  pjax : function(evt) {
    if(evt) { evt.preventDefault(); }
    var link;

    evt.target.tagName != "A" ? link = $(evt.target).closest("a") : link = $(evt.target)
    app.router.navigate(link.attr("href").substring(1), true)
  }

})

