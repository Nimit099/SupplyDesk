/*******************************************************
* Name          : ts_MyQualifications
* Author        : Karan
* Create Date   : 29/07/2022
* Description   : Used in ts_MyQualifications Component in community site
*******************************************************/
import { LightningElement, track, wire } from 'lwc';
import communityicon from '@salesforce/resourceUrl/communityicons';
import getQualification from '@salesforce/apex/ts_ProfileModule.getQualification';
import fetchContact from '@salesforce/apex/ts_ProfileModule.fetchContact';
import { NavigationMixin } from 'lightning/navigation';
export default class Ts_MyQualifications extends NavigationMixin(LightningElement) {

    editImg = communityicon + '/communityicons/edit.png';
    @track qualificationList;
    @track checkClient;
    @track showEdit;
    @track reloadpage;

    qualification_lst = ["CV", "Emergency Contact", "Photo", "References", "Overseas Police Check"];
    qualificationDropdown_lst = ["Early Years Qualifications", "Support Qualifications", "Teacher Qualification", "Post 16 Qualifications", "Overseas Teacher Qualifications"];

    /***************************************************
    * Author             : Karan
    * Created Date       : 29/07/2022
    * Last Modified Date : 29/07/2022
    * Description        : used for getting contact type of login user .
    ***************************************************/
    connectedCallback() {
        try {
            fetchContact()
                .then(result => {
                    if (result != null) {
                        if (result.Community_Contact_Type__c == 'Client') {
                            this.checkClient = false;
                            var url = window.location.origin;
                            url = url + '/s/error';
                            window.open(url, '_self');
                        } else {
                            this.getQualify();
                            this.checkClient = true;
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
    * Author             : Karan
    * Created Date       : 29/07/2022
    * Last Modified Date : 04/08/2022   // Mihir
    * Description        : for get qualification list for user.
    * Last Modified      : only given qualificatio shown 
    ***************************************************/
    getQualify() {
        try {
            getQualification()
                .then(result => {
                    var qlst = [];
                    for (var i = 0; i < result.length; i++) {
                        if (result[i].TR1__Status__c == 'Requested') {

                            result[i]["Status"] = true;
                        } else {

                            result[i]["Status"] = false;
                        }
                        if (this.qualification_lst.includes(result[i].TR1__Qualification__r.Name)) {
                            qlst.push(result[i]);
                        }
                    }
                    this.qualificationList = qlst;
                })
                .catch(error => {
                });
        } catch (error) {
            this.reloadpage = true;
            this.template.querySelectorAll('c-ts_-error-component')[0].openModal();
        }
    }

    /***************************************************
    * Author             : Karan
    * Created Date       : 29/07/2022
    * Last Modified Date : 29/07/2022 
    * Description        : Run method after click on qualification edit button and call qualification detail component.
    ***************************************************/
    editQualification(event) {
        try {
            let m = event.currentTarget.dataset.id;

            this[NavigationMixin.Navigate]({
                type: 'comm__namedPage',
                attributes: {
                    name: 'QualificationDetail__c',
                    url: '/s/qualificationdetail'
                },
                state: {
                    qualification: m
                }
            }, true);
        } catch (error) {
            this.reloadpage = true;
            this.template.querySelectorAll('c-ts_-error-component')[0].openModal();
        }
    }

    // 
    check(event) {
        this.dispatchEvent(new CustomEvent('getmenu', { bubbles: true, detail: "profile" }));
    }
}