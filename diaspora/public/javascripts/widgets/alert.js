(function() {
  var Alert = function() {
    var self = this;

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


    this.subscribe("widget/ready", function() {
      $(document).bind("close.facebox", function() {
				$("#diaspora_alert").remove();
      });
    }); 


    this.alert = function(title, content) {
      $($.mustache(self.faceboxTemplate, {
				title: title,
				content: content
      })).appendTo(document.body);

      $.facebox({
        div: "#diaspora_alert"
      }, "diaspora_alert");
    }
  };

  Diaspora.widgets.add("alert", Alert);
})();
