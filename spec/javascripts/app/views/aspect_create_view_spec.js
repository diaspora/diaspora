describe("app.views.AspectCreate", function() {
  beforeEach(function() {
    app.events.off("aspect:create");
  });

  context("without a person", function() {
    beforeEach(function() {
      this.view    = new app.views.AspectCreate();
    });

    describe("#render", function() {
      beforeEach(function() {
        this.view.render();
      });

      it("should show the aspect creation form inside a modal", function() {
        expect(this.view.$("#newAspectModal.modal").length).toBe(1);
        expect(this.view.$("#newAspectModal form").length).toBe(1);
        expect(this.view.$("#newAspectModal input#aspect_name").length).toBe(1);
        expect(this.view.$("#newAspectModal .btn-primary").length).toBe(1);
      });

      it("shouldn't show a hidden person id input", function() {
        expect(this.view.$("#newAspectModal input#aspect_person_id").length).toBe(0);
      });
    });

    describe("#inputKeypress", function() {
      beforeEach(function() {
        this.view.render();
        spyOn(this.view, "createAspect");
      });

      it("should call createAspect if the enter key was pressed", function() {
        var e = $.Event("keypress", { which: Keycodes.ENTER });
        this.view.inputKeypress(e);
        expect(this.view.createAspect).toHaveBeenCalled();
      });

      it("shouldn't call createAspect if another key was pressed", function() {
        var e = $.Event("keypress", { which: Keycodes.TAB });
        this.view.inputKeypress(e);
        expect(this.view.createAspect).not.toHaveBeenCalled();
      });
    });

    describe("#createAspect", function() {
      beforeEach(function() {
        this.view.render();
        this.view.$el.append($("<div id='flash-container'/>"));
        app.flashMessages = new app.views.FlashMessages({ el: this.view.$("#flash-container") });
        app.aspects = new app.collections.Aspects();
      });

      it("should send the correct name to the server", function() {
        var name = "New aspect name";
        this.view.$("input#aspect_name").val(name);
        this.view.createAspect();
        var obj = JSON.parse(jasmine.Ajax.requests.mostRecent().params);
        expect(obj.name).toBe(name);
      });

      it("should send person_id = null to the server", function() {
        this.view.createAspect();
        var obj = JSON.parse(jasmine.Ajax.requests.mostRecent().params);
        /* jshint camelcase: false */
        expect(obj.person_id).toBe(null);
        /* jshint camelcase: true */
      });

      context("with a successfull request", function() {
        beforeEach(function() {
          this.response = {
            status: 200,
            responseText: JSON.stringify({id: 1337, name: "new name"})
          };
        });

        it("should hide the modal", function() {
          this.view.$(".modal").removeClass("fade");
          this.view.$(".modal").modal("toggle");
          expect(this.view.$(".modal")).toHaveClass("in");
          this.view.createAspect();
          jasmine.Ajax.requests.mostRecent().respondWith(this.response);
          expect(this.view.$(".modal")).not.toHaveClass("in");
        });

        it("should display a flash message", function() {
          this.view.createAspect();
          jasmine.Ajax.requests.mostRecent().respondWith(this.response);
          expect(this.view.$(".flash-message")).toBeSuccessFlashMessage(
            Diaspora.I18n.t("aspects.create.success", {name: "new name"})
          );
        });
      });

      context("with a failing request", function() {
        beforeEach(function() {
          this.response = { status: 422 };
        });

        it("should hide the modal", function() {
          this.view.$(".modal").removeClass("fade");
          this.view.$(".modal").modal("show");
          expect(this.view.$(".modal")).toHaveClass("in");
          this.view.createAspect();
          jasmine.Ajax.requests.mostRecent().respondWith(this.response);
          expect(this.view.$(".modal")).not.toHaveClass("in");
        });

        it("should display a flash message", function() {
          this.view.createAspect();
          jasmine.Ajax.requests.mostRecent().respondWith(this.response);
          expect(this.view.$(".flash-message")).toBeErrorFlashMessage(
            Diaspora.I18n.t("aspects.create.failure")
          );
        });
      });
    });
  });

  context("with a person", function() {
    beforeEach(function() {
      var person = new app.models.Person({id: "42"});
      this.view = new app.views.AspectCreate({person: person});
    });

    describe("#render", function() {
      beforeEach(function() {
        this.view.render();
      });

      it("should show the aspect creation form inside a modal", function() {
        expect(this.view.$("#newAspectModal.modal").length).toBe(1);
        expect(this.view.$("#newAspectModal form").length).toBe(1);
        expect(this.view.$("#newAspectModal input#aspect_name").length).toBe(1);
        expect(this.view.$("#newAspectModal .btn-primary").length).toBe(1);
      });

      it("should show a hidden person id input", function() {
        expect(this.view.$("#newAspectModal input#aspect_person_id").length).toBe(1);
        expect(this.view.$("#newAspectModal input#aspect_person_id").prop("value")).toBe("42");
      });
    });

    describe("#createAspect", function() {
      beforeEach(function() {
        this.view.render();
        app.aspects = new app.collections.Aspects();
      });

      it("should send the correct name to the server", function() {
        var name = "New aspect name";
        this.view.$("input#aspect_name").val(name);
        this.view.createAspect();
        var obj = JSON.parse(jasmine.Ajax.requests.mostRecent().params);
        expect(obj.name).toBe(name);
      });

      it("should send the correct person_id to the server", function() {
        this.view.createAspect();
        var obj = JSON.parse(jasmine.Ajax.requests.mostRecent().params);
        /* jshint camelcase: false */
        expect(obj.person_id).toBe("42");
        /* jshint camelcase: true */
      });

      it("should ensure that events order is fine", function() {
        spyOn(this.view, "ensureEventsOrder").and.callThrough();
        this.view.$(".modal").removeClass("fade");
        this.view.$(".modal").modal("toggle");
        this.view.createAspect();
        jasmine.Ajax.requests.mostRecent().respondWith({
          status: 200,
          responseText: JSON.stringify({id: 1337, name: "new name"})
        });
        expect(this.view.ensureEventsOrder.calls.count()).toBe(2);
      });

      it("should ensure that events order is fine after failure", function() {
        spyOn(this.view, "ensureEventsOrder").and.callThrough();
        this.view.$(".modal").removeClass("fade");
        this.view.$(".modal").modal("toggle");
        this.view.createAspect();
        jasmine.Ajax.requests.mostRecent().respondWith({status: 422});
        expect(this.view.ensureEventsOrder.calls.count()).toBe(1);

        this.view.$(".modal").removeClass("fade");
        this.view.$(".modal").modal("toggle");
        this.view.createAspect();
        jasmine.Ajax.requests.mostRecent().respondWith({
          status: 200,
          responseText: JSON.stringify({id: 1337, name: "new name"})
        });
        expect(this.view.ensureEventsOrder.calls.count()).toBe(3);
      });
    });
  });
});
