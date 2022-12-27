/*******************************************************
* Name          : Ts_Register
* Author        : RAVI MODI
* Create Date   : 29/06/2022
* UsedBy        : Used in community site components
* Description   : For Register new user in Community Portal

================================================================================
Change No.          Developer Name              Date                Description     
1.                  Mihir                       04/08/2022          team and job title picklist dependent value set

*******************************************************/

import { LightningElement, track, wire } from 'lwc';
import { loadStyle } from 'lightning/platformResourceLoader';
import { getPicklistValues, getObjectInfo } from 'lightning/uiObjectInfoApi';
import commstyle from '@salesforce/resourceUrl/CommunityCSS';
import loginbg from '@salesforce/resourceUrl/loginbg';
import communityicon from '@salesforce/resourceUrl/communityicons';
import Contact from '@salesforce/schema/Contact';
import Roles__c from '@salesforce/schema/Contact.Roles__c';
import Job_Title__c from '@salesforce/schema/Contact.Job_Title__c';
import ts_Excelent from '@salesforce/resourceUrl/test';
import ts_Excelent2 from '@salesforce/resourceUrl/test2';
import basePath from "@salesforce/community/basePath";

import CreateUser from '@salesforce/apex/ts_ProfileModule.createuser';
import getDependentPicklistValues from '@salesforce/apex/ts_ProfileModule.getDependentPicklistValues';
import { NavigationMixin } from 'lightning/navigation';
export default class Ts_Register extends NavigationMixin(LightningElement) {

    bglogo = communityicon + '/communityicons/supplydesk_logo.png';
    fname_icon = communityicon + '/communityicons/firstname.png';
    email_icon = communityicon + '/communityicons/email.png';
    mob_icon = communityicon + '/communityicons/mobileno.png';
    phone_icon = communityicon + '/communityicons/phoneno.png';
    postcode_icon = communityicon + '/communityicons/postcode.png';
    job_icon = communityicon + '/communityicons/jobtitle.png';

    @track jobpicklistflt = [];
    @track teampicklist = [];
    options = [];

    @track teamval;

    contwrap;
    emailerror;
    fnameerror;
    phoneerror;
    postcodeerror;
    mobileerror;
    joberror;
    joboption;
    testimg = ts_Excelent;
    testimg2 = ts_Excelent2;

    // for loading spinner
    @track isSpinner = false;
    // For Reload Page
    @track reloadpage;

    @track controllingValues = [];
    @track dependentValues = [];
    @track selectedCountry;
    @track selectedState;
    @track isEmpty = false;
    @track error;
    controlValues;
    totalDependentValues = [];
    disableIt = true;
    filterUniStaff = [];

    // Get Object Info.
    @wire(getObjectInfo, { objectApiName: Contact })
    conObjectInfo;

    @wire(getPicklistValues, {
        recordTypeId: '$conObjectInfo.data.defaultRecordTypeId',
        fieldApiName: Roles__c
    })
    wiredRatingPicklist({ error, data }) {
        if (data) {
            this.jobpicklist = data;
        } else {
            this.error = error;
        }
    }

    getdependentpicklist() {
        getDependentPicklistValues()
            .then((result) => {
                for (var key in result) {
                    this.filterUniStaff.push(key);
                    this.options = this.filterUniStaff.map((elem) => {
                        const option = {
                            label: elem,
                            value: elem
                        };
                        return option;
                    });
                }
                this.joboption = result;
            })
            .catch((error) => {
                this.reloadpage = true;
                this.template.querySelectorAll('c-ts_-error-component')[0].openModal();
            })
    }

    @wire(getPicklistValues, {
        recordTypeId: '$conObjectInfo.data.defaultRecordTypeId',
        fieldApiName: Job_Title__c
    })
    picklist2({ error, data }) {
        if (data) {
            var dataValuesList = data.values;
            this.teampicklist = this.options;

        } 
    }

    // called when team picklist changed                  // Mihir   04/08/2022
    handleUpsellChange(event) {
        try {
            this.disableIt = false;
            this.teamval = event.target.value;
            let key = this.jobpicklist.controllerValues[event.target.value];
            this.jobpicklistflt = this.joboption[event.target.value];
            var optlst = [];
            var rf = this.joboption[event.target.value];
            rf.forEach(element => {
                var value = element;
                var label = element;
                optlst.push({ value, label });
            })
            this.jobpicklistflt = optlst;
            this.contwrap.Team = event.target.value;
        } catch (error) {
            this.reloadpage = true;
            this.template.querySelectorAll('c-ts_-error-component')[0].openModal();        
        }
    }

    // Called when Page is loaded                                       //RAVI MODI         //01/07/2022
    connectedCallback() {
        try {
            this.isSpinner = true;
            this.getdependentpicklist();
            this.setwraponload();
            var meta = document.createElement("meta");
            meta.setAttribute("name", "viewport");
            meta.setAttribute("content", "width=device-width, initial-scale=1.0");
            document.getElementsByTagName('head')[0].appendChild(meta);
            setTimeout(() => {
                this.isSpinner = false;
            }, 1000);
        } catch (error) {
            this.reloadpage = true;
            this.template.querySelectorAll('c-ts_-error-component')[0].openModal();
        }
    }

    // Get Background Image
    get backgroundImage() {
        return `background-image:url(${loginbg})`;
    }

    // For loading CSS                                       //RAVI MODI         //01/07/2022
    renderedCallback() {

        Promise.all([
            loadStyle(this, commstyle)
            ]).then(() => {
            })
            .catch(error => {
               
            });
    }

    // Handle Change for getting value of Fields            //RAVI MODI           //01/07/2022
    handleChange(event) {
        try {
            var valname = event.target.name;
            if (valname == "FirstName") {
                this.contwrap.FirstName = event.target.value;
            } else if (valname == "LastName") {
                this.contwrap.LastName = event.target.value;
            } else if (valname == "Email") {
                this.contwrap.Email = event.target.value;
            } else if (valname == "Job Title") {
                this.contwrap.Job = event.target.value;
            } else if (valname == "URNCode") {
                this.contwrap.URNCode = event.target.value;
            } else if (valname == "Mobile") {
                this.contwrap.Mobile = event.target.value;
            } else if (valname == "Phone") {
                this.contwrap.Phone = event.target.value;
            } else if (valname == "Team") {
                this.contwrap.Team = event.target.value;
            }
        } catch (error) {
            this.reloadpage = true;
            this.template.querySelectorAll('c-ts_-error-component')[0].openModal();        }
    }

    /***************************************************
     * Author             : sakina
     * Created Date       : 10/08/2022
     * Last Modified Date : 10/08/2022        
     * Description        : Show error message for job title if user try to enter "Job title" field without entering Team field 
     ***************************************************/
    // Register new User                                    //RAVI MODI         //01/07/2022
    register() {

        try {
            var wrapdata = JSON.stringify(this.contwrap);
            var phoneno = /(^\d{9}$|^\d{10}$|^\d{11}$|^\d{12}$)/;

            if (this.contwrap["FirstName"].length == 0) {
                this.fnameerror = "Complete this Field!!!";
                var firstName = this.template.querySelector('.f-name');
                firstName.style.border = '1px solid red';
                this.template.querySelector('c-ts_-tost-notification').showToast('error', 'Complete this Field!!!', 3000);

            } else {
                this.fnameerror = "";
                var firstName = this.template.querySelector('.f-name');
                firstName.style.border = 'none';

            }

            if (this.contwrap["LastName"].length == 0) {
                this.fnameerror = "Complete this Field!!!";
                var lastName = this.template.querySelector('.lname');
                lastName.style.border = '1px solid red';
                this.template.querySelector('c-ts_-tost-notification').showToast('error', 'Complete this Field!!!', 3000);

            } else {
                this.fnameerror = "";
                var lastName = this.template.querySelector('.lname');
                lastName.style.border = 'none';

            }

            var job = this.template.querySelector('.job');
            var team = this.template.querySelector('.team');

            if (this.contwrap["Job"].length == 0) {

                if (this.disableIt == false) {
                    team.style.border = 'none';
                } else {
                    this.joberror = "Complete this Field!!!";
                    job.style.border = '1px solid red';
                    team.style.border = '1px solid red';
                    this.template.querySelector('c-ts_-tost-notification').showToast('error', 'Complete this Field!!!', 3000);
                }

            } else {
                this.joberror = '';
                job.style.border = 'none';
                team.style.border = 'none';

            }
            // Job
            if (this.contwrap["Email"].length == 0) {
                this.emailerror = "Complete this Field!!!"
                var email = this.template.querySelector('.e-mail');
                email.style.border = '1px solid red';
                this.template.querySelector('c-ts_-tost-notification').showToast('error', 'Complete this Field!!!', 3000);

            } else {
                var pattern = /^(([^<>()\[\]\\.,;#:\s@"]+(\.[^<>()\[\]\\.,;:\s@"]+)*)|(".+"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$/;
                var emailpattern = pattern.test(this.contwrap["Email"]);
                if (!emailpattern) {
                    this.emailerror = "Enter Valid Email Address!!!";
                    var email = this.template.querySelector('.e-mail');
                    email.style.border = '1px solid red';
                    this.template.querySelector('c-ts_-tost-notification').showToast('error', 'Enter Valid Email Address!!!', 3000);

                } else {
                    this.emailerror = "";
                    var email = this.template.querySelector('.e-mail');
                    email.style.border = 'none';
                }
            }

            if (this.contwrap["URNCode"].length == 0) {
                this.postcodeerror = "Complete this Field!!!";
                var URNCode = this.template.querySelector('.urnCode');
                URNCode.style.border = '1px solid red';
                this.template.querySelector('c-ts_-tost-notification').showToast('error', 'Complete this Field!!!', 3000);

            } else {
                this.postcodeerror = "";
                var URNCode = this.template.querySelector('.urnCode');
                URNCode.style.border = 'none';
            }


            if (this.contwrap["Phone"].length == 0) {
                this.phoneerror = "Complete this Field!!!";
                var Phone = this.template.querySelector('.Phone');
                Phone.style.border = '1px solid red';
                this.template.querySelector('c-ts_-tost-notification').showToast('error', 'Complete this Field!!!', 3000);

            } else if (!phoneno.test(this.contwrap["Phone"])) {
                if (!phoneno.test(this.contwrap["Phone"]) && !phoneno.test(this.contwrap["Mobile"])) {
                    this.template.querySelector('c-ts_-tost-notification').showToast('error', 'Enter Valid Mobile Number and Phone Number', 3000);
                } else {
                    this.phoneerror = "Enter Valid Phone Number";
                    var Phone = this.template.querySelector('.Phone');
                    Phone.style.border = '1px solid red';
                    this.template.querySelector('c-ts_-tost-notification').showToast('error', 'Enter Valid Phone Number', 3000);
                }

            } else {
                this.phoneerror = "";
                var Phone = this.template.querySelector('.Phone');
                Phone.style.border = 'none';
            }

            if (this.contwrap["Mobile"].length == 0) {
                this.mobileerror = "Complete this Field!!!";
                var mobile = this.template.querySelector('.mobile');
                mobile.style.border = '1px solid red';
                this.template.querySelector('c-ts_-tost-notification').showToast('error', 'Complete this Field!!!', 3000);

            } else if (!phoneno.test(this.contwrap["Mobile"])) {
                if (!phoneno.test(this.contwrap["Phone"]) && !phoneno.test(this.contwrap["Mobile"])) {
                    this.template.querySelector('c-ts_-tost-notification').showToast('error', 'Enter Valid Mobile Number and Phone Number', 3000);
                } else {
                    this.mobileerror = "Enter Valid Mobile Number";
                    var mobile = this.template.querySelector('.mobile');
                    mobile.style.border = '1px solid red';
                    this.template.querySelector('c-ts_-tost-notification').showToast('error', 'Enter Valid Mobile Number', 3000);
                }
            } else {
                this.mobileerror = "";
                var mobile = this.template.querySelector('.mobile');
                mobile.style.border = 'none';

            }
            if (this.postcodeerror.length == 0 && this.fnameerror.length == 0 && this.emailerror.length == 0 && this.phoneerror.length == 0 && this.mobileerror.length == 0 && this.joberror.length == 0) {

                this.isSpinner = true;
                CreateUser({ contwrapdata: wrapdata, email: this.contwrap.Email })
                    .then((result) => {
                        if (result == 'User Created') {
                            this.isSpinner = false;
                            var ele = this.template.querySelectorAll('lightning-input,lightning-combobox,lightning-textarea');
                            for (var i = 0; i < ele.length; i++) {
                                ele[i].value = '';
                            }
                            this.template.querySelector('c-ts_-tost-notification').showToast('success', 'User succesfully created, Please Check Email For Password and login', 5000);
                        } else if (result == 'Invalid PostCode') {
                            this.isSpinner = false;
                            var ele = this.template.querySelectorAll('lightning-input,lightning-combobox,lightning-textarea');
                            for (var i = 0; i < ele.length; i++) {
                                ele[i].value = '';
                            }
                            this.template.querySelector('c-ts_-tost-notification').showToast('error', 'You entered wrong URN please check your mail', 5000);
                        } else if (result == 'Email already Exist') {
                            this.isSpinner = false;
                            this.template.querySelector('c-ts_-tost-notification').showToast('error', 'Email already exist', 3000);
                        } else {
                            this.isSpinner = false;
                            this.reloadpage = true;
                            this.template.querySelectorAll('c-ts_-error-component')[0].openModal();
                        }
                    })
                    .catch((error) => {
                        this.reloadpage = true;
                        this.template.querySelectorAll('c-ts_-error-component')[0].openModal();
                    });
            } 
        } catch (error) {
            this.reloadpage = true;
            this.template.querySelectorAll('c-ts_-error-component')[0].openModal();        }
    }

    setwraponload() {
        this.contwrap = {}
        this.contwrap.FirstName = '';
        this.contwrap.LastName = '';
        this.contwrap.Email = '';
        this.contwrap.Job = '';
        this.contwrap.Postcode = '';
        this.contwrap.URNCode = '';
        this.contwrap.Mobile = '';
        this.contwrap.Phone = '';
        this.contwrap.Team = '';
    }
}