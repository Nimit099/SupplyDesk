import Longitude from '@salesforce/schema/Lead.Longitude';
import { LightningElement,track,api} from 'lwc';

export default class CommonToast extends LightningElement {
    @track type='success';
    @track message;
    @track messageIsHtml=false;
    @track showToastBar_success = false;
    @track showToastBar_error = false;
    @api autoCloseTime = 5000;
    @track icon='';
    
    @api messagee ;


    @api
    showToast(type, message, time) {
        this.type = type;
        this.message = message;
        this.autoCloseTime=time;
        if(this.type == "success"){
            this.showToastBar_success = true;
            this.showToastBar_error = false;
        }
        else{
            this.showToastBar_success = false;
            this.showToastBar_error = true;

        }
        console.log('OUTPUT toast: ',message);
        setTimeout(() => {
            this.closeModel();
        }, this.autoCloseTime);
    }

    
    closeModel() {
        this.showToastBar_success = false;
        this.showToastBar_error = false;
        this.type = '';
        this.message = '';
    }
 
    get outerClass() {
        return 'slds-notify slds-notify_toast ';
    }
}