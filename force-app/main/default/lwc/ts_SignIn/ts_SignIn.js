/*
 * Author :  RAVI MODI
 * Company :  MV Clouds Private Limited
 * Description : Community Login Page
 */

import { LightningElement, wire, track } from 'lwc';
import { loadStyle } from 'lightning/platformResourceLoader';
import { NavigationMixin } from 'lightning/navigation';
import commstyle from '@salesforce/resourceUrl/CommunityCSS';
import doLogin from '@salesforce/apex/ts_ProfileModule.doLogin';
import isguest from '@salesforce/user/isGuest';
import loginbg from '@salesforce/resourceUrl/loginbg';
import communityicon from '@salesforce/resourceUrl/communityicons';
export default class Ts_SignIn extends NavigationMixin(LightningElement) {

    passwordimg = communityicon + '/communityicons/password.png';
    bglogo = communityicon + '/communityicons/supplydesk_logo.png';
    userimg = communityicon + '/communityicons/username.png';
    @track isSpinner = false; // for loading spinner 
    @track iconName;
    username;
    password;

    isguestuser = isguest; //For Checking is user is logged out or not

    // For Reload Page
    @track reloadpage;

    connectedCallback() {

        try {
            this.isSpinner = true;
            if (!this.isguestuser) {
                this[NavigationMixin.Navigate]({
                    type: 'comm__loginPage',
                    attributes: {
                        actionName: 'logout'
                    },
                });
            }
            setTimeout(() => {
                this.isSpinner = false;
            }, 2000);
        } catch (error) {
            this.isSpinner = false;
            this.reloadpage = true;
            this.template.querySelectorAll('c-ts_-error-component')[0].openModal();
        }
    }

    // Get Background Image
    get backgroundImage() {
        return `background-image:url(${loginbg})`;
    }

    renderedCallback() {

        Promise.all([
                loadStyle(this, commstyle)
            ]).then(() => {
            })
            .catch(error => {
                this.reloadpage = true;
                this.template.querySelectorAll('c-ts_-error-component')[0].openModal();
            });
    }

    // sakina
    enterPassword() {
        try {
            var inp = this.template.querySelectorAll("lightning-input");
            inp.forEach(function(element) {
                if (element.name == "password") {
                    this.password = element.value;
                }
            }, this);
        } catch (error) {
            this.reloadpage = true;
            this.template.querySelectorAll('c-ts_-error-component')[0].openModal();
        }
    }
    showPassword(event) {
            try {
                    var inp = this.template.querySelectorAll("lightning-input");
                    inp.forEach(function(element) {
                        if (element.name == "password") {
                            const type = element.type
                            if (type == 'password') {
                                element.type = 'text';
                                event.target.iconName = 'utility:preview';
                            } else {
                                element.type = 'password';
                                event.target.iconName = 'utility:hide';
                            }
                        }

                    }, this);
            } catch (error) {
                this.reloadpage = true;
                this.template.querySelectorAll('c-ts_-error-component')[0].openModal();           
            }
    }
        // ]
    login() {

        try {
            var inp = this.template.querySelectorAll("lightning-input");
            inp.forEach(function(element) {
                if (element.name == "username") {
                    this.username = element.value;
                } else if (element.name == "password") {
                    this.password = element.value;
                }
            }, this);

            if (this.username == "" || this.username.length == 0) {
                this.template.querySelector('c-ts_-tost-notification').showToast('error', 'Complete this Field', 3000);
            } else if (this.password == "" || this.password.length == 0) {
                this.template.querySelector('c-ts_-tost-notification').showToast('error', 'Complete this Field', 3000);
            } else if (this.username.length > 0) {
                this.loginerror = "";
                doLogin({
                        username: this.username,
                        password: this.password
                    })
                    .then((result) => {
                        if (result.startsWith('http')) {
                            window.location.href = result;
                        } else {
                            this.template.querySelector('c-ts_-tost-notification').showToast('error', 'Username or password not matched', 3000);
                        }
                    })
                    .catch((error) => {
                        this.reloadpage = true;
                        this.template.querySelectorAll('c-ts_-error-component')[0].openModal();
                    });
            }
        } catch (error) {
            this.reloadpage = true;
            this.template.querySelectorAll('c-ts_-error-component')[0].openModal();        
        }
    }
}