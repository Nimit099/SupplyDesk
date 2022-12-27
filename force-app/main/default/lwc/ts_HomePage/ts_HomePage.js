/*******************************************************
 * Name          : ts_HomePage
 * Author        : Karan
 * Create Date   : 29/07/2022
 * Description   : Used in ts_HomePage Component in community site
 *******************************************************/
import { LightningElement, wire, track } from 'lwc';
import fetchContact from '@salesforce/apex/ts_ProfileModule.fetchContact';             //Get Contact Record to check client or not.
import { getRecord } from 'lightning/uiRecordApi';
import USER_ID from '@salesforce/user/Id';
import NAME_FIELD from '@salesforce/schema/User.Name';
import LAST_LOGIN from '@salesforce/schema/User.LastLoginDate';
import IMG_URL from '@salesforce/schema/User.FullPhotoUrl';
import commstyle from '@salesforce/resourceUrl/CommunityCSS';
import { NavigationMixin } from 'lightning/navigation';
import { loadStyle } from 'lightning/platformResourceLoader';
import communityicon from '@salesforce/resourceUrl/communityicons';
export default class Ts_HomePage extends NavigationMixin(LightningElement) {

    @track uName;
    @track lastLogin;
    @track checkClient;
    @track imgUrl;
    @track count = 0;
    @track isSpinner = false;
    @track reloadpage;
    @track swipeDirection;
    @track touchstartX = 0;
    @track touchstartY = 0;
    @track touchendX = 0;
    @track touchendY = 0;

    image = communityicon + '/communityicons/image.png';
    image1 = communityicon + '/communityicons/image1.png';
    image2 = communityicon + '/communityicons/image2.png';
    image3 = communityicon + '/communityicons/image3.png';
    image4 = communityicon + '/communityicons/image4.png';

    myAccImg = communityicon + '/communityicons/myaccount.png';
    tmSheetImg = communityicon + '/communityicons/timesheet.png';
    cmpImg = communityicon + '/communityicons/compliance.png';
    myQualImg = communityicon + '/communityicons/MyQualificationImg.png';
    schedularImg = communityicon + '/communityicons/scheduler.png';
    usernameval = NAME_FIELD;

    @wire(getRecord, {
        recordId: USER_ID,
        fields: [NAME_FIELD, LAST_LOGIN, IMG_URL]
    }) wireuser({
        error,
        data
    }) {
        if (error) {
            this.error = error;
        } else if (data) {
            this.uName = data.fields.Name.value;
            this.lastLogin = data.fields.LastLoginDate.value;
            this.imgUrl = data.fields.FullPhotoUrl.value;
        }
    }


    renderedCallback() {
        try {
            Promise.all([
                loadStyle(this, commstyle)
            ]).then(() => {
            })
                .catch(error => {
                });
        } catch (e) {
            this.reloadpage = true;
            this.template.querySelectorAll('c-ts_-error-component')[0].openModal();

        }
    }



    /***************************************************
     * Author             : Karan
     * Created Date       : 29/07/2022
     * Last Modified Date : 29/07/2022
     * Description        : used for getting contact type of login user .
     ***************************************************/
    connectedCallback() {
        try {
            this.isSpinner = true;
            fetchContact()
                .then(result => {
                    if (result != null) {
                        if (result.Community_Contact_Type__c == 'Client') {
                            this.checkClient = false;

                        } else {
                            this.checkClient = true;
                        }
                        this.isSpinner = false;

                    }
                })
                .catch(error => {
                });
        } catch (e) {
            this.reloadpage = true;
            this.template.querySelectorAll('c-ts_-error-component')[0].openModal();

        }

    }

    /***************************************************
     * Author             : Karan
     * Created Date       : 29/07/2022
     * Last Modified Date : 29/07/2022
     * Description        : for Navigate to different component
     ***************************************************/
    redirectpage(event) {
        try {
            var nameval = event.target.dataset.name;
            var urlValue = '/s/';
            this.isSpinner = true;

            var pageapiname;
            if (nameval == 'Profile') {
                urlValue = urlValue + 'profile';
                pageapiname = 'Profile__c';
                this.dispatchEvent(new CustomEvent('getdetails', { bubbles: true, detail: "profile" }));
            } else if (nameval == "Timesheets") {
                urlValue = urlValue + 'timesheet';
                pageapiname = 'TimeSheet__c';
                this.dispatchEvent(new CustomEvent('getdetails', { bubbles: true, detail: "timesheet" }));
            } else if (nameval == 'Scheduler') {
                urlValue = urlValue + 'myavailability';
                pageapiname = 'myAvailability__c';
                this.dispatchEvent(new CustomEvent('getdetails', { bubbles: true, detail: "scheduler" }));
            } else if (nameval == 'Compliance') {
                urlValue = urlValue + 'compliance';
                pageapiname = 'Compliance__c';
                this.dispatchEvent(new CustomEvent('getdetails', { bubbles: true, detail: "compliance" }));
            } else if (nameval == 'My Qualifications') {
                urlValue = urlValue + 'myqualifications';
                pageapiname = 'MyQualifications__c';
                this.dispatchEvent(new CustomEvent('getdetails', { bubbles: true, detail: "myqualifications" }));
            }

            this[NavigationMixin.Navigate]({
                type: 'comm__namedPage',
                attributes: {
                    name: pageapiname,
                    url: urlValue
                },
            });
            this.isLoading = false;
        } catch (e) {
            this.reloadpage = true;
            this.template.querySelectorAll('c-ts_-error-component')[0].openModal();
        }

    }

    /***************************************************
     * Author             : 
     * Created Date       : 29/07/2022
     * Last Modified Date : 29/07/2022
     * Description        : for scroll different optioon in main screen like my account, scheduler, timesheet.
     ***************************************************/
    Next(event) {
        try {
            this.count = this.count + 1;
            if (this.checkClient == false) {
                if (this.count == 0) {
                    let cards = this.template.querySelector('.dbsection-reporting');
                    cards.classList.remove('hide');
                    cards.classList.add('show');


                    let cards2 = this.template.querySelector('.dbsection-compliance');
                    cards2.classList.add('hide');
                    cards2.classList.remove('show');


                    let cards3 = this.template.querySelector('.dbsection-timesheets');
                    cards3.classList.add('hide');
                    cards2.classList.remove('show');


                    let prevIcon = this.template.querySelector('.previousIcon');
                    
                    prevIcon.classList.add('hide');
                    prevIcon.classList.remove('show');

                } else if (this.count == 1) {
                    let cards = this.template.querySelector('.dbsection-reporting');
                    cards.classList.add('hide');
                    cards.classList.remove('show');


                    let cards2 = this.template.querySelector('.dbsection-compliance');
                    cards2.classList.add('show');
                    cards2.classList.remove('hide');


                    let cards3 = this.template.querySelector('.dbsection-timesheets');
                    cards3.classList.add('hide');
                    cards3.classList.remove('show');


                    let prevIcon = this.template.querySelector('.previousIcon');
                    prevIcon.classList.remove('hide');
                    prevIcon.classList.add('show');

                } else if (this.count == 2) {
                    let cards = this.template.querySelector('.dbsection-reporting');
                    cards.classList.add('hide');
                    cards.classList.remove('show');


                    let cards2 = this.template.querySelector('.dbsection-compliance');
                    cards2.classList.add('hide');
                    cards2.classList.remove('show');


                    let cards3 = this.template.querySelector('.dbsection-timesheets');
                    cards3.classList.add('show');
                    cards3.classList.remove('hide');


                    let prevIcon = this.template.querySelector('.previousIcon');
                    let nextIcon = this.template.querySelector('.nextIcon');

                    prevIcon.classList.remove('hide');
                    prevIcon.classList.add('show');

                    nextIcon.classList.remove('show');
                    nextIcon.classList.add('hide');
                }
            }
            if (this.checkClient == true) {
                if (this.count == 0) {
                    let cards = this.template.querySelector('.dbsection-reporting');
                    cards.classList.add('show');
                    cards.classList.remove('hide');

                    let cards3 = this.template.querySelector('.dbsection-timesheets');
                    cards3.classList.add('hide');
                    cards3.classList.remove('show');

                    let cards4 = this.template.querySelector('.dbsection-scheduler');
                    cards4.classList.add('hide');
                    cards4.classList.remove('show');

                    let cards5 = this.template.querySelector('.dbsection-qualification');
                    cards5.classList.add('hide');
                    cards5.classList.remove('show');

                    let prevIcon = this.template.querySelector('.previousIcon');
                    prevIcon.classList.remove('show');
                    prevIcon.classList.add('hide');

                } else if (this.count == 1) {
                    let cards = this.template.querySelector('.dbsection-reporting');
                    cards.classList.add('hide');
                    cards.classList.remove('show');

                    let cards3 = this.template.querySelector('.dbsection-timesheets');
                    cards3.classList.add('hide');
                    cards3.classList.remove('show');

                    let cards4 = this.template.querySelector('.dbsection-scheduler');
                    cards4.classList.add('show');
                    cards4.classList.remove('hide');

                    let cards5 = this.template.querySelector('.dbsection-qualification');
                    cards5.classList.add('hide');
                    cards5.classList.remove('show');

                    let prevIcon = this.template.querySelector('.previousIcon');
                    prevIcon.classList.remove('hide');
                    prevIcon.classList.add('show');

                } else if (this.count == 2) {
                    let cards = this.template.querySelector('.dbsection-reporting');
                    cards.classList.add('hide');
                    cards.classList.remove('show');

                    let cards3 = this.template.querySelector('.dbsection-timesheets');
                    cards3.classList.add('hide');
                    cards3.classList.remove('show');

                    let cards4 = this.template.querySelector('.dbsection-scheduler');
                    cards4.classList.add('hide');
                    cards4.classList.remove('show');


                    let cards5 = this.template.querySelector('.dbsection-qualification');
                    cards5.classList.add('show');
                    cards5.classList.remove('hide');


                    let prevIcon = this.template.querySelector('.previousIcon');
                    let nextIcon = this.template.querySelector('.nextIcon');

                    prevIcon.classList.remove('hide');
                    prevIcon.classList.add('show');

                    nextIcon.classList.remove('hide');
                    nextIcon.classList.add('show');

                } else if (this.count == 3) {
                    let cards = this.template.querySelector('.dbsection-reporting');
                    cards.classList.add('hide');
                    cards.classList.remove('show');

                    let cards3 = this.template.querySelector('.dbsection-timesheets');
                    cards3.classList.add('show');
                    cards3.classList.remove('hide');


                    let cards4 = this.template.querySelector('.dbsection-scheduler');
                    cards4.classList.add('hide');
                    cards4.classList.remove('show');


                    let cards5 = this.template.querySelector('.dbsection-qualification');
                    cards5.classList.add('hide');
                    cards5.classList.remove('show');


                    let prevIcon = this.template.querySelector('.previousIcon');
                    let nextIcon = this.template.querySelector('.nextIcon');

                    prevIcon.classList.remove('hide');
                    prevIcon.classList.add('show');

                    nextIcon.classList.remove('show');
                    nextIcon.classList.add('hide');
                }

            }
        } catch (e) {
            this.reloadpage = true;
            this.template.querySelectorAll('c-ts_-error-component')[0].openModal();

        }


    }

    /***************************************************
     * Author             : 
     * Created Date       : 29/07/2022
     * Last Modified Date : 29/07/2022
     * Description        : for scroll different optioon in main screen like my account, scheduler, timesheet.
     ***************************************************/
    previous(event) {
        try {

            this.count = this.count - 1;
            if (this.checkClient == false) {
                if (this.count == 1) {
                    let cards = this.template.querySelector('.dbsection-reporting');
                    cards.classList.add('hide');
                    cards.classList.remove('show');


                    let cards2 = this.template.querySelector('.dbsection-compliance');
                    cards2.classList.add('show');
                    cards2.classList.remove('hide');


                    let cards3 = this.template.querySelector('.dbsection-timesheets');
                    cards3.classList.add('hide');
                    cards3.classList.remove('show');


                    let prevIcon = this.template.querySelector('.previousIcon');
                    let nextIcon = this.template.querySelector('.nextIcon');

                    prevIcon.classList.remove('hide');
                    prevIcon.classList.add('show');

                    nextIcon.classList.remove('hide');
                    nextIcon.classList.add('show');


                } else if (this.count == 0) {

                    let cards = this.template.querySelector('.dbsection-reporting');
                    cards.classList.add('show');
                    cards.classList.remove('hide');


                    let cards2 = this.template.querySelector('.dbsection-compliance');
                    cards2.classList.add('hide');
                    cards2.classList.remove('show');


                    let cards3 = this.template.querySelector('.dbsection-timesheets');
                    cards3.classList.add('hide');
                    cards3.classList.remove('show');


                    let prevIcon = this.template.querySelector('.previousIcon');
                    let nextIcon = this.template.querySelector('.nextIcon');
                    prevIcon.classList.remove('show');
                    prevIcon.classList.add('hide');

                    nextIcon.classList.remove('hide');
                    nextIcon.classList.add('show');


                } else if (this.count == -1) {
                    let cards = this.template.querySelector('.dbsection-reporting');
                    cards.classList.add('hide');
                    cards.classList.remove('show');


                    let cards2 = this.template.querySelector('.dbsection-compliance');
                    cards2.classList.add('hide');
                    cards2.classList.remove('show');


                    let cards3 = this.template.querySelector('.dbsection-timesheets');
                    cards3.classList.add('show');
                    cards3.classList.remove('hide');


                    let prevIcon = this.template.querySelector('.previousIcon');
                    let nextIcon = this.template.querySelector('.nextIcon');

                    prevIcon.classList.remove('hide');
                    prevIcon.classList.add('show');

                    nextIcon.classList.remove('show');
                    nextIcon.classList.add('hide');
                    this.count = 0;

                }
            }


            if (this.checkClient == true) {
                if (this.count == 2) {
                    let cards = this.template.querySelector('.dbsection-reporting');
                    cards.classList.add('hide');
                    cards.classList.remove('show');



                    let cards3 = this.template.querySelector('.dbsection-timesheets');
                    cards3.classList.add('hide');
                    cards3.classList.remove('show');


                    let cards4 = this.template.querySelector('.dbsection-scheduler');
                    cards4.classList.add('hide');
                    cards4.classList.remove('show');


                    let cards5 = this.template.querySelector('.dbsection-qualification');
                    cards5.classList.add('show');
                    cards5.classList.remove('hide');


                    let prevIcon = this.template.querySelector('.previousIcon');
                    let nextIcon = this.template.querySelector('.nextIcon');

                    prevIcon.classList.remove('hide');
                    prevIcon.classList.add('show');

                    nextIcon.classList.remove('hide');
                    nextIcon.classList.add('show');


                } else if (this.count == 0) {

                    let cards = this.template.querySelector('.dbsection-reporting');
                    cards.classList.add('show');
                    cards.classList.remove('hide');



                    let cards3 = this.template.querySelector('.dbsection-timesheets');
                    cards3.classList.add('hide');
                    cards3.classList.remove('show');


                    let cards4 = this.template.querySelector('.dbsection-scheduler');
                    cards4.classList.add('hide');
                    cards4.classList.remove('show');


                    let cards5 = this.template.querySelector('.dbsection-qualification');
                    cards5.classList.add('hide');
                    cards5.classList.remove('show');


                    let prevIcon = this.template.querySelector('.previousIcon');
                    let nextIcon = this.template.querySelector('.nextIcon');

                    prevIcon.classList.remove('show');
                    prevIcon.classList.add('hide');

                    nextIcon.classList.remove('hide');
                    nextIcon.classList.add('show');

                } else if (this.count == 1) {
                    let cards = this.template.querySelector('.dbsection-reporting');
                    cards.classList.add('hide');
                    cards.classList.remove('show');


                    let cards5 = this.template.querySelector('.dbsection-qualification');
                    cards5.classList.add('hide');
                    cards5.classList.remove('show');


                    let cards3 = this.template.querySelector('.dbsection-timesheets');
                    cards3.classList.add('hide');
                    cards3.classList.remove('show');


                    let cards4 = this.template.querySelector('.dbsection-scheduler');
                    cards4.classList.add('show');
                    cards4.classList.remove('hide');


                    let prevIcon = this.template.querySelector('.previousIcon');
                    let nextIcon = this.template.querySelector('.nextIcon');

                    prevIcon.classList.remove('hide');
                    prevIcon.classList.add('show');

                    nextIcon.classList.remove('hide');
                    nextIcon.classList.add('show');

                }
            }

        } catch (e) {
            this.reloadpage = true;
            this.template.querySelectorAll('c-ts_-error-component')[0].openModal();
        }
    }
    check(event) {
        this.dispatchEvent(new CustomEvent('getmenu', { bubbles: true, detail: "profile" }));
    }
}