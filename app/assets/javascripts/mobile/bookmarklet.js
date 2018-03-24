// @license magnet:?xt=urn:btih:0b31508aeb0634b347b8270c7bee4d411b5d4109&dn=agpl-3.0.txt AGPL-v3-or-Later

$(document).ready(function() {
  function publisherContent(params) {
    if (params.content) {
      return params.content;
    }

    var separator = "\n\n";
    var contents = "### " + params.title + separator;
    if (params.notes) {
      var notes = params.notes.toString().replace(/(?:\r\n|\r|\n)/g, "\n> ");
      contents += "> " + notes + separator;
    }
    contents += params.url;
    return contents;
  }

  var content = publisherContent(gon.preloads.bookmarklet);
  if (content.length > 0) {
    var textarea = $("#status_message_text");
    textarea.val(content);
    autosize.update(textarea);
  }
});
// @license-end
