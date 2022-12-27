/*******************************************************
 * Name          : ts_ChangePassword
 * Author        : Karan
 * Create Date   : 26/07/2022
 * Description   : Used in ts_ProfilePage Component in community site
 *******************************************************/
import { LightningElement, track, wire } from 'lwc';
import communityicon from '@salesforce/resourceUrl/communityicons';
import changepassword from '@salesforce/apex/ts_ProfileModule.changepass';

export default class Ts_ChangePassword extends LightningElement {

    changePassImg = communityicon + '/communityicons/changePassIcon.png';;
    cancelImg = communityicon + '/communityicons/cancel.png';
    oldpass;
    newpass;
    verifypass;
    @track reloadpage;

    connectedCallback() {
        console.log('connectedcall');
    }

    /***************************************************
     * Author             : Karan
     * Created Date       : 26/07/2022
     * Last Modified Date : 26/07/2022
     * Description        : store data in js from input fields
     ***************************************************/
    handleChange(event) {
        try {
            console.log({ event });
            var nameval = event.target.name;
            console.log({ nameval });
            if (nameval == 'currentPassword') {
                this.oldpass = event.target.value;
            } else if (nameval == 'newPassword') {
                this.newpass = event.target.value;
            } else if (nameval == 'conNewPassword') {
                this.verifypass = event.target.value;
            }
        } catch (error) {
            console.log({ error });
            this.reloadpage = true;
            this.template.querySelectorAll('c-ts_-error-component')[0].openModal();
        }
    }

    /***************************************************
     * Author             : Karan
     * Created Date       : 26/07/2022
     * Last Modified Date : 26/07/2022
     * Description        : run method after click on update password button
     ***************************************************/
    changepass() {
        try {
            console.log('changepass');
            console.log('oldpass--->', this.oldpass);
            console.log('newpass--->', this.newpass);
            console.log('verifypass--->', this.verifypass);

            if (this.oldpass == undefined || this.newpass == undefined || this.verifypass == undefined) {
                this.template.querySelector('c-ts_-tost-notification').showToast('error', 'Please Enter Password', 3000);
            } else if (this.oldpass.length == 0 || this.newpass.length == 0 || this.verifypass.length == 0) {
                this.template.querySelector('c-ts_-tost-notification').showToast('error', 'Please Enter Password', 3000);
            } else {
                console.log("else");
                if (this.newpass != this.verifypass) {
                    this.template.querySelector('c-ts_-tost-notification').showToast('error', 'Your new passwords do not match.', 3000);
                } else if (this.newpass == this.oldpass) {
                    this.template.querySelector('c-ts_-tost-notification').showToast('error', 'You cannot reuse this old Password.', 3000);
                } else {
                    changepassword({
                            newPassword: this.newpass,
                            verifyNewPassword: this.verifypass,
                            oldpassword: this.oldpass
                        })
                        .then(result => {
                            console.log({ result });
                            if (result == "/MyAccount") {
                                this.template.querySelector('c-ts_-tost-notification').showToast('success', 'Your Password Successfuly Changed.', 3000);
                                this.oldpass = "";
                                this.newpass = "";
                                this.verifypass = "";
                            } else {
                                if (result.substring(0, 7) == 'Error: ') {
                                    this.template.querySelector('c-ts_-tost-notification').showToast('error', result.substring(7, result.length), 3000);
                                } else {
                                    this.template.querySelector('c-ts_-tost-notification').showToast('error', result, 3000);
                                }
                            }
                        })
                        .catch(error => {
                            console.log({ error });
                            this.template.querySelector('c-ts_-tost-notification').showToast('error', 'Something Went Wrong', 3000);
                        });
                }
            }
        } catch (error) {
            console.log({ error });
            this.reloadpage = true;
            this.template.querySelectorAll('c-ts_-error-component')[0].openModal();
        }
    }

    /***************************************************
     * Author             : Karan
     * Created Date       : 26/07/2022
     * Last Modified Date : 26/07/2022
     * Description        : run method after click on cancel password button
     ***************************************************/
    cancelPass() {
        try {
            console.log('cancelPass');
            this.oldpass = '';
            this.newpass = '';
            this.verifypass = '';
        } catch (error) {
            console.log({ error });
            this.reloadpage = true;
            this.template.querySelectorAll('c-ts_-error-component')[0].openModal();
        }
    }
}