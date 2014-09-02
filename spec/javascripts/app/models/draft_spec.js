describe("app.models.Draft", function() {

  beforeEach(function() {
    this.draft = new app.models.Draft();
  });

  describe("saveDraft", function() {

    beforeEach(function() {
      this.draft.set("text", "Cool Beans");
      this.draft.saveDraft();
    });

    it("should store the text in localStorage", function() {
      var messageAttributes = JSON.parse(localStorage.getItem("message")).text;
      expect(messageAttributes).toEqual("Cool Beans");
    });

    describe("getDraft", function() {

      it("should retrieve the text in localStorage", function() {
        var messageAttributes = this.draft.getDraft().text;
        expect(messageAttributes).toEqual("Cool Beans");
      });
    });
  });
});
