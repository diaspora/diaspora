Diaspora.widgets.add("alert", function() {
  this.start = function() {
    $(document).bind("close.facebox", function() {
      if ($("#diaspora_alert").length) {
        $("#diaspora_alert").detach();
      }
    });
  };

  this.faceboxTemplate = '<div id="diaspora_alert" class="facebox_content">' +
    '<div class="span-12 last">' +
      '<div id="facebox_header">' +
        '<h4>' +
          '{{title}}' +
        '</h4>' +
      '</div>' +
      '{{content}}' +
    '</div>' +
  '</div>';


  this.alert = function(title, content) {
    var template = $.mustache(this.faceboxTemplate, {
      title: title,
      content: content
    });

    $(template).appendTo(document.body);

    $.facebox({
      div: "#diaspora_alert"
    }, 'diaspora_alert');
  }
});
