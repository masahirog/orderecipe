$(function(){
  $('.all_select_material').select2({
  width:"270px",
  placeholder: "食材資材を選択してください"
  });

  $(".all_box").on("change",function(){
    var prop = $('.all_box').prop('checked');
    if (prop) {
     $('.menu_check').children().prop('checked', true);
    } else {
     $('.menu_check').children().prop('checked', false);
   };
  });
  $(".all_select_material").on("change",function(){
    var id = $(this).val();
    var name = $(".all_select_material option:selected").text();
    $(".menu_include_material").each(function(){
      var prop = $(this).children(".menu_check").children().prop('checked');
      if (prop) {
        var j = $(this).children(".select_material").children().val();
        $(this).children(".select_material").children().val(id);
        $(this).children(".select_material").find(".select2-selection__rendered").text(name);
      }else{
      };
    });
  });
});
