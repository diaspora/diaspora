describe("app.models.Notification", function() {
  beforeEach(function() {
    this.model = new app.models.Notification({
      "reshared": {},
      "type": "reshared"
    });
  });

  describe("constructor", function() {
    it("calls parent constructor with the correct parameters", function() {
      spyOn(Backbone, "Model").and.callThrough();
      new app.models.Notification({attribute: "attribute"}, {option: "option"});
      expect(Backbone.Model).toHaveBeenCalledWith(
        {attribute: "attribute"},
        {option: "option", parse: true}
      );
    });
  });

  describe("parse", function() {
    beforeEach(function() {
      this.response = {
        "reshared": {
          "id": 45,
          "target_type": "Post",
          "target_id": 11,
          "recipient_id": 1,
          "unread": true,
          "created_at": "2015-10-27T19:56:30.000Z",
          "updated_at": "2015-10-27T19:56:30.000Z",
          "note_html": "<html/>"
        },
        "type": "reshared"
      };
      this.parsedResponse = {
        "type": "reshared",
        "id": 45,
        "target_type": "Post",
        "target_id": 11,
        "recipient_id": 1,
        "unread": true,
        "created_at": "2015-10-27T19:56:30.000Z",
        "updated_at": "2015-10-27T19:56:30.000Z",
        "note_html": "<html/>"
      };
    });

    it("correctly parses the object", function() {
      var parsed = this.model.parse(this.response);
      expect(parsed).toEqual(this.parsedResponse);
    });

    it("correctly parses the object twice", function() {
      var parsed = this.model.parse(this.parsedResponse);
      expect(parsed).toEqual(this.parsedResponse);
    });
  });

  describe("setRead", function() {
    it("calls setUnreadStatus with 'false'", function() {
      spyOn(app.models.Notification.prototype, "setUnreadStatus");
      new app.models.Notification({"reshared": {}, "type": "reshared"}).setRead();
      expect(app.models.Notification.prototype.setUnreadStatus).toHaveBeenCalledWith(false);
    });
  });

  describe("setUnread", function() {
    it("calls setUnreadStatus with 'true'", function() {
      spyOn(app.models.Notification.prototype, "setUnreadStatus");
      new app.models.Notification({"reshared": {}, "type": "reshared"}).setUnread();
      expect(app.models.Notification.prototype.setUnreadStatus).toHaveBeenCalledWith(true);
    });
  });

  describe("setUnreadStatus", function() {
    beforeEach(function() {
      this.target = new app.models.Notification({"reshared": {id: 16}, "type": "reshared"});
      spyOn(app.models.Notification.prototype, "set").and.callThrough();
      spyOn(app.models.Notification.prototype, "trigger");
    });

    it("calls calls ajax with correct parameters and sets 'unread' attribute", function() {
      this.target.setUnreadStatus(true);
      jasmine.Ajax.requests.mostRecent().respondWith({status: 200, responseText: '{"guid": 16, "unread": true}'});
      var call = jasmine.Ajax.requests.mostRecent();

      expect(call.url).toBe("/notifications/16");
      /* eslint-disable camelcase */
      expect(call.params).toEqual("set_unread=true");
      /* eslint-enable camelcase */
      expect(call.method).toEqual("PUT");
      expect(app.models.Notification.prototype.set).toHaveBeenCalledWith("unread", true);
      expect(app.models.Notification.prototype.trigger).toHaveBeenCalledWith("userChangedUnreadStatus", this.target);
    });
  });
});
