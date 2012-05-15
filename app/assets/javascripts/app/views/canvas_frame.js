//= require ./small_frame

app.views.CanvasFrame = app.views.SmallFrame.extend({

  SINGLE_COLUMN_WIDTH : 265,
  DOUBLE_COLUMN_WIDTH : 560,

  adjustedImageHeight : function() {
    if(!(this.model.get("photos") || [])[0]) { return }

    var modifiers = [this.dimensionsClass(), this.colorClass()].join(' ')
      , width;

    /* mobile width
     *
     *  currently does not re-calculate on orientation change */
    if($(window).width() <= 767) {
      width = $(window).width();
    }

    var firstPhoto = this.model.get("photos")[0]
      , width = width || (modifiers.search("x2") != -1 ? this.DOUBLE_COLUMN_WIDTH : this.SINGLE_COLUMN_WIDTH)
      , ratio = width / firstPhoto.dimensions.width;

    return(ratio * firstPhoto.dimensions.height)
  },

  presenter : function(){
    return _.extend(this.smallFramePresenter(), {
      adjustedImageHeight : this.adjustedImageHeight()
    })
  }
});
