$(function(){
    first_input_check()
    $('.input_select_product').select2({
    width:"300px",
    placeholder: "お弁当を選択してください"
  });
    $('.select_order_materials').select2({
    placeholder: "発注する食材を選択"
  });


  $(".vendor_select").on("change",function(){
    $(".all_delete").prop('checked', false);
    $(".order_materials_li").show();
      var chosen_company = $.trim($(".vendor_select option:selected").text());
    $(".order_materials_li").each(function(){
      var company_name = $.trim($(this).children(".vendor_company_name").text());
      if(chosen_company=="") {
        $(this).show();
      } else {
      if (chosen_company == company_name) {
      }else {
        $(this).hide();
      }};
    });
  });

  $(".index_vendor_select").on("change",function(){
    $(".index_vendor_list").show();
      var chosen_company = $.trim($(".index_vendor_select option:selected").text());
    $(".index_vendor_list").each(function(){
      var company_name = $.trim($(this).children(".vendor_company_name").text());
      if(chosen_company=="") {
        $(this).show();
      } else {
      if (chosen_company == company_name) {
      }else {
        $(this).hide();
      }};
    });
  });

  $(".input_select_product").on('change', function(){
    var id = $(this).val();
    var li =  $(this).parent().parent("li")
    var index = $(".form_li").index(li)
    $(".hidden_form").children().children("li").eq(index).children(".select").children().val(id);
  });

  $(".input_cook_num").on('change', function(){
    var num = $(this).val();
    var li =  $(this).parent().parent("li")
    var index = $(".form_li").index(li)
    $(".hidden_form").children().children("li").eq(index).children(".cook_num").children().val(num);
  });

  $(".all_delete").on("change",function(){
    var prop = $('.all_delete').prop('checked');
    if (prop) {
      $(".order_materials_li").each (function(){
        if ($(this).css('display') == 'block') {
          $(this).children('.destroy_order_material').children().prop('checked', true);
        }
      });
    }else {
        $(".order_materials_li").each (function(){
          if ($(this).css('display') == 'block') {
            $(this).children('.destroy_order_material').children().prop('checked', false);
          };
        });
      };
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
    add_li();
    input_check();
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
      var calculated_value = data.material.calculated_value;
      var order_unit = data.material.order_unit;
      var calculate_unit = "1 "+order_unit+"："+ calculated_value+" "+unit
      console.log(unit);
      $(".order_materials_li").eq(u).children(".vendor_company_name").text(vendor);
      $(".order_materials_li").eq(u).children(".order_material_unit").text(order_unit);
      $(".order_materials_li").eq(u).children(".calculate_unit").text(calculate_unit);
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

    $(".add_order_materials").keypress(function (e) {
      add_li();
      var code = e.which ? e.which : e.keyCode;
      if (code == 13) {
      var last_li =$(".order_materials_li").last()
      last_li.children(".order_material_name").children().select2('open');
      e.preventDefault();
      }
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
  function add_li(){
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
    $(".select_order_materials").select2({width:"100%",placeholder: "発注する食材を選択"});
    last_li.children(".order_quantity").children().val("");
    last_li.children(".order_material_unit").empty();
    last_li.children(".vendor_company_name").empty();
    last_li.children(".calculated_material_unit").empty();
    last_li.children(".calculate_unit").empty();
    last_li.children(".calculated_value").empty();
    last_li.children(".destroy_order_material").children().prop('checked',false);
    last_li.children(".order_material_name").children(".select_order_materials").removeAttr("disabled");
    last_li.children(".order_quantity").children().removeAttr("disabled");
  };

});
