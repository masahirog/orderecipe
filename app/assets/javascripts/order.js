$(document).on('turbolinks:load', function() {
  change_color();
  $('[data-toggle="tooltip"]').tooltip();
  $('[data-toggle="popover"]').popover();
  first_input_check();
  $('.input_select_product').select2();
  // $('.select_order_materials').select2({
  //   placeholder: "発注する食材を選択"
  // });
  material_select2();
  $('.material_search').select2();

  $('.fixed_flag').on('change',function(){
    submit_button_check();
  });
  $('#order_staff_name').on('keyup',function(){
    submit_button_check();
  });

  function submit_button_check(){
    var fix = $('.fixed_flag').val();
    var name = $('#order_staff_name').val();
    if (fix=="true"&& name != '') {
      $(".save-btn").val('確定で保存する');
      $(".save-btn").removeClass("btn-danger");
      $(".save-btn").addClass("btn-success");
    }else{
      $(".save-btn").val('未確定で保存する');
      $(".save-btn").removeClass("btn-success");
      $(".save-btn").addClass("btn-danger");
    }
  }

  function material_select2(){
    $(".select_order_materials").select2({
      ajax: {
        url: "/menus/get_material/",
        dataType: 'json',
        delay: 50,
        data: function(params) {
          return {　q: params.term　};
        },
        processResults: function (data, params) {
          console.log(data);
          return { results: $.map(data, function(obj) {
              return { id: obj[0], text: obj[1] };
            })
          };
        }
      }
    });
  };

  $(document).on('change','.order_quantity',function(){
    var input = $(this).val();
    if (isNumber(input)) {
      $(this).css('background-color','white');
    }else{
      $(this).css('background-color','red');
      $(this).val(0);
    }
    function isNumber(val){
      var regex = new RegExp(/^[0-9]+(\.[0-9]+)?$/);
      return regex.test(val);
    }
  });


  $('.add_order_material').on('click',function(){
    setTimeout(function(){
      material_select2();
    },5);
    change_color();
  });



  $("#all_make_date_change").on("change", function(){
    var date = $(this).val()
    $(".input_make_date").val(date)
  });


  $(".order_management_id_search").on("blur",function(){
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

  $(".input_select_product").on("change",function(){
    var id = $(this).val();
    var inp_bentoid = $(this).parent().parent().find(".order_management_id_search")
    $.ajax({
      url: "/orders/check_management_id",
      data: { id : id },
      dataType: "json",
      async: false
    })
    .done(function(data){
      if (data) {
        var management_id = parseInt(data.management_id)
        inp_bentoid.val(management_id);
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
    var chosen_id = $(".vendor_select option:selected").val();
    $(".order_materials_tr").each(function(){
      var vendor_id = $(this).find(".vendor_company_name").children('input').val();
      if(chosen_id=="") {
        $(this).show();
      } else {
      if (chosen_id == vendor_id) {
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
          destroy_color(this);
        }
      });
    }else {
        $(".order_materials_tr").each (function(){
          if ($(this).is(':visible')) {
            $(this).find(".destroy_order_materials").prop('checked', false);
            undestroy_color(this);
            input_check();
          }
        });
      };
    });

  //削除チェックを監視
  $('#order_materials_table').on('change','.check_box', function(){
  	if ($(this).is(':checked')) {
      var tr = $(this).parent().parent("tr")
      destroy_color(tr);
  	} else {
      var tr = $(this).parent().parent("tr")
      undestroy_color(tr);
      input_check()
  	}
  });

  function destroy_color(li){
    $(li).css('background-color', 'darkgray');
  }
  function undestroy_color(li){
    $(li).find(".select_order_materials").removeAttr("disabled");
    $(li).find(".order_quantity").removeAttr("disabled");
    $(li).find(".order_material_memo").children().removeAttr("disabled");
    $(li).find(".order_material_date").children().removeAttr("disabled");
  }

  $("#order_materials_table").on('change','.order_quantity', function(){
    input_check()
  });

  // input内のチェックと各カラムへの代入、materialデータベースに無ければ空欄にする
  $("#order_materials_table").on('change','.select_order_materials', function(){
    input_check()
    var index = $(this).parent().parent("tr")
    var u = $('tr.order_materials_tr').index(index);
    var id = $(this).val();
    if (isNaN(id) == true) {} else{
    $.ajax({
        url: "/orders/material_info/",
        data: { id : id },
        dataType: "json",
        async: false
    })
    .done(function(data){
      var unit = data.material.recipe_unit;
      var vendor = data.material.vendor_company_name;
      var color = data.material.color;
      var recipe_unit_quantity = data.material.recipe_unit_quantity;
      var order_unit = data.material.order_unit;
      var order_unit_quantity = data.material.order_unit_quantity;
      var delivery_deadline = data.material.delivery_deadline
      var change_unit = order_unit_quantity+order_unit+"："+ recipe_unit_quantity+" "+unit
      if (color=='') {
        $(".order_materials_tr").eq(u).find(".vendor_company_name").text(vendor).css("color",'color:#A9A9A9;').css("font-weight",'normal');
      }else{
        $(".order_materials_tr").eq(u).find(".vendor_company_name").text(vendor).css("color",'red').css("font-weight",'bold');
      }
      console.log(delivery_deadline);
      $(".order_materials_tr").eq(u).find(".delivery_deadline_span").val(delivery_deadline);
      $(".order_materials_tr").eq(u).find(".order_material_unit").val(order_unit);
      $(".order_materials_tr").eq(u).find(".change_unit").text(change_unit);

    });
  }});
  //送信前のバリデーション
  $('.order_submit').on('click', function check(){
    //発注しないチェックがはいっていた場合は、inputの検証をスルーする
    destroy_check = 0
    $('.order_materials_tr').each(function(){
      var material_id = $(this).find(".select_order_materials").val();
      var order_quantity = $(this).find(".order_quantity").val();
      var destroy_flag = $(this).find(".destroy_order_materials").prop('checked');
      if (material_id=="" || order_quantity== ""){
        destroy_check = 1
        alert("空欄があります");
        return false;
      };
    });
    if (destroy_check == 1){
      return false;
    }else{
      $('.edit_order').submit();
      $('.new_order').submit();
    }
  });


    $("#all_date_change").on("change", function(){
      var date = $(this).val()
      $('.order_materials_tr').each(function(){
        if ($(this).is(':visible')){$(this).find(".input_delivery_date").val(date)}
      });
      change_color();
    });

    $("#order_materials_table").on("change",".input_delivery_date",function(){
      change_color();
    });

    function change_color(){
      $(".input_delivery_date").css("background-color","white")
      var date_arr = []
      $('.order_materials_tr').each(function(){
        var date = $(this).find(".input_delivery_date").val()
        $(this).find(".input_delivery_date").removeClass().addClass("form-control input_delivery_date date_input "+date);
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
        }
      }
    });
  };
  // ページ読み込んだ時の色付け
  function first_input_check(){
    change_color()
    $('.order_materials_tr').each(function(){
      var material_id = $(this).find(".select_order_materials").val()
      var order_quantity = $(this).find(".order_quantity").val()
      if  ($(this).find(".destroy_order_materials").is(':checked')) {
        destroy_color(this);
      }else {
        if (material_id=="" || order_quantity== ""){
          $(this).css('background-color', '#FEC9C9');
          $(".top_alert").css("color","red").text("＊終売にチェックが付いている商品は選択出来ません")
        }else {
          $(this).css('background-color', '#FFFFFF');
        }
      }
    });
  };
});
