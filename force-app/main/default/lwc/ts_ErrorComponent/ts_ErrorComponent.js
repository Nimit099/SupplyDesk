import { LightningElement,  api } from 'lwc';
import communityicon from '@salesforce/resourceUrl/communityicons';

export default class Ts_ErrorComponent extends LightningElement {

    @api openpopup = false;
    @api reloadpage;            //For Reload Page
    warningicon = communityicon + '/communityicons/warning.png';;

    @api
    openModal() {
        this.openpopup = true;
    }

    closeModal(event) {
        this.dispatchEvent(new CustomEvent('closebtn', { detail: {} }));
        this.openpopup = false;
        if (this.reloadpage) {
            window.location.reload(); //For Reload Page
        }
    }

}