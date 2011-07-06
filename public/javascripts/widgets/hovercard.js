(function() {
  var HoverCard = function() {
    var self = this;

    self.jXHRs = [];

    this.start = function() {
      self.personCache = new this.Cache();
      self.dropdownCache = new this.Cache();
  
      self.hoverCard = {
        tip: $("#hovercard"),
        dropdownContainer: $("#hovercard_dropdown_container"),
        offset: {
          left: 0,
          top: 18
        },
        personLink: $("#hovercard").find("a.person"),
        avatar: $("#hovercard").find(".avatar"),
        dropdown: $("#hovercard").find(".dropdown_list")
      };

      $(document.body).delegate("a.author:not(.self)", "hover", self.handleHoverEvent);
      self.hoverCard.tip.hover(self.hoverCardHover, self.clearTimeout);

      Diaspora.widgets.subscribe("aspectDropdown/updated aspectDropdown/blurred", function(evt, personId, dropdownHtml) {
        self.dropdownCache.cache["/people/" + personId + "/aspect_membership_button"] = $(dropdownHtml).removeClass("active").get(0).outerHTML;
      });
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
      self.timeout = setTimeout(self.showHoverCard, 600);
    };

    this.showHoverCard = function() {
      self.hoverCard.tip.hide();
      self.hoverCard.tip.prependTo(self.target.parent());

      self.personCache.get(self.target.attr("href") + ".json", function(person) {
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

      self.dropdownCache.get(self.target.attr("href") + "/aspect_membership_button", function(dropdown) {
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
      };

      if((typeof delayed === "boolean" && delayed) || (typeof delayed === "object" && delayed.type === "mouseleave")) {
        self.hoverCardTimeout = setTimeout(callback, 200);
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

  Diaspora.widgets.add("hoverCard", HoverCard);
})();
