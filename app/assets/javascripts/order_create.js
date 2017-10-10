$(function(){
    $('.input_select_product').select2({
    width:"300px",
    placeholder: "お弁当を選択してください"
  });
    $('.select_order_materials').select2({
    width:"200px",
    placeholder: "発注する食材を選択"
  });

  // //removeアクション、materialの削除
  // $(".orders_all").on('click','.remove', function(){
  //   $(this).parent().children(".destroy_order_materials").val(true);
  //       $(this).parent().parent("li").hide();
  // });
  //
  // //addアクション、materialの追加
  // $(".add_order_materials").on('click', function(){
  //     var u = $(".order_materials_li").length;
  //     $(".select_order_materials").select2('destroy');
  //     $("#order_materials_list_0").clone().attr('id', "order_materials_list_" + u ).appendTo(".order_materials_ul");
  //     $("#order_materials_list_" + u).children(".material_name").children(".select_order_materials").val("");
  //     $(".select_order_materials").select2({width:"200px",placeholder: "発注する食材を選択"});
  //     $("#order_materials_list_" + u).children(".order_quantity").children().val("");
  //     $("#order_materials_list_" + u).children(".material_unit").empty();
  //     $("#order_materials_list_" + u).children(".vendor_company_name").empty();
  //     $("#vendor_id" + u ).empty();
  //     $("#amount_used_id" +u ).val("");
  //     $("#price_used_id" + u ).empty();
  //     $("#calculated_unit" + u).empty();
  //   });
  //
  // // input内のチェックと各カラムへの代入、materialデータベースに無ければ空欄にする
  // $(".orders_all").on('change','.select_order_materials', function(){
  // var index = $(this).parent().parent("li")
  // var u = $('li.order_materials_li').index(index);
  // var id = $(this).val();
  //   if (isNaN(id) == true) {} else{
  //   $.ajax({
  //       url: "/orders/material_info/" + id,
  //       data: { id : id },
  //       dataType: "json",
  //       async: false
  //   })
  //   .done(function(data){
  //     var unit = data.material.calculated_unit;
  //     var vendor = data.material.vendor_company_name;
  //     $("#order_materials_list_" + u).children(".vendor_company_name").text(vendor);
  //     $("#order_materials_list_" + u).children(".material_unit").text(unit);
  //   });
  // }});

});
