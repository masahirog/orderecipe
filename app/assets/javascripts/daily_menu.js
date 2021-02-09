$(document).on('turbolinks:load', function() {
  reset_row_order();

  $('#daily_menu_details_area').on('keyup','.input_num',function(){
    var single_item_num = Number($(this).parents('.daily_menu_detail_tr').find('.single_item_number').val());
    var sub_item_num = Number($(this).parents('.daily_menu_detail_tr').find('.sub_item_number').val());
    var total_manufacturing_number = single_item_num + sub_item_num
    $(this).parents('.daily_menu_detail_tr').find('.manufacturing_number').val(total_manufacturing_number);
    calculate_num();
  });


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

  $("#daily_menu_details_area").on('click','.remove_fields', function(){
    setTimeout(function(){
      calculate_num();
    },5);
  });

  $("#daily_menu_details_area").on("change",'.input_select_product',function(){
    var product_id =  parseInt($(this).val());
    var td = $(this).parent().parent().find(".bejihan_sozai_flag_td")
    $.ajax({
      url: "/products/get_product",
      data: { product_id : product_id },
      dataType: "json",
      async: false
    })
    .done(function(data){
      if (data['bejihan_sozai_flag']==true) {
        td.text('true');
      }else{
        td.text('');
      };
      calculate_num();
    });
  });



  function calculate_num(){
    var total_sum = 0;
    var sozai_sum = 0;
    $('.daily_menu_detail_tr:visible').each(function(i){
      total_sum += Number($(this).find('.manufacturing_number').val());
      if ($(this).find('.bejihan_sozai_flag_td').text()=='true') {
        sozai_sum += Number($(this).find('.single_item_number').val());
        console.log(sozai_sum);
      }
    });
    $('.total_manufacturing_number').val(total_sum);
    $('.input_sozai_manufacturing_number').val(sozai_sum);
  }

  //並び替え
  function reset_row_order(){
    var u = 0
    $(".daily_menu_detail_tr:visible").each(function(){
      $(this).children(".row_order").children().val(u)
      u += 1
    });
  };
});
