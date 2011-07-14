/*   Copyright (c) 2010, Diaspora Inc.  This file is
 *   licensed under the Affero General Public License version 3 or later.  See
 *   the COPYRIGHT file.
 */


(function() {
  var Embedder = function() {
    var self = this;
    this.services = {};


    self.subscribe("widget/ready", function() {
      $.extend(self, {
				stream: $("#main_stream")
      });
 
      self.ensureDOMStructure();

      self.stream.delegate("a.video-link", "click", self.onVideoLinkClicked);
      self.registerServices();
    });
    
    this.ensureDOMStructure = function() {
      var post = self.stream.children(".stream_element:first"),
				content = post.children(".sm_body").children(".content").children("p");

      self.canEmbed = !!content.length;
    };
  

    this.register = function(service, template) {
      self.services[service] = template;
    };

    this.render = function(service, views) {
      var template = (typeof self.services[service] === "string")
          ? self.services[service]
          : self.services.undefined;
  
      return $.mustache(template, views);
    };

    this.embed = function(videoLink) {
      var host = videoLink.data("host"),
				container = $("<div/>", { "class": "video-container" }),
				videoContainer = videoLink.closest(".content").children(".video-container");

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
        self.render(service, videoLink.data())
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

    this.onVideoLinkClicked = function(evt) {
      if(self.canEmbed) {
				evt.preventDefault();
				self.embed($(this));
      }
    };

    this.registerServices = function() {
      var watchVideoOn = Diaspora.widgets.i18n.t("videos.watch");

      self.register("youtube.com",
        '<a href="//www.youtube.com/watch?v={{video-id}}{{anchor}}" target="_blank">' + $.mustache(watchVideoOn, { provider: "YouTube" }) + '</a><br />' +
        '<iframe class="youtube-player" type="text/html" src="http://www.youtube.com/embed/{{video-id}}?wmode=opaque{{anchor}}"></iframe>');

      self.register("vimeo.com",
				'<a href="http://vimeo.com/{{video-id}}">' + $.mustache(watchVideoOn, { provider: "Vimeo" }) + '</a><br />' +
				'<iframe class="vimeo-player" src="http://player.vimeo.com/video/{{video-id}}"></iframe>');

      self.register("undefined", '<p>' + Diaspora.widgets.i18n.t("videos.unknown") + ' - {{host}}</p>');
    };
  };

  Diaspora.widgets.add("embedder", Embedder);
})();
