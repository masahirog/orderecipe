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

  $(".order_bento_id_search").on("blur",function(){
    var bento_id =  parseInt($(this).val());
    var inp = $(this).parent().parent().find(".input_select_product")
    $.ajax({
      url: "/orders/get_bento_id",
      data: { bento_id : bento_id },
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

  $(".input_select_product").on("change",function(){
    var id = $(this).val();
    var inp_bentoid = $(this).parent().parent().find(".order_bento_id_search")
    $.ajax({
      url: "/orders/check_bento_id",
      data: { id : id },
      dataType: "json",
      async: false
    })
    .done(function(data){
      if (data) {
        var bento_id = parseInt(data.bento_id)
        inp_bentoid.val(bento_id);
      }else{
        inp_bentoid.val("");
      }
    });
  });


  //indexで使用
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

 //new_form
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

//form(new|edit)
  $(".vendor_select").on("change",function(){
    $(".all_delete").prop('checked', false);
    $(".order_materials_tr").show();
      var chosen_company = $.trim($(".vendor_select option:selected").text());
    $(".order_materials_tr").each(function(){
      var company_name = $.trim($(this).find(".vendor_company_name").text());
      if(chosen_company=="") {
        $(this).show();
      } else {
      if (chosen_company == company_name) {
      }else {
        $(this).hide();
      }};
    });
  });

  $(".all_delete").on("change",function(){
    var prop = $('.all_delete').prop('checked');
    if (prop) {
      $(".order_materials_tr").each (function(){//表示されている企業だけ変更
        if ($(this).is(':visible')) {
          $(this).find(".destroy_order_materials").prop('checked', true);
          $(this).css('background-color', 'gray');
          $(this).find(".select_order_materials").attr("disabled", "disabled");
          $(this).find(".order_quantity").attr("disabled", "disabled");
          $(this).find(".input_order_code").attr("disabled", "disabled");
          $(this).find(".order_material_memo").children().attr("disabled", "disabled");
          $(this).find(".order_material_date").children().attr("disabled", "disabled");
        }
      });
    }else {
        $(".order_materials_tr").each (function(){
          if ($(this).is(':visible')) {
            $(this).find(".destroy_order_materials").prop('checked', false);
            $(this).find(".select_order_materials").removeAttr("disabled");
            $(this).find(".order_quantity").removeAttr("disabled");
            $(this).find(".input_order_code").removeAttr("disabled");
            $(this).find(".order_material_memo").children().removeAttr("disabled");
            $(this).find(".order_material_date").children().removeAttr("disabled");
            input_check()
          }
        });
      };
    });

  //削除チェックを監視
  $('.orders_all').on('change','.check_box', function(){
  	if ($(this).is(':checked')) {
      var tr = $(this).parent().parent("tr")
      tr.css('background-color', 'gray');
      tr.find(".select_order_materials").attr("disabled", "disabled");
      tr.find(".order_quantity").attr("disabled", "disabled");
      tr.find(".input_order_code").attr("disabled", "disabled");
      tr.find(".order_material_memo").children().attr("disabled", "disabled");
      tr.find(".order_material_date").children().attr("disabled", "disabled");
  	} else {
      var tr = $(this).parent().parent("tr")
      tr.find(".select_order_materials").removeAttr("disabled");
      tr.find(".order_quantity").removeAttr("disabled");
      tr.find(".input_order_code").removeAttr("disabled");
      tr.find(".order_material_memo").children().removeAttr("disabled");
      tr.find(".order_material_date").children().removeAttr("disabled");
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
      var color = data.material.color;
      var calculated_value = data.material.calculated_value;
      var order_unit = data.material.order_unit;
      var order_unit_quantity = data.material.order_unit_quantity;
      var change_unit = order_unit_quantity+order_unit+"："+ calculated_value+" "+unit
      if (color=='') {
        $(".order_materials_tr").eq(u).find(".vendor_company_name").text(vendor).css("color",'color:#A9A9A9;');
      }else{
        $(".order_materials_tr").eq(u).find(".vendor_company_name").text(vendor).css("color",'red');  
      }
      $(".order_materials_tr").eq(u).find(".order_material_unit").text(order_unit);
      $(".order_materials_tr").eq(u).find(".change_unit").text(change_unit);

    });
  }});
  //送信前のバリデーション
  $('.order_submit').on('click', function check(){
    //発注しないチェックがはいっていた場合は、inputの検証をスルーする
      destroy_check = 0
      $('.order_materials_tr').each(function(){
        if ($(this).find(".destroy_order_materials").is(':checked')){}else{
          var material_id = $(this).find(".select_order_materials").val()
          var order_quantity = $(this).find(".order_quantity").val()
          if (material_id=="" || order_quantity== ""){
            destroy_check = 1
            alert("入力が不完全です");
            return false;
        }else {};
      }
    });
      if (destroy_check == 1){
        return false;
      }else{
        $('.edit_order').submit();
        $('.new_order').submit();
      }
    });

    $(".add_order_materials").keypress(function (e) {
      add_tr();
      var code = e.which ? e.which : e.keyCode;
      if (code == 13) {
      var last_tr =$(".order_materials_tr").last()
      last_tr.find(".select_order_materials").select2('open');
      e.preventDefault();
      }
    });
    //オーダーコードでの検索
    $(".orders_all").on('change','.input_order_code', function(){
      var id =  parseInt($(this).val());
      $(this).parent().parent().find(".select_order_materials").val(id).change();
    });

    $("#all_date_change").on("change", function(){
      var date = $(this).val()
      $('.order_materials_tr').each(function(){
        if ($(this).is(':visible')){$(this).find(".input_delivery_date").val(date)}
      });
      change_color();
    });

    $("#all_make_date_change").on("change", function(){
      var date = $(this).val()
      $(".input_make_date").val(date)
    });

    $(".orders_all").on("change",".input_delivery_date",function(){
      change_color();
    });

    function change_color(){
      $(".input_delivery_date").css("background-color","white")
      var date_arr = []
      $('.order_materials_tr').each(function(){
        var date = $(this).find(".input_delivery_date").val()
        $(this).find(".input_delivery_date").removeClass().addClass("form-control input_delivery_date "+date);
        date_arr.push(date)
      });
      var countDuplicate = function(arr){
        return arr.reduce(function(counts, key){
          counts[key] = (counts[key])? counts[key] + 1 : 1 ;
          return counts;
        }, {});
      };
      var uniq_arr = countDuplicate(date_arr);
      var i = 0;
      var color =["#FFF","#FFC7AF","#BAD3FF","#FFDDFF","#DDDDDD","#FFFFCC","#CCFFCC"];
      $.each(uniq_arr,function(key,value){
          $("."+key).css("background-color",color[i]);
          i = i + 1;
      });
    };

  //入力チェックと色付け
  function input_check(){
    $('.order_materials_tr').each(function(){
      var material_id = $(this).find(".select_order_materials").val()
      var order_quantity = $(this).find(".order_quantity").val()
      if  ($(this).find(".destroy_order_materials").is(':checked')) {
      }else {
      if (material_id=="" || order_quantity== ""){
        $(this).css('background-color', '#FEC9C9');
      }else {
        $(this).css('background-color', '#FFFFFF');
    }}});
  };
  // ページ読み込んだ時の色付け
  function first_input_check(){
    change_color()
    $('.order_materials_tr').each(function(){
      var material_id = $(this).find(".select_order_materials").val()
      var order_quantity = $(this).find(".order_quantity").val()
      if (material_id=="" || order_quantity== ""){
        $(this).css('background-color', '#FEC9C9');
        $(".top_alert").css("color","red").text("＊終売にチェックが付いている商品は選択出来ません")
      }else {
        $(this).css('background-color', '#FFFFFF');
    }});
  };

  function add_tr(){
    $(".vendor_select").val("").change();
    var u = $(".order_materials_tr").length;
    $(".select_order_materials").select2('destroy');
    $(".input_order_code").select2('destroy');
    $("tr.order_materials_tr").first().clone().appendTo("tbody");
    var last_tr =$(".order_materials_tr").last()
    last_tr.find(".select_order_materials").val("");
    last_tr.children(".order_material_name").children("select").attr('name', "order[order_materials_attributes]["+ u +"][material_id]" );
    last_tr.children(".order_material_name").children("select").attr('id', "order_order_materials_attributes_"+ u +"_material_id" );
    last_tr.find(".order_quantity").attr('name', "order[order_materials_attributes]["+ u +"][order_quantity]" );
    last_tr.find(".order_quantity").attr('id', "order_order_materials_attributes_"+ u +"_order_quantity" );
    last_tr.find(".calculated_value").attr('name', "order[order_materials_attributes]["+ u +"][calculated_quantity]" );
    last_tr.find(".calculated_value").attr('id', "order_order_materials_attributes_"+ u +"_calculated_quantity" );
    last_tr.children(".destroy_order_material").children().attr("name","order[order_materials_attributes]["+u+"][_destroy]");//hiddenの変換、順番も変えない
    last_tr.find(".destroy_order_materials").attr('id', "order_order_materials_attributes_"+ u +"__destroy" );
    last_tr.children(".order_material_memo").children().attr('id', "order_order_materials_attributes_"+ u +"_order_material_memo" );
    last_tr.children(".order_material_memo").children().attr('name', "order[order_materials_attributes]["+u+"][order_material_memo]" );
    last_tr.children(".delivery_date").children().attr('id', "order_order_materials_attributes_"+ u +"_delivery_date" );
    last_tr.children(".delivery_date").children().attr('name', "order[order_materials_attributes]["+u+"][delivery_date]" );
    $(".select_order_materials").select2({width:"100%",placeholder: "発注する食材を選択"});
    $(".input_order_code").select2({width:"120px"});
    last_tr.find(".order_quantity").val("");
    last_tr.find(".order_material_unit").empty();
    last_tr.find(".calculated_material_unit").empty();
    last_tr.find(".vendor_company_name").empty();
    last_tr.find(".change_unit").empty();
    last_tr.find(".calculated_value").val(0);
    last_tr.children(".destroy_order_material").children().prop('checked',false);
    last_tr.find(".select_order_materials").removeAttr("disabled");
    last_tr.find(".input_order_code").removeAttr("disabled");
    last_tr.find(".order_quantity").removeAttr("disabled");
    last_tr.find(".order_material_memo").children().val("");
    last_tr.find(".delivery_date").children().val($("#all_date_change").val());
    change_color()
  };
});
