app.views.SinglePost = app.views.Post.extend({

  /* SINGLE POST SHOULD BE BROKEN OUT INTO A PAGE VIEW!!!! */

  className : "loaded",

  postRenderTemplate : function() {
    /* nav should be a subview! and tested! (this is some prototyping stuff right here... */
    this.setNav();

    /* post author info should be a subview!  and tested! */
    this.setAuthor();

    /* post author info should be a subview!  and tested! */
    this.setFeedback();
  },

  setNav : function() {
    var mappings = {"#forward" : "next_post",
                    "#back" : "previous_post"};

    _.each(mappings, function(attribute, selector){
      this.setArrow($(selector), this.model.get(attribute))
    }, this);

    this.setMappings();
  },

  setArrow : function(arrow, loc) {
    loc ? arrow.attr('href', loc) : arrow.remove()
  },

  setMappings : function() {
    var nextPostLocation = this.model.get("next_post");
    var previousPostLocation = this.model.get("previous_post");
    var doc = $(document);

    /* focus modal */
    doc.keypress(function(event){
      $('#text').focus();
      $('#comment').modal();
    });

    /* navagation hooks */
    doc.keydown(function(e){
      if (e.keyCode == 37 && nextPostLocation) {
        window.location = nextPostLocation

      }else if(e.keyCode == 39 && previousPostLocation) {
        window.location = previousPostLocation
      }
    })
  },

  setAuthor : function() {
    // author avatar
    // time of post
    // reshared via... (if appliciable)
  },

  setFeedback : function() {
    // go back to profile (app.user())
    // liking
    // following
    // resharing
    // commenting
  }

});
