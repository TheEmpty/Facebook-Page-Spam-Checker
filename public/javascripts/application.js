jQuery(function($) {
  // create a convenient toggleLoading function
  var toggleLoading = function() { $("#ajax_loader").toggle() };

  $(".ajax_loading")
    .bind("ajaxStart",  toggleLoading)
    .bind("ajaxComplete", toggleLoading);
});
