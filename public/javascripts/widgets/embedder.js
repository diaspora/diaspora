/*   Copyright (c) 2010, Diaspora Inc.  This file is
 *   licensed under the Affero General Public License version 3 or later.  See
 *   the COPYRIGHT file.
 */


(function() {
  var Embedder = function() {
    var self = this;
    this.services = {};

    this.subscribe("widget/ready", function(evt, contentElement) {
      self.contentElement = contentElement;

      self.contentElement.delegate("a.video-link", "click", self.embedVideo);
      self.registerServices();
    });

    this.register = function(service, template) {
      self.services[service] = template;
    };

    this.render = function(service, views) {
      var template = (typeof self.services[service] === "string")
          ? self.services[service]
          : self.services.undefined;
  
      return $.mustache(template, views);
    };

    this.embedVideo = function(evt) {
      evt.preventDefault();
      evt.stopPropagation();

      var videoLink = $(this),
        host = videoLink.data("host"),
				container = $("<div/>", { "class": "video-container" }),
				videoContainer = self.contentElement.children(".video-container");

      if (videoContainer.length) {
				videoContainer.slideUp("fast", function() { 
	  			$(this).detach();
				});
				return;
      }

      if ($("div.video-container").length) {
        $("div.video-container").slideUp("fast", function() { $(this).detach(); });
      }

      container.html(
        self.render(host, videoLink.data())
      );

      container.hide()
				.insertAfter(videoLink.parent())
				.slideDown("fast");

      videoLink.click(function() {
				videoContainer.slideUp("fast", function() {
	  			$(this).detach();
				});	
      });  
    };

    this.registerServices = function() {
      self.register("youtube.com",
        '<a href="//www.youtube.com/watch?v={{video-id}}{{anchor}}" target="_blank">' + Diaspora.I18n.t("videos.watch", { provider: "YouTube" }) + '</a><br />' +
        '<iframe class="youtube-player" type="text/html" src="http://www.youtube.com/embed/{{video-id}}?wmode=opaque{{anchor}}"></iframe>');

      self.register("vimeo.com",
				'<a href="http://vimeo.com/{{video-id}}">' + Diaspora.I18n.t("videos.watch", { provider: "Vimeo" }) + '</a><br />' +
				'<iframe class="vimeo-player" src="http://player.vimeo.com/video/{{video-id}}"></iframe>');

      self.register("undefined", '<p>' + Diaspora.I18n.t("videos.unknown") + ' - {{host}}</p>');
    };
  };

  Diaspora.Widgets.Embedder = Embedder;
})();
