$(function(){
  $(document).on('turbolinks:load', function(){
    $(".products_tr").click(function(e) {
      if(!$(e.target).is('a')){
        window.location = $(this).children(".products_index").children("a").attr('href');
      };
    });

    $(".menus_tr").click(function(e) {
      if(!$(e.target).is('a')){
        window.location = $(this).children(".menus_index").children("a").attr('href');
      };
    });

    $(".materials_tr").click(function(e) {
      if(!$(e.target).is('a')){
        window.location = $(this).children(".materials_index").children("a").attr('href');
      };
    });
    $(".vendors_tr").click(function(e) {
      if(!$(e.target).is('a')){
        window.location = $(this).children(".vendors_index").children("a").attr('href');
      };
    });
  });
});
