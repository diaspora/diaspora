describe("app.models.Message", function() {

  beforeEach(function() {
    this.message = new app.models.Message();
  });

  describe("saveDraft", function() {

    beforeEach(function() {
      this.message.set("text", "Cool Beans");
      this.message.saveDraft();
    });

    it("should store the text in localStorage", function() {
      var messageAttributes = JSON.parse(localStorage.getItem("message")).text;
      expect(messageAttributes).toEqual("Cool Beans");
    });

    describe("getDraft", function() {

      it("should retrieve the text in localStorage", function() {
        var messageAttributes = this.message.getDraft().text;
        expect(messageAttributes).toEqual("Cool Beans");
      });
    });
  });
});
