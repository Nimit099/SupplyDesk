import { LightningElement,track,wire } from 'lwc';
import changePassIcon from '@salesforce/resourceUrl/changePassIcon';
import cancelIcon from '@salesforce/resourceUrl/cancelIcon';
import resetpass from '@salesforce/apex/ts_ProfileModule.resetpass';
 
export default class Ts_ChangePassword extends LightningElement {

    changePassImg = changePassIcon;
    cancelImg = cancelIcon;
    // oldpass;
    newpass;
    verifypass;

    connectedCallback(){
        console.log('connectedcall');
    }

    handleChange(event) {
        console.log({event});
        var nameval = event.target.name;
        console.log({nameval});
        // if (nameval == 'currentPassword') {
        //     this.oldpass = event.target.value;
        // } else 
        if (nameval == 'newPassword') {
            this.newpass = event.target.value;
        } else if (nameval == 'conNewPassword') {
            this.verifypass = event.target.value;
        }
    }

    changepass(){
        
        // console.log('oldpass--->',this.oldpass);
        console.log('newpass--->',this.newpass);
        console.log('verifypass--->',this.verifypass);

        resetpass({ newPassword: 'Mvclouds@1234567',
            usrid: '0050C000005dFPLQA2'
            // oldpassword: this.oldpass
        })   
        .then(result => {
            console.log({result});
        })
        .catch(error => {
            console.log({error});
        });
    }
}