//税率は最終的なproduct_cost_priceに1.08をかけている

$(function(){
  $(document).on('turbolinks:load', function(){
    $('.input_select_menu').select2({
    width:"300px",
    placeholder: "メニューを選択してください",
    // allowClear: true //
  });
    //ナンバーの振り直し
    var u = 0
    $("tr.add_tr_menu").each(function() {
      set_pr(this,u)

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
          get_menu_price(data,u)
      })};
      u = u+1;
      calculate_product_price()
    });


  //addアクション、materialの追加
  $(".add_menu").on('click', function addInput(){
    var i = parseInt(document.getElementById("used_menu_table_body").rows.length);
    //tbodyに1行追加
    $(".input_select_menu").select2('destroy');
    $("#add_tr0").clone().appendTo("table");
    set_pr("tr:last",i)
    $("#select_menu" + i ).val("");
    $(".input_select_menu").select2({ width:"300px",placeholder: "メニューを選択してください" });
    $("#cost_price_id" + i ).empty();
    $("#material_name"+i).children().remove();
    $("#amount_used"+i).children().remove();
    $("#calculated_unit"+i).children().remove();
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
        set_pr(this,u)
        u = u+1;
      });

      calculate_product_price()
    }});

      $("#used_menu_table_body").on('change','.input_select_menu', function(){
        var id = $(this).val();
        var i = $(this).parent().parent().children(".trno").children().html();
        $("#select_menu"+i).val(id);
          $.ajax({
              url: "/products/get_menu_cost_price/" + id,
              data: { id : id },
              dataType: "json",
          })
          .done(function(data) {
            get_menu_price(data,i)
            calculate_product_price()
         });
      });


      function set_pr(elm,u){
        $(elm).attr('id', "add_tr" + u );
        $(elm).children(".trno").children().text(u);
        $(elm).children(".select").children().attr('id', "select_menu" + u );
        $(elm).children(".cost_price").children().attr('id', "cost_price_id" + u );
        $(elm).children(".material_name").children().attr('id', "material_name" + u );
        $(elm).children(".amount_used").children().attr('id', "amount_used" + u );
        $(elm).children(".calculated_unit").children().attr('id', "calculated_unit" + u );
        $(elm).children(".select").children().attr('name', "product[product_menus_attributes]["+u+"][menu_id]" );
      };

      function calculate_product_price(){
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
        parseFloat(document.getElementById('sum_material_cost').value=　(kingaku).toFixed(2));
        parseFloat(document.getElementById('tax').value=　(kingaku*0.08).toFixed(2));
        parseFloat(document.getElementById('product_cost_price').value=　(kingaku*1.08).toFixed(1));
      };
      function get_menu_price(data,i){
        var cost = data.menu.cost_price;
        $('#cost_price_id' + i).text(cost+"円");
         $("#material_name"+i).children().remove();
         $("#amount_used"+i).children().remove();
         $("#calculated_unit"+i).children().remove();

        var maxi = data.menu.materials.length
        for(var ii = 0; ii < maxi; ii++) {
          var name = data.menu.materials[ii].name
          var amount_used = data.menu.menu_materials[ii].amount_used
          var unit = data.menu.materials[ii].calculated_unit
          $("#material_name"+i).append("<li>"+name+"</li>");
          $("#amount_used"+i).append("<li class='text-right'>"+amount_used+" "+unit+"</li>");

      }};
  });
});
