$(function(){
  //removeアクション、materialの削除
  $(".orders_all").on('click','.remove', function(){
    $(this).parent().children(".destroy_order_materials").val(true);
        $(this).parent().parent("li").hide();
  });
  //addアクション、materialの追加
  $(".add_order_materials").on('click', function(){
      var u = $(".order_materials_li").length;
      $(".input_select_product").select2('destroy');
      $("li.order_materials_li").first().clone().appendTo(".order_materials_ul");

      var last_li = $(".order_materials_li").last()
      last_li.children(".order_material_name").children(".input_select_product").val("");
      last_li.children(".order_material_name").children("select").attr('name', "order[order_materials_attributes]["+ u +"][material_id]" );
      last_li.children(".order_material_name").children("select").attr('id', "order_order_materials_attributes_"+ u +"_material_id" );
      last_li.children(".order_quantity").children("").attr('name', "order[order_materials_attributes]["+ u +"][order_quantity]" );
      last_li.children(".order_quantity").children("").attr('id', "order_order_materials_attributes_"+ u +"_order_quantity" );
      last_li.children(".destroy_order_material").children(".destroy_order_materials").attr('name', "order[order_materials_attributes]["+ u +"][_destroy]" );
      last_li.children(".destroy_order_material").children(".destroy_order_materials").attr('id', "order_order_materials_attributes_"+ u +"__destroy" );
      $(".input_select_product").select2({width:"200px",placeholder: "発注する食材を選択"});
      last_li.children(".order_quantity").children().val("");
      last_li.children(".order_material_unit").empty();
      last_li.children(".vendor_company_name").empty();
    });

  // input内のチェックと各カラムへの代入、materialデータベースに無ければ空欄にする
  $(".orders_all").on('change','.input_select_product', function(){
  var index = $(this).parent().parent("li")
  var u = $('li.order_materials_li').index(index);
  var id = $(this).val();
    if (isNaN(id) == true) {} else{
    $.ajax({
        url: "/orders/material_info/" + id,
        data: { id : id },
        dataType: "json",
        async: false
    })
    .done(function(data){
      var unit = data.material.calculated_unit;
      var vendor = data.material.vendor_company_name;
      $(".order_materials_li").eq(u).children(".vendor_company_name").text(vendor);
      $(".order_materials_li").eq(u).children(".order_material_unit").text(unit);
    });
  }});
});
