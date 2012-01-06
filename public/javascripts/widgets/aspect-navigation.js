/*   Copyright (c) 2010, Diaspora Inc.  This file is
 *   licensed under the Affero General Public License version 3 or later.  See
 *   the COPYRIGHT file.
 */

(function() {
  Diaspora.Widgets.AspectNavigation = function() {
    var self = this;

    this.subscribe("widget/ready", function(evt, aspectNavigation) {
      $.extend(self, {
        aspectNavigation: aspectNavigation,
        aspectSelectors: aspectNavigation.find("a.aspect_selector[data-guid]"),
        aspectLis: aspectNavigation.find("li[data-aspect_id]"),
        toggleSelector: aspectNavigation.find("a.toggle_selector")
      });

      self.aspectSelectors.click(self.toggleAspect);
      self.toggleSelector.click(self.toggleAll);
    });

    this.selectedAspects = function() {
      return self.aspectNavigation.find("li.active[data-aspect_id]").map(function() { return $(this).data('aspect_id') });
    };

    this.toggleAspect = function(evt) {
      evt.preventDefault();

      $(this).parent().toggleClass("active");
      self.perform();
    };

    this.toggleAll = function(evt) {
      evt.preventDefault();

      if (self.allSelected()) {
        self.aspectLis.removeClass("active");
      } else {
        self.aspectLis.addClass("active");
      }
      self.perform();
    };

    this.perform = function() {
      if (self.noneSelected()) {
        return;
      } else {
        window.location = self.generateURL(); // hella hax
      }
    };

    this.calculateToggleText = function() {
      if (self.allSelected()) {
        self.toggleSelector.text(Diaspora.I18n.t('aspect_navigation.deselect_all'));
      } else {
        self.toggleSelector.text(Diaspora.I18n.t('aspect_navigation.select_all'));
      }
    };

    this.generateURL = function() {
      var baseURL = 'aspects';

      // generate new url
      baseURL = baseURL.replace('#','');
      baseURL += '?';

      self.aspectLis.each(function() {
        var aspectLi = $(this);
        if (aspectLi.hasClass("active")) {
          baseURL += "a_ids[]=" + aspectLi.data("aspect_id") + "&";
        }
      });

      if(!$("#publisher").hasClass("closed")) {
        // open publisher
        baseURL += "op=true";
      } else {
        // slice last '&'
        baseURL = baseURL.slice(0,baseURL.length-1);
      }
      return baseURL;
    };

    this.noneSelected = function() {
      return self.aspectLis.filter(".active").length === 0;
    }

    this.allSelected = function() {
      return self.aspectLis.not(".active").length === 0;
    }
  };
})();
