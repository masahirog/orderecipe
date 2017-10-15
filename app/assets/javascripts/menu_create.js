
$(function(){
    $('.input_select_material').select2({
    width:"300px",
    placeholder: "食材資材を選択してください"
  });
    var u = 0
    $("tr.add_tr_material").each(function() {
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
    var u = $("tr.add_tr_material").length
    $(".input_select_material").select2('destroy');
    $("tr.add_tr_material").first().clone().appendTo("table");
    var last_tr =$(".add_tr_material").last()
    last_tr.children(".select_material").children().attr('name', "menu[menu_materials_attributes]["+u+"][material_id]" );
    last_tr.children(".select_material").children().attr('id', "menu_menu_materials_attributes_"+u+"_material_id" );
    last_tr.children(".amount_used").children().attr('name', "menu[menu_materials_attributes]["+u+"][amount_used]" );
    last_tr.children(".amount_used").children().attr('id', "menu_menu_materials_attributes_"+u+"_amount_used" );
    last_tr.children(".remove_material").children(".destroy_materials").attr('id', "menu_menu_materials_attributes_"+u+"__destroy");
    last_tr.children(".remove_material").children(".destroy_materials").attr('name', "menu[menu_materials_attributes]["+u+"][_destroy]");
    last_tr.children(".select_material").children().val("");
    $(".input_select_material").select2({width:"300px",placeholder: "食材資材を選択してください"});
    last_tr.children(".cost_price").empty();
    last_tr.children(".vendor").empty();
    last_tr.children(".amount_used").children().val("");
    last_tr.children(".price_used").children(".price_used_value").empty();
    last_tr.children(".calculated_unit").empty();
    last_tr.children(".remove_material").children(".destroy_materials").prop('checked',false);
    last_tr.show();
  });

  //removeのチェックと、trをhide
  $(".table_body").on('click','.remove_btn', function(){
    $(this).parent().children(".destroy_materials").prop('checked', true);
    $(this).parent().parent("tr.add_tr_material").hide();
    calculate_menu_price()
  });


// input内のチェックと各カラムへの代入、materialデータベースに無ければ空欄にする
  $(".table_body").on('change','.input_select_material', function(){
    var u = $(".table_body tr").index($(this).parent().parent("tr.add_tr_material"))
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
  $(".table_body").on('change','.amount_used', function(){
    var u = $(".table_body tr").index($(this).parent("tr.add_tr_material"))
    var cost_price = $(this).parent("tr.add_tr_material").children(".cost_price").html()
    var amount_used = $(this).parent("tr.add_tr_material").children(".amount_used").children(".amount_used_input").val();
    if (isNaN(amount_used) == true){
      var calculate_price = 0;
    }else {
      var calculate_price = (cost_price * amount_used).toFixed(2)};
      $(this).parent("tr.add_tr_material").children(".price_used").children(".price_used_value").text(calculate_price);
    calculate_menu_price();
  });


//メニュー価格の変更
  function calculate_menu_price(){
    var row_len =  $("tr.add_tr_material").length
    var  menu_price = 0;
    $("tr.add_tr_material").each(function(){
      if ($(this).children(".remove_material").children(".destroy_materials").is(':checked')){
      }else{
        var price_used = Number($(this).children(".price_used").children(".price_used_value").html())
        if (isNaN(price_used) == true ){}else{
        menu_price += price_used}
      }});
    $(".menu_cost_price").val(menu_price.toFixed(1))
  };

  function get_material_info(data,u){
    amount_used = $("tr.add_tr_material").eq(u).children(".amount_used").children().val();
    var cost = data.material.cost_price;
    var unit = data.material.calculated_unit;
    var vendor = data.material.vendor_company_name;
    $("tr.add_tr_material").eq(u).children(".vendor").text(vendor);
    $("tr.add_tr_material").eq(u).children(".cost_price").text(cost);
    $("tr.add_tr_material").eq(u).children(".calculated_unit").text(unit);
    if (isNaN(amount_used) == true){
      var calculate_price = 0;
    }else {
      var calculate_price = (cost * amount_used).toFixed(2)}
    $("tr.add_tr_material").eq(u).children(".price_used").children(".price_used_value").text(calculate_price);
  };
});
