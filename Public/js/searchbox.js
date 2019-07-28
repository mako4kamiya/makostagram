$(function() {
    // これは効く
    // $(document).on('click','button',function(){
    //     $('#try').hide();
    //     });

    // これは効かない
    // $(document).on('click','button',function(){
    //     $('#search-box').hide();
    //     });

    // これは効く
    // $('button').click(function(){
    //     $('#try').hide();
    // });

    // これは効かない
    // $('#search-box ').click(function(){
    //     $('#search-box ').hide();
    // });

    // これも効かない
    // $('button').click(function(){
    //     $('#search-box').hide();
    // });

})