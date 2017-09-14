import '../css/app.scss';
import 'bootstrap';
import "phoenix_html";
import socket from "./socket"

$('#view_user').on('change', function() {
  document.location.href = `/?user=${$(this).val()}`;
});

$( document ).ajaxSend((event, xhr, settings) => {
  xhr.setRequestHeader('Authorization', `Bearer ${window.token}`);
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
