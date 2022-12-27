/*******************************************************
 * Name          : ts_Timesheet
 * Author        : Nitin
 * Create Date   : 29/07/2022
 * Description   : Used in ts_Timesheet Component in community site
 *******************************************************/
import { LightningElement, track } from 'lwc';
import getTimesheet from "@salesforce/apex/ts_TimesheetController.getTimesheet";
import { NavigationMixin } from 'lightning/navigation';
import approveRejectTimeSheet from "@salesforce/apex/ts_TimesheetController.approveRejectTimeSheet";
import downloadPdf from "@salesforce/apex/ts_TimesheetController.downloadPdf";

import ts_Excelent from '@salesforce/resourceUrl/ts_Excelent';
import ts_VeryGood from '@salesforce/resourceUrl/ts_VeryGood';
import ts_Good from '@salesforce/resourceUrl/ts_Good';
import ts_RequireImprovments from '@salesforce/resourceUrl/ts_RequireImprovments';
import ts_Unsetisfy from '@salesforce/resourceUrl/ts_Unsetisfy';
import fetchContact from '@salesforce/apex/ts_TimesheetController.fetchContact'; //Get Contact Record to check client or not.\
import getAllTimesheet from "@salesforce/apex/ts_TimesheetController.getAllTimesheet";
import communityicon from '@salesforce/resourceUrl/communityicons';
// import custom label
import feedbackTitle from '@salesforce/label/c.Give_Feedback_Text';
import rejectionTitle from '@salesforce/label/c.Give_Feedback_For_Candidate';
import Longitude from '@salesforce/schema/Lead.Longitude';



export default class Ts_Timesheet extends NavigationMixin(LightningElement) {

    viewIcon = communityicon + '/communityicons/ts_view.png';
    printIcon = communityicon + '/communityicons/ts_print.png';
    approveIcon = communityicon + '/communityicons/ts_approve.png';
    rejectIcon = communityicon + '/communityicons/ts_reject.png';
    popupCloseBtnIcon = communityicon + '/communityicons/close.png';
    popupSendBtnIcon = communityicon + '/communityicons/ts_send_btn.png';
    message = communityicon + '/communityicons/message.png';

    @track activeTimeSheet = []; // Used For Displaying List of Timesheet.
    @track isSpinner = false; // for loading spinner 
    @track isClientApproveModalOpen = false; // Used IN popup Modal when Approve button Clicked.
    @track selectedRetting = ''; // Rating Value that selected in Approve Modal.
    @track ratingValue = '';
    @track approveNotes = ''; // Approver Notes For Approving of time sheet.
    @track isNoTimesheetRecord = false; // for Displaying No Records Found.
    @track isClientRejectedModalOpen = false; // Used IN popup Modal when Reject button Clicked.
    @track rejectionNotes = ''; // Approver Notes For Rejection of time sheet.
    @track checkCandidate;
    @track ClientApproveModal = true;
    @track feedbackHeading = feedbackTitle;
    @track feedbackCandidateHeading = rejectionTitle;

    status;
    requesteQualityCall;

    rejectBtnIcon = communityicon + '/communityicons/cancel.png';
    approveBtnIcon = communityicon + '/communityicons/ts_approve_btn.png';
    excelentEmg = ts_Excelent;
    VeryGoodEmg = ts_VeryGood;
    goodEmg = ts_Good;
    requireImprovmentsEmg = ts_RequireImprovments;
    unsetisfyEmg = ts_Unsetisfy;
    selectedTimesheet;
    text_area_required = false;

    /***************************************************
     * Author             : Krunal
     * Created Date       : 29/07/2022
     * Last Modified Date : 29/07/2022
     * Description        : get client and candidate data.
     ***************************************************/
    connectedCallback() {
        try {
            var status = "'Rejected' , 'Submitted' , 'Submited' , 'Changed By Payroll'";
            this.timesheetListGenrater(status);
            fetchContact()
                .then(result => {
                    if (result != null) {
                        if (result.Community_Contact_Type__c == 'Client') {
                            this.checkCandidate = false;
                        } else if (result.Community_Contact_Type__c = 'Candidate') {
                            this.checkCandidate = true;
                        }
                        this.isSpinner = false;
                    }
                })
                .catch(error => {
                });
            this.allTimeSheet();
        } catch (error) {
            console.log({error});
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
            getAllTimesheet()
                .then((result) => {
                    if (this.checkCandidate == true) {
                        result.forEach(element => {
                            if (element.Feedback_Modal_Open_Candidate__c != undefined) {
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
                })
        } catch (error) {
            this.reloadpage = true;
            this.template.querySelectorAll('c-ts_-error-component')[0].openModal();
        }
    }

    /***************************************************
     * Author             : Nitin
     * Created Date       : 29/07/2022
     * Last Modified Date : 29/07/2022
     * Description        : get timesheet data for display timesheet records
     ***************************************************/
    timesheetListGenrater(status) {
        try {
            this.status = status;
            this.isSpinner = true;
            getTimesheet({ timesheetStatus: status })
                .then((result) => {
                    this.activeTimeSheet = result;
                    if (this.activeTimeSheet == null) {
                        this.isNoTimesheetRecord = true;
                        let colHeads = this.template.querySelectorAll('.colHead');
                        colHeads.forEach(element => {
                            element.style.width = "9%";
                        });
                    } else if (this.activeTimeSheet.length == 0) {
                        this.isNoTimesheetRecord = true;
                        let colHeads = this.template.querySelectorAll('.colHead');
                        colHeads.forEach(element => {
                            element.style.width = "9%";
                        });
                    } else {
                        this.isNoTimesheetRecord = false;
                        let colHeads = this.template.querySelectorAll('.colHead');
                        colHeads.forEach(element => {
                            element.style.width = "8.3333333333%";
                        });
                    }
                    // for Convering Week Ending date Formate YYYY-MM-DD to DD-MM-YYYY
                    result.forEach(element => {
                        if (element.TR1__Week_Ending__c != null) {
                            element.TR1__Week_Ending__c = element.TR1__Week_Ending__c.split("-").reverse().join("-");
                        }
                    });

                    this.isSpinner = false;
                })
                .catch((error) => {
                    this.isSpinner = false;
                    this.template.querySelector('c-ts_-tost-notification').showToast('error', 'Something Went Wrong', 3000);
                });
        } catch (error) {
            this.reloadpage = true;
            this.template.querySelectorAll('c-ts_-error-component')[0].openModal();
        }
    }

    /***************************************************
     * Author             : Nitin
     * Created Date       : 29/07/2022
     * Last Modified Date : 29/07/2022
     * Description        : for display timesheet in active timesheet tab
     ***************************************************/
    displayActiveTimesheet(event) {
        try {
            this.template.querySelector('.active-timesheet-btn').classList.add('timesheet-btn-active');
            this.template.querySelector('.historical-timesheet-btn').classList.remove('timesheet-btn-active');

            var status = "'Rejected' , 'Submitted' , 'Submited' , 'Changed By Payroll'";
            this.timesheetListGenrater(status); // calling this method for getting list of Active Timesheet
        } catch (error) {
            this.reloadpage = true;
            this.template.querySelectorAll('c-ts_-error-component')[0].openModal();
        }
    }

    /***************************************************
     * Author             : Nitin
     * Created Date       : 29/07/2022
     * Last Modified Date : 29/07/2022
     * Description        : for display timesheet in historical timesheet tab
     ***************************************************/
    displayHistoricalTimesheet(event) {
        try {
            this.template.querySelector('.historical-timesheet-btn').classList.add('timesheet-btn-active');
            this.template.querySelector('.active-timesheet-btn').classList.remove('timesheet-btn-active');

            var status = "'Approved'";

            this.timesheetListGenrater(status); // calling this method for getting list of Historical Timesheet
        } catch (error) {
            this.reloadpage = true;
            this.template.querySelectorAll('c-ts_-error-component')[0].openModal();
        }
    }

    /***************************************************
     * Author             : Nitin
     * Created Date       : 29/07/2022
     * Last Modified Date : 29/07/2022
     * Description        : for navigate user to priview, print, approve and reject timesheet
     ***************************************************/
    navigatepage(event) {
        try {
            var urlValue = '/s/';
            var nameval = event.target.dataset.name;
            this.selectedTimesheet = event.target.dataset.id;

            if (nameval == "View") {
                urlValue = urlValue + 'timesheet/timesheetdetail';

                this[NavigationMixin.Navigate]({
                    type: 'comm__namedPage',
                    attributes: {
                        name: 'TimeSheetDetail__c',
                        url: urlValue
                    },
                    state: {
                        id: this.selectedTimesheet // Value must be a string
                    }
                });
            } else if (nameval == "Print") {

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
                    downloadPdf({ recordid: this.selectedTimesheet })
                        .then((result) => {
                            var strFile = result;
                            const link = document.createElement('a');
                            link.href = 'data:application/octet-stream;base64,' + strFile;
                            link.download = 'TimesheetDetail.pdf';
                            link.click();
                            this.isSpinner = false;
                        })
                        .catch(error => {
                            this.reloadpage = true;
                            this.template.querySelectorAll('c-ts_-error-component')[0].openModal();
                            this.isSpinner = false;
                        })
                } else {
                    urlValue = urlValue + 'timesheet/timesheetpdf';
                    this[NavigationMixin.Navigate]({
                        type: 'comm__namedPage',
                        attributes: {
                            name: 'TimesheetPDF__c',
                            url: urlValue
                        },
                        state: {
                            recordId: this.selectedTimesheet // Value must be a string
                        }
                    });
                }

            } else if (nameval == "Approve") {
                if (this.status != " 'Approved' ") {
                    if (this.ClientApproveModal == true) {
                        this.isClientApproveModalOpen = true;
                    } else {
                        this.isSpinner = true;
                        approveRejectTimeSheet({ operation: 'Approve', timesheetId: this.selectedTimesheet, openModal: false })
                            .then((result) => {
                                this.template.querySelector('c-ts_-tost-notification').showToast('success', 'Timesheet approved', 3000);
                                this.timesheetListGenrater(this.status);
                                this.isSpinner = false;
                            })
                            .catch((error) => {
                                this.isSpinner = false;
                                this.template.querySelector('c-ts_-tost-notification').showToast('error', 'Something Went Wrong', 3000);
                            });
                    }
                } else {
                    this.template.querySelector('c-ts_-tost-notification').showToast('error', 'Time sheet is already approved', 3000);
                }
            } else if (nameval == "Reject") {
                this.isClientRejectedModalOpen = true;
            }
        } catch (error) {
            this.reloadpage = true;
            this.template.querySelectorAll('c-ts_-error-component')[0].openModal();
        }
    }

    /***************************************************
     * Author             : Nitin
     * Created Date       : 29/07/2022
     * Last Modified Date : 29/07/2022
     * Description        : for give rating form approve popup
     ***************************************************/
    selectRating(event) {
        try {
            var selectedRetting = event.currentTarget.dataset.id;
            this.ratingValue = selectedRetting;
            if (selectedRetting == "Excellent" || selectedRetting == "Very Good") {
                this.text_area_required = false;
            } else {
                this.text_area_required = true;
            }
            if (selectedRetting == "Excellent") {
                this.selectedRetting = 'Excellent';
                this.template.querySelector('[data-id="Excellent"]').className = ' emg-excel slds-box slds-box_x-small slds-text-align_center slds-m-around_x-small';
                this.template.querySelector('[data-id="Very Good"]').className = 'slds-box slds-box_x-small slds-text-align_center slds-m-around_x-small';
                this.template.querySelector('[data-id="Good"]').className = 'slds-box slds-box_x-small slds-text-align_center slds-m-around_x-small';
                this.template.querySelector('[data-id="Requires Improvement"]').className = 'slds-box slds-box_x-small slds-text-align_center slds-m-around_x-small';
                this.template.querySelector('[data-id="Unsatisfactory"]').className = 'slds-box slds-box_x-small slds-text-align_center slds-m-around_x-small';
            } else if (selectedRetting == "Very Good") {
                this.selectedRetting = 'Very Good';
                this.template.querySelector('[data-id="Very Good"]').className = ' emg-very-good slds-box slds-box_x-small slds-text-align_center slds-m-around_x-small';
                this.template.querySelector('[data-id="Excellent"]').className = 'slds-box slds-box_x-small slds-text-align_center slds-m-around_x-small';
                this.template.querySelector('[data-id="Good"]').className = 'slds-box slds-box_x-small slds-text-align_center slds-m-around_x-small';
                this.template.querySelector('[data-id="Requires Improvement"]').className = 'slds-box slds-box_x-small slds-text-align_center slds-m-around_x-small';
                this.template.querySelector('[data-id="Unsatisfactory"]').className = 'slds-box slds-box_x-small slds-text-align_center slds-m-around_x-small';
            } else if (selectedRetting == "Good") {
                this.selectedRetting = 'Good';
                this.template.querySelector('[data-id="Good"]').className = 'emg-good slds-box slds-box_x-small slds-text-align_center slds-m-around_x-small';
                this.template.querySelector('[data-id="Excellent"]').className = 'slds-box slds-box_x-small slds-text-align_center slds-m-around_x-small';
                this.template.querySelector('[data-id="Very Good"]').className = 'slds-box slds-box_x-small slds-text-align_center slds-m-around_x-small';
                this.template.querySelector('[data-id="Requires Improvement"]').className = 'slds-box slds-box_x-small slds-text-align_center slds-m-around_x-small';
                this.template.querySelector('[data-id="Unsatisfactory"]').className = 'slds-box slds-box_x-small slds-text-align_center slds-m-around_x-small';
            } else if (selectedRetting == "Requires Improvement") {
                this.selectedRetting = 'Requires Improvement';
                this.template.querySelector('[data-id="Requires Improvement"]').className = 'emg-ri slds-box slds-box_x-small slds-text-align_center slds-m-around_x-small';
                this.template.querySelector('[data-id="Excellent"]').className = 'slds-box slds-box_x-small slds-text-align_center slds-m-around_x-small';
                this.template.querySelector('[data-id="Very Good"]').className = 'slds-box slds-box_x-small slds-text-align_center slds-m-around_x-small';
                this.template.querySelector('[data-id="Good"]').className = 'slds-box slds-box_x-small slds-text-align_center slds-m-around_x-small';
                this.template.querySelector('[data-id="Unsatisfactory"]').className = 'slds-box slds-box_x-small slds-text-align_center slds-m-around_x-small';
            } else if (selectedRetting == "Unsatisfactory") {
                this.selectedRetting = 'Unsatisfactory';
                this.template.querySelector('[data-id="Unsatisfactory"]').className = 'emg-unsetisfy slds-box slds-box_x-small slds-text-align_center slds-m-around_x-small';
                this.template.querySelector('[data-id="Excellent"]').className = 'slds-box slds-box_x-small slds-text-align_center slds-m-around_x-small';
                this.template.querySelector('[data-id="Very Good"]').className = 'slds-box slds-box_x-small slds-text-align_center slds-m-around_x-small';
                this.template.querySelector('[data-id="Good"]').className = 'slds-box slds-box_x-small slds-text-align_center slds-m-around_x-small';
                this.template.querySelector('[data-id="Requires Improvement"]').className = 'slds-box slds-box_x-small slds-text-align_center slds-m-around_x-small';
            }
        } catch (error) {
            this.isSpinner = false;
            this.template.querySelector('c-ts_-tost-notification').showToast('error', 'Something Went Wrong', 3000);
        }
    }

    /***************************************************
     * Author             : Nitin
     * Created Date       : 29/07/2022
     * Last Modified Date : 29/07/2022
     * Description        : for set approve note from popup modal.
     ***************************************************/
    saveApproveNotes(event) {
        try {
            this.approveNotes = event.detail.value;
        } catch (error) {
            console.log({error});
        }
    }

    /***************************************************
     * Author             : Krunal
     * Created Date       : 29/07/2022
     * Last Modified Date : 29/07/2022
     * Description        : close reject modal.
     ***************************************************/
    closeRejectModal() {
        try {
            this.isClientRejectedModalOpen = false;
            this.rejectionNotes = '';
        } catch (error) {
            console.log({error});
        }
    }

    /***************************************************
     * Author             : Krunal
     * Created Date       : 29/07/2022
     * Last Modified Date : 29/07/2022
     * Description        : close approve modal.
     ***************************************************/
    closeApproveModal() {
        try {
            this.isClientApproveModalOpen = false;
            this.approveNotes = '';
        } catch (error) {
            console.log({error});
        }
    }

    /***************************************************
     * Author             : Nitin
     * Created Date       : 29/07/2022
     * Last Modified Date : 29/07/2022
     * Description        : approve timesheet from popup modal.
     ***************************************************/
    approveTimesheet() {
        try {
            var operation = "Approve";
            var notes = this.approveNotes.trim();
            var ratingValue = this.selectedRetting;
            var rqc = this.requesteQualityCall;

            if (this.ratingValue == "Excellent" || this.ratingValue == "Very Good") {
                this.isSpinner = true;
                this.isClientApproveModalOpen = false;
                approveRejectTimeSheet({ operation: operation, timesheetId: this.selectedTimesheet, notes: notes, ratingValue: ratingValue, rqc: rqc, openModal: true })
                    .then((result) => {
                        this.ClientApproveModal = false;
                        this.template.querySelector('c-ts_-tost-notification').showToast('success', 'Timesheet approved', 3000);
                        this.displayActiveTimesheet();
                        this.isSpinner = false;
                    })
                    .catch((error) => {
                        this.template.querySelector('c-ts_-tost-notification').showToast('error', 'Something Went Wrong', 3000);
                        this.isSpinner = false;
                    });
            } else if (this.ratingValue.length > 0) {
                this.text_area_required = true;
                if (notes.length > 0) {
                    this.isClientApproveModalOpen = false;
                    this.isSpinner = true;
                    approveRejectTimeSheet({ operation: operation, timesheetId: this.selectedTimesheet, notes: notes, ratingValue: ratingValue, rqc: rqc, openModal: true })
                        .then((result) => {
                            this.ClientApproveModal = false;
                            this.template.querySelector('c-ts_-tost-notification').showToast('success', 'Timesheet approved', 3000);
                            this.displayActiveTimesheet();
                            this.isSpinner = false;
                        })
                        .catch((error) => {
                            this.isSpinner = false;
                            this.template.querySelector('c-ts_-tost-notification').showToast('error', 'Something Went Wrong', 3000);
                        });
                } else {
                    let fieldToFocus = this.template.querySelector("lightning-textarea");
                    fieldToFocus.focus();
                    this.template.querySelector('c-ts_-tost-notification').showToast('error', 'Please Write Something', 3000);
                }
            } else {
                this.template.querySelector('c-ts_-tost-notification').showToast('error', 'Please Give Feedback', 3000);
            }
        } catch (error) {
            this.reloadpage = true;
            this.template.querySelectorAll('c-ts_-error-component')[0].openModal();        }
    }

    /***************************************************
     * Author             : Krunal
     * Created Date       : 29/07/2022
     * Last Modified Date : 29/07/2022
     * Description        : save reject notes.
     ***************************************************/
    saveRejectionNotes(event) {
        try {
            this.rejectionNotes = event.detail.value;
        } catch (error) {
            console.log({error});
        }
    }

    /***************************************************
     * Author             : Krunal
     * Created Date       : 29/07/2022
     * Last Modified Date : 29/07/2022
     * Description        : reject timesheet from timesheet list.
     ***************************************************/
    rejectTimesheet() {
        try {
            var operation = "Reject";
            var notes = this.rejectionNotes.trim();
            if (notes == '') {
                this.template.querySelector('c-ts_-tost-notification').showToast('error', 'Please give the reason of rejection', 3000);
            } else {
                this.isSpinner = true;
                this.isClientRejectedModalOpen = false;
                approveRejectTimeSheet({ operation: operation, timesheetId: this.selectedTimesheet, notes: notes })
                    .then((result) => {
                        this.template.querySelector('c-ts_-tost-notification').showToast('success', 'Timesheet rejected', 3000);
                        this.timesheetListGenrater(this.status);
                        this.rejectionNotes = '';
                        this.isSpinner = false;
                    })
                    .catch((error) => {
                        this.isSpinner = false;
                        this.template.querySelector('c-ts_-tost-notification').showToast('error', 'Something Went Wrong', 3000);
                    });
            }

        } catch (error) {
            this.reloadpage = true;
            this.template.querySelectorAll('c-ts_-error-component')[0].openModal();
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
            this.requesteQualityCall = event.target.checked;
        } catch (error) {
            console.log({error});
        }
    }
    check(event) {
        this.dispatchEvent(new CustomEvent('getmenu', { bubbles: true, detail: "profile" }));
    }
}