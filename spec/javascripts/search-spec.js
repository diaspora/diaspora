/*   Copyright (c) 2010-2011, Diaspora Inc.  This file is
*   licensed under the Affero General Public License version 3 or later.  See
*   the COPYRIGHT file.
*/

describe("List", function() {

  describe("runDelayedSearch", function() {
    beforeEach( function(){
    });

    it('gets called on initialize', function(){
      spyOn( List, 'startSearchDelay');
      spec.loadFixture('pending_external_people_search');
      expect(List.startSearchDelay).toHaveBeenCalled();
    });
  });

  describe("runDelayedSearch", function() {
    beforeEach( function(){
      spec.loadFixture('empty_people_search');
      List.initialize();
    });

    it('inserts contact html', function(){
      List.handleSearchRefresh( { count:1,search_html: '<div class='testing_insert_div'>hello</div>' } );
      expect($(".testing_insert_div").text().toEqual( "hello" ));

    });
  });
});
