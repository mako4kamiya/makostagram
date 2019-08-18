// 検索ボックスのクリックイベント
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

// // いいね！のクリックイベント
// $(function() {
//     $('.like').click(function(){
//         $('.like').addClass('display-none');
//         $('.like').removeClass('display-block');
//         $('.dislike').addClass('display-block');
//         $('.dislike').removeClass('display-none');
//         });
//     $('.dislike').click(function(){
//         $('.like').addClass('display-block');
//         $('.like').removeClass('display-none');
//         $('.dislike').addClass('display-none'); 
//         $('.dislike').removeClass('display-block');
//     });
    
// })

// $(function() {
//     $('.like').click(function(){
        
//         $.ajax({
//             type: 'GET',
//             url: '/like/:id',
//             // dataType: 'json',  //json形式指定
//             // data: {
//             // },
//         })
//         .done(function () {
//             $('.like').addClass('display-none');
//             $('.like').removeClass('display-block');
//             $('.dislike').addClass('display-block');
//             $('.dislike').removeClass('display-none');
//             });
//     }); 
//     $('.dislike').click(function(){
//         $('.like').addClass('display-block');
//         $('.like').removeClass('display-none');
//         $('.dislike').addClass('display-none'); 
//         $('.dislike').removeClass('display-block');
//     });
    
// })




