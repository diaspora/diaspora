(function() {
  Diaspora.Mobile.Gallery = {
    initialize: function() {
      $(".photo_attachments").each(function() {
        new Diaspora.Gallery({el: $(this)});
      });
    }
  };
})();

$(function() {
  Diaspora.Mobile.Gallery.initialize();
});
