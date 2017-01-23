// @license magnet:?xt=urn:btih:0b31508aeb0634b347b8270c7bee4d411b5d4109&dn=agpl-3.0.txt AGPL-v3-or-Later

$(document).ready(function() {
  function publisherContent(params) {
    if (params.content) {
      return params.content;
    }

    var content = params.title + " - " + params.url;
    if (params.notes.length > 0) {
      content += " - " + params.notes;
    }
    return content;
  }

  var content = publisherContent(gon.preloads.bookmarklet);
  if (content.length > 0) {
    $("#status_message_text").val(content);
  }
});
// @license-end
