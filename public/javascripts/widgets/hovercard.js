(function() {
  var HoverCard = function() {
    var self = this;

    this.start = function() {
      this.hoverCard = {
        tip: $("#hovercard"),
        offset: {
          left: 00,
          top: 20
        },
        personLink: $("#hovercard").find("a.person"),
        avatar: $("#hovercard").find(".avatar"),
        dropdown: $("#hovercard").find(".dropdown_list")
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
      self.timeout = setTimeout(self.showHoverCard, 100);
    };

    this.showHoverCard = function() {
      self.hoverCard.tip.fadeOut('fast');
      self.hoverCard.tip.prependTo(self.target.parent());

      $.getJSON(self.target.attr("href"), function(person) {
        var position = self.target.position();
        self.hoverCard.tip.css({
          left: position.left + self.hoverCard.offset.left,
          top: position.top + self.hoverCard.offset.top
        });

        self.hoverCard.avatar.attr("src", person.avatar);
        self.hoverCard.personLink.attr("href", person.url);
        self.hoverCard.personLink.text(person.name);
        self.hoverCard.dropdown.attr("data-person-id", person.id);

        self.hoverCard.tip.fadeIn('fast');
      });

      $.get(self.target.attr('href')+'/aspect_membership_button',function(data){
        self.hoverCard.tip.find('#hovercard_dropdown_container').html(data);
      });
    };

    this.populateDropdown = function(aspect_ids){
      var dropdown = this.hoverCard.tip.find('.dropdown_list'),
          listElements = dropdown.children('li'),
          inAspects = false;

      // check-off aspects
      $.each(listElements, function(idx,el){
        var element = $(el);
        if( aspect_ids.indexOf(element.attr('data-aspect_id')) !== -1 ){
          element.addClass('selected');
          inAspects = true;
        }
      });

      // make button green
    };

    this.clearTimeout = function(delayed) {
      function callback() {
          self.timeout = clearTimeout(self.timeout);
          self.hoverCard.tip.hide();
      };

      if((typeof delayed === "boolean" && delayed) || (typeof delayed === "object" && delayed.type === "mouseleave")) {
        self.hoverCardTimeout = setTimeout(callback, 400);
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
