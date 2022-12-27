/***************************************************
 * Author             : Mihir
 * Created Date       : 28/06/2022
 * Last Modified Date : 29/07/2022
 * Description        : Help page
 ***************************************************/
import { LightningElement, api, wire, track } from 'lwc';
import sendEmailToController from '@salesforce/apex/ts_ProfileModule.sendEmailToController';
import sd_logo from '@salesforce/resourceUrl/SD_Logo';
import communityicon from '@salesforce/resourceUrl/communityicons';                             //For Community Images
import getData from '@salesforce/apex/ts_ProfileModule.getData';
export default class Ts_ContactUs extends LightningElement {

    bglogo = sd_logo;
    Name = "";
    Subject = "";
    Email = "";
    Body = "";
    send_icon = communityicon + '/communityicons/send.png';
    location_icon = communityicon + '/communityicons/location.png';
    contactus_icon = communityicon + '/communityicons/contactus.png';
    redmail_icon = communityicon + '/communityicons/redmail.png';
    sdlogo_icon = communityicon + '/communityicons/supplydesk_logo.png';

    // for loading spinner
    @track isSpinner = false;
    // For Reload Page
    @track reloadpage;
    @track fullName;

    connectedCallback() {
        try {
            this.isSpinner = true;
            var meta = document.createElement("meta");
            meta.setAttribute("name", "viewport");
            meta.setAttribute("content", "width=device-width, initial-scale=1.0");
            document.getElementsByTagName('head')[0].appendChild(meta);

            getData()

            .then(result => {
                if (result == null) {
                    this.template.querySelector('c-ts_-tost-notification').showToast('error', 'Something Went Wrong', 3000);
                } else {
                    this.fullName = result.con.FirstName + '  ' + result.con.LastName;
                }
            })
            setTimeout(() => {
                this.isSpinner = false;
            }, 1000);
        } catch (error) {
        }
    }

    /***************************************************
     * Author             : Mihir , Sakina(add Toast messages)
     * Created Date       : 28/06/2022
     * Last Modified Date : 17th August 2022
     * Description        : Email send when clicked send button
     ***************************************************/

    handleSendClick(event) {
        try {
            var inp = this.template.querySelectorAll("lightning-input");

            inp.forEach(function(element) {
                if (element.name == "user_name") {
                    this.Name = element.value;
                } else if (element.name == "subject") {
                    this.Subject = element.value;
                }
            }, this);

            var Email = this.template.querySelectorAll("select");
            this.Email = Email[0].value;

            var message = this.template.querySelectorAll("lightning-textarea");
            this.Body = message[0].value;

            this.isSpinner = true;

            const recordInput = { Name: this.Name, Subject: this.Subject, Email: this.Email, Body: this.Body }
            if (recordInput.Body == undefined && recordInput.Name == '') {
                this.isSpinner = false;
                this.template.querySelector('c-ts_-tost-notification').showToast('error', 'Please Enter Name and  Message  ', 3000);

            } else if (recordInput.Body == '' && recordInput.Name == '') {
                this.isSpinner = false;
                this.template.querySelector('c-ts_-tost-notification').showToast('error', 'Please Enter Name and  Message ', 3000);

            } else if (recordInput.Body == undefined || recordInput.Body == '') {
                this.isSpinner = false;
                this.template.querySelector('c-ts_-tost-notification').showToast('error', 'Please Enter  Message  ', 3000);

            } else if (recordInput.Name == '') {
                this.isSpinner = false;
                this.template.querySelector('c-ts_-tost-notification').showToast('error', 'Please Enter  Name  ', 3000);

            } else {
                sendEmailToController(recordInput)
                    .then((result) => {
                        this.isSpinner = false;
                        this.template.querySelector('c-ts_-tost-notification').showToast('success', 'Your message is Send Successfully  ', 3000);

                    }).catch(error => {
                        this.reloadpage = true;
                        this.isSpinner = false;
                        this.template.querySelectorAll('c-ts_-error-component')[0].openModal();
                    })
            }
        } catch (error) {
            this.reloadpage = true;
            this.template.querySelectorAll('c-ts_-error-component')[0].openModal();
        }
    }

    /***************************************************
     * Author             : Mihir
     * Created Date       : 28/07/2022
     * Last Modified Date : 28/07/2022
     * Description        : menubar closing event
     ***************************************************/

    check(event) {
        this.dispatchEvent(new CustomEvent('getmenu', { bubbles: true, detail: "profile" }));
    }
}