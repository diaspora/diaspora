// @license magnet:?xt=urn:btih:0b31508aeb0634b347b8270c7bee4d411b5d4109&dn=agpl-3.0.txt AGPL-v3-or-Later
$(document).ready(function(){
  $(document).on('click', '.conversation-wrapper', function(){
    var conversation_path = $(this).data('conversation-path');
    $.getScript(conversation_path, function() {
      Diaspora.page.directionDetector.updateBinds();
    });
    history.pushState(null, "", conversation_path);
    return false;
  });

  $(window).bind("popstate", function(){
    if (location.href.match(/conversations\/\d+/) !== null) {
      $.getScript(location.href, function() {
        Diaspora.page.directionDetector.updateBinds();
      });
      return false;
    }
  });
});
// @license-end
