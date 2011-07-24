(function() {
  var HoverCard = function() {
    var self = this;

    self.jXHRs = [];
    self.isDragged = false;

    self.subscribe("widget/ready", function() {
      self.personCache = new self.Cache();
      self.dropdownCache = new self.Cache();

      var card = $("#hovercard");
      self.hoverCard = {
        tip: $("#hovercard_container"),
        dropdownContainer: $("#hovercard_dropdown_container"),
        offset: {
          left: -10,
          top: 13
        },
        personLink: card.find("a.person"),
        avatar: card.find(".avatar"),
        dropdown: card.find(".dropdown_list"),
        hashtags: card.find(".hashtags"),
      };

      $(document.body).delegate("a.hovercardable:not(.self)", "hover", self.handleHoverEvent);
      self.hoverCard.tip.live('mouseenter', self.hoverCardHover)
                        .live('mouseleave', self.clearTimeout);

      Diaspora.widgets.subscribe("person/aspectMembershipUpdated", function(evt, obj) {
        var personId = obj.person_id;
        var aspectIds = obj.aspect_ids;

        self.dropdownCache.generateFromAjax(personId, aspectIds);
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
      if(self.isDragged)
        return;

      self.hoverCard.tip.hide();
      self.hoverCard.tip.css('position', 'absolute');

      self.showNearTarget();
      self.personCache.get(self.target.attr("data-hovercard") + ".json?includes=tags", function(person) {
        self.populateHovercard(person);
      });
    };

    this.startDragging = function(person) {
      self.isDragged = true;
      self.target = person;
      var personId = parseInt(person.attr('data-person_id'));

      if(self.hoverCard.tip.is(':hidden'))
        self.hoverCard.tip.css('position', 'fixed');

      self.hoverCard.tip.hide();
      self.hoverCard.dropdownContainer.hide();
      
      self.clearHovercard(personId);
      self.personCache.get('/people/' + personId + '.json?includes=tags', function(_person) {
        self.populateHovercard(_person);
      });
      
      self.hoverCard.tip.fadeTo('fast', 0.5);
    }

    this.stopDragging = function() {
      self.hoverCard.tip.hide();
      self.hoverCard.tip.css({ opacity: 1 });
      self.hoverCard.dropdownContainer.show();

      self.isDragged = false;
    }

    this.showNearTarget = function() { 
      var position = self.target.position();
      var offset = self.hoverCard.offset;

      self.hoverCard.tip.css({
        left: position.left + offset.left,
        top: position.top + offset.top
      });

      self.hoverCard.tip.prependTo(self.target.parent());
    }

    this.clearHovercard = function(personId) {
      var person = {
        id: parseInt(personId),
        avatar: "/images/user/default.png",
        url: "",
        name: "",
        tags: [],
      };

      self.hoverCard.hashtags.html("");
      self.populateHovercard(person);
    };


    this.populateHovercard = function(person) {
      self.hoverCard.avatar.attr("src", person.avatar);
      self.hoverCard.personLink.attr("href", person.url);
      self.hoverCard.personLink.text(person.name);
      self.hoverCard.dropdown.attr("data-person_id", person.id);

      self.hoverCard.avatar.width(50);
      self.hoverCard.avatar.height(50);

      self.hoverCard.hashtags.html("");
      $.each(person.tags, function(index, hashtag) {
        self.hoverCard.hashtags.append(
          $("<a/>", {
            href: "/tags/" + hashtag.substring(1)
          }).text(hashtag)
        );
      });

      if(!self.isDragged)
        self.dropdownCache.get(self.target.attr("data-hovercard") + "/aspect_membership_button", function(dropdown) {
          self.hoverCard.dropdownContainer.html(dropdown);
          self.hoverCard.tip.fadeIn(140);
        });
    };

    this.clearTimeout = function(delayed) {
      if(self.isDragged)
        return;

      self.personCache.clearjXHRs();
      self.dropdownCache.clearjXHRs();
      function callback() {
          if(self.isDragged)
            return;

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

      this.generateFromAjax = function(personId, aspectIds){
        if(self.length==0)
          return;

        var dropdown = $(self.cache[0]);
        var dropdown_list = dropdown.children('.dropdown_list');
        dropdown_list.attr('data-person_id',personId);
        ContactEdit.updateCheckboxes(personId, aspectIds, dropdown_list);
        
        self.cache["/people/" + personId + "/aspect_membership_button"] = dropdown.outerHTML;
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
