(function() {
  Diaspora.Mobile.Drawer = {
    initialize: function() {
      this.drawer = $("#drawer");
      this.mainContent = $("#main");
      this.dragZone = this.createDragZone();
      this.mainContent.append(this.dragZone);

      var self = this;
      var dateLastEvent = Date.now();
      var debouncingThreshold = 40;
      var hammerOpts = {
        "prevent_default": false,
        threshold: 0,
        direction: Hammer.DIRECTION_HORIZONTAL
      };

      $("#all_aspects").bind("tap click", function(evt) {
        evt.preventDefault();
        $(this).find("+ li").toggleClass("hide");
      });

      $("#followed_tags").bind("tap click", function(evt) {
        evt.preventDefault();
        $(this).find("+ li").toggleClass("hide");
      });

      $("#menu-badge").on("tap click", function(evt) {
        evt.preventDefault();
        self.createOverlay();
        self.openDrawer();
      });

      this.mainContent.on("tap click", function() {
        if (self.isDrawerOpened()) {
          self.closeDrawer();
        }
      });

      this.dragZone.hammer(hammerOpts)
        .bind("panstart", function() {
          self.createOverlay();
          $("body").css("overflow", "hidden");
          self.drawer.addClass("gesture").removeClass("closed-drawer").removeClass("opened-drawer");
        })
        .bind("pan", function(e) {
          if (Date.now() - dateLastEvent < debouncingThreshold) {
            e.preventDefault();
            return;
          }

          if (e.gesture.pointerType === "touch") {
            dateLastEvent = Date.now();
            var distanceFromRight = window.innerWidth - e.gesture.center.x;

            // Keep within boudaries
            distanceFromRight = Math.max(distanceFromRight, 0);
            distanceFromRight = Math.min(distanceFromRight, self.drawer.width());

            self.drawer.css("left", "calc(100% - " + distanceFromRight + "px)");
            $("#main-overlay").css("opacity", distanceFromRight / self.drawer.width());
          }
        })
        .bind("panend", function(e) {
          if (e.gesture.pointerType === "touch") {
            var velocityX = e.gesture.velocityX;
            var openedMenu = (window.innerWidth - e.gesture.center.x) < (window.innerWidth / 2);
            if (!openedMenu || velocityX > 0.3) {
              // Open the menu
              self.openDrawer();
            } else if ((openedMenu && velocityX <= 0.3) || velocityX < -0.3) {
              // Close the menu
              self.closeDrawer();
            }
          }
        });
    },

    createDragZone: function() {
      var dragZone = $("<div id='drag-zone'></div>");
      dragZone.css({
        position: "fixed",
        top: 0,
        right: 0,
        height: "100vh",
        width: "15px",
        "z-index": 100
      });
      return dragZone;
    },

    mutateDragZone: function() {
      if (this.isDrawerOpened()) {
        this.dragZone.css({
          width: window.innerWidth - (this.drawer.width() - 40),
          right: "unset",
          left: 0
        });
      } else {
        this.dragZone.css({
          width: "15px",
          right: 0,
          left: "unset"
        });
      }
    },

    openDrawer: function() {
      this.drawer.addClass("opened-drawer").removeClass("gesture").removeClass("closed-drawer");
      this.drawer.css("left", "calc(100% - " + this.drawer.width() + "px)");
      this.mutateDragZone();
      $("#main-overlay").animate({opacity: 1}, 50);
    },

    closeDrawer: function() {
      $("body").css("overflow", "");
      this.drawer.addClass("closed-drawer").removeClass("opened-drawer").removeClass("gesture");
      this.drawer.css("left", "100%");
      this.mutateDragZone();

      $("#main-overlay").animate({opacity: 0}, 50, function() {
        $(this).remove();
      });
    },

    isDrawerOpened: function() {
      return this.drawer.hasClass("opened-drawer");
    },

    createOverlay: function() {
      if ($("#main-overlay").size() === 0) {
        var overlay = $("<div id='main-overlay'></div>");
        overlay.css({
          "background-color": "rgba(0, 0, 0, .5)",
          height: "100vh",
          left: 0,
          opacity: 0,
          position: "fixed",
          top: 0,
          width: "100vw",
          "z-index": 3
        });
        this.mainContent.append(overlay);
      }
    }
  };
})();

$(function() {
  Diaspora.Mobile.Drawer.initialize();
});
