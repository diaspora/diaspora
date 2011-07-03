(function() {
  var HoverCard = function() {
    var self = this;

    this.start = function() {
      this.hoverCard = {
        tip: $("#hovercard"),
        offset: {
          left: -30,
          top: -60
        },
        personLink: $("#hovercard").find("a.person"),
        avatar: $("#hovercard").find(".avatar")
      };

      $(document.body).delegate("a.author", "hover", this.handleHoverEvent);
      this.hoverCard.tip.hover(this.hoverCardHover, this.clearTimeout);
    };

    this.handleHoverEvent = function(evt) {
      self.target = $(evt.target);

      if(evt.type === "mouseenter") {
        self.startHover();
      }
      else {
        self.clearTimeout(evt);
      }
    };

    this.startHover = function(evt) {
      if(!self.hoverCardTimeout) {
        self.clearTimeout(false);
      }
      self.timeout = setTimeout(self.showHoverCard, 30);
    };

    this.showHoverCard = function() {
      self.hoverCard.tip.hide();
      self.hoverCard.tip.prependTo(self.target.parent());

      $.getJSON(self.target.attr("href"), function(person) {
        var position = self.target.position();
        self.hoverCard.tip.css({
          position: "absolute",
          left: position.left + self.hoverCard.offset.left,
          top: position.top + self.hoverCard.offset.top
        });

        self.hoverCard.avatar.attr("src", person.avatar);
        self.hoverCard.personLink.attr("href", self.target.attr("href"));
        self.hoverCard.personLink.text(person.name);

        self.hoverCard.tip.show();
      });
    };

    this.clearTimeout = function(delayed) {
      function callback() {
          self.timeout = clearTimeout(self.timeout);
          self.hoverCard.tip.hide();
      };

      if((typeof delayed === "boolean" && delayed) || (typeof delayed === "object" && delayed.type === "mouseleave")) {
        self.hoverCardTimeout = setTimeout(callback, 300);
      }
      else {
        callback();
      }
    };

    this.hoverCardHover = function() {
      self.hoverCardTimeout = clearTimeout(self.hoverCardTimeout);
    };
  };

  Diaspora.widgets.add("hoverCard", HoverCard);
})();
