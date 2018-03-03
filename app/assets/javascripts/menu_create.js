
$(function(){
  $('.all_select_menu').select2({
  width:"270px",
  placeholder: "メニュー名を選択してください"
  });
  $('.input_select_material').select2({
    placeholder: "食材資材を選択してください"
  });
  $('.select_used_additives').select2({

  });

    calculate_menu_price();
    reset_row_order();

    u = 0
  $(".add_li_material").each(function(){
    var eos = $(this).children(".sales_check").text()
    eos_check(eos,u);
    u += 1
  });
//並び替え時のrow_order更新
  $(".ul-sortable").sortable({
    update: function(){
      reset_row_order();
    }});

  //removeのチェックと、trをhide
  $(".material_ul").on('click','.remove_btn', function(){
    $(this).parent().children(".destroy_materials").prop('checked', true);
    $(this).parent().parent(".add_li_material").hide();
    calculate_menu_price();
    reset_row_order();
  });


// input内のチェックと各カラムへの代入、materialデータベースに無ければ空欄にする
  $(".material_ul").on('change','.input_select_material', function(){
    additives_select_change()
    $('.eos-alert').hide();
    $('body').css('padding-top',0);

    var u = $(".add_li_material").index($(this).parent().parent(".add_li_material"))
    var id = $(this).val();
    if (isNaN(id) == true) {} else{
      $.ajax({
        url: "/menus/get_cost_price/" + id,
        data: { id : id },
        dataType: "json",
        async: false
      })
      .done(function(data){
        get_material_info(data,u);
        calculate_menu_price();
      });
  }});

  //amount_used変更でprice_used取得
  $(".material_ul").on('change','.amount_used', function(){
    var u = $(".add_li_material").index($(this).parent(".add_li_material"))
    var cost_price = $(this).parent(".add_li_material").children(".cost_price").children(".cost_price_value").html()
    var amount_used = $(this).parent(".add_li_material").children(".amount_used").children(".amount_used_input").val();
    if (isNaN(amount_used) == true){
      var calculate_price = 0;
    }else {
      var calculate_price = Math.round( (cost_price * amount_used) * 100 ) / 100 ;
      // var calculate_price = (cost_price * amount_used).toFixed(2)};
      $(this).parent(".add_li_material").children(".price_used").children(".price_used_value").text(calculate_price);
    calculate_menu_price();
  }});

  $(".all_box").on("change",function(){
    var prop = $('.all_box').prop('checked');
    if (prop) {
     $('.product_check').children().prop('checked', true);
    } else {
     $('.product_check').children().prop('checked', false);
   };
  });

  $(".all_select_menu").on("change",function(){
    var id = $(this).val();
    var name = $(".all_select_menu option:selected").text();
    $(".product_include_menu").each(function(){
      var prop = $(this).children(".product_check").children().prop('checked');
      if (prop) {
        var j = $(this).children(".select_menu").children().val();
        $(this).children(".select_menu").children().val(id);
        $(this).children(".select_menu").find(".select2-selection__rendered").text(name);
      }else{
      };
    });
  });

  //material追加
  $(".add_material").on('click', function (){
    addInput();
  });

  //追加ボタン時のカーソル移動
  $(".add_material").keypress(function (e) {
    addInput();
    var code = e.which ? e.which : e.keyCode;
    if (code == 13) {
    var last_li =$(".add_li_material").last()
    last_li.children(".select_material").children().select2('open');
    e.preventDefault();
    }
  });


//メニュー更新ボタンを押した後、仕込みが両方埋まっているかチェック
  $('#menu_submit_btn').click(function(){
    var i = 0
    if(!confirm('更新するとお弁当全てに反映されますが、よろしいですか？')){
        /* キャンセルの時の処理 */
        return false;
    }else{
        /*　OKの時の処理 */
        $(".add_li_material").each(function(){
          if ($(this).children(".preparation").children().val()=="" && $(this).children(".select_post").children().val()==""){
          }else if($(this).children(".preparation").children().val().length > 0  && $(this).children(".select_post").children().val().length > 0){
          }else{
            i += 1
          };
        });
        if (i==0) {
          $('form').submit();
        }else{
          alert("仕込みが埋まっていないものがあります。")
        };
    };
  });




//メニュー価格の変更
  function calculate_menu_price(){
    var row_len =  $(".add_li_material").length
    var  menu_price = 0;
    $(".add_li_material").each(function(){
      if ($(this).children(".remove_material").children(".destroy_materials").is(':checked')){
      }else{
        var price_used = Number($(this).children(".price_used").children(".price_used_value").html())
        if (isNaN(price_used) == true ){}else{
        menu_price += price_used}
      }});
      var sum_material_cost = Math.round( menu_price * 100 ) / 100 ;
      $(".sum_material_cost").val(sum_material_cost)
      var sum_material_cost_tax = Math.round( (sum_material_cost * 0.08) * 100 ) / 100 ;
      $(".sum_material_cost_tax").val(sum_material_cost_tax)
      var menu_cost_price = Math.round( (sum_material_cost * 1.08) * 100 ) / 100 ;
      $(".menu_cost_price").val(menu_cost_price)
  };

  function get_material_info(data,u,x){
    amount_used = $(".add_li_material").eq(u).children(".amount_used").children().val();
    var cost = data.material.cost_price;
    var unit = data.material.calculated_unit;
    var vendor = data.material.vendor_company_name;
    var eos = data.material.end_of_sales;
    $(".add_li_material").eq(u).children(".sales_check").text(eos);
    $(".add_li_material").eq(u).children(".vendor").text(vendor);
    $(".add_li_material").eq(u).children(".cost_price").children(".cost_price_value").text(cost);
    $(".add_li_material").eq(u).children().children(".calculated_unit").text(unit);
    //終売のアラートon
    eos_check(eos,u)
    if (isNaN(amount_used) == true){
      var calculate_price = 0;
    }else {
      var calculate_price = Math.round( (cost * amount_used) * 100 ) / 100 ;
    $(".add_li_material").eq(u).children(".price_used").children(".price_used_value").text(calculate_price);
  }};

  function eos_check(eos,u){
    if (eos==1) {
      $(".add_li_material").eq(u).attr("style","background-color:gray;")
      var height = $('.eos-alert').innerHeight();
      $('body').css('padding-top',height);
      $('.eos-alert').show();
    }else {
      $(".add_li_material").eq(u).attr("style","background-color:white;")
    }
  };

  //addアクション、materialの追加
  function addInput(){
    var u = $(".add_li_material").length
    $(".input_select_material").select2('destroy');
    $(".add_li_material").first().clone().appendTo(".material_ul");
    var last_li =$(".add_li_material").last()

    last_li.children(".row_order").children().attr('name', "menu[menu_materials_attributes]["+u+"][row_order]" );
    last_li.children(".row_order").children().attr('id', "menu_menu_materials_attributes_"+u+"_row_order" );
    last_li.children(".select_material").children().attr('name', "menu[menu_materials_attributes]["+u+"][material_id]" );
    last_li.children(".select_material").children().attr('id', "menu_menu_materials_attributes_"+u+"_material_id" );
    last_li.children(".amount_used").children().attr('name', "menu[menu_materials_attributes]["+u+"][amount_used]" );
    last_li.children(".amount_used").children().attr('id', "menu_menu_materials_attributes_"+u+"_amount_used" );
    last_li.children(".remove_material").children(".destroy_materials").attr('id', "menu_menu_materials_attributes_"+u+"__destroy");
    last_li.children(".remove_material").children("").attr('name', "menu[menu_materials_attributes]["+u+"][_destroy]");
    last_li.children(".select_material").children().val("");
    last_li.children(".preparation").children().attr('id', "menu_menu_materials_attributes_"+u+"_preparation" );
    last_li.children(".preparation").children().attr('name', "menu[menu_materials_attributes]["+u+"][preparation]" );
    last_li.children(".select_post").children().attr('id', "menu_menu_materials_attributes_"+u+"_post" );
    last_li.children(".select_post").children().attr('name', "menu[menu_materials_attributes]["+u+"][post]" );
    last_li.children(".sales_check").empty();
    last_li.children(".preparation").children().val("");
    last_li.children(".select_post").children().val("");
    $(".input_select_material").select2({width:"270px",placeholder: "食材資材を選択してください"});
    last_li.children(".row_order").children().val(u);
    last_li.children(".cost_price").children(".cost_price_value").empty();
    last_li.children(".vendor").empty();
    last_li.children(".amount_used").children().val("");
    last_li.children(".price_used").children(".price_used_value").empty();
    last_li.children().children(".calculated_unit").empty();
    last_li.children(".remove_material").children(".destroy_materials").prop('checked',false);
    last_li.show();
  };

  function reset_row_order(){
    $(".add_li_material").each(function(i){
      $(this).children(".row_order").children().val(i)
    });
  };

  function additives_select_change() {
    var array = [];
    $(".add_li_material").each(function(){
      var id = $(this).find(".input_select_material").val();
      array.push(id);
    });
    var data = array
    $.ajax({
      type: 'POST',
      url: "/materials/change_additives",
      data: { data : data },
      dataType: "json",
      async: false
    })
    .done(function(data){
      $(".select_used_additives").select2('destroy');
      $(".select_used_additives optgroup").remove();
      $(".select_used_additives").select2({
        data: data
      });
    });
  }
});
