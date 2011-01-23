/*   Copyright (c) 2010, Diaspora Inc.  This file is
 *   licensed under the Affero General Public License version 3 or later.  See
 *   the COPYRIGHT file.
 */
var Embedder = {
  services: {},
  register: function(service, template) {
    Embedder.services[service] = template;
  },
  render: function(service, views) {
    var template = (typeof Embedder.services[service] === "string")
        ? Embedder.services[service]
        : Embedder.services.undefined;

    return $.mustache(template, views);
  },
  embed: function($this) {
    var service = $this.data("host"),
      container = document.createElement("div"),
      $container = $(container).attr("class", "video-container"),
      $videoContainer = $this.parent().siblings("div.video-container");

    if($videoContainer.length) {
      $videoContainer.slideUp("fast", function() { $(this).detach(); });
      return;
    }

    if ($("div.video-container").length) {
      $("div.video-container").slideUp("fast", function() { $(this).detach(); });
    }

    $container.html(Embedder.render(service, $this.data()));

    $container.hide()
      .insertAfter($this.parent())
      .slideDown('fast');

    $this.click(function() {
      $container.slideUp('fast', function() {
        $(this).detach();
      });
    });
  },
  initialize: function() {
    $(".stream").delegate("a.video-link", "click", Embedder.onVideoLinkClick);
  },
  onVideoLinkClick: function(evt) {
    evt.preventDefault();
    Embedder.embed($(this));
  }
};

Embedder.register("youtube.com",
    '<a href="//www.youtube.com/watch?v={{video-id}}" target="_blank">Watch this video on Youtube</a><br />' +
    '<iframe class="youtube-player" type="text/html" src="http://www.youtube.com/embed/{{video-id}}"></iframe>');

Embedder.register("vimeo.com",
  '<a href="http://vimeo.com/{{video-id}}">Watch this video on Vimeo</a><br />' +
  '<iframe class="vimeo-player" src="http://player.vimeo.com/video/{{video-id}}"></iframe>');

Embedder.register("undefined", '<p>Unknown video type - {{host}}</p>');

$(document).ready(function() {
  Embedder.initialize();
});