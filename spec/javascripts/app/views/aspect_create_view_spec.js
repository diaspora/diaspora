describe("app.views.AspectCreate", function() {
  beforeEach(function() {
    app.events.off("aspect:create");
    // disable jshint camelcase for i18n
    /* jshint camelcase: false */
    Diaspora.I18n.load({
      aspects: {
        make_aspect_list_visible: "Make contacts in this aspect visible to each other?",
        name: "Name",
        create: {
          add_a_new_aspect: "Add a new aspect",
          success: "Your new aspect <%= name %> was created",
          failure: "Aspect creation failed."
        }
      }
    });
    /* jshint camelcase: true */
  });

  context("without a person id", function() {
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
        expect(this.view.$("#newAspectModal input#aspect_contacts_visible").length).toBe(1);
        expect(this.view.$("#newAspectModal .btn.creation").length).toBe(1);
      });

      it("shouldn't show a hidden person id input", function() {
        expect(this.view.$("#newAspectModal input#aspect_person_id").length).toBe(0);
      });
    });


    describe("#createAspect", function() {
      beforeEach(function() {
        this.view.render();
      });

      it("should send the correct name to the server", function() {
        var name = "New aspect name";
        this.view.$("input#aspect_name").val(name);
        this.view.createAspect();
        var obj = JSON.parse(jasmine.Ajax.requests.mostRecent().params);
        expect(obj.name).toBe(name);
      });

      it("should send the correct contacts_visible to the server", function() {
        this.view.createAspect();
        var obj = JSON.parse(jasmine.Ajax.requests.mostRecent().params);
        /* jshint camelcase: false */
        expect(obj.contacts_visible).toBeFalsy();
        /* jshint camelcase: true */

        this.view.$("input#aspect_contacts_visible").prop("checked", true);
        this.view.createAspect();
        obj = JSON.parse(jasmine.Ajax.requests.mostRecent().params);
        /* jshint camelcase: false */
        expect(obj.contacts_visible).toBeTruthy();
        /* jshint camelcase: true */
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
          this.view.$(".modal").modal("show");
          expect(this.view.$(".modal")).toHaveClass("in");
          this.view.createAspect();
          jasmine.Ajax.requests.mostRecent().respondWith(this.response);
          expect(this.view.$(".modal")).not.toHaveClass("in");
        });

        it("should display a flash message", function() {
          this.view.createAspect();
          jasmine.Ajax.requests.mostRecent().respondWith(this.response);
          expect($("[id^=\"flash\"]")).toBeSuccessFlashMessage(
            Diaspora.I18n.t("aspects.create.success", {name: "new name"})
          );
        });
      });

      context("with a failing request", function() {
        beforeEach(function() {
          this.response = { status: 422 };
        });

        it("should hide the modal", function() {
          this.view.$(".modal").modal("show");
          expect(this.view.$(".modal")).toHaveClass("in");
          this.view.createAspect();
          jasmine.Ajax.requests.mostRecent().respondWith(this.response);
          expect(this.view.$(".modal")).not.toHaveClass("in");
        });

        it("should display a flash message", function() {
          this.view.createAspect();
          jasmine.Ajax.requests.mostRecent().respondWith(this.response);
          expect($("[id^=\"flash\"]")).toBeErrorFlashMessage(
            Diaspora.I18n.t("aspects.create.failure")
          );
        });
      });
    });
  });

  context("with a person id", function() {
    beforeEach(function() {
      this.view    = new app.views.AspectCreate({personId: "42"});
    });

    describe("#render", function() {
      beforeEach(function() {
        this.view.render();
      });

      it("should show the aspect creation form inside a modal", function() {
        expect(this.view.$("#newAspectModal.modal").length).toBe(1);
        expect(this.view.$("#newAspectModal form").length).toBe(1);
        expect(this.view.$("#newAspectModal input#aspect_name").length).toBe(1);
        expect(this.view.$("#newAspectModal input#aspect_contacts_visible").length).toBe(1);
        expect(this.view.$("#newAspectModal .btn.creation").length).toBe(1);
      });

      it("should show a hidden person id input", function() {
        expect(this.view.$("#newAspectModal input#aspect_person_id").length).toBe(1);
        expect(this.view.$("#newAspectModal input#aspect_person_id").prop("value")).toBe("42");
      });
    });

    describe("#createAspect", function() {
      beforeEach(function() {
        this.view.render();
      });

      it("should send the correct name to the server", function() {
        var name = "New aspect name";
        this.view.$("input#aspect_name").val(name);
        this.view.createAspect();
        var obj = JSON.parse(jasmine.Ajax.requests.mostRecent().params);
        expect(obj.name).toBe(name);
      });

      it("should send the correct contacts_visible to the server", function() {
        this.view.createAspect();
        var obj = JSON.parse(jasmine.Ajax.requests.mostRecent().params);
        /* jshint camelcase: false */
        expect(obj.contacts_visible).toBeFalsy();
        /* jshint camelcase: true */

        this.view.$("input#aspect_contacts_visible").prop("checked", true);
        this.view.createAspect();
        obj = JSON.parse(jasmine.Ajax.requests.mostRecent().params);
        /* jshint camelcase: false */
        expect(obj.contacts_visible).toBeTruthy();
        /* jshint camelcase: true */
      });

      it("should send the correct person_id to the server", function() {
        this.view.createAspect();
        var obj = JSON.parse(jasmine.Ajax.requests.mostRecent().params);
        /* jshint camelcase: false */
        expect(obj.person_id).toBe("42");
        /* jshint camelcase: true */
      });
    });
  });
});
