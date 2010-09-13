/*   Copyright 2010 Diaspora Inc.
 *
 *   This file is part of Diaspora.
 *
 *   Diaspora is free software: you can redistribute it and/or modify
 *   it under the terms of the GNU Affero General Public License as published by
 *   the Free Software Foundation, either version 3 of the License, or
 *   (at your option) any later version.
 *
 *   Diaspora is distributed in the hope that it will be useful,
 *   but WITHOUT ANY WARRANTY; without even the implied warranty of
 *   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 *   GNU Affero General Public License for more details.
 *
 *   You should have received a copy of the GNU Affero General Public License
 *   along with Diaspora.  If not, see <http://www.gnu.org/licenses/>.
 */


$(document).ready( function() {
    $('div#image_picker div.small_photo').click( function() {
      $('#image_url_field').val($(this).attr('id'));

      $('div#image_picker div.small_photo').removeClass('selected');
      $("div#image_picker div.small_photo input[type='checkbox']").attr("checked", false);

      $(this).addClass('selected');
      $(this).children("input[type='checkbox']").attr("checked", true);
    });
});
