$(function() {
    $('#search-box').click(function(){
        $('#search-box').addClass('display-none');
        $('#search-box-active').addClass('visible'); //blockだとデザインが崩れるのでvisible
        $('#search-box-active').removeClass('display-none');
        //visibleだとデザインが崩れるので.search-box-activeはdisplay:blockで非表示
    });
    $('#close').click(function(){
        $('#search-box').removeClass('display-none');
        $('#search-box-active').removeClass('visible');
        $('#search-box-active').addClass('display-none');
    });
    
})