// @license magnet:?xt=urn:btih:0b31508aeb0634b347b8270c7bee4d411b5d4109&dn=agpl-3.0.txt AGPL-v3-or-Later
var View = {
  initialize: function() {
    /* label placeholders */
    $("input, textarea").placeholder();

    $(document).on('ajax:success', 'form[data-remote]', function () {
      $(this).clearForm();
      $(this).focusout();
    });

    /* tag following */
    $("#new_tag_following .tag_input").bind('focus', function(){
      $(this).siblings("#tag_following_submit").removeClass('hidden');
    });
  },
};

$(function() {
  View.initialize();
});
// @license-end
