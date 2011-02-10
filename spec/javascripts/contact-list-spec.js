/*   Copyright (c) 2010, Diaspora Inc.  This file is
*   licensed under the Affero General Public License version 3 or later.  See
*   the COPYRIGHT file.
*/

describe("Contact List", function() {
    describe("disconnectUser", function() {
      it("does an ajax call to person delete with the passed in id", function(){
        var id = '3';
        spyOn($,'ajax').andCallThrough();
        List.disconnectUser(id);
        expect($.ajax).toHaveBeenCalledWith(
            url: "/people/" + id,
            type: "DELETE",
            success: function(){
                $('.contact_list li[data-guid='+id+']').fadeOut(200);
              }
          );
      });
  });
});
