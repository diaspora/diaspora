// @license magnet:?xt=urn:btih:0b31508aeb0634b347b8270c7bee4d411b5d4109&dn=agpl-3.0.txt AGPL-v3-or-Later
var View = {
  initialize: function() {
    /* label placeholders */
    $("input, textarea").placeholder();

    /* "Toggling" the search input */
    $(this.search.selector)
      .blur(this.search.blur)
      .focus(this.search.focus)

    /* Submit the form when the user hits enter */
      .keypress(this.search.keyPress);

    $(document).on('ajax:success', 'form[data-remote]', function () {
      $(this).clearForm();
      $(this).focusout();
    });

    /* tag following */
    $("#new_tag_following .tag_input").bind('focus', function(){
      $(this).siblings("#tag_following_submit").removeClass('hidden');
    });

    $('a[rel*=facebox]').facebox();
    $(document).bind('reveal.facebox', function() {
      Diaspora.page.directionDetector.updateBinds();
    });

    /* facebox 'done' buttons */
    $(document).on('click', "*[rel*=close]", function(){ $.facebox.close(); });
  },

  search: {
    blur: function() {
      $(this).removeClass("active");
    },
    focus: function() {
      $(this).addClass("active");
    },
    selector: "#q"
  },
};

$(function() {
  View.initialize();
});
// @license-end
