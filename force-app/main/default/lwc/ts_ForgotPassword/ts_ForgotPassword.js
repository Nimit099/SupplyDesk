import { LightningElement, track, wire } from 'lwc';
import { loadStyle } from 'lightning/platformResourceLoader';
import commstyle from '@salesforce/resourceUrl/CommunityCSS';
import uname_img from '@salesforce/resourceUrl/usernameimg';
import sd_logo from '@salesforce/resourceUrl/SD_Logo';
import { getRecord } from 'lightning/uiRecordApi';
import NAME_FIELD from '@salesforce/schema/User.Name';
import USER_ID from '@salesforce/user/Id';
import forgotpassword from '@salesforce/apex/ts_ProfileModule.forgotSitePassword';

export default class Ts_ForgotPassword extends LightningElement {

    bglogo = sd_logo;
    userimg = uname_img;
    username;
    errormsg;

    usrname = NAME_FIELD;
    usrid = USER_ID;

    renderedCallback() {
        Promise.all([
                loadStyle(this, commstyle)
            ]).then(() => {
                console.log('Files loaded');
            })
            .catch(error => {
                console.log(error.body.message);
            });
    }

    connectedCallback() {
        console.log('Forgot Connected Callback');
        console.log('usrname->', this.usrname);
        console.log('usrid->', this.usrid);
    }

    handleChange(event) {
        console.log({ event });
        this.username = event.target.value;
        console.log(this.username);
    }

    forgotpass() {
        console.log('forgotpass');
        console.log('username-->', this.username);

        forgotpassword({
                usernameval: this.username
            })
            .then((result) => {
                console.log({ result });
                if (result == 'true') {
                    window.location.replace('/s/');
                } else {
                    console.log('else');
                    this.errormsg = result;
                }
            })
            .catch((error) => {
                console.log(error);
            });
    }
}