/*   Copyright (c) 2011, Diaspora Inc.  This file is
*   licensed under the Affero General Public License version 3 or later.  See
*   the COPYRIGHT file.
*/

describe("TagFollowings", function() {
  describe("unfollow", function(){
    it("tests unfollow icon visibility on mouseover event", function(){
      spec.loadFixture('aspects_index_with_one_followed_tag');
      TagFollowings.initialize();

      var tag_li = $('li.unfollow#partytimeexcellent');
      var icon_div = $('.unfollow_icon');

      expect(icon_div.hasClass('hidden')).toBeTruthy();
      tag_li.mouseover();
      expect(icon_div.hasClass('hidden')).toBeFalsy();
      tag_li.mouseout();
      expect(icon_div.hasClass('hidden')).toBeTruthy();
    });
  });
});
