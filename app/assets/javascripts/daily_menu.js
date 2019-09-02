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

  $("#daily_menu_details_area").on('keyup','.manufacturing_number', function(){
    calculate_num();
  });

  $("#daily_menu_details_area").on('keyup','.manufacturing_number', function(){
    calculate_num();
  });
  $("#daily_menu_details_area").on('click','.remove_fields', function(){
    setTimeout(function(){
      calculate_num();
    },5);
  });



  function calculate_num(){
    var sum = 0;
    $('.daily_menu_detail_tr:visible').each(function(i){
      sum += Number($(this).find('.manufacturing_number').val());
    });
    $('.total_manufacturing_number').val(sum);
  }
  $("#daily_menu_details_area").on("blur",'.make_dailymenu_management_id_search',function(){
    var management_id =  parseInt($(this).val());
    var inp = $(this).parent().parent().find(".input_select_product")
    $.ajax({
      url: "/orders/get_management_id",
      data: { management_id : management_id },
      dataType: "json",
      async: false
    })
    .done(function(data){
      if (data) {
        var id = parseInt(data.id)
        inp.val(id).change();
      }else{
        inp.val("").change();
      }
    });
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
