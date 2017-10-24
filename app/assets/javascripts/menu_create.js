
$(function(){
    $('.input_select_material').select2({
      placeholder: "食材資材を選択してください"
  });
    var u = 0
    $(".add_li_material").each(function() {
        var id = $(this).children(".select_material").children(".input_select_material").val()
        if (isNaN(id) == true) {} else{
        $.ajax({
            url: "/menus/get_cost_price/" + id,
            data: { id : id },
            dataType: "json",
            async: false
        })
        .done(function(data) {
          get_material_info(data,u)
      })};
      u = u+1;
    });
    calculate_menu_price();

  //addアクション、materialの追加
  $(".add_material").on('click', function addInput(){
    var u = $(".add_li_material").length
    $(".input_select_material").select2('destroy');
    $(".add_li_material").first().clone().appendTo(".material_ul");
    var last_li =$(".add_li_material").last()
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
    last_li.children(".preparation").children().val("");
    last_li.children(".select_post").children().val("");
    $(".input_select_material").select2({width:"270px",placeholder: "食材資材を選択してください"});
    last_li.children(".cost_price").children(".cost_price_value").empty();
    last_li.children(".vendor").empty();
    last_li.children(".amount_used").children().val("");
    last_li.children(".price_used").children(".price_used_value").empty();
    last_li.children().children(".calculated_unit").empty();
    last_li.children(".remove_material").children(".destroy_materials").prop('checked',false);
    last_li.show();
  });

  //removeのチェックと、trをhide
  $(".material_ul").on('click','.remove_btn', function(){
    $(this).parent().children(".destroy_materials").prop('checked', true);
    $(this).parent().parent(".add_li_material").hide();
    calculate_menu_price()
  });


// input内のチェックと各カラムへの代入、materialデータベースに無ければ空欄にする
  $(".material_ul").on('change','.input_select_material', function(){
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
      var calculate_price = (cost_price * amount_used).toFixed(2)};
      $(this).parent(".add_li_material").children(".price_used").children(".price_used_value").text(calculate_price);
    calculate_menu_price();
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
    $(".menu_cost_price").val(menu_price.toFixed(1))
  };

  function get_material_info(data,u){
    amount_used = $(".add_li_material").eq(u).children(".amount_used").children().val();
    var cost = data.material.cost_price;
    var unit = data.material.calculated_unit;
    var vendor = data.material.vendor_company_name;
    $(".add_li_material").eq(u).children(".vendor").text(vendor);
    $(".add_li_material").eq(u).children(".cost_price").children(".cost_price_value").text(cost);
    $(".add_li_material").eq(u).children().children(".calculated_unit").text(unit);
    if (isNaN(amount_used) == true){
      var calculate_price = 0;
    }else {
      var calculate_price = (cost * amount_used).toFixed(2)}
    $(".add_li_material").eq(u).children(".price_used").children(".price_used_value").text(calculate_price);
  };
});
