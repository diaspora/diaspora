app.views.StreamObject = app.views.Base.extend({

  postRenderTemplate : function() {
    // collapse long posts
    this.$(".collapsible").expander({
      slicePoint: 400,
      widow: 12,
      expandPrefix: "",
      expandText: Diaspora.I18n.t("show_more"),
      userCollapse: false,
      beforeExpand: function() {
        if ($(this).find('.summary').length == 0) { // Sigh. See comments in the spec.
          var readMoreDiv = $(this).find('.read-more');
          var lastElementBeforeReadMore = readMoreDiv.prev();
          var firstElementAfterReadMore = readMoreDiv.next().children().first();

          if (lastElementBeforeReadMore.is('p')) {
            lastElementBeforeReadMore.append(firstElementAfterReadMore.html());
            firstElementAfterReadMore.remove();

          } else if (lastElementBeforeReadMore.is('ul') && firstElementAfterReadMore.is('ul')) {
            var firstBullet = firstElementAfterReadMore.children().first();
            lastElementBeforeReadMore.find('li').last().append(firstBullet.html());
            firstBullet.remove();
          }
          readMoreDiv.remove();
        }
      }
    });
  },

  destroyModel: function(evt) {
    if (evt) {
      evt.preventDefault();
    }
    if (!confirm(Diaspora.I18n.t("confirm_dialog"))) {
      return
    }

    this.model.destroy();
    this.slideAndRemove();
  },

  slideAndRemove : function() {
    $(this.el).slideUp(400, function() {
      $(this).remove();
    });
  }
});
