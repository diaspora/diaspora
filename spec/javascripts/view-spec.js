/*   Copyright (c) 2010-2011, Diaspora Inc.  This file is
*   licensed under the Affero General Public License version 3 or later.  See
*   the COPYRIGHT file.
*/

describe("View", function() {
  it("is the object that helps the UI", function() {
    expect(typeof View === "object").toBeTruthy();
  });

  describe("publisher", function() {
    beforeEach(function() {
      $("#jasmine_content").html(
        '<div id="publisher">' +
          '<form action="/status_messages" class="new_status_message" id="new_status_message" method="post">' +
            '<textarea id="status_message_text" name="status_message[text]"></textarea>' +
          '</form>' +
        '</div>'
      );
    });
  });

  describe("search", function() {
    beforeEach(function() {
      $("#jasmine_content").html(
        '<input id="q" name="q" placeholder="Search" results="5" type="search" class="">'
      );
    });
    describe("focus", function() {
      it("adds the class 'active' when the user focuses the text field", function() {
        View.initialize();
        $(View.search.selector).focus();
        expect($(View.search.selector)).toHaveClass("active");
      });
    });
    describe("blur", function() {
      it("removes the class 'active' when the user blurs the text field", function() {
        View.initialize();
        $(View.search.selector).focus().blur();
        expect($(View.search.selector)).not.toHaveClass("active");
      });
    });
  });
});
