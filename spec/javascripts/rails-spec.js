describe("rails", function() {
  describe("remote forms", function() {
    beforeEach(function() {
      $("#jasmine_content").html(
          '<form accept-charset="UTF-8" id="form" action="/status_messages" data-remote="true"  method="post">' +
            '<textarea id="status_message_message" name="status_message[message]">Some status message</textarea>' +
            '<input type="submit">' +
          '</form>'
      );
    });
    it("should retain form values if ajax fails", function() {
      $('#form').trigger('ajax:failure');
      expect($('#status_message_message').val()).not.toEqual("");
    });
    it("should clear form on ajax:success", function() {
      $('#form').trigger('ajax:success');
      
      expect($('#status_message_message').val()).toEqual("");
    
    });
  });
});