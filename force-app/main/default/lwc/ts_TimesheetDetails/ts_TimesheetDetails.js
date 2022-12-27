/*******************************************************
 * Name          : ts_TimesheetDetails
 * Author        : Nitin
 * Create Date   : 29/07/2022
 * Description   : Used in ts_TimesheetDetails Component in community site
 *******************************************************/
import { LightningElement, track, wire } from 'lwc';

import approveRejectTimeSheet from "@salesforce/apex/ts_TimesheetController.approveRejectTimeSheet";
import getTimesheetDetails from "@salesforce/apex/ts_TimesheetController.getTimesheetDetails";
import sendMessageToJobOwner from "@salesforce/apex/ts_TimesheetController.sendMessageToJobOwner";
import fetchContact from "@salesforce/apex/ts_TimesheetController.fetchContact";


import ts_Excelent from '@salesforce/resourceUrl/ts_Excelent';
import ts_VeryGood from '@salesforce/resourceUrl/ts_VeryGood';
import ts_Good from '@salesforce/resourceUrl/ts_Good';
import ts_RequireImprovments from '@salesforce/resourceUrl/ts_RequireImprovments';
import ts_Unsetisfy from '@salesforce/resourceUrl/ts_Unsetisfy';

import { getRecord } from 'lightning/uiRecordApi';
import USER_ID from '@salesforce/user/Id';
import NAME_FIELD from '@salesforce/schema/User.Name';
import IMG_URL from '@salesforce/schema/User.FullPhotoUrl';
import communityicon from '@salesforce/resourceUrl/communityicons';
import { NavigationMixin } from 'lightning/navigation';
import getAllTimesheet from "@salesforce/apex/ts_TimesheetController.getAllTimesheet";

// import custom label
import feedbackTitle from '@salesforce/label/c.Give_Feedback_Text';
import rejectionTitle from '@salesforce/label/c.Give_Feedback_For_Candidate';




export default class Ts_TimesheetDetails extends NavigationMixin(LightningElement) {
    rejectBtnIcon = communityicon + '/communityicons/cancel.png';
    approveBtnIcon = communityicon + '/communityicons/ts_approve_btn.png';
    popupCloseBtnIcon = communityicon + '/communityicons/close.png';
    popupSendBtnIcon = communityicon + '/communityicons/ts_send_btn.png';
    message = communityicon + '/communityicons/message.png';

    excelentEmg = ts_Excelent;
    VeryGoodEmg = ts_VeryGood;
    goodEmg = ts_Good;
    requireImprovmentsEmg = ts_RequireImprovments;
    unsetisfyEmg = ts_Unsetisfy;
    timesheetId;

    @track loginUserId; // Loged In user Id
    @track userName; // Loged In user Name
    @track profImgUrl; // Loged in user profile Image URL

    @track isSpinner = false; // for loading spinner
    @track isClientRejectedModalOpen = false; // Used IN popup Modal when Reject button Clicked.
    @track isClientApproveModalOpen = false; // Used IN popup Modal when Approve button Clicked.
    @track isSendMessageModalOpen = false; // Used IN popup Modal when send message button Clicked.
    @track tsObj = []; // Storing Timesheet Object From Wrapper class that return from apex class.
    @track tsdLst = []; // Storing TimesheetDetails Object List From Wrapper class that return from apex class.
    @track vacancyName; // Used for displaying vacancy Name.
    @track weekEndingDate = ''; // Used for week Ending date in dd-mm-yyyy formate.
    @track rejectionNotes = ''; // Approver Notes For Rejection of time sheet.
    @track approveNotes = ''; // Approver Notes For Approving of time sheet.
    @track messageToJobOwner = ''; // Message For Job Owner when send message Clicked.
    @track selectedRetting = ''; // Rating Value that selected in Approve Modal as par object field.
    @track ratingValue = ''; // Rating Value that selected in Approve Modal as par label.
    @track requesteQualityCall = false; // Request Quality Call Value that selected in Approve Modal.
    @track isUserClient; // This variable shows that user is Client or Candidate.
    @track reloadpage; // Use for reload component
    @track ClientApproveModal = true; // check feedback model is previous open or not
    @track status // show approved status of user
    text_area_required = false;
    @track ShowSection = true; // text field required or not in feedback popup modal
    @track feedbackHeading = feedbackTitle;
    @track feedbackCandidateHeading = rejectionTitle;


    /***************************************************
     * Author             : Nitin
     * Created Date       : 29/07/2022
     * Last Modified Date : 29/07/2022
     * Description        : geting user Name and profile Image for displaying.
     ***************************************************/
    @wire(getRecord, {
        recordId: USER_ID,
        fields: [NAME_FIELD, IMG_URL]
    }) wireuser({
        error,
        data
    }) {
        if (error) {
            this.error = error;
        } else if (data) {
            this.userName = data.fields.Name.value;
            console.log('this.uName-->', this.userName);
            this.profImgUrl = data.fields.FullPhotoUrl.value;
            console.log('this.profImgUrl-->', this.profImgUrl);
        }
    }


    /***************************************************
     * Author             : Nitin
     * Created Date       : 29/07/2022
     * Last Modified Date : 29/07/2022
     * Description        : This method runs when component loads
     ***************************************************/
    connectedCallback() {
        try {
            this.isSpinner = true;
            const queryString = window.location.search;
            const urlParams = new URLSearchParams(queryString);
            this.timesheetId = urlParams.get('id');
            // fetchContact()
            //     .then(result => {
            //         if (result != null) {
            //             console.log({ result });
            //             if (result.Community_Contact_Type__c == 'Client') {
            //                 this.ShowSection = false;
            //                 this.checkClient = false;

            //             } else {
            //                 this.checkClient = true;
            //             }
            //             this.isSpinner = false;

            //         } else {
            //             console.log('Contact null');
            //             console.log({ result });
            //         }
            //     })
            //     .catch(error => {
            //         console.log({ error });
            //     });

            getTimesheetDetails({ timesheetId: this.timesheetId })

                .then((result) => {
                    console.log(result.timesheet);
                    console.log('____________________________');
                    console.log({ result });
                    this.tsObj = result.timesheet;
                    this.vacancyName = result.timesheet.TR1__Job_Order__r.TR1__Job_Title__c;
                    this.tsdLst = result.timesheetDetailsList;
                    this.isUserClient = result.isClient;
                    this.status = result.timesheet.TR1__Status__c;

                    // For adding pound sign before Rates when Rates are not null 
                    if (result.timesheet.Charge_Rate_1__c != null) {
                        result.timesheet.Charge_Rate_1__c = '£' + result.timesheet.Charge_Rate_1__c;
                    }
                    if (result.timesheet.Charge_Rate_2__c != null) {
                        result.timesheet.Charge_Rate_2__c = '£' + result.timesheet.Charge_Rate_2__c;
                    }
                    if (result.timesheet.Charge_Rate_3__c != null) {
                        result.timesheet.Charge_Rate_3__c = '£' + result.timesheet.Charge_Rate_3__c;
                    }
                    if (result.timesheet.Total_Reported_Charge__c != null) {
                        result.timesheet.Total_Reported_Charge__c = '£' + result.timesheet.Total_Reported_Charge__c;
                    }
                    if (result.timesheet.Total_Reported_Pay__c != null) {
                        result.timesheet.Total_Reported_Pay__c = '£' + result.timesheet.Total_Reported_Pay__c;
                    }

                    // for Convering Week Ending date Formate YYYY-MM-DD to DD-MM-YYYY
                    if (result.timesheet.TR1__Week_Ending__c != null) {
                        this.weekEndingDate = result.timesheet.TR1__Week_Ending__c.split("-").reverse().join("-");
                    }
                    // for Convering timesheet details table date Formate YYYY-MM-DD to DD-MM-YYYY
                    result.timesheetDetailsList.forEach(element => {
                        if (element.TR1__Date__c != null) {
                            element.TR1__Date__c = element.TR1__Date__c.split("-").reverse().join("-");
                        }
                    });
                    // this.dayCharge=;
                    // this.halfDayCharge;
                    // this.hourCharge;
                    console.log("connected CallBack from this tsObj ==>", this.tsObj);
                    console.log("connected CallBack from this tsdLst ==>", this.tsdLst);
                    console.log("connected CallBack from this isUserClient ==>", this.isUserClient);
                    this.isSpinner = false;
                })
                .catch((error) => {
                    this.isSpinner = false;
                    console.log({ error });
                    console.log('-------------------------');
                });
            this.allTimeSheet();
        } catch (error) {
            console.log({ error });
            this.reloadpage = true;
            this.template.querySelectorAll('c-ts_-error-component')[0].openModal();
        }
    }


    /***************************************************
     * Author             : Krunal
     * Created Date       : 29/07/2022
     * Last Modified Date : 29/07/2022
     * Description        : get all timesheet data for show feedback box.
     ***************************************************/
    allTimeSheet() {
        try {
            console.log('allTimeSheet');
            getAllTimesheet()
                .then((result) => {
                    console.log({ result });
                    if (this.isUserClient == false) {
                        result.forEach(element => {
                            if (element.Feedback_Modal_Open_Candidate__c != undefined) {
                                // Date Format : mm-dd-yyyy
                                const today = new Date();
                                const modalData = new Date(element.Feedback_Modal_Open_Candidate__c);
                                const todayDate = new Date(String(today.getMonth() + 1).padStart(2, '0') + '-' + String(today.getDate()).padStart(2, '0') + '-' + today.getFullYear());
                                const diffTime = Math.abs(todayDate - modalData);
                                const diffDays = Math.ceil(diffTime / (1000 * 60 * 60 * 24));
                                if (diffDays < 31 && modalData.getMonth() == todayDate.getMonth()) {
                                    this.ClientApproveModal = false;
                                }
                            }
                        });
                    } else {
                        result.forEach(element => {
                            if (element.Feedback_Modal_Open__c != undefined) {
                                // Date Format : mm-dd-yyyy
                                const today = new Date();
                                const modalData = new Date(element.Feedback_Modal_Open__c);
                                const todayDate = new Date(String(today.getMonth() + 1).padStart(2, '0') + '-' + String(today.getDate()).padStart(2, '0') + '-' + today.getFullYear());
                                const diffTime = Math.abs(todayDate - modalData);
                                const diffDays = Math.ceil(diffTime / (1000 * 60 * 60 * 24));
                                if (diffDays < 7 && modalData.getDay() <= todayDate.getDay()) {
                                    this.ClientApproveModal = false;
                                }
                            }
                        });
                    }
                })
                .catch((error) => {
                    console.log({ error });
                })
        } catch (error) {
            console.log({ error });
        }
    }


    /***************************************************
     * Author             : Krunal
     * Created Date       : 29/07/2022
     * Last Modified Date : 29/07/2022
     * Description        : save request quality call data form approve popup modal.
     ***************************************************/
    requestCheck(event) {
        try {
            // this.requesteQualityCall = event.detail.value;
            this.requesteQualityCall = event.target.checked;
            console.log("reuest Call Change ==>" + this.requesteQualityCall);
        } catch (error) {
            console.log({ error });
        }
    }


    /***************************************************
     * Author             : Nitin
     * Created Date       : 29/07/2022
     * Last Modified Date : 29/07/2022
     * Description        : used for approving timesheet when reject button clicked
     ***************************************************/
    approveTimesheet() {
        try {
            this.isSpinner = true;
            var operation = "Approve";
            var notes = this.approveNotes;
            var ratingValue = this.selectedRetting;
            var rqc = this.requesteQualityCall;
            console.log({ ratingValue });

            if (this.ratingValue == '') {
                this.template.querySelector('c-ts_-tost-notification').showToast('error', 'Please give your feedback', 3000);
                this.isSpinner = false;
                return false;
            } else if (this.ratingValue == "Excellent" || this.ratingValue == "Very Good") {
                approveRejectTimeSheet({ operation: operation, timesheetId: this.timesheetId, notes: notes, ratingValue: ratingValue, rqc: rqc, openModal: true })
                    .then((result) => {
                        this.status = "Approved";
                        console.log("result from apex class ==>" + result);
                        this.template.querySelector('c-ts_-tost-notification').showToast('success', 'Your feedback is submit successfully', 3000);
                        this.isClientApproveModalOpen = false;
                        this.isSpinner = false;
                        this.navigateToTimeSheet();
                    })
                    .catch((error) => {
                        console.log({ error });
                        this.isSpinner = false;
                    });
            } else {
                if (notes == '') {
                    this.template.querySelector('c-ts_-tost-notification').showToast('error', 'Complete required field', 3000);
                    this.isSpinner = false;
                    return false;
                } else {
                    approveRejectTimeSheet({ operation: operation, timesheetId: this.timesheetId, notes: notes, ratingValue: ratingValue, rqc: rqc, openModal: true })
                        .then((result) => {
                            this.status = "Approved";
                            this.template.querySelector('c-ts_-tost-notification').showToast('success', 'Your feedback is submit successfully', 3000);
                            this.isClientApproveModalOpen = false;
                            this.isSpinner = false;
                            this.navigateToTimeSheet();
                        })
                        .catch((error) => {
                            console.log({ error });
                            this.isSpinner = false;
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
     * Author             : Nitin
     * Created Date       : 29/07/2022
     * Last Modified Date : 29/07/2022
     * Description        : used for rejecting timesheet when reject button clicked
     ***************************************************/
    rejectTimesheet() {
        try {
            this.isSpinner = true;
            console.log("reject Timesheet Clicked ===>");
            var operation = "Reject";
            var notes = this.rejectionNotes.trim();
            console.log("text field of rejection ===>" + notes);
            if (notes == '') {
                this.template.querySelector('c-ts_-tost-notification').showToast('error', 'Please give the reason of rejection', 3000);
                this.isSpinner = false;
                return false;
            } else {
                approveRejectTimeSheet({ operation: operation, timesheetId: this.timesheetId, notes: notes })
                    .then((result) => {
                        console.log("result from apex class ==>" + result);
                        this.template.querySelector('c-ts_-tost-notification').showToast('success', 'Send successfully', 3000);
                        this.closeRejectModal();
                        this.navigateToTimeSheet();
                    })
                    .catch((error) => {
                        console.log({ error });
                    });
                this.isSpinner = false;
            }
        } catch (error) {
            console.log({ error });
            this.reloadpage = true;
            this.template.querySelectorAll('c-ts_-error-component')[0].openModal();
        }
    }


    /***************************************************
     * Author             : Nitin
     * Created Date       : 29/07/2022
     * Last Modified Date : 29/07/2022
     * Description        : used for sending message to job owner when send Message button clicked
     ***************************************************/
    sendMessage() {
        try {
            this.isSpinner = true;
            var message = this.messageToJobOwner.trim();
            console.log("text field of messageToJobOwner ===>" + message);
            sendMessageToJobOwner({ timesheetId: this.timesheetId, message: message })
                .then((result) => {
                    console.log("result from apex class ==>" + result);
                    this.isSendMessageModalOpen = false;
                    this.template.querySelector('c-ts_-tost-notification').showToast('success', 'Send successfully', 3000);
                    this.isSpinner = false;
                })
                .catch((error) => {
                    console.log({ error });
                    this.isSpinner = false;
                });
        } catch (error) {
            console.log({ error });
            this.reloadpage = true;
            this.template.querySelectorAll('c-ts_-error-component')[0].openModal();
        }
    }


    /***************************************************
     * Author             : Nitin
     * Created Date       : 29/07/2022
     * Last Modified Date : 29/07/2022
     * Description        : used in Approve Popup to get selected rating.
     ***************************************************/
    selectRating(event) {
        try {
            // var pvalue = event.currentTarget.dataset.id;
            var selectedRetting = event.currentTarget.dataset.id;
            this.ratingValue = selectedRetting;
            console.log("selected Imogi value ====>" + this.selectedRetting);
            if (selectedRetting == "Excellent" || selectedRetting == "Very Good") {
                this.text_area_required = false;
            } else {
                this.text_area_required = true;
            }

            if (selectedRetting == "Excellent") {
                // this.selectedRetting = '/services/data/v55.0/sobjects/StaticResource/0810C000000Qdqw/Body';
                this.selectedRetting = 'Excellent';
                this.template.querySelector('[data-id="Excellent"]').className = ' emg-excel slds-box slds-box_x-small slds-text-align_center slds-m-around_x-small';
                this.template.querySelector('[data-id="Very Good"]').className = 'slds-box slds-box_x-small slds-text-align_center slds-m-around_x-small';
                this.template.querySelector('[data-id="Good"]').className = 'slds-box slds-box_x-small slds-text-align_center slds-m-around_x-small';
                this.template.querySelector('[data-id="Requires Improvement"]').className = 'slds-box slds-box_x-small slds-text-align_center slds-m-around_x-small';
                this.template.querySelector('[data-id="Unsatisfactory"]').className = 'slds-box slds-box_x-small slds-text-align_center slds-m-around_x-small';
            } else if (selectedRetting == "Very Good") {
                // this.selectedRetting = '/services/data/v55.0/sobjects/StaticResource/0810C000000Qdr1/Body';
                this.selectedRetting = 'Very Good';
                this.template.querySelector('[data-id="Very Good"]').className = ' emg-very-good slds-box slds-box_x-small slds-text-align_center slds-m-around_x-small';
                this.template.querySelector('[data-id="Excellent"]').className = 'slds-box slds-box_x-small slds-text-align_center slds-m-around_x-small';
                this.template.querySelector('[data-id="Good"]').className = 'slds-box slds-box_x-small slds-text-align_center slds-m-around_x-small';
                this.template.querySelector('[data-id="Requires Improvement"]').className = 'slds-box slds-box_x-small slds-text-align_center slds-m-around_x-small';
                this.template.querySelector('[data-id="Unsatisfactory"]').className = 'slds-box slds-box_x-small slds-text-align_center slds-m-around_x-small';
            } else if (selectedRetting == "Good") {
                // this.selectedRetting = '/services/data/v55.0/sobjects/StaticResource/0810C000000Qdr6/Body';
                this.selectedRetting = 'Good';
                this.template.querySelector('[data-id="Good"]').className = 'emg-good slds-box slds-box_x-small slds-text-align_center slds-m-around_x-small';
                this.template.querySelector('[data-id="Excellent"]').className = 'slds-box slds-box_x-small slds-text-align_center slds-m-around_x-small';
                this.template.querySelector('[data-id="Very Good"]').className = 'slds-box slds-box_x-small slds-text-align_center slds-m-around_x-small';
                this.template.querySelector('[data-id="Requires Improvement"]').className = 'slds-box slds-box_x-small slds-text-align_center slds-m-around_x-small';
                this.template.querySelector('[data-id="Unsatisfactory"]').className = 'slds-box slds-box_x-small slds-text-align_center slds-m-around_x-small';
            } else if (selectedRetting == "Requires Improvement") {
                // this.selectedRetting = '/services/data/v55.0/sobjects/StaticResource/0810C000000QdrB/Body';
                this.selectedRetting = 'Requires Improvement';
                this.template.querySelector('[data-id="Requires Improvement"]').className = 'emg-ri slds-box slds-box_x-small slds-text-align_center slds-m-around_x-small';
                this.template.querySelector('[data-id="Excellent"]').className = 'slds-box slds-box_x-small slds-text-align_center slds-m-around_x-small';
                this.template.querySelector('[data-id="Very Good"]').className = 'slds-box slds-box_x-small slds-text-align_center slds-m-around_x-small';
                this.template.querySelector('[data-id="Good"]').className = 'slds-box slds-box_x-small slds-text-align_center slds-m-around_x-small';
                this.template.querySelector('[data-id="Unsatisfactory"]').className = 'slds-box slds-box_x-small slds-text-align_center slds-m-around_x-small';
            } else if (selectedRetting == "Unsatisfactory") {
                // this.selectedRetting = '/services/data/v55.0/sobjects/StaticResource/0810C000000QdrG/Body';
                this.selectedRetting = 'Unsatisfactory';
                this.template.querySelector('[data-id="Unsatisfactory"]').className = 'emg-unsetisfy slds-box slds-box_x-small slds-text-align_center slds-m-around_x-small';
                this.template.querySelector('[data-id="Excellent"]').className = 'slds-box slds-box_x-small slds-text-align_center slds-m-around_x-small';
                this.template.querySelector('[data-id="Very Good"]').className = 'slds-box slds-box_x-small slds-text-align_center slds-m-around_x-small';
                this.template.querySelector('[data-id="Good"]').className = 'slds-box slds-box_x-small slds-text-align_center slds-m-around_x-small';
                this.template.querySelector('[data-id="Requires Improvement"]').className = 'slds-box slds-box_x-small slds-text-align_center slds-m-around_x-small';
            }
        } catch (error) {
            console.log({ error });
        }
    }


    /***************************************************
     * Author             : Nitin
     * Created Date       : 29/07/2022
     * Last Modified Date : 29/07/2022
     * Description        : used for getting rejection notes from text area on onchange event.
     ***************************************************/
    saveRejectionNotes(event) {
        try {
            this.rejectionNotes = event.detail.value;
        } catch (error) {
            console.log({ error });
            this.reloadpage = true;
            this.template.querySelectorAll('c-ts_-error-component')[0].openModal();
        }
    }


    /***************************************************
     * Author             : Nitin
     * Created Date       : 29/07/2022
     * Last Modified Date : 29/07/2022
     * Description        : used for getting Approver notes from text area on onchange event.
     ***************************************************/
    saveApproveNotes(event) {
        try {
            this.approveNotes = event.detail.value;
        } catch (error) {
            console.log({ error });
            this.reloadpage = true;
            this.reloadpage = true;
            this.template.querySelectorAll('c-ts_-error-component')[0].openModal();
        }
    }


    /***************************************************
     * Author             : Nitin
     * Created Date       : 29/07/2022
     * Last Modified Date : 29/07/2022
     * Description        : used for getting message from text area of send message to job owner on onchange event.
     ***************************************************/
    saveMessageForJobOwner(event) {
        try {
            this.messageToJobOwner = event.detail.value;
        } catch (error) {
            console.log({ error });
            this.reloadpage = true;
            this.template.querySelectorAll('c-ts_-error-component')[0].openModal();
        }
    }


    /***************************************************
     * Author             : Nitin
     * Created Date       : 29/07/2022
     * Last Modified Date : 29/07/2022
     * Description        : used for closing popup modal of approve, reject and send Message.
     ***************************************************/
    closeRejectModal() {
        try {
            this.isClientRejectedModalOpen = false;
            this.isClientApproveModalOpen = false;
            this.isSendMessageModalOpen = false;

            this.approveNotes = '';
            this.rejectionNotes = '';
            this.requesteQualityCall = false;
        } catch (error) {
            console.log({ error });
            this.reloadpage = true;
            this.template.querySelectorAll('c-ts_-error-component')[0].openModal();
        }
    }


    /***************************************************
     * Author             : Nitin
     * Created Date       : 29/07/2022
     * Last Modified Date : 29/07/2022
     * Description        : used for oppening Reject Timesheet popup-modal.
     ***************************************************/
    openRejectModal() {
        try {
            this.isClientRejectedModalOpen = true;
        } catch (error) {
            console.log({ error });
            this.reloadpage = true;
            this.template.querySelectorAll('c-ts_-error-component')[0].openModal();
        }
    }


    /***************************************************
     * Author             : Nitin
     * Created Date       : 29/07/2022
     * Last Modified Date : 29/07/2022
     * Description        : used for oppening Approve Timesheet popup-modal.
     ***************************************************/
    openApproveModal() {
        try {
            console.log(this.status);

            if (this.status != "Approved") {
                if (this.ClientApproveModal == true) {
                    this.isClientApproveModalOpen = true;
                } else {
                    this.isSpinner = true;
                    approveRejectTimeSheet({ operation: 'Approve', timesheetId: this.timesheetId, openModal: false })
                        .then((result) => {
                            this.status = "Approved";
                            console.log({ result });
                            this.template.querySelector('c-ts_-tost-notification').showToast('success', 'Timesheet approved', 3000);
                            this.isSpinner = false;
                            this.navigateToTimeSheet();
                        })
                        .catch((error) => {
                            this.isSpinner = false;
                            console.log({ error });
                            this.template.querySelector('c-ts_-tost-notification').showToast('error', 'Something Went Wrong', 3000);
                        });
                }
            } else {
                this.template.querySelector('c-ts_-tost-notification').showToast('error', 'Time sheet is already approved', 3000);
            }
        } catch (error) {
            console.log({ error });
            this.reloadpage = true;
            this.template.querySelectorAll('c-ts_-error-component')[0].openModal();
        }
    }


    /***************************************************
     * Author             : Nitin
     * Created Date       : 29/07/2022
     * Last Modified Date : 29/07/2022
     * Description        : used for oppening send Message to job owner popup-modal.
     ***************************************************/
    openMessageModal() {
        try {
            this.isSendMessageModalOpen = true;
        } catch (error) {
            console.log({ error });
            this.reloadpage = true;
            this.template.querySelectorAll('c-ts_-error-component')[0].openModal();
        }
    }


    /***************************************************
     * Author             : sakina
     * Created Date       : 29/07/2022
     * Last Modified Date : 29/07/2022
     * Description        : used for going back to timesheet component
     ***************************************************/
    navigateToTimeSheet() {
        try {
            this.isSpinner = true;
            var urlValue = '/s/';
            console.log('enter timesheet');
            this[NavigationMixin.Navigate]({
                type: "comm__namedPage",
                attributes: {
                    name: "TimeSheet__c",
                    urlValue: urlValue + 'timesheet'
                },
            });
            this.isSpinner = false;
        } catch (error) {
            console.log({ error });
        }
    }
    check(event) {
        this.dispatchEvent(new CustomEvent('getmenu', { bubbles: true, detail: "profile" }));
    }
}