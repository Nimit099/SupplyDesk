window.addEventListener('getdetails',function(event){
    console.log('GET DETAILS');
    console.log({event});
    var s = event.detail.userProfile;
    userProfile = Object.assign({}, s);
});


window.onload = function(){
    console.log('LOADED');
}