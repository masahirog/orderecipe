
$(function(){
  calculate_menu_price();
  reset_row_order();
  calculate_menu_nutrition();

  $(".select_used_additives").select2();


  $(".input_select_material").select2({
    ajax: {
      url:'/materials/search.json',
      dataType: 'json',
      delay: 50,
      data: function(params) {
        return {　q: params.term　};
      },
      processResults: function (data, params) {
        return { results: $.map(data, function(obj) {
            return { id: obj.id, text: obj.name };
          })
        };
      }
    }
  });
  $(".input_food_ingredient").select2({
    ajax: {
      url:'/menus/food_ingredient_search.json',
      dataType: 'json',
      delay: 50,
      data: function(params) {
        return {　q: params.term　};
      },
      processResults: function (data, params) {
        return { results: $.map(data, function(obj) {
            return { id: obj.id, text: obj.name };
          })
        };
      }
    }
  });

  $('.add_fields').on('click',function(){
    setTimeout(function(){
      $(".input_select_material").select2('destroy');
      $(".input_food_ingredient").select2('destroy');
      reset_row_order();
      $(".input_select_material").select2({
        ajax: {
          url:'/materials/search.json',
          dataType: 'json',
          delay: 50,
          data: function(params) {
            return {　q: params.term　};
          },
          processResults: function (data, params) {
            return { results: $.map(data, function(obj) {
                return { id: obj.id, text: obj.name };
              })
            };
          }
        }
      });
      $(".input_food_ingredient").select2({
        ajax: {
          url:'/menus/food_ingredient_search.json',
          dataType: 'json',
          delay: 50,
          data: function(params) {
            return {　q: params.term　};
          },
          processResults: function (data, params) {
            return { results: $.map(data, function(obj) {
                return { id: obj.id, text: obj.name };
              })
            };
          }
        }
      });
    },5);
  });

  u = 0
  $(".add_li_material").each(function(){
    var eos = $(this).children(".sales_check").text()
    eos_check(eos,u);
    u += 1
  });

//並び替え時のrow_order更新
  $(".material_ul.ul-sortable").sortable({
    update: function(){
      reset_row_order();
    }});

  //removeのチェックと、trをhide
  $(".material_ul").on('click','.remove_fields', function(){
    setTimeout(function(){
      calculate_menu_price();
      reset_row_order();
      calculate_menu_nutrition();
    },10);
  });


// input内のチェックと各カラムへの代入、materialデータベースに無ければ空欄にする
  $(".material_ul").on('change','.input_select_material', function(){
    additives_select_change()
    $('.eos-alert').hide();
    $('body').css('padding-top',0);
    var u = $(".add_li_material").index($(this).parents('.add_li_material'));
    console.log(u);

     $(".add_li_material").eq(u).find(".input_nutritions input").val(0);
     $(".menu_materials_li").eq(u).find('.view_food_ingredient').text("");
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
        calculate_menu_nutrition();
      });
  }});

  //amount_used変更でprice_used取得
  $(".material_ul").on('change','.amount_used', function(){
    var u = $(".add_li_material").index($(this).parent(".add_li_material"));
    var cost_price = $(this).parent(".add_li_material").children(".cost_price").html();
    var amount_used = $(this).parent(".add_li_material").find(".amount_used_input").val();
    if (isNaN(amount_used) == true){
      var calculate_price = 0;
    }else {
      var calculate_price = Math.round( (cost_price * amount_used) * 100 ) / 100 ;
      // var calculate_price = (cost_price * amount_used).toFixed(2)};
      $(this).parent(".add_li_material").children(".price_used").text(calculate_price);
      calculate_menu_price();
      var unit = $(".add_li_material").eq(u).find(".calculated_unit").text().trim();
      var id = $(".add_li_material").eq(u).find(".input_food_ingredient").val();
      if (unit=='g'||unit=='ml') {
        $(this).parent(".add_li_material").find(".input_gram_quantity").val(amount_used);
        input_menu_materials_nutrition(id,amount_used,u)
      }else{
        $(this).parent(".add_li_material").find(".input_gram_quantity").val("");
      }
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

  $('.input_food_ingredient').on('change',function(){
    var id = $(this).val();
    var gram_amount = $(this).parents('li').find('.input_gram_quantity').val();
    var index = $('.menu_materials_li').index($(this).parents('.menu_materials_li'));
    if (gram_amount=='') {}else{
      input_menu_materials_nutrition(id,gram_amount,index)
    }
  });

  $('.input_gram_quantity').on('blur',function(){
    var id = $(this).parents('li').find('.input_food_ingredient').val();
    var gram_amount = $(this).val();
    var index = $('.menu_materials_li').index($(this).parents('.menu_materials_li'));
    if (id=='') {}else{
      input_menu_materials_nutrition(id,gram_amount,index)
    }
  });


  function input_menu_materials_nutrition(id,gram_amount,index){
    $.ajax({
      url: "/menus/get_food_ingredient",
      data: { id : id ,gram_amount : gram_amount,index : index},
      dataType: "json",
      async: false
    })
    .done(function(data){
      $(".menu_materials_li").eq(data[0]).find(".input_calorie").val(data[1]['calorie'])
      $(".menu_materials_li").eq(data[0]).find(".input_protein").val(data[1]['protein'])
      $(".menu_materials_li").eq(data[0]).find(".input_lipid").val(data[1]['lipid'])
      $(".menu_materials_li").eq(data[0]).find(".input_carbohydrate").val(data[1]['carbohydrate'])
      $(".menu_materials_li").eq(data[0]).find(".input_dietary_fiber").val(data[1]['dietary_fiber'])
      $(".menu_materials_li").eq(data[0]).find(".input_potassium").val(data[1]['potassium'])
      $(".menu_materials_li").eq(data[0]).find(".input_calcium").val(data[1]['calcium'])
      $(".menu_materials_li").eq(data[0]).find(".input_vitamin_b1").val(data[1]['vitamin_b1'])
      $(".menu_materials_li").eq(data[0]).find(".input_vitamin_b2").val(data[1]['vitamin_b2'])
      $(".menu_materials_li").eq(data[0]).find(".input_vitamin_c").val(data[1]['vitamin_c'])
      $(".menu_materials_li").eq(data[0]).find(".input_salt").val(data[1]['salt'])
      $(".menu_materials_li").eq(data[0]).find(".input_magnesium").val(data[1]['magnesium'])
      $(".menu_materials_li").eq(data[0]).find(".input_iron").val(data[1]['iron'])
      $(".menu_materials_li").eq(data[0]).find(".input_zinc").val(data[1]['zinc'])
      $(".menu_materials_li").eq(data[0]).find(".input_copper").val(data[1]['copper'])
      $(".menu_materials_li").eq(data[0]).find(".input_folic_acid").val(data[1]['folic_acid'])
      $(".menu_materials_li").eq(data[0]).find(".input_vitamin_d").val(data[1]['vitamin_d'])
      $(".menu_materials_li").eq(data[0]).find('.view_food_ingredient').text(data[2])
      calculate_menu_nutrition()
    });
  };

  function calculate_menu_nutrition(){
    var arr_menu_nutrition =[]
    var obj = {calorie:0,protein:0,lipid:0,carbohydrate:0,dietary_fiber:0,potassium:0,
      calcium:0,vitamin_b1:0,vitamin_b2:0,vitamin_c:0,salt:0,magnesium:0,iron:0,zinc:0,
      copper:0,folic_acid:0,vitamin_d:0};
    $(".menu_materials_li").each(function(i) {
      calorie = Number(obj['calorie']) + Number($(this).find(".input_calorie").val());
      protein = Number(obj['protein']) + Number($(this).find(".input_protein").val());
      lipid = Number(obj['lipid']) + Number($(this).find(".input_lipid").val());
      carbohydrate = Number(obj['carbohydrate']) + Number($(this).find(".input_carbohydrate").val());
      dietary_fiber = Number(obj['dietary_fiber']) + Number($(this).find(".input_dietary_fiber").val());
      potassium = Number(obj['potassium']) + Number($(this).find(".input_potassium").val());
      calcium = Number(obj['calcium']) + Number($(this).find(".input_calcium").val());
      // vitamin_b1 = Number(obj['vitamin_b1']) + Number($(this).find(".input_vitamin_b1").val());
      // vitamin_b2 = Number(obj['vitamin_b2']) + Number($(this).find(".input_vitamin_b2").val());
      vitamin_c = Number(obj['vitamin_c']) + Number($(this).find(".input_vitamin_c").val());
      salt = Number(obj['salt']) + Number($(this).find(".input_salt").val());
      // magnesium = Number(obj['magnesium']) + Number($(this).find(".input_magnesium").val());
      // iron = Number(obj['iron']) + Number($(this).find(".input_iron").val());
      // zinc = Number(obj['zinc']) + Number($(this).find(".input_zinc").val());
      // copper = Number(obj['copper']) + Number($(this).find(".input_copper").val());
      // folic_acid = Number(obj['folic_acid']) + Number($(this).find(".input_folic_acid").val());
      // vitamin_d = Number(obj['vitamin_d']) + Number($(this).find(".input_vitamin_d").val());

      obj = {calorie:calorie,protein:protein,lipid:lipid,carbohydrate:carbohydrate,dietary_fiber:dietary_fiber,
        potassium:potassium,calcium:calcium,vitamin_c:vitamin_c,salt:salt};
    });
    $(".menu_calorie").text(Math.round(obj['calorie']*100)/100);
    $(".menu_protein").text(Math.round(obj['protein']*100)/100);
    $(".menu_lipid").text(Math.round(obj['lipid']*100)/100);
    $(".menu_carbohydrate").text(Math.round(obj['carbohydrate']*100)/100);
    $(".menu_dietary_fiber").text(Math.round(obj['dietary_fiber']*100)/100);
    $(".menu_potassium").text(Math.round(obj['potassium']*100)/100);
    $(".menu_calcium").text(Math.round(obj['calcium']*100)/100);
    // $(".menu_vitamin_b1").text(Math.round(obj['vitamin_b1']*100)/100);
    $(".menu_vitamin_c").text(Math.round(obj['vitamin_c']*100)/100);
    $(".menu_salt").text(Math.round(obj['salt']*100)/100);
    // $(".menu_magnesium").text(Math.round(obj['magnesium']*100)/100);
    // $(".menu_iron").text(Math.round(obj['iron']*100)/100);
    // $(".menu_zinc").text(Math.round(obj['zinc']*100)/100);
    // $(".menu_copper").text(Math.round(obj['copper']*100)/100);
    // $(".menu_folic_acid").text(Math.round(obj['folic_acid']*100)/100);
    // $(".menu_vitamin_d").text(Math.round(obj['vitamin_d']*100)/100);

  };


//メニュー価格の変更
  function calculate_menu_price(){
    var row_len =  $(".add_li_material").length
    var menu_price = 0;
    $(".add_li_material").each(function(){
      if ($(this).children(".remove_material").children("input").val()==1){
      }else{
        var price_used = Number($(this).children(".price_used").html())
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

  function get_material_info(data,u){
    var amount_used = $(".add_li_material").eq(u).find(".amount_used_input").val();
    var cost = data.material.cost_price;
    var unit = data.material.calculated_unit;
    var vendor = data.material.vendor_company_name;
    var eos = data.material.end_of_sales;
    $(".add_li_material").eq(u).children(".sales_check").text(eos);
    $(".add_li_material").eq(u).children(".vendor").text(vendor);
    $(".add_li_material").eq(u).children(".cost_price").text(cost);
    $(".add_li_material").eq(u).find(".calculated_unit").text(unit);
    //終売のアラートon
    eos_check(eos,u)
    if (isNaN(amount_used) == true){
      var calculate_price = 0;
    }else {
      var calculate_price = Math.round( (cost * amount_used) * 100 ) / 100 ;
    $(".add_li_material").eq(u).children(".price_used").text(calculate_price);
    }
    unit_check(unit,u)
  };

  function unit_check(unit,u){
    if (unit=='g' || unit=='ml') {
      $(".add_li_material").eq(u).find('.input_gram_quantity').attr('readonly',true).attr('style','background-color:#EBEBEB');
    }else{
      $(".add_li_material").eq(u).find('.input_gram_quantity').attr('readonly',false).attr('style','background-color: #ffa2a2;')
    }
  };

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
    $(".input_select_material").select2({width:"270px",placeholder: "食材資材を選択してください"});
    last_li.find(".input_row_order").val(u);
  };

  function reset_row_order(){
    $(".add_li_material").each(function(i){
      $(this).find('.input_row_order').val(i)
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
      console.log(data);
      $(".select_used_additives").select2('destroy');
      $(".select_used_additives optgroup").remove();
      $(".select_used_additives").select2({
        data: data
      });
    });
  }
});
