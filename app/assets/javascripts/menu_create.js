
$(function(){
  $(document).on('turbolinks:load', function(){
    $('.input_select_material').select2({
    width:"300px",
    placeholder: "食材資材を選択してください",
    // allowClear: true //
    })
    //ナンバーの振り直し
    var u = 0
    $("tr.add_tr_material").each(function() {
      set(this,u);
        var id = parseInt(document.getElementById("select_material"+u).value);
        //空の時は起動しない
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
    // calculate_menu_price()

  //addアクション、materialの追加
  $(".add_material").on('click', function addInput(){
      var u = parseInt(document.getElementById("table_body").rows.length);
      //tbodyに1行追加z
      $(".input_select_material").select2('destroy');
      $("#add_tr0").clone().appendTo("table");
      set("tr:last",u)
      $("#select_material" + u).val("");
      $(".input_select_material").select2({width:"300px",placeholder: "食材資材を選択してください"});
      $("#cost_price_id" + u ).empty();
      $("#vendor_id" + u ).empty();
      $("#amount_used_id" +u ).val("");
      $("#price_used_id" + u ).empty();
      $("#calculated_unit" + u).empty();
    });

  //removeアクション、materialの削除
  $("#table_body").on('click','.remove', function(){
    //1行目は残す
    var q = $(this).parent().parent().children(".trno").children().html();
    if (q == 0){} else{
       $("#menu_menu_materials_attributes_"+q+"__destroy").val(true);

        $(this).parent().parent().remove();

    //ナンバーの振り直し
      var u = 0
      $("tr.add_tr_material").each(function () {
        set(this,u)
        u = u+1;
      });
      calculate_menu_price();
  }});


// input内のチェックと各カラムへの代入、materialデータベースに無ければ空欄にする
      $("#table_body").on('change','.input_select_material', function(){
      var u = $(this).parent().parent().children(".trno").children().html();
      var id = $(this).val();
        if (isNaN(id) == true) {} else{
        $.ajax({
            url: "/menus/get_cost_price/" + id,
            data: { id : id },
            dataType: "json",
            async: false
        })
        .done(function(data){
          get_material_info(data,u)
          calculate_menu_price()
        })
      }});

    //amount_used変更でprice_used取得
    $("#table_body").on('change','.amount_used', function(){
          var u = $(this).parent().children(".trno").children().html();

          //使用価格の計算ゾーン
          var cost_price = parseFloat(document.getElementById("cost_price_id" + u).innerHTML);
          var amount_used = parseFloat(document.getElementById("amount_used_id" + u).value);
          if (isNaN(amount_used) == true){
            var calculate_price = 0;
          }else {
            var calculate_price = (cost_price * amount_used).toFixed(2)}
            $('#price_used_id' + u).text(calculate_price+"円");

          calculate_menu_price()
    });


  function set(elm,u){
  $(elm).attr('id', "add_tr" + u );
  $(elm).children(".trno").children().text(u);
  $(elm).children(".select").children().attr('id', "select_material" + u );
  $(elm).children(".cost_price").children().attr('id', "cost_price_id" + u );
  $(elm).children(".vendor").children().attr('id', "vendor_id" + u );
  $(elm).children(".amount_used").children().attr('id', "amount_used_id" +u );
  $(elm).children(".price_used").children().attr('id', "price_used_id" + u );
  $(elm).children(".select").children().attr('name', "menu[menu_materials_attributes]["+u+"][material_id]" );
  $(elm).children(".amount_used").children().attr('name', "menu[menu_materials_attributes]["+u+"][amount_used]" );
  $(elm).children(".calculated_unit").children().attr('id', "calculated_unit" + u );
  };

//メニュー価格の変更
  function calculate_menu_price(){
    var row = parseFloat($("tr:last").find(".trno").children().html()+1);
    var  menu_price = 0;
      for (var u_row = 0; u_row < row ; u_row++){
        var price_used = parseFloat($(".price_used").children('#price_used_id'+u_row).html());
        if (isNaN(price_used)){
          continue;
        }
          menu_price += price_used ;
        };
        document.getElementById('menu_cost_price').value=　menu_price.toFixed(2);
      };

  function get_material_info(data,u){
    var amount_used = parseFloat(document.getElementById("amount_used_id" + u).value);
    var cost = data.material.cost_price;
    var unit = data.material.calculated_unit;
    var vendor = data.material.vendor_company_name;
    $('#vendor_id' + u).text(vendor);
    $('#cost_price_id' + u).text(cost+"円");
    $('#calculated_unit' + u).text(unit);

    if (isNaN(amount_used) == true){
      var calculate_price = 0;
    }else {
      var calculate_price = (cost * amount_used).toFixed(2)}
    $('#price_used_id' + u).text(calculate_price+"円");
  };
});
});
