describe("Diaspora.Alert", function() {
  beforeEach(function() {
    spec.loadFixture("aspects_index");

    $(document).trigger("close.facebox");
  });

  afterEach(function() {
    $("#facebox").remove();

  });


  describe("on widget ready", function() {
    it("should remove #diaspora_alert on close.facebox", function() {
      Diaspora.Alert.show("YEAH", "YEAHH");
      expect($("#diaspora_alert").length).toEqual(1);
      $(document).trigger("close.facebox");
      expect($("#diaspora_alert").length).toEqual(0);
    });
  });

  describe("alert", function() {
    it("should render a mustache template and append it the body", function() {
      Diaspora.Alert.show("YO", "YEAH");
      expect($("#diaspora_alert").length).toEqual(1);
      $(document).trigger("close.facebox");
    });
  });
});
