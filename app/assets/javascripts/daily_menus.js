$(document).on('turbolinks:load', function() {
  reset_row_order();
  $("#daily_menu_details_area").sortable({
    update: function(){
      reset_row_order();
  }});
  $('.add_menu_details').on('click',function(){
    setTimeout(function(){
      $(".input_select_product").select2();
      reset_row_order();
    },1);
  });
  //destrou
  $("#daily_menu_details_area").on('click','.remove_fields', function(){
    setTimeout(function(){
      reset_row_order();
    },10);
  });
  //並び替え
  function reset_row_order(){
    var u = 0
    $(".daily_menu_detail_tr:visible").each(function(){
      $(this).children(".row_order").children().val(u)
      u += 1
    });
  };
});
