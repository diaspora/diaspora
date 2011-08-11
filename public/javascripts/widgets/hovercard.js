(function() {
  var HoverCard = function() {
    var self = this;

    self.jXHRs = [];

    self.subscribe("widget/ready", function(evt, hoverCard) {
      self.personCache = new self.Cache();
      self.dropdownCache = new self.Cache();

      self.hoverCard = {
        tip: $("#hovercard_container"),
        dropdownContainer: $("#hovercard_dropdown_container"),
        offset: {
          left: -10,
          top: 13
        },
        personLink: hoverCard.find("a.person"),
        avatar: hoverCard.find(".avatar"),
        dropdown: hoverCard.find(".dropdown_list"),
        hashtags: hoverCard.find(".hashtags")
      };

      $(document.body).delegate("a.hovercardable:not(.self)", "hover", self.handleHoverEvent);
      self.hoverCard.tip.hover(self.hoverCardHover, self.clearTimeout);

      self.subscribe("aspectDropdown/updated aspectDropdown/blurred", function(evt, personId, dropdownHtml) {
        self.dropdownCache.cache["/people/" + personId + "/aspect_membership_button"] = $(dropdownHtml).removeClass("active").get(0).outerHTML;
      });
    });

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
      self.timeout = setTimeout(self.showHoverCard, 600);
    };

    this.showHoverCard = function() {
      self.hoverCard.tip.hide();
      self.hoverCard.tip.prependTo(self.target.parent());

      self.personCache.get(self.target.attr("data-hovercard") + ".json?includes=tags", function(person) {
        self.populateHovercard(person);
      });
    };

    this.populateHovercard = function(person) {
      var position = self.target.position();
      self.hoverCard.tip.css({
        left: position.left + self.hoverCard.offset.left,
        top: position.top + self.hoverCard.offset.top
      });

      self.hoverCard.avatar.attr("src", person.avatar);
      self.hoverCard.personLink.attr("href", person.url);
      self.hoverCard.personLink.text(person.name);
      self.hoverCard.dropdown.attr("data-person-id", person.id);

      self.hoverCard.hashtags.html("");
      $.each(person.tags, function(index, hashtag) {
        self.hoverCard.hashtags.append(
          $("<a/>", {
            href: "/tags/" + hashtag.substring(1)
          }).text(hashtag)
        );
      });

      self.dropdownCache.get(self.target.attr("data-hovercard") + "/aspect_membership_button", function(dropdown) {
        self.hoverCard.dropdownContainer.html(dropdown);
        self.hoverCard.tip.fadeIn(140);
      });
    };

    this.clearTimeout = function(delayed) {
      self.personCache.clearjXHRs();
      self.dropdownCache.clearjXHRs();

      function callback() {
          self.timeout = clearTimeout(self.timeout);
          self.hoverCard.tip.hide();
          self.hoverCard.dropdownContainer.html("");
      }

      if((typeof delayed === "boolean" && delayed) || (typeof delayed === "object" && delayed.type === "mouseleave")) {
        self.hoverCardTimeout = setTimeout(callback, 20);
      }
      else {
        callback();
      }
    };

    this.hoverCardHover = function() {
      self.hoverCardTimeout = clearTimeout(self.hoverCardTimeout);
    };

    this.Cache = function() {
      var self = this;
      this.cache = {};
      this.jXHRs = [];

      this.get = function(key, callback) {
        if(typeof self.cache[key] === "undefined") {
          self.jXHRs.push($.get(key, function(response) {
            self.cache[key] = response;
            callback(response);
            self.jXHRs.shift();
          }));
        }
        else {
          callback(self.cache[key]);
        }
      };

      this.clearjXHRs = function() {
        $.each(self.jXHRs, function(index, jXHR) {
          jXHR.abort();
        });
        self.jXHRs = [];
      };
    };
  };

  Diaspora.Widgets.HoverCard = HoverCard;
})();
