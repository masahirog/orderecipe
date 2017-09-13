
$(function(){
  $(document).on('turbolinks:load', function(){ //リロードしなくてもjsが動くようにする
    //ナンバーの振り直し
    var u = 0
    $("tr.add_tr_material").each(function() {

      $(this).attr('id', "add_tr" + u );
      $(this).children(".trno").children().text(u);
      $(this).children(".search_material").children("input").attr('id', "search_material" + u );
      $(this).children(".search_material").children("ul").attr('id', "result" + u );
      $(this).children(".select").children().attr('id', "select_material" + u );
      $(this).children(".cost_price").children().attr('id', "cost_price_id" + u );
      $(this).children(".vendor").children().attr('id', "vendor_id" + u );
      $(this).children(".amount_used").children().attr('id', "amount_used_id" +u );
      $(this).children(".price_used").children().attr('id', "price_used_id" + u );
      $(this).children(".select").children().attr('name', "menu[menu_materials_attributes]["+u+"][material_id]" );
      $(this).children(".amount_used").children().attr('name', "menu[menu_materials_attributes]["+u+"][amount_used]" );
      $(this).children(".calculated_unit").children().attr('id', "calculated_unit" + u );

      $(".search_material").children("ul").hide();



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
          var name = data.material.name;
          $('#search_material' + u).val(name);
          var cost = data.material.cost_price;
          var unit = data.material.calculated_unit;
          var vendor = data.material.vendor_company_name;
          $('#vendor_id' + u).text(vendor);
          $('#calculated_unit' + u).text(unit);
          // 以下price_usedの計算
          $('#cost_price_id' + u).text(cost+"円");
          //使用価格の計算ゾーン
          var amount_used = parseFloat(document.getElementById("amount_used_id" + u).value);
          //amount_usedが空欄ならcalculate_priceを0
          if (isNaN(amount_used) == true){
            var calculate_price = 0;
          }else {
            var calculate_price = (cost * amount_used).toFixed(1)}
          // //calculate_priceを更新
          $('#price_used_id' + u).text(calculate_price+"円 ");
      })};
      u = u+1;
    });



  //addアクション、materialの追加
  $(".add_material").on('click', function addInput(){
    var u = parseInt(document.getElementById("table_body").rows.length);
    //tbodyに1行追加
    $("#add_tr0").clone().attr('id',"add_tr"+u).appendTo("table");
    $("tr:last").children(".trno").children().text(u);
    $("tr:last").children(".search_material").children("input").attr('id', "search_material" + u ).val("");
    $("tr:last").children(".search_material").children("ul").attr('id', "result" + u );
    $("tr:last").children(".select").children().attr('id', "select_material" + u ).val("");
    $("tr:last").children(".cost_price").children().attr('id', "cost_price_id" + u ).empty();
    $("tr:last").children(".vendor").children().attr('id', "vendor_id" + u ).empty();
    $("tr:last").children(".amount_used").children().attr('id', "amount_used_id" +u ).val("");
    $("tr:last").children(".price_used").children().attr('id', "price_used_id" + u ).empty();
    $("tr:last").children(".calculated_unit").children().attr('id','calculated_unit' + u).empty();
    $("tr:last").children(".select").children().attr('name', "menu[menu_materials_attributes]["+u+"][material_id]" );
    $("tr:last").children(".amount_used").children().attr('name', "menu[menu_materials_attributes]["+u+"][amount_used]" );
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

        $(this).attr('id', "add_tr" + u );
        $(this).children(".trno").children().text(u);
        $(this).children(".search_material").children("input").attr('id', "search_material" + u );
        $(this).children(".search_material").children("ul").attr('id', "result" + u );
        $(this).children(".select").children().attr('id', "select_material" + u );
        $(this).children(".cost_price").children().attr('id', "cost_price_id" + u );
        $(this).children(".vendor").children().attr('id', "vendor_id" + u );
        $(this).children(".amount_used").children().attr('id', "amount_used_id" +u );
        $(this).children(".price_used").children().attr('id', "price_used_id" + u );
        $(this).children(".calculated_unit").children().attr('id','calculated_unit' + u);
        $(this).children(".select").children().attr('name', "menu[menu_materials_attributes]["+u+"][material_id]" );
        $(this).children(".amount_used").children().attr('name', "menu[menu_materials_attributes]["+u+"][amount_used]" );

        u = u+1;
      });

      //メニュー価格の変更
      var row = parseFloat($("tr:last").find(".trno").children().html()+1);
      var  menu_price = 0;
      for (var u_row = 0; u_row < row ; u_row++){
        var price_used = parseFloat($(".price_used").children('#price_used_id'+u_row).html());
        if (isNaN(price_used)){
          continue;
        }
          menu_price += price_used;
        };
        document.getElementById('menu_cost_price').value=　menu_price.toFixed(1);
  }});

//search_materialカラムのinput時にmaterialモデル内をキーワード検索する
    $("#table_body").on('keyup', '.search_material_input', function(e){
      e.preventDefault();
      var u = $(this).parent().parent().children(".trno").children().html();
      if ($(this).val()=="") {
        $(".search_material").children("ul").hide();
      } else {

      $('#result'+u).show();
      var input = $.trim($(this).val()); //この要素に入力された語句を取得し($(this).val())、前後の不要な空白を取り除いた($.trim(...);)上でinputという変数に(var input =)代入
      $.ajax({
        url: '/menus/material_search',
        type: 'GET',
        data: ('keyword=' + input),
        processData: false,
        contentType: false,
        dataType: 'json'
      })
      .done(function(data){
      $('#result'+u).find('li').remove();
      if($("#search_material"+u).val()==""||$("#search_material"+u).val()==" "){}else{
        $(data).each(function(d, material){
        $('#result'+u).append('<li class="li1 list-group-item" value='+material.id+', style="cursor: pointer">' + material.name + '</li>')
      })
      }});
    }});



//リスト内のliをカーソルでinputに表示する
    $("#table_body").on("mouseover",".li1", function(){
      var name = $(this).text();
      var u = $(this).parent().parent().parent().children(".trno").children().html();
      $("#search_material"+u).val(name);
    });


//input内のチェックと各カラムへの代入、materialデータベースに無ければ空欄にする
    $("#table_body").on('blur', '.search_material_input', function(){
      var u = $(this).parent().parent().children(".trno").children().html();
      var input = $(this).val();
        $.ajax({
          url: '/menus/material_exist',
          type: 'GET',
          data: ('keyword=' + input),
          processData: false,
          contentType: false,
          dataType: 'json'
        })
        .done(function(data){
          //ajaxうまくいったとき
          $(".search_material").children("ul").hide();
          var cost = data.material.cost_price;
          var unit = data.material.calculated_unit;
          var id = data.material.id
          var vendor = data.material.vendor_company_name;
          var amount_used = parseFloat(document.getElementById("amount_used_id" + u).value);
          $('#vendor_id' + u).text(vendor);
          $("#select_material"+u).val(id);
          // console.log(cost)
          $('#cost_price_id' + u).text(cost+"円");
          $('#calculated_unit' + u).text(unit);

          if (isNaN(amount_used) == true){
            var calculate_price = 0; //amount_usedが空欄ならcalculate_priceを0
          }else {
            var calculate_price = (cost * amount_used).toFixed(1)}
         //calculate_priceを更新
          $('#price_used_id' + u).text(calculate_price+"円");
          //メニュー価格の変更
          var row = parseFloat($("tr:last").find(".trno").children().html()+1);
          var  menu_price = 0;
            for (var u_row = 0; u_row < row ; u_row++){
              var price_used = parseFloat($(".price_used").children('#price_used_id'+u_row).html());
              if (isNaN(price_used)){
                continue;
              }
                menu_price += price_used ;
              };
              document.getElementById('menu_cost_price').value=　menu_price.toFixed(1);

        })
        .fail(function(){
          $("#search_material"+u).val("");
          $(".search_material").children("ul").hide();
          $("#vendor_id" + u ).empty();
          $("#cost_price_id" + u ).empty();
          $("#price_used_id" + u ).empty();
          $("#calculated_unit" + u).text("")
          //メニュー価格の変更
          var row = parseFloat($("tr:last").find(".trno").children().html()+1);
          var  menu_price = 0;
            for (var u_row = 0; u_row < row ; u_row++){
              var price_used = parseFloat($(".price_used").children('#price_used_id'+u_row).html());
              if (isNaN(price_used)){
                continue;
              }
                menu_price += price_used ;
              };
              document.getElementById('menu_cost_price').value=　menu_price.toFixed(1);

          console.log("ajax failed");
          //ajax失敗した時
        });
      });


    //amount_used変更でprice_used取得
    $("#table_body").on('change','.amount_used', function(){
          var u = $(this).parent().children(".trno").children().html();

          //使用価格の計算ゾーン
          var cost_price = parseFloat(document.getElementById("cost_price_id" + u).innerHTML);
          var amount_used = parseFloat(document.getElementById("amount_used_id" + u).value);
          //amount_usedが空欄ならcalculate_priceを0
          if (isNaN(amount_used) == true){
            var calculate_price = 0;
          }else {
            var calculate_price = (cost_price * amount_used).toFixed(1)}
            $('#price_used_id' + u).text(calculate_price+"円");

          //メニュー価格の変更
          var row = parseFloat($("tr:last").find(".trno").children().html()+1);
          var  menu_price = 0;
            for (var u_row = 0; u_row < row ; u_row++){
              var price_used = parseFloat($(".price_used").children('#price_used_id'+u_row).html());
              if (isNaN(price_used)){
                continue;
              }
                menu_price += price_used;
              };
            document.getElementById('menu_cost_price').value=　menu_price.toFixed(1);
    });
  });
});
