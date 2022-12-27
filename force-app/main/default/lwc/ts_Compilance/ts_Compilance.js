/*******************************************************
* Name          : ts_Compilance
* Author        : RAVI MODI
* Create Date   : 01/07/2022
* UsedBy        : Used in community site components
* Description   : For Compliance Page

================================================================================
Change No.          Developer Name              Date                Description     
1.                  Nitin                       23-08-2022          Method (getcrvalue) : Formated Date Field from YYYY-MM-DD to DD-MM-YYYY in ID Checked, Barred List and DBS Valid Date.

*******************************************************/

import { LightningElement, wire, track } from 'lwc';
import { NavigationMixin } from 'lightning/navigation';
import USER_ID from '@salesforce/user/Id';
import communityicon from '@salesforce/resourceUrl/communityicons';
import getcrdata from '@salesforce/apex/ts_ProfileModule.getcrdata';
import downloadpdf from '@salesforce/apex/ts_ProfileModule.downloadpdf';
import fetchContact from '@salesforce/apex/ts_ProfileModule.fetchContact';

export default class Ts_Compilance extends NavigationMixin(LightningElement) {

    @track checkClient;
    idCheck = false;
    crId;
    crlist;
    usrId = USER_ID;
    cvrImg = communityicon + '/communityicons/compliance_image.png';
    nodata = communityicon + '/communityicons/nodata.png';
    @track nodatafound = false; // For No Record Found
    @track reloadpage; // For Reload Page
    @track isSpinner = false;


    /***************************************************
     * Author             : RAVI MODI
     * Created Date       : 29/07/2022
     * Last Modified Date : 29/07/2022
     * Description        : Get Background Image
     ***************************************************/
    get backgroundImage() {
        return `background-image:url(${this.cvrImg})`;
    }

    /***************************************************
     * Author             : RAVI MODI
     * Created Date       : 29/07/2022
     * Last Modified Date : 29/07/2022
     * Description        : Get Background Image When No data found
     ***************************************************/
    get nodatafoundimg() {
        return `background-image:url(${this.nodata})`;
    }

    /***************************************************
     * Author             : RAVI MODI
     * Created Date       : 29/07/2022
     * Last Modified Date : 29/07/2022
     * Description        : Connected Call back
     ***************************************************/
    connectedCallback() {
        try {
            fetchContact()
                .then(result => {
                    if (result != null) {
                        if (result.Community_Contact_Type__c == 'Client') {
                            this.getcrvalue();
                            this.checkClient = true;
                        } else {
                            var url = window.location.origin;
                            url = url + '/s/error';
                            window.open(url, '_self');
                            this.checkClient = false;
                        }
                        this.isSpinner = false;

                    }
                })
                .catch(error => {
                });
        } catch (error) {
            this.reloadpage = true;
            this.template.querySelectorAll('c-ts_-error-component')[0].openModal();
        }

    }

    /***************************************************
     * Author             : RAVI MODI
     * Created Date       : 29/07/2022
     * Last Modified Date : 29/07/2022
     * Description        : Get Closing Report Value
     ***************************************************/
    getcrvalue() {
        try {
            this.isSpinner = true;
            getcrdata({ userid: this.usrId })
                .then((result) => {
                    this.crlist = result;

                    if (this.crlist.length == 0) {
                        this.nodatafound = true;
                        this.isSpinner = false;

                    } else {
                        this.nodatafound = false;
                        this.isSpinner = false;


                        this.crlist.forEach(item => {
                            let text = '';
                            if (item.hasOwnProperty('TR1__Person_Placed__r') == true) {
                                text = item.TR1__Person_Placed__r.Qualification_Verified_Hidden__c;
                            }
                            let qualificationValue = '';
                            if (text != null && text != undefined && text != '') {
                                qualificationValue = text.toLowerCase();
                            }
                            if (qualificationValue == 'yes') {
                                this.idCheck = true;
                                item["qualificationVerified"] = true;
                            } else {
                                this.idCheck = false;
                                item["qualificationVerified"] = false;
                            }

                            if (item.hasOwnProperty('TR1__Person_Placed__r') == true) {
                                if (item.TR1__Person_Placed__r.SET_Checked_Date_Hidden__c != null) {
                                    item.TR1__Person_Placed__r.SET_Checked_Date_Hidden__c = item.TR1__Person_Placed__r.SET_Checked_Date_Hidden__c.split("-").reverse().join("-");
                                }
                                if (item.TR1__Person_Placed__r.Barred_List_Date_Checked_Hidden__c != null) {
                                    item.TR1__Person_Placed__r.Barred_List_Date_Checked_Hidden__c = item.TR1__Person_Placed__r.Barred_List_Date_Checked_Hidden__c.split("-").reverse().join("-");
                                }
                                if (item.TR1__Person_Placed__r.DBS_Issue_Date_Hidden__c != null) {
                                    item.TR1__Person_Placed__r.DBS_Issue_Date_Hidden__c = item.TR1__Person_Placed__r.DBS_Issue_Date_Hidden__c.split("-").reverse().join("-");
                                }
                            }
                        });
                    }
                })
                .catch(error => {
                    this.reloadpage = true;
                    this.template.querySelectorAll('c-ts_-error-component')[0].openModal();
                    this.isSpinner = false;
                })
        } catch (error) {
            this.reloadpage = true;
            this.template.querySelectorAll('c-ts_-error-component')[0].openModal();
        }


    }

    /***************************************************
     * Author             : RAVI MODI
     * Created Date       : 29/07/2022
     * Last Modified Date : 29/07/2022
     * Description        : Open PDF of Compliance
     ***************************************************/
    openpdf(event) {

        try {

            var crval = event.target.dataset.value;
            const ua = navigator.userAgent;
            var device;
            if (/(tablet|ipad|playbook|silk)|(android(?!.*mobi))/i.test(ua)) {
                device = 'tablet';
            } else if (/Mobile|Android|iP(hone|od)|IEMobile|BlackBerry|Kindle|Silk-Accelerated|(hpw|web)OS|Opera M(obi|ini)/.test(ua)) {
                device = 'mobile';
            } else {
                device = 'windows';
            }

            if (device != 'windows') {
                this.isSpinner = true;
                downloadpdf({ recordid: crval })
                    .then((result) => {
                        var strFile = result;
                        const reader = new FileReader();

                        const link = document.createElement('a');
                        link.href = 'data:application/octet-stream;base64,' + strFile;
                        link.download = 'fileName.pdf';
                        link.click();
                        this.isSpinner = false;
                    })
                    .catch(error => {
                        this.reloadpage = true;
                        this.template.querySelectorAll('c-ts_-error-component')[0].openModal();
                        this.isSpinner = false;
                    })
            } else {
                if (crval != null || crval != '' || crval != undefined) {
                    this[NavigationMixin.Navigate]({
                        type: 'comm__namedPage',
                        attributes: {
                            name: 'CompliancePDF__c',
                            url: '/s/compliance/compliancepdf',
                        },
                        state: {
                            recordId: crval
                        }
                    });
                }
            }

        } catch (error) {
            this.reloadpage = true;
            this.template.querySelectorAll('c-ts_-error-component')[0].openModal();
        }
    }

    check(event) {
        this.dispatchEvent(new CustomEvent('getmenu', { bubbles: true, detail: "profile" }));
    }
}