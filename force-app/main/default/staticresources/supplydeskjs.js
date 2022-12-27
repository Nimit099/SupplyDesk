window.addEventListener("getdetails",function(event){
    var eventname = event.detail;
    if(eventname != null && eventname != undefined && eventname != ''){
        var navigationCmp = document.querySelector('c-ts_-navigation-theme');
        if(navigationCmp != null){
            navigationCmp.getselectedtab(eventname);
        }
    }
});

window.addEventListener("getmenu", function (event) {
    var eventname = event.detail;
    if (eventname != null && eventname != undefined && eventname != '') {
        var navigationCmp = document.querySelector('c-ts_-navigation-theme');
        navigationCmp.check2();
    }
});