$(function(){
    first_input_check()
    $('.input_select_product').select2({
    width:"300px",
    placeholder: "お弁当を選択してください"
  });
    $('.select_order_materials').select2({
    width:"200px",
    placeholder: "発注する食材を選択"
  });

  //削除チェックを監視
  $('.orders_all').on('change','.check_box', function(){
  	if ($(this).is(':checked')) {
      var li = $(this).parent().parent("li")
      li.css('background-color', 'gray');
      li.children(".order_material_name").children(".select_order_materials").attr("disabled", "disabled");
      li.children(".order_quantity").children().attr("disabled", "disabled");
  	} else {
      var li = $(this).parent().parent("li")
      li.children(".order_material_name").children(".select_order_materials").removeAttr("disabled");
      li.children(".order_quantity").children().removeAttr("disabled");
      input_check()
  	}
  });


  //addアクション、materialの追加
  $(".add_order_materials").on('click', function(){
    var u = $(".order_materials_li").length;
    $(".select_order_materials").select2('destroy');
    $("li.order_materials_li").first().clone().appendTo(".order_materials_ul");
    var last_li =$(".order_materials_li").last()
    last_li.children(".order_material_name").children(".select_order_materials").val("");
    last_li.children(".order_material_name").children("select").attr('name', "order[order_materials_attributes]["+ u +"][material_id]" );
    last_li.children(".order_material_name").children("select").attr('id', "order_order_materials_attributes_"+ u +"_material_id" );
    last_li.children(".order_quantity").children("").attr('name', "order[order_materials_attributes]["+ u +"][order_quantity]" );
    last_li.children(".order_quantity").children("").attr('id', "order_order_materials_attributes_"+ u +"_order_quantity" );
    last_li.children(".destroy_order_material").children(".destroy_order_materials").attr('name', "order[order_materials_attributes]["+ u +"][_destroy]" );
    last_li.children(".destroy_order_material").children(".destroy_order_materials").attr('id', "order_order_materials_attributes_"+ u +"__destroy" );
    $(".select_order_materials").select2({width:"200px",placeholder: "発注する食材を選択"});
    last_li.children(".order_quantity").children().val("");
    last_li.children(".order_material_unit").empty();
    last_li.children(".vendor_company_name").empty();
    last_li.children(".destroy_order_material").children().prop('checked',false);
    last_li.children(".order_material_name").children(".select_order_materials").removeAttr("disabled");
    last_li.children(".order_quantity").children().removeAttr("disabled");
    input_check()
  });

  $(".orders_all").on('change','.order_quantity', function(){
    input_check()
  });

  // input内のチェックと各カラムへの代入、materialデータベースに無ければ空欄にする
  $(".orders_all").on('change','.select_order_materials', function(){
    input_check()
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
  //送信前のバリデーション
  $('.order_submit').on('click', function check(){
    //発注しないチェックがはいっていた場合は、inputの検証をスルーする
      destroy_check = 0
      $('.order_materials_li').each(function(){
        if ($(this).children(".destroy_order_material").children(".destroy_order_materials").is(':checked')){}else{
          var material_id = $(this).children(".order_material_name").children().val()
          var order_quantity = $(this).children(".order_quantity").children().val()
          if (material_id=="" || order_quantity== ""){
            destroy_check = 1
            alert("入力が不完全です");
            return false;
        }else {};
      }});
      if (destroy_check == 1){return false} //errorがtrueならonclickを抜ける
    });

  //入力チェックと色付け
  function input_check(){
    $('.order_materials_li').each(function(){
      var material_id = $(this).children(".order_material_name").children().val()
      var order_quantity = $(this).children(".order_quantity").children().val()
      if  ($(this).children(".destroy_order_material").children().is(':checked')) {
      }else {
      if (material_id=="" || order_quantity== ""){
        $(this).css('background-color', '#FEC9C9');
      }else {
        $(this).css('background-color', '#FFFFFF');
    }}});
  };
  // ページ読み込んだ時の色付け
  function first_input_check(){
    $('.order_materials_li').each(function(){
      var material_id = $(this).children(".order_material_name").children().val()
      var order_quantity = $(this).children(".order_quantity").children().val()
      if (material_id=="" || order_quantity== ""){
        $(this).css('background-color', '#FEC9C9');
        $(".top_alert").css("color","red").text("＊終売にチェックが付いている商品は選択出来ません")
      }else {
        $(this).css('background-color', '#FFFFFF');
    }});
  };

});
