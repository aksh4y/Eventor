/**
 * Created by Akshay on 2/11/2017.
 */

var URL_REQ = "https://www.eventbriteapi.com/v3/events/search/?location.address=boston&categories=114&token=DX43YVUK5EDWAE357ROL";

var xhReq = new XMLHttpRequest();
xhReq.open("GET", URL_REQ, false);
xhReq.send(null);
var cwData = JSON.parse(xhReq.responseText)

$.each(cwData.events, function (i, events) {

        var option_cate = '<li class="item"><a href="#">' + events.name.text + '</a></li>';
        $('#product_list').append(option_cate);

});