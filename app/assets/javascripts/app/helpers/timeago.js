// @license magnet:?xt=urn:btih:0b31508aeb0634b347b8270c7bee4d411b5d4109&dn=agpl-3.0.txt AGPL-v3-or-Later
(function(){
  app.helpers.timeago = function(el) {
    el.find('time.timeago').each(function(i,e) {
      $(e).attr('title', new Date($(e).attr('datetime')).toLocaleString());
    }).timeago().tooltip();
  };
})();
// @license-end
