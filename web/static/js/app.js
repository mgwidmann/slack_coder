// Brunch automatically concatenates all files in your
// watched paths. Those paths can be configured at
// config.paths.watched in "brunch-config.js".
//
// However, those files will only be executed if
// explicitly imported. The only exception are files
// in vendor, which are never wrapped in imports and
// therefore are always executed.

// Import dependencies
//
// If you no longer want to use a dependency, remember
// to also remove its path from "config.paths.watched".
import "phoenix_html";
require("bootstrap");
// Import local files
//
// Local files can be imported directly using relative
// paths "./socket" or full ones "web/static/js/socket".

import socket from "./socket"

$('#view_user').on('change', function() {
  document.location.href = `/?user=${$(this).val()}`;
});

$(document).on('click', '.refresh-pr', function(){
  var owner = $(this).data('owner');
  var repo = $(this).data('repo');
  var pr = $(this).data('pr');
  $.ajax({
    method: 'GET',
    url: `/api/pull_requests/${owner}/${repo}/${pr}/refresh`
  })
});

$(function () {
  $('[data-toggle="tooltip"]').tooltip()
})
