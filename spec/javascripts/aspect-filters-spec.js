/*   Copyright (c) 2010, Diaspora Inc.  This file is
*   licensed under the Affero General Public License version 3 or later.  See
*   the COPYRIGHT file.
*/

describe('AspectFilters', function(){
  it('initializes selectedGUIDS', function(){
    expect(AspectFilters.selectedGUIDS).toEqual([]);
  });
  it('initializes requests', function(){
    expect(AspectFilters.requests).toEqual(0);
  });
});
