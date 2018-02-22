$(function(){
  first_input_check()
  $('.input_select_product').select2({
    width:"300px",
    placeholder: "お弁当を選択してください"
  });
  $('.select_order_materials').select2({
    placeholder: "発注する食材を選択"
  });
  $('.input_order_code').select2({
    width:"120px",
  });

  $(".vendor_select").on("change",function(){
    $(".all_delete").prop('checked', false);
    $(".order_materials_tr").show();
      var chosen_company = $.trim($(".vendor_select option:selected").text());
    $(".order_materials_tr").each(function(){
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
    var tr =  $(this).parent().parent("tr")
    var index = $(".form_tr").index(tr)
    $(".hidden_form").children().children("tr").eq(index).children(".select").children().val(id);
  });

  $(".input_cook_num").on('change', function(){
    var num = $(this).val();
    var tr =  $(this).parent().parent("tr")
    var index = $(".form_tr").index(tr)
    $(".hidden_form").children().children("tr").eq(index).children(".cook_num").children().val(num);
  });

  $(".all_delete").on("change",function(){
    var prop = $('.all_delete').prop('checked');
    if (prop) {
      $(".order_materials_tr").each (function(){
          $(this).children('.destroy_order_material').children().prop('checked', true);
          $(this).find(".select_order_materials").attr("disabled", "disabled");
          $(this).children(".order_quantity").children().attr("disabled", "disabled");
          $(this).css('background-color', 'gray');
          $(this).find(".input_order_code").attr("disabled", "disabled");
      });
    }else {
        $(".order_materials_tr").each (function(){
            $(this).children('.destroy_order_material').children().prop('checked', false);
            $(this).find(".select_order_materials").removeAttr("disabled");
            $(this).children(".order_quantity").children().removeAttr("disabled");
            $(this).find(".input_order_code").removeAttr("disabled");
            input_check()
        });
      };
    });

  //削除チェックを監視
  $('.orders_all').on('change','.check_box', function(){
  	if ($(this).is(':checked')) {
      var tr = $(this).parent().parent("tr")
      tr.css('background-color', 'gray');
      tr.find(".select_order_materials").attr("disabled", "disabled");
      tr.children(".order_quantity").children().attr("disabled", "disabled");
      tr.find(".input_order_code").attr("disabled", "disabled");

  	} else {
      var tr = $(this).parent().parent("tr")
      tr.find(".select_order_materials").removeAttr("disabled");
      tr.children(".order_quantity").children().removeAttr("disabled");
      tr.find(".input_order_code").removeAttr("disabled");
      input_check()
  	}
  });


  //addアクション、materialの追加
  $(".add_order_materials").on('click', function(){
    add_tr();
    input_check();
  });

  $(".orders_all").on('change','.order_quantity', function(){
    input_check()
  });

  // input内のチェックと各カラムへの代入、materialデータベースに無ければ空欄にする
  $(".orders_all").on('change','.select_order_materials', function(){
    input_check()
    var index = $(this).parent().parent("tr")
    var u = $('tr.order_materials_tr').index(index);
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
      $(".order_materials_tr").eq(u).children(".vendor_company_name").text(vendor);
      $(".order_materials_tr").eq(u).children(".order_material_unit").text(order_unit);
      $(".order_materials_tr").eq(u).children(".calculate_unit").text(calculate_unit);
    });
  }});
  //送信前のバリデーション
  $('.order_submit').on('click', function check(){
    //発注しないチェックがはいっていた場合は、inputの検証をスルーする
      destroy_check = 0
      $('.order_materials_tr').each(function(){
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
      add_tr();
      var code = e.which ? e.which : e.keyCode;
      if (code == 13) {
      var last_tr =$(".order_materials_tr").last()
      last_tr.children(".order_material_name").children().select2('open');
      e.preventDefault();
      }
    });
    //オーダーコードでの検索
    $(".orders_all").on('change','.input_order_code', function(){
      var id =  parseInt($(this).val());
      $(this).parent().parent().find(".select_order_materials").val(id).change();
    });


  //入力チェックと色付け
  function input_check(){
    $('.order_materials_tr').each(function(){
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
    $('.order_materials_tr').each(function(){
      var material_id = $(this).children(".order_material_name").children().val()
      var order_quantity = $(this).children(".order_quantity").children().val()
      if (material_id=="" || order_quantity== ""){
        $(this).css('background-color', '#FEC9C9');
        $(".top_alert").css("color","red").text("＊終売にチェックが付いている商品は選択出来ません")
      }else {
        $(this).css('background-color', '#FFFFFF');
    }});
  };
  function add_tr(){
    var u = $(".order_materials_tr").length;
    $(".select_order_materials").select2('destroy');
    $(".input_order_code").select2('destroy');
    $("tr.order_materials_tr").first().clone().appendTo("tbody");
    var last_tr =$(".order_materials_tr").last()
    last_tr.find(".select_order_materials").val("");
    last_tr.children(".order_material_name").children("select").attr('name', "order[order_materials_attributes]["+ u +"][material_id]" );
    last_tr.children(".order_material_name").children("select").attr('id', "order_order_materials_attributes_"+ u +"_material_id" );
    last_tr.children(".order_quantity").children("").attr('name', "order[order_materials_attributes]["+ u +"][order_quantity]" );
    last_tr.children(".order_quantity").children("").attr('id', "order_order_materials_attributes_"+ u +"_order_quantity" );
    last_tr.find(".destroy_order_materials").attr('name', "order[order_materials_attributes]["+ u +"][_destroy]" );
    last_tr.find(".destroy_order_materials").attr('id', "order_order_materials_attributes_"+ u +"__destroy" );
    last_tr.children(".order_quantity").children("").attr('id', "order_order_materials_attributes_"+ u +"_order_material_memo" );
    $(".select_order_materials").select2({width:"100%",placeholder: "発注する食材を選択"});
    $(".input_order_code").select2({width:"120px"});
    last_tr.children(".order_quantity").children().val("");
    last_tr.children(".order_material_unit").empty();
    last_tr.children(".vendor_company_name").empty();
    last_tr.children(".calculated_material_unit").empty();
    last_tr.children(".calculate_unit").empty();
    last_tr.children(".calculated_value").empty();
    last_tr.children(".destroy_order_material").children().prop('checked',false);
    last_tr.find(".select_order_materials").removeAttr("disabled");
    last_tr.find(".input_order_code").removeAttr("disabled");
    last_tr.children(".order_quantity").children().removeAttr("disabled");
    last_tr.children(".order_material_memo").children().val("");
  };

});
