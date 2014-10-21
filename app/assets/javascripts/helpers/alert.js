// @license magnet:?xt=urn:btih:0b31508aeb0634b347b8270c7bee4d411b5d4109&dn=agpl-3.0.txt AGPL-v3-or-Later

Diaspora.Alert = {
  faceboxTemplate:
    '<div id="diaspora_alert">' +
      '<div class="span-12 last">' +
        '<div id="facebox_header">' +
          '<h4>' +
          '<%= title %>' +
          '</h4>' +
        '</div>' +
        '<%= content %>' +
      '</div>' +
    '</div>',

  show: function(title, content) {
    $(_.template(this.faceboxTemplate)({
      title: title,
    content: content
    })).appendTo(document.body);

    $.facebox({
      div: "#diaspora_alert"
    }, "diaspora_alert");
  }
};

$(function() {
  $(document).bind("close.facebox", function() {
    $("#diaspora_alert").remove();
  });
});
// @license-end

