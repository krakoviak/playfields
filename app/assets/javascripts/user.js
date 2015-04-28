/**
 * Created by kirill_khaidukov on 20/04/15.
 */

$(function () {
    $('.accordion .cell').click(function () {
        var env_name = $(this).text().trim();
        console.log(env_name);
        $(document).scrollTop($("#" + env_name).offset().top);
        window.location.hash = env_name;
        if ($(document).scrollTop() > $(window).height()) {
            $('.back').fadeIn();
        }
    });

    $('.back').click(function () {
        $(document).scrollTop(0);
        $(this).fadeOut();
        //window.location.hash = null;
        history.pushState("", document.title, window.location.pathname);
    });

    $(document).scroll(function () {
        var y = $(this).scrollTop();
        if (y > $(window).height()) {
            $('.back').fadeIn();
        } else {
            $('.back').fadeOut();
        }
    });
});