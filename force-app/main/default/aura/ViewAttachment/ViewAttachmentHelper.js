({
	getImages : function(component, event, helper){  
		var conId  = component.get("v.recordId");  
		var action = component.get("c.getContents");
        // component.set("v.Spinner",true);
        action.setParams({
			"conId" : conId	
		});
		
        action.setCallback(this, function(response) {
            var state = response.getState();
            if(component.isValid() && state === 'SUCCESS') {
                var result = response.getReturnValue();
                console.log('datas');
                console.log(result);
                component.set('v.imgId', result);
            }
        });
         $A.enqueueAction(action);
	 },
	 
	showToast : function(component, event, helper) {
        var toastEvent = $A.get("e.force:showToast");
        toastEvent.setParams({
            "title": "Info!",
            "type" : "info",
            "message": "No more files found."
        });
        toastEvent.fire();
	},
})