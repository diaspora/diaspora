/*   Copyright (c) 2010-2012, Diaspora Inc.  This file is
 *   licensed under the Affero General Public License version 3 or later.  See
 *   the COPYRIGHT file.
 */

describe("app.views.Publisher", function() {
  context("standalone", function() {
    beforeEach(function() {
      loginAs(factory.userAttrs());

      spec.loadFixture("aspects_index");
      this.view = new app.views.Publisher({
        standalone: true
      });
      this.view.open();
    });

    it("hides the close button in standalone mode", function() {
      expect(this.view.$(".md-cancel").is(":visible")).toBeFalsy();
    });

    it("hides the manage services link in standalone mode", function() {
      expect(this.view.$(".question_mark").is(":visible")).toBeFalsy();
    });

    describe("createStatusMessage", function(){
      it("doesn't add the status message to the stream", function() {
        app.stream = { addNow: $.noop };
        spyOn(app.stream, "addNow");
        this.view.createStatusMessage($.Event());
        jasmine.Ajax.requests.mostRecent().respondWith({ status: 200, responseText: "{\"id\": 1}" });
        expect(app.stream.addNow).not.toHaveBeenCalled();
      });
    });
  });

  context("plain publisher", function() {
    beforeEach(function() {
      loginAs(factory.userAttrs());

      spec.loadFixture("aspects_index");
      this.view = new app.views.Publisher();
    });

    describe("#initSubviews", function() {
      it("calls checkSubmitAvailability if the publisher is prefilled with mentions", function() {
        spyOn(this.view, "checkSubmitAvailability");
        this.view.prefillMention = "user@example.org";
        this.view.initSubviews();
        expect(this.view.checkSubmitAvailability).toHaveBeenCalled();
      });
    });

    describe("#open", function() {
      it("removes the 'closed' class from the publisher element", function() {
        expect($(this.view.el)).toHaveClass("closed");
        this.view.open($.Event());
        expect($(this.view.el)).not.toHaveClass("closed");
      });

      it("won't open when disabled", function() {
        this.view.disabled = true;
        this.view.open($.Event());
        expect($(this.view.el)).toHaveClass("closed");
      });
    });

    describe("#close", function() {
      beforeEach(function() {
        this.view.open($.Event());
      });

      it("removes the 'active' class from the publisher element", function(){
        this.view.close($.Event());
        expect($(this.view.el)).toHaveClass("closed");
      });

      it("resets the element's height", function() {
        $(this.view.el).find("#status_message_text").height(100);
        this.view.close($.Event());
        expect($(this.view.el).find("#status_message_text").attr("style")).not.toContain("height");
      });

      it("calls autosize.update", function() {
        spyOn(autosize, "update");
        this.view.close($.Event());
        expect(autosize.update).toHaveBeenCalledWith(this.view.inputEl);
      });

      it("should hide the poll container correctly", function() {
        this.view.$el.find(".poll-creator").click();
        expect(this.view.$el.find(".publisher-textarea-wrapper")).toHaveClass("with-poll");
        expect(this.view.$el.find(".poll-creator-container")).toBeVisible();
        this.view.close();
        expect(this.view.$el.find(".publisher-textarea-wrapper")).not.toHaveClass("with-poll");
        expect(this.view.$el.find(".poll-creator-container")).not.toBeVisible();
        this.view.open();
        expect(this.view.$el.find(".publisher-textarea-wrapper")).not.toHaveClass("with-poll");
        expect(this.view.$el.find(".poll-creator-container")).not.toBeVisible();
        this.view.$el.find(".poll-creator").click();
        expect(this.view.$el.find(".publisher-textarea-wrapper")).toHaveClass("with-poll");
        expect(this.view.$el.find(".poll-creator-container")).toBeVisible();
      });

      it("should close the publisher when clicking outside", function() {
        expect("#publisher").not.toHaveClass("closed");
        $("body").click();
        expect("#publisher").toHaveClass("closed");
      });

      it("should not close the publisher when clicking inside", function() {
        expect("#publisher").not.toHaveClass("closed");
        $("#publisher").find(".publisher-textarea-wrapper").click();
        expect("#publisher").not.toHaveClass("closed");
        $("#publisher").find(".aspect-dropdown button").click();
        expect("#publisher").not.toHaveClass("closed");
      });

      it("should not close the publisher when clicking inside on a mobile", function() {
        // Bootstrap inserts a .dropdown-backdrop next to the dropdown menu
        // that take the whole page when it detects a mobile.
        // Clicking on this element should not close the publisher.
        // See https://github.com/diaspora/diaspora/issues/6979.
        $("#publisher").find(".aspect-dropdown").append("<div class='dropdown-backdrop'></div>")
          .css({position: "fixed", left: 0, right: 0, bottom: 0, top: 0, "z-index": 990});
        expect("#publisher").not.toHaveClass("closed");
        $("#publisher").find(".aspect-dropdown button").click();
        expect("#publisher").not.toHaveClass("closed");
        $("#publisher").find(".dropdown-backdrop").click();
        expect("#publisher").not.toHaveClass("closed");
      });
    });

    describe("#clear", function() {
      it("calls close", function(){
        spyOn(this.view, "close");

        this.view.clear($.Event());
        expect(this.view.close).toHaveBeenCalled();
      });

      it("calls hidePreview", function() {
        spyOn(this.view.markdownEditor, "hidePreview");

        this.view.clear($.Event());
        expect(this.view.markdownEditor.hidePreview).toHaveBeenCalled();
      });

      it("clears all textareas", function(){
        _.each(this.view.$("textarea"), function(element){
          $(element).val('this is some stuff');
          expect($(element).val()).not.toBe("");
        });

        this.view.clear($.Event());

        _.each(this.view.$("textarea"), function(element){
          expect($(element).val()).toBe("");
        });
      });

      it("removes all photos from the dropzone area", function(){
        var self = this;
        _.times(3, function(){
          self.view.photozoneEl.append($("<li>"));
        });

        expect(this.view.photozoneEl.html()).not.toBe("");
        this.view.clear($.Event());
        expect(this.view.photozoneEl.html()).toBe("");
      });

      it("removes all photo values appended by the photo uploader", function(){
        $(this.view.el).prepend("<input name='photos[]' value='3'/>");
        var photoValuesInput = this.view.$("input[name='photos[]']");

        photoValuesInput.val("3");
        this.view.clear($.Event());
        expect(this.view.$("input[name='photos[]']").length).toBe(0);
      });

      it("destroy location if exists", function(){
        setFixtures('<div id="location"></div>');
        this.view.view_locator = new app.views.Location({el: "#location"});

        expect($("#location").length).toBe(1);
        this.view.clear($.Event());
        expect($("#location").length).toBe(0);
      });

      it("removes the 'submitting' class from the textarea wrapper", function(){
        this.view.wrapperEl.addClass("submitting");
        expect(this.view.wrapperEl).toHaveClass("submitting");
        this.view.clear($.Event());
        expect(this.view.wrapperEl).not.toHaveClass("submitting");
      });
    });

    describe("createStatusMessage", function(){
      it("adds the status message to the stream", function() {
        app.stream = { addNow: $.noop };
        spyOn(app.stream, "addNow");
        this.view.createStatusMessage($.Event());
        jasmine.Ajax.requests.mostRecent().respondWith({ status: 200, responseText: "{\"id\": 1}" });
        expect(app.stream.addNow).toHaveBeenCalled();
      });

      it("adds the 'submitting' class from the textarea wrapper", function(){
        expect(this.view.wrapperEl).not.toHaveClass("submitting");
        this.view.createStatusMessage($.Event());
        expect(this.view.wrapperEl).toHaveClass("submitting");
      });
    });

    describe('#setText', function() {
      it("sets the content text", function() {
        this.view.setText("FOO bar");
        expect(this.view.inputEl.val()).toEqual("FOO bar");
      });
    });

    describe('#setEnabled', function() {
      it("disables the publisher", function() {
        expect(this.view.disabled).toBeFalsy();
        this.view.setEnabled(false);

        expect(this.view.disabled).toBeTruthy();
        expect(this.view.inputEl.prop("disabled")).toBeTruthy();
      });

      it("disables submitting", function() {
        this.view.setText("TESTING");
        expect(this.view.submitEl.prop("disabled")).toBeFalsy();

        this.view.setEnabled(false);
        expect(this.view.submitEl.prop("disabled")).toBeTruthy();
      });
    });

    describe("publishing a post with keyboard", function(){
      it("should submit the form when ctrl+enter is pressed", function(){
        this.view.render();
        var form = this.view.$("form");
        var submitCallback = jasmine.createSpy().and.returnValue(false);
        form.submit(submitCallback);

        var e = $.Event("keydown", { which: Keycodes.ENTER, ctrlKey: true });
        this.view.keyDown(e);

        expect(submitCallback).toHaveBeenCalled();
        expect($(this.view.el)).not.toHaveClass("closed");
      });

      it("should submit the form when cmd+enter is pressed", function() {
        this.view.render();
        var form = this.view.$("form");
        var submitCallback = jasmine.createSpy().and.returnValue(false);
        form.submit(submitCallback);

        var e = $.Event("keydown", {which: Keycodes.ENTER, metaKey: true});
        this.view.keyDown(e);

        expect(submitCallback).toHaveBeenCalled();
        expect($(this.view.el)).not.toHaveClass("closed");
      });
    });

    describe("tryClose", function() {
      it("doesn't close the publisher if it is submittable", function() {
        spyOn(this.view, "_submittable").and.returnValue(true);
        spyOn(this.view, "close");
        this.view.tryClose();
        expect(this.view.close).not.toHaveBeenCalled();
      });

      it("doesn't close the publisher if it is in preview mode", function() {
        spyOn(this.view, "_submittable").and.returnValue(false);
        spyOn(this.view.markdownEditor, "isPreviewMode").and.returnValue(true);
        spyOn(this.view, "close");
        this.view.tryClose();
        expect(this.view.close).not.toHaveBeenCalled();
      });

      it("closes the publisher if it is neither submittable nor in preview mode", function() {
        spyOn(this.view, "_submittable").and.returnValue(false);
        spyOn(this.view.markdownEditor, "isPreviewMode").and.returnValue(false);
        spyOn(this.view, "close");
        this.view.tryClose();
        expect(this.view.close).toHaveBeenCalled();
      });
    });

    describe("_beforeUnload", function(){
      it("calls _submittable", function(){
        spyOn(this.view, "_submittable");
        $(window).trigger('beforeunload');
        expect(this.view._submittable).toHaveBeenCalled();
      });

      it("returns a confirmation if the publisher is submittable", function(){
        spyOn(this.view, "_submittable").and.returnValue(true);
        var e = $.Event();
        expect(this.view._beforeUnload(e)).toBe(Diaspora.I18n.t('confirm_unload'));
        expect(e.returnValue).toBe(Diaspora.I18n.t('confirm_unload'));
      });

      it("doesn't ask for a confirmation if the publisher isn't submittable", function(){
        spyOn(this.view, "_submittable").and.returnValue(false);
        var e = $.Event();
        expect(this.view._beforeUnload(e)).toBe(undefined);
        expect(e.returnValue).toBe(undefined);
      });
    });
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

    describe("#clear", function() {
      it("resets the char counter", function() {
        this.view.$(".service_icon").first().trigger("click");
        expect(parseInt(this.view.$(".counter").text(), 10)).toBeGreaterThan(0);
        this.view.$(".counter").text("0");
        expect(parseInt(this.view.$(".counter").text(), 10)).not.toBeGreaterThan(0);
        this.view.clear($.Event());
        expect(parseInt(this.view.$(".counter").text(), 10)).toBeGreaterThan(0);
      });
    });
  });

  context("aspect selection", function(){
    beforeEach( function(){
      loginAs(factory.userAttrs());
      spec.loadFixture("status_message_new");

      this.view = new app.views.Publisher();
      this.view.open();
    });

    it("initializes with 'all_aspects'", function(){
      expect($("#publisher #visibility-icon")).not.toHaveClass("entypo-globe");
      expect($("#publisher #visibility-icon")).toHaveClass("entypo-lock");
    });

    describe("toggles the selected entry visually", function(){
      it("click on the first aspect", function(){
        this.view.$(".aspect-dropdown li.aspect_selector:first").click();
        expect($("#publisher #visibility-icon")).not.toHaveClass("entypo-globe");
        expect($("#publisher #visibility-icon")).toHaveClass("entypo-lock");
      });

      it("click on public", function(){
        this.view.$(".aspect-dropdown li.public").click();
        expect($("#publisher #visibility-icon")).toHaveClass("entypo-globe");
        expect($("#publisher #visibility-icon")).not.toHaveClass("entypo-lock");
      });

      it("click on 'all aspects'", function(){
        expect($("#publisher #visibility-icon")).not.toHaveClass("entypo-globe");
        expect($("#publisher #visibility-icon")).toHaveClass("entypo-lock");
      });
    });

    describe("hidden form elements", function(){
      beforeEach(function(){
        $('.dropdown-menu').append('<li data-aspect_id="42" class="aspect_selector" />');
      });

      it("removes a previous selection and inserts the current one", function() {
        var selected = $('input[name="aspect_ids[]"]');
        expect(selected.length).toBe(1);
        expect(selected.first().val()).toBe('all_aspects');

        var evt = $.Event("click", { target: $('.aspect-dropdown li.aspect_selector:last') });
        this.view.viewAspectSelector.toggleAspect(evt);

        selected = $('input[name="aspect_ids[]"]');
        expect(selected.length).toBe(1);
        expect(selected.first().val()).toBe('42');
      });

      it("toggles the same item", function() {
        expect($('input[name="aspect_ids[]"][value="42"]').length).toBe(0);

        var evt = $.Event("click", { target: $('.aspect-dropdown li.aspect_selector:last') });
        this.view.viewAspectSelector.toggleAspect(evt);
        expect($('input[name="aspect_ids[]"][value="42"]').length).toBe(1);

        evt = $.Event("click", { target: $('.aspect-dropdown li.aspect_selector:last') });
        this.view.viewAspectSelector.toggleAspect(evt);
        expect($('input[name="aspect_ids[]"][value="42"]').length).toBe(0);
      });

      it("keeps other fields with different values", function() {
        $('.dropdown-menu').append('<li data-aspect_id="99" class="aspect_selector" />');
        var evt = $.Event("click", { target: $('.aspect-dropdown li.aspect_selector:eq(-2)') });
        this.view.viewAspectSelector.toggleAspect(evt);
        evt = $.Event("click", { target: $('.aspect-dropdown li.aspect_selector:eq(-1)') });
        this.view.viewAspectSelector.toggleAspect(evt);

        expect($('input[name="aspect_ids[]"][value="42"]').length).toBe(1);
        expect($('input[name="aspect_ids[]"][value="99"]').length).toBe(1);
      });
    });
  });

  context("locator", function() {
    beforeEach(function() {
      loginAs(factory.userAttrs());

      spec.loadFixture("aspects_index");
      this.view = new app.views.Publisher();
    });

    describe('#showLocation', function(){
      it("Show location", function(){

        // inserts location to the DOM; it is the location's view element
        setFixtures('<div class="location-container"></div>');

        // creates a fake Locator
        OSM = {};
        OSM.Locator = function(){return { getAddress:function(){}}};

        // validates there is not location
        expect($("#location").length).toBe(0);

        // this should create a new location
        this.view.showLocation();

        // validates there is one location created
        expect($("#location").length).toBe(1);
      });
    });

    describe('#destroyLocation', function(){
      it("Destroy location if exists", function(){
        setFixtures('<div id="location"></div>');
        this.view.view_locator = new app.views.Location({el: "#location"});
        this.view.destroyLocation();

        expect($("#location").length).toBe(0);
      });
    });

    describe('#avoidEnter', function(){
      it("Avoid submitting the form when pressing enter", function(){
        // simulates the event object
        var evt = $.Event("keydown", { which: Keycodes.ENTER });

        // should return false in order to avoid the form submition
        expect(this.view.avoidEnter(evt)).toBeFalsy();
      });
    });
  });

  context('uploader', function() {
    beforeEach(function() {
      jQuery.fx.off = true;
      setFixtures(
        "<div id=\"publisher\">" +
        "  <div class=\"content_creation\"><form>" +
        "    <div id=\"publisher-textarea-wrapper\">" +
        "      <div id=\"photodropzone_container\">" +
        "        <ul id=\"photodropzone\"></ul>" +
        "      </div>" +
        "    </div>" +
        "    <input type=\"submit\" />" +
        "  </form></div>" +
        "</div>"
      );
    });

    it("initializes the FineUploader plugin", function() {
      spyOn(qq, "FineUploaderBasic");
      new app.views.Publisher();

      expect(qq.FineUploaderBasic).toHaveBeenCalled();
    });

    context('event handlers', function() {
      beforeEach(function() {
        this.view = new app.views.Publisher();

        // replace the uploader plugin with a dummy object
        var uploadView = this.view.viewUploader;
        this.uploader = {
          onProgress: _.bind(uploadView.progressHandler, uploadView),
          onUploadStarted: _.bind(uploadView.uploadStartedHandler, uploadView),
          onUploadCompleted: _.bind(uploadView.uploadCompleteHandler, uploadView)
        };
        uploadView.uploader = this.uploader;
      });

      context("progress", function() {
        beforeEach(function() {
          this.view.photozoneEl.append(
            "<li id=\"upload-0\" class=\"publisher_photo loading\" style=\"position:relative;\">" +
            "  <div class=\"progress\">" +
            "    <div class=\"progress-bar progress-bar-striped active\" role=\"progressbar\"></div>" +
            "  </div>" +
            "  <div class=\"spinner\"></div>" +
            "</li>");
          this.view.photozoneEl.append(
            "<li id=\"upload-1\" class=\"publisher_photo loading\" style=\"position:relative;\">" +
            "  <div class=\"progress\">" +
            "    <div class=\"progress-bar progress-bar-striped active\" role=\"progressbar\"></div>" +
            "  </div>" +
            "  <div class=\"spinner\"></div>" +
            "</li>");
        });

        it("shows progress in percent", function() {
          this.uploader.onProgress(0, "test.jpg", 20);
          this.uploader.onProgress(1, "test2.jpg", 25);

          var dropzone = $("#photodropzone");
          expect(dropzone.find("li.loading#upload-0 .progress-bar").attr("style")).toBe("width: 20%;");
          expect(dropzone.find("li.loading#upload-1 .progress-bar").attr("style")).toBe("width: 25%;");
        });
      });

      context("submitting", function() {
        beforeEach(function() {
          this.uploader.onUploadStarted(null, "test.jpg");
        });

        it("adds a placeholder", function() {
          expect(this.view.wrapperEl.attr("class")).toContain("with_attachments");
          expect(this.view.photozoneEl.find("li").length).toBe(1);
        });

        it("disables the publisher buttons", function() {
          expect(this.view.submitEl.prop("disabled")).toBeTruthy();
        });
      });

      context('successful completion', function() {
        beforeEach(function() {
          $("#photodropzone").html("<li id='upload-0' class='publisher_photo loading'></li>");

          /* eslint-disable camelcase */
          this.uploader.onUploadCompleted(0, "test.jpg", {
            data: { photo: {
              id: '987',
              unprocessed_image: {
                scaled_full: {url: "/uploads/images/scaled_full_test.jpg"},
                thumb_large: {url: "/uploads/images/thumb_large_test.jpg"},
                thumb_medium: {url: "/uploads/images/thumb_medium_test.jpg"},
                thumb_small: {url: "/uploads/images/thumb_small_test.jpg"},
                url: "/uploads/images/test.jpg"
              }
            }},
            success: true });
        });
        /* eslint-enable camelcase */

        it('adds a hidden input to the publisher', function() {
          var input = this.view.$('input[type="hidden"][value="987"][name="photos[]"]');
          expect(input.length).toBe(1);
        });

        it('replaces the placeholder', function() {
          var li  = this.view.photozoneEl.find("li");
          var img = li.find('img');

          expect(li).not.toHaveClass("loading");
          expect(img.attr("src")).toBe("/uploads/images/thumb_medium_test.jpg");
          expect(img.attr("data-small")).toBe("/uploads/images/thumb_small_test.jpg");
          expect(img.attr("data-scaled")).toBe("/uploads/images/scaled_full_test.jpg");
          expect(img.attr("data-id")).toBe("987");
        });

        it('re-enables the buttons', function() {
          expect(this.view.submitEl.prop("disabled")).toBeFalsy();
        });
      });

      context('unsuccessful completion', function() {
        beforeEach(function() {
          $("#photodropzone").append("<li id='upload-0' class='publisher_photo loading'></li>");

          /* eslint-disable camelcase */
          this.uploader.onUploadCompleted(0, "test.jpg", {
            data: { photo: {
              id: '987',
              unprocessed_image: {
                thumb_small: {url: "test.jpg"},
                thumb_medium: {url: "test.jpg"},
                thumb_large: {url: "test.jpg"},
                scaled_full: {url: "test.jpg"}
              }
            }},
            success: false });
        });
        /* eslint-enable camelcase */
        it('shows error message', function() {
          expect($("#photodropzone li").length).toEqual(0);
          expect($("#upload_error").text()).toBe(Diaspora.I18n.t("photo_uploader.error", {file: "test.jpg"}));
        });
      });
    });

    context('photo removal', function() {
      beforeEach(function(done) {
        this.view = new app.views.Publisher();
        this.view.wrapperEl.addClass("with_attachments");
        this.view.photozoneEl.html(
          "<li class=\"publisher_photo\">."+
          "  <img data-id=\"444\" />"+
          "  <div class=\"x\">X</div>"+
          "  <div class=\"circle\"></div>"+
          "</li>"
        );

        spyOn(jQuery, 'ajax').and.callFake(function(opts) { opts.success(); });
        this.view.viewUploader.on("change", done);
        this.view.photozoneEl.find(".x").click();
      });

      it('removes the element', function() {
        var photo = this.view.photozoneEl.find("li.publisher_photo");
        expect(photo.length).toBe(0);
      });

      it('sends an ajax request', function() {
        expect($.ajax).toHaveBeenCalled();
      });

      it('removes class on wrapper element', function() {
        expect(this.view.wrapperEl.attr("class")).not.toContain("with_attachments");
      });
    });
  });
});
