/*   Copyright (c) 2010, Diaspora Inc.  This file is
*   licensed under the Affero General Public License version 3 or later.  See
*   the COPYRIGHT file.
*/

$("#edit_aspect_trigger").live("click", function() {
    EditPane.toggle();
});

var EditPane = {
  setTranslations: function(translations) {
    EditPane.translations = translations;
  },

  toggle: function() {
    if( $("#edit_aspect_pane").hasClass("active") ) {
      EditPane.fadeOut();
    } else {
      EditPane.fadeIn();
    }
  },

  fadeIn: function() {
    var trigger = $("#edit_aspect_trigger");

    $("#edit_aspect_pane").addClass("active");
    $(".contact_pictures").fadeOut(200, function() {
      $("#edit_aspect_pane").fadeIn(200);
      trigger.html(EditPane.translations.doneEditing);
    });
  },

  fadeOut: function() {
    var trigger = $("#edit_aspect_trigger");
    trigger.html(EditPane.translations.editAspect);

    $("#edit_aspect_pane").removeClass("active");
    $("#edit_aspect_pane").fadeOut(200, function() {
      $(".contact_pictures").fadeIn(200);
    });
  }
};
