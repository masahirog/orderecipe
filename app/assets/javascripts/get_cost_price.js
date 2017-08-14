$(function(){
  $("#detail-association-insertion-point").on('change', '#select', function(){
    var id = $(this).children().val();
        $.ajax({
            url: "/menus/get_cost_price/" + id,
            data: { id : id },
            dataType: "json",
            // success: function(res) {
            //   $(this).parent().find(".aaa").text(res.cost_price)
            // }
        })

        .done(function(data) {
          var cost = data.material.cost_price;
          $('.nested-fields .aaa').text(cost);
        })

    });
});
