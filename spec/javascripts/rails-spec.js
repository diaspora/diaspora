describe("rails", function() {
  describe("remote forms", function() {
    beforeEach(function() {
      $("#jasmine_content").html(
          '<form accept-charset="UTF-8" id="form" action="/status_messages" data-remote="true"  method="post">' +
            '<textarea id="status_message_text" name="status_message[text]">Some status message</textarea>' +
            '<input type="submit">' +
            '<input id="standard_hidden" type="hidden" value="keep this value">' +
            '<input id="clearable_hidden" type="hidden" class="clear_on_submit" value="clear this value">' +
          '</form>'
      );
    });
    it("should retain form values if ajax fails", function() {
      $('#form').trigger('ajax:failure');
      expect($('#status_message_text').val()).not.toEqual("");
    });
    it("should clear form on ajax:success", function() {
      $('#form').trigger('ajax:success');

      expect($('#status_message_text').val()).toEqual("");

    });
    it('should not clear normal hidden fields', function(){
      $('#form').trigger('ajax:success');
      expect($('#standard_hidden').val()).toEqual("keep this value");
    });
    it('should clear hidden fields marked clear_on_submit', function(){
      $('#form').trigger('ajax:success');
      expect($('#clearable_hidden').val()).toEqual("");
    });
  });
});
