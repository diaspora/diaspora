/*   Copyright (c) 2010-2011, Diaspora Inc.  This file is
*   licensed under the Affero General Public License version 3 or later.  See
*   the COPYRIGHT file.
*/

describe("Publisher", function() {

  describe("runDelayedSearch", function() {
    beforeEach( function(){
      spec.loadFixture('pending_external_people_search');
      Publisher.open();
    });

    it('gets called on initialize', function(){
      spyOn(Publisher, 'runDelayedSearch');
      Publisher.initialize();
      expect(Publisher.runDelayedSearch).toHaveBeenCalled();
    });
  });

  describe("runDelayedSearch", function() {
    beforeEach( function(){
      spec.loadFixture('empty_people_search');
      Publisher.open();
    });

    it('inserts contact html', function(){
      Publisher.initialize();
      Publisher.handleSearchRefresh( "<div class='testing_insert_div'>hello</div>");
      expect($(".testing_insert_div").text().toEqual( "hello" ));

    });
  });
});
