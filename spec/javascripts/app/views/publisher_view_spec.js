/*   Copyright (c) 2010-2012, Diaspora Inc.  This file is
 *   licensed under the Affero General Public License version 3 or later.  See
 *   the COPYRIGHT file.
 */

describe("app.views.Publisher", function() {
  describe("standalone", function() {
    beforeEach(function() {
      // should be jasmine helper
      loginAs({name: "alice", avatar : {small : "http://avatar.com/photo.jpg"}});

      spec.loadFixture("aspects_index");
      this.view = new app.views.Publisher({
        standalone: true
      });
    });

    it("hides the close button in standalone mode", function() {
      expect(this.view.$('#hide_publisher').is(':visible')).toBeFalsy();
    });

    it("hides the post preview button in standalone mode", function() {
      expect(this.view.$('.post_preview_button').is(':visible')).toBeFalsy();
    });
  });

  context("plain publisher", function() {
    beforeEach(function() {
      // should be jasmine helper
      loginAs({name: "alice", avatar : {small : "http://avatar.com/photo.jpg"}});

      spec.loadFixture("aspects_index");
      this.view = new app.views.Publisher();
    });

    describe("#open", function() {
      it("removes the 'closed' class from the publisher element", function() {
        expect($(this.view.el)).toHaveClass("closed");
        this.view.open($.Event());
        expect($(this.view.el)).not.toHaveClass("closed");
      });
    });

    describe("#close", function() {
      beforeEach(function() {
        this.view.open($.Event());
      });

      it("removes the 'active' class from the publisher element", function(){
        this.view.close($.Event());
        expect($(this.view.el)).toHaveClass("closed");
      })

      it("resets the element's height", function() {
        $(this.view.el).find("#status_message_fake_text").height(100);
        this.view.close($.Event());
        expect($(this.view.el).find("#status_message_fake_text").attr("style")).not.toContain("height");
      });
    });

    describe("#clear", function() {
      it("calls close", function(){
        spyOn(this.view, "close");

        this.view.clear($.Event());
        expect(this.view.close).toHaveBeenCalled();
      })

      it("calls removePostPreview", function(){
        spyOn(this.view, "removePostPreview");

        this.view.clear($.Event());
        expect(this.view.removePostPreview).toHaveBeenCalled();
      })

      it("clears all textareas", function(){
        _.each(this.view.$("textarea"), function(element){
          $(element).val('this is some stuff');
          expect($(element).val()).not.toBe("");
        });

        this.view.clear($.Event());

        _.each(this.view.$("textarea"), function(element){
          expect($(element).val()).toBe("");
        });
      })

      it("removes all photos from the dropzone area", function(){
        var self = this;
        _.times(3, function(){
          self.view.el_photozone.append($("<li>"))
        });

        expect(this.view.el_photozone.html()).not.toBe("");
        this.view.clear($.Event());
        expect(this.view.el_photozone.html()).toBe("");
      })

      it("removes all photo values appended by the photo uploader", function(){
        $(this.view.el).prepend("<input name='photos[]' value='3'/>")
        var photoValuesInput = this.view.$("input[name='photos[]']");

        photoValuesInput.val("3")
        this.view.clear($.Event());
        expect(this.view.$("input[name='photos[]']").length).toBe(0);
      })
    });

    describe("createStatusMessage", function(){
      it("calls handleTextchange to complete missing mentions", function(){
        spyOn(this.view, "handleTextchange");
        this.view.createStatusMessage($.Event());
        expect(this.view.handleTextchange).toHaveBeenCalled();
      })
    });

    describe("publishing a post with keyboard", function(){
      it("should submit the form when ctrl+enter is pressed", function(){
        this.view.render();
        var form = this.view.$("form")
        var submitCallback = jasmine.createSpy().andReturn(false);
        form.submit(submitCallback);

        var e = $.Event("keydown", { keyCode: 13 });
        e.ctrlKey = true;
        this.view.keyDown(e);

        expect(submitCallback).toHaveBeenCalled();
        expect($(this.view.el)).not.toHaveClass("closed");
      })
    })
  });

  context("services", function(){
    beforeEach( function(){
      spec.loadFixture('aspects_index_services');
      this.view = new app.views.Publisher();
    });

    it("toggles the 'dim' class on a clicked item", function() {
      var first = $(".service_icon").eq(0);
      var second = $(".service_icon").eq(1);

      expect(first.hasClass('dim')).toBeTruthy();
      expect(second.hasClass('dim')).toBeTruthy();

      first.trigger('click');

      expect(first.hasClass('dim')).toBeFalsy();
      expect(second.hasClass('dim')).toBeTruthy();

      first.trigger('click');

      expect(first.hasClass('dim')).toBeTruthy();
      expect(second.hasClass('dim')).toBeTruthy();
    });

    it("creates a counter element", function(){
      expect(this.view.$('.counter').length).toBe(0);
      $(".service_icon").first().trigger('click');
      expect(this.view.$('.counter').length).toBe(1);
    });

    it("removes any old counters", function(){
      spyOn($.fn, "remove");
      $(".service_icon").first().trigger('click');
      expect($.fn.remove).toHaveBeenCalled();
    });

    it("toggles the hidden input field", function(){
      expect(this.view.$('input[name="services[]"]').length).toBe(0);
      $(".service_icon").first().trigger('click');
      expect(this.view.$('input[name="services[]"]').length).toBe(1);
      $(".service_icon").first().trigger('click');
      expect(this.view.$('input[name="services[]"]').length).toBe(0);
    });

    it("toggles the correct input", function() {
      var first = $(".service_icon").eq(0);
      var second = $(".service_icon").eq(1);

      first.trigger('click');
      second.trigger('click');

      expect(this.view.$('input[name="services[]"]').length).toBe(2);

      first.trigger('click');

      var prov1 = first.attr('id');
      var prov2 = second.attr('id');

      expect(this.view.$('input[name="services[]"][value="'+prov1+'"]').length).toBe(0);
      expect(this.view.$('input[name="services[]"][value="'+prov2+'"]').length).toBe(1);
    });
  });

  context("aspect selection", function(){
    beforeEach( function(){
      spec.loadFixture('status_message_new');

      this.radio_els = $('#publisher .dropdown li.radio');
      this.check_els = $('#publisher .dropdown li.aspect_selector');

      this.view = new app.views.Publisher();
      this.view.open();
    });

    it("initializes with 'all_aspects'", function(){
      expect(this.radio_els.first().hasClass('selected')).toBeFalsy();
      expect(this.radio_els.last().hasClass('selected')).toBeTruthy();

      _.each(this.check_els, function(el){
        expect($(el).hasClass('selected')).toBeFalsy();
      });
    });

    it("toggles the selected entry visually", function(){
      this.check_els.last().trigger('click');

      _.each(this.radio_els, function(el){
        expect($(el).hasClass('selected')).toBeFalsy();
      });

      expect(this.check_els.first().hasClass('selected')).toBeFalsy();
      expect(this.check_els.last().hasClass('selected')).toBeTruthy();
    });

    describe("hidden form elements", function(){
      beforeEach(function(){
        this.li = $('<li data-aspect_id="42" />');
        this.view.$('.dropdown_list').append(this.li);
      });

      it("removes a previous selection and inserts the current one", function() {
        var selected = this.view.$('input[name="aspect_ids[]"]');
        expect(selected.length).toBe(1);
        expect(selected.first().val()).toBe('all_aspects');

        this.li.trigger('click');

        selected = this.view.$('input[name="aspect_ids[]"]');
        expect(selected.length).toBe(1);
        expect(selected.first().val()).toBe('42');
      });

      it("toggles the same item", function() {
        expect(this.view.$('input[name="aspect_ids[]"][value="42"]').length).toBe(0);

        this.li.trigger('click');
        expect(this.view.$('input[name="aspect_ids[]"][value="42"]').length).toBe(1);

        this.li.trigger('click');
        expect(this.view.$('input[name="aspect_ids[]"][value="42"]').length).toBe(0);
      });

      it("keeps other fields with different values", function() {
        var li2 = $("<li data-aspect_id=99></li>");
        this.view.$('.dropdown_list').append(li2);

        this.li.trigger('click');
        li2.trigger('click');

        expect(this.view.$('input[name="aspect_ids[]"][value="42"]').length).toBe(1);
        expect(this.view.$('input[name="aspect_ids[]"][value="99"]').length).toBe(1);
      });
    });

  });

  context("locator", function() {
    beforeEach(function() {
      // should be jasmine helper
      loginAs({name: "alice", avatar : {small : "http://avatar.com/photo.jpg"}});

      spec.loadFixture("aspects_index");
      this.view = new app.views.Publisher();
    });

    describe('#showLocation', function(){
      it("Show location", function(){

        // inserts location to the DOM; it is the location's view element
        setFixtures('<div id="publisher_textarea_wrapper"></div>');

        // creates a fake Locator
        OSM = {};
        OSM.Locator = function(){return { getAddress:function(){}}};

        // validates there is not location
        expect($("#location").length).toBe(0);

        // this should create a new location
        this.view.showLocation();

        // validates there is one location created
        expect($("#location").length).toBe(1);
      })
    });

    describe('#destroyLocation', function(){
      it("Destroy location if exists", function(){
        setFixtures('<div id="location"></div>');
        this.view.view_locator = new app.views.Location({el: "#location"});
        this.view.destroyLocation();

        expect($("#location").length).toBe(0);
      })
    });

    describe('#avoidEnter', function(){
      it("Avoid submitting the form when pressing enter", function(){
        // simulates the event object
        evt = {};
        evt.keyCode = 13;

        // should return false in order to avoid the form submition
        expect(this.view.avoidEnter(evt)).toBeFalsy();
      })
    });
  });

});

