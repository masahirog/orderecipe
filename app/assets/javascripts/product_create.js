//税率は最終的なproduct_cost_priceに1.08をかけている



$(function(){
  $(document).on('turbolinks:load', function(){ //リロードしなくてもjsが動くようにする
    //ナンバーの振り直し
    var u = 0
    $("tr.add_tr_menu").each(function() {

      $(this).attr('id', "add_tr" + u );
      $(this).children(".trno").children().text(u);
      $(this).children(".search_menu").children("#search_menu0").attr('id', "search_menu" + u );
      $(this).children(".search_menu").children("#result0").attr('id', "result" + u );
      $(this).children(".select").children("#select_menu0").attr('id', "select_menu" + u );
      $(this).children(".cost_price").children().attr('id', "cost_price_id" + u );
      $(this).children(".select").children().attr('name', "product[product_menus_attributes]["+u+"][menu_id]" );
      $(".search_menu").children("ul").hide();


        var id = parseInt(document.getElementById("select_menu"+u).value);
        //空の時は起動しない
        if (isNaN(id) == true) {} else{
        $.ajax({
            url: "/products/get_menu_cost_price/" + id,
            data: { id : id },
            dataType: "json",
            async: false
        })

        .done(function(data) {
          var name = data.menu.name;
          var cost = data.menu.cost_price;
            $('#search_menu' + u).val(name);
          // 以下price_usedの計算
          $('#cost_price_id' + u).text(cost+"円");
      })};
      u = u+1;
    });


  //addアクション、materialの追加
  $(".add_menu").on('click', function addInput(){
    var i = parseInt(document.getElementById("used_menu_table_body").rows.length);
    //tbodyに1行追加
    $("#add_tr0").clone().attr('id',"add_tr"+i).appendTo("table");
    $("tr:last").children(".trno").children().text(i);
    $("tr:last").children(".search_menu").children("#search_menu0").attr('id', "search_menu" + i ).val("");
    $("tr:last").children(".search_menu").children("#result0").attr('id', "result" + i );
    $("tr:last").children(".select").children().attr('id', "select_menu" + i ).empty();
    $("tr:last").children(".cost_price").children().attr('id', "cost_price_id" + i ).empty();

    $("tr:last").children(".select").children().attr('name', "product[product_menus_attributes]["+i+"][menu_id]" );
  });

  //removeアクション、materialの削除
  $("#used_menu_table_body").on('click','.remove', function(){
    //1行目は残す
    var q = $(this).parent().parent().children(".trno").children().html();
    if (q == 0){} else{
       $("#product_product_menus_attributes_"+q+"__destroy").val(true);

        $(this).parent().parent().remove();

    //ナンバーの振り直し
      var u = 0
      $("tr.add_tr_menu").each(function () {

        $(this).attr('id', "add_tr" + u );
        $(this).children(".trno").children().text(u);
        $(this).children(".search_menu").children("input").attr('id', "search_menu" + u );
        $(this).children(".search_menu").children("ul").attr('id', "result" + u );
        $(this).children(".select").children().attr('id', "select_menu" + u );
        $(this).children(".cost_price").children().attr('id', "cost_price_id" + u );

        $(this).children(".select").children().attr('name', "product[product_menus_attributes]["+u+"][menu_id]" );
        u = u+1;
      });

      //product_cost_priceの変更
      var row = parseFloat($("tr:last").find(".trno").children().html()+1);
      var  kingaku = 0;
      for (var i_row = 0; i_row < row ; i_row++){
        var ffff = parseFloat($('#cost_price_id'+i_row).html());
        if (isNaN(ffff)){
          continue;
        }
          kingaku += ffff;
        };
    parseFloat(document.getElementById('product_cost_price').value=　(kingaku * 1.08).toFixed(1));
  }});


    $("#used_menu_table_body").on('keyup', 'input', function(e){
      e.preventDefault(); //キャンセル可能なイベントをキャンセル
      var i = $(this).parent().parent().children(".trno").children().html();
      $("#cost_price_id"+i).text("");
      $("#product_cost_price").val("");
      $('#result'+i).show();
      var input = $.trim($(this).val()); //この要素に入力された語句を取得し($(this).val())、前後の不要な空白を取り除いた($.trim(...);)上でinputという変数に(var input =)代入
      $.ajax({
        url: '/products/menu_search',
        type: 'GET',
        data: ('keyword=' + input),
        processData: false,
        contentType: false,
        dataType: 'json'
      })
      .done(function(data){

      $('#result'+i).find('li').remove();
      if($("#search_menu"+i).val()==""||$("#search_menu"+i).val()==" "){}else{
        $(data).each(function(u, menu){
        $('#result'+i).append('<li class="li1 list-group-item" value='+menu.id+', style="cursor: pointer">' + menu.name + '</li>')
        })
      }});
    });

    //カーソルで値をinputに表示する
      $("#used_menu_table_body").on("mouseover",".li1", function(){
        var name = $(this).text();
        var u = $(this).parent().parent().parent().children(".trno").children().html();
        $("#search_menu"+u).val(name);
      });

      //input内のチェック
          $("#used_menu_table_body").on('blur', '.search_menu_input', function(){
            var u = $(this).parent().parent().children(".trno").children().html();
            var input = $(this).val();
              $.ajax({
                url: '/products/menu_exist',
                type: 'GET',
                data: ('keyword=' + input),
                processData: false,
                contentType: false,
                dataType: 'json'
              })
              .done(function(data){
                //ajaxうまくいったとき
                $(".search_menu").children("ul").hide();
                var cost = data.menu.cost_price;
                var id = data.menu.id
                $("#select_menu"+u).val(id);
                $('#cost_price_id' + u).text(cost+"円");
                //product_cost_priceの変更
                var row = parseFloat($("tr:last").find(".trno").children().html()+1);
                var  product_cost_price = 0;
                  for (var u_row = 0; u_row < row ; u_row++){
                    var menu_price = parseFloat($(".cost_price").children('#cost_price_id'+u_row).html());
                    if (isNaN(menu_price)){
                      continue;
                    }
                      product_cost_price += menu_price ;
                    };
                    parseFloat(document.getElementById('product_cost_price').value=　(product_cost_price * 1.08).toFixed(1));

              })
              .fail(function(){
                $("#search_menu"+u).val("");
                $(".search_menu").children("ul").hide();
                $("#cost_price_id" + u ).empty();
                //メニュー価格の変更
                var row = parseFloat($("tr:last").find(".trno").children().html()+1);
                var  product_cost_price = 0;
                  for (var u_row = 0; u_row < row ; u_row++){
                    var menu_price = parseFloat($(".cost_price").children('#cost_price_id'+u_row).html());
                    if (isNaN(menu_price)){
                      continue;
                    }
                      product_cost_price += menu_price ;
                    };
                    parseFloat(document.getElementById('product_cost_price').value=　(product_cost_price * 1.08).toFixed(1));

                console.log("ajax failed");
                //ajax失敗した時
              })
            });


      $("#used_menu_table_body").on("click",".li1", function(){
        var name = $(this).text();
        var id = $(this).val();
        var i = $(this).parent().parent().parent().children(".trno").children().html();
        $("#search_menu"+i).val(name);
        $("#select_menu"+i).val(id);
        $("#result"+i).hide();
          $.ajax({
              url: "/products/get_menu_cost_price/" + id,
              data: { id : id },
              dataType: "json",
          })
          .done(function(data) {
            var cost = data.menu.cost_price;
            // 以下price_usedの計算
            $('#select_menu' + i ).parent().parent().find('#cost_price_id' + i).text(cost);
            //メニュー価格の変更
            var row = parseFloat($("tr:last").find(".trno").children().html()+1);
            var  kingaku = 0;
            for (var i_row = 0; i_row < row ; i_row++){
              var ffff = parseFloat($('#cost_price_id'+i_row).html());
              if (isNaN(ffff)){
                continue;
              }
                kingaku += ffff;
              };
          parseFloat(document.getElementById('product_cost_price').value=　(kingaku * 1.08).toFixed(1));

         });
      });
  });
});
