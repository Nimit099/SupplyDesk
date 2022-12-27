/*******************************************************
 * Name          : ts_ForgotPasswordPage
 * Author        : Krunal
 * Create Date   : 08/08/2022
 * Description   : Used in ts_ForgotPasswordPage Component in community site for forgot password
 *******************************************************/
import { LightningElement, track, wire } from 'lwc';
import forgotSitePassword from '@salesforce/apex/ts_ProfileModule.forgotSitePassword';
import loginbg from '@salesforce/resourceUrl/loginbg';
import communityicon from '@salesforce/resourceUrl/communityicons';

export default class Ts_ForgotPasswordPage extends LightningElement {

    bglogo = communityicon + '/communityicons/supplydesk_logo.png';
    emaillogo = communityicon + '/communityicons/email.png';
    @track UserId;
    @track isSpinner;

    handleChange(event) {
        this.UserId = event.target.value;
    }

    // Get Background Image
    get backgroundImage() {
        return `background-image:url(${loginbg})`;
    }


    /***************************************************
     * Author             : Krunal, sakina
     * Created Date       : 08/08/2022
     * Last Modified Date : 08/08/2022        
     * Description        : use for forgot password
     ***************************************************/
    resetPass(event) {
        try {
            this.isSpinner = true;
            const emailRegex = /^(([^<>()\[\]\\.,;:\s@"]+(\.[^<>()\[\]\\.,;:\s@"]+)*)|(".+"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$/;
            let email = this.template.querySelector(".fpinput_cls");
            let emailVal = email.value;
            if (this.UserId != undefined && this.UserId != '') {

                if (emailVal.match(emailRegex)) {

                    // var errorMsg = this.template.querySelector('.fperrorMsg');
                    // errorMsg.style.display = 'none';
                    forgotSitePassword({ UsrId: this.UserId })
                        .then((result) => {
                            console.log({ result });
                            this.isSpinner = false;
                            if (result[0] == 'Success') {
                                var errorMsg = this.template.querySelector('.fpinput-field');
                                errorMsg.style.border = 'none';
                                this.template.querySelector('c-ts_-tost-notification').showToast('success', 'Password Reset Link Sent To Your Mail', 3000);
                                var formContainer = this.template.querySelector('.forms-fpcontainer');
                                formContainer.style.display = 'none';
                                var confirmContainer = this.template.querySelector('.confirm-fpcontainer');
                                confirmContainer.style.display = 'block';
                            } else if (result[0] == 'Error') {
                                var errorMsg = this.template.querySelector('.fpinput-field');
                                errorMsg.style.border = '1px solid red';
                                // this.template.querySelector('c-ts_-tost-notification').showToast('error', result[1], 3000);
                                this.template.querySelector('c-ts_-tost-notification').showToast('error', 'Username is not exist', 3000);



                            }
                        })
                        .catch(error => {
                            console.log({ error });
                            this.template.querySelector('c-ts_-tost-notification').showToast('error', 'Something Went Wrong', 3000);
                            this.isSpinner = false;
                        });
                } else {
                    var errorMsg = this.template.querySelector('.fpinput-field');
                    errorMsg.style.border = '1px solid red';
                    this.template.querySelector('c-ts_-tost-notification').showToast('error', 'Please enter valid Username', 3000);
                    this.isSpinner = false;
                }
                // email.reportValidity();
            } else {
                var errorMsg = this.template.querySelector('.fpinput-field');
                errorMsg.style.border = '1px solid red';
                this.template.querySelector('c-ts_-tost-notification').showToast('error', 'Please Enter Username', 3000);
                this.isSpinner = false;
            }






        } catch (error) {
            console.log({ error });
            this.template.querySelector('c-ts_-tost-notification').showToast('error', 'Something Went Wrong', 3000);
            this.isSpinner = false;
        }
    }
}