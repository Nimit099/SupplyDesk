/*******************************************************
* Name          : ts_scheduler
* Author        : Nitin, Mihir
* Create Date   : 29/07/2022
* Description   : Used in ts_scheduler Component in community site
*******************************************************/

import { LightningElement, track, wire } from 'lwc';
import { loadScript, loadStyle } from 'lightning/platformResourceLoader';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import FullCalendarJS from '@salesforce/resourceUrl/FullCalendarJS';
import deleteCalEvent from '@salesforce/apex/ts_schedulercontroller.deleteCalEvent';
import saveCreateAvailRecord from '@salesforce/apex/ts_schedulercontroller.saveCreateAvailRecord';
import saveDateRange from '@salesforce/apex/ts_schedulercontroller.saveDateRange';
import fetchData from '@salesforce/apex/ts_schedulercontroller.fetchData';
import displaySelectedDateAvailability from '@salesforce/apex/ts_schedulercontroller.displaySelectedDateAvailability';
import displayMonthWeekAvailability from '@salesforce/apex/ts_schedulercontroller.displayMonthWeekAvailability';
import communityicon from '@salesforce/resourceUrl/communityicons';
import Candidate_Availability__c from '@salesforce/schema/Candidate_Availability__c';
import { getPicklistValues, getObjectInfo } from 'lightning/uiObjectInfoApi';
import Type__c from '@salesforce/schema/Candidate_Availability__c.Type__c';
import { refreshApex } from '@salesforce/apex';
export default class FullCalendarJs extends LightningElement {

    avlIcon = communityicon + '/communityicons/available.png';
    unavlIcon = communityicon + '/communityicons/notworking.png';
    bkdBAnotherIcon = communityicon + '/communityicons/workingforother.png';

    @track reloadpage;
    @track selectedDate = "";
    @track totalEventCount;
    @track eventWrapperList = [];

    @track availiblityDataLst = [];
    @track totalAvailiblityCount;
    @track eventTypeOption = [];

    @track availableCount = 0;
    @track unAvailableCount = 0;
    @track bkdbyanthagency = 0;

    @track isDateClicked = true;
    @track selectedDateForAvaibilityList = "";

    @track monthWiseAvailibilityData = [];
    @track monthWiseAvailibilityDataSize = 0;
    @track isMonthButtonClicked = false;
    @track viewStartDate = '';
    @track viewEndDate = '';
    @track viewTitle = '';

    //To avoid the recursion from renderedcallback
    fullCalendarJsInitialised = false;
    value = 'Available';
    //Fields to store the event data -- add all other fields you want to add
    title;
    startDate;
    endDate;
    typeValue;
    deletevalue;
    allevent;

    wrapp = [];

    //To store the orignal wire object to use in refreshApex method
    eventOriginalData = [];

    eventsRendered = false;      //To render initial events only once
    openSpinner = false;        //To open the spinner in waiting screens
    openModal = false;         //To open form
    openDeleteModal = false;  // To open delete model

    @track
    events = []; //all calendar events are stored in this field


    showRange = false;  //Added for date range by Karan
    mon = true;
    tue = true;
    wed = true;
    thu = true;
    fri = true;
    sat = false;
    sun = false;

    startDateDr;
    endDateDr;
    startTimeDr;
    endTimeDr;

    stRange;
    edRange;

    /***************************************************
    * Author             : Nitin
    * Created Date       : 29/07/2022
    * Last Modified Date : 29/07/2022
    * Description        : getting picklist value of Candidate_Availability__c object's ==> Type__c field.
    ***************************************************/
    @wire(getObjectInfo, { objectApiName: Candidate_Availability__c })
    qualObjectInfo;

    @wire(getPicklistValues, {
        recordTypeId: '$qualObjectInfo.data.defaultRecordTypeId',
        fieldApiName: Type__c
    })

    overseasteacherOps(data, error) {
        try {
            if (data && data.data && data.data.values) {
                let options = [];
                data.data.values.forEach(objPicklist => {
                    options.push({ label: objPicklist.value, value: objPicklist.value });
                });
                this.eventTypeOption = options;
            } 
        } catch (error) {
            this.reloadpage = true;
            this.template.querySelectorAll('c-ts_-error-component')[0].openModal();        }
    };

    /***************************************************
    * Author             : Nitin
    * Created Date       : 29/07/2022
    * Last Modified Date : 29/07/2022
    * Description        : Load the fullcalendar.io in this lifecycle hook method
    ***************************************************/
    renderedCallback() {
        try {
            // Performs this operation only on first render
            if (this.fullCalendarJsInitialised) {
                return;
            }
            this.fullCalendarJsInitialised = true;
            this.getAllavaibilityData();
            const ele = this.template.querySelector('div.fullcalendarjs');
            const modal = this.template.querySelector('div.modalclass');

            // Executes all loadScript and loadStyle promises
            // and only resolves them once all promises are done
            try {
                Promise.all([
                    loadScript(this, FullCalendarJS + '/FullCalendarJS/jquery.min.js'),
                    loadScript(this, FullCalendarJS + '/FullCalendarJS/moment.min.js'),
                    loadScript(this, FullCalendarJS + '/FullCalendarJS/fullcalendar.min.js'),
                    loadStyle(this, FullCalendarJS + '/FullCalendarJS/fullcalendar.min.css'),
                ])
                    .then(() => {
                        const ele = this.template.querySelector('div.fullcalendarjs');
                        const modal = this.template.querySelector('div.modalclass');
                        setTimeout(() => {
                            this.initializeCalendar();
                        }, 500);
                    })
                    .catch((error) => {
                        setTimeout(() => {
                            this.initializeCalendar();
                        }, 500);
                    });
            } catch (error) {
            }
        } catch (error) {
            this.reloadpage = true;
            this.template.querySelectorAll('c-ts_-error-component')[0].openModal();
        }
    }

    connectedCallback() {
        try {
            this.wrapp = {};
            this.wrapp.startDate = '';
            this.wrapp.EndDate = '';
            this.wrapp.TypeValue = 'Available';
            this.wrapp.mon = true;
            this.wrapp.tue = true;
            this.wrapp.wed = true;
            this.wrapp.thu = true;
            this.wrapp.fri = true;
            this.wrapp.sat = false;
            this.wrapp.sun = false;
            this.wrapp.sd_dr = '';
            this.wrapp.ed_dr = '';
            this.wrapp.st_dr = '';
            this.wrapp.et_dr = '';
            this.wrapp.st_dttm = '';
            this.wrapp.ed_dttm = '';
            this.getDateInFormat();
        } catch (error) {
            this.reloadpage = true;
            this.template.querySelectorAll('c-ts_-error-component')[0].openModal();
        }
    }

    /***************************************************
    * Author             : Nitin
    * Created Date       : 29/07/2022
    * Last Modified Date : 29/07/2022
    * Description        : get screen size and set calender size
    ***************************************************/
    getScreenSize() {
        try {
            let ScreenWidth = screen.width;
            if (767 < ScreenWidth && ScreenWidth <= 1024) {
                setTimeout(() => {
                    const ele = this.template.querySelector('div.fullcalendarjs');
                    $(ele).fullCalendar({
                        defaultDate: new Date(),
                        defaultView: 'agendaDay',
                        navLinks: true,
                        selectHelper: true,
                        selectable: true,
                    });
                }, 2000);
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
    * Description        : Get data from server - in this example, it fetches from the event object
    ***************************************************/

    @wire(fetchData)
    eventObj(value) {
        try {
            this.eventOriginalData = value; //To use in refresh cache
            const { data, error } = value;
            this.allevent = value;
            if (data) {
                setTimeout(() => {

                    //format as fullcalendar event object
                    let events = data.map((event) => {
                        return {
                            id: event.Id,
                            start: event.Start_Date_Time__c,
                            end: event.End_Date_Time__c,
                            typeValue: event.Type__c, //to get the type values from backend
                        };
                    });
                    this.events = JSON.parse(JSON.stringify(events));
                    this.totalEventCount = this.events.length;
                    this.error = undefined;

                    //load only on first wire call -
                    // if events are not rendered, try to remove this 'if' condition and add directly
                    if (!this.eventsRendered) {
                        //Add events to calendar
                        const ele = this.template.querySelector('div.fullcalendarjs');
                        $(ele).fullCalendar('renderEvents', this.events, true);
                        this.eventsRendered = true;
                    }
                }, 2000);
            } else if (error) {
                this.events = [];
                this.error = 'No events are found';
            }
        } catch (error) {
            this.reloadpage = true;
            this.template.querySelectorAll('c-ts_-error-component')[0].openModal();
        }
    }

    /***************************************************
    * Author             : Nitin
    * Created Date       : 29/07/2022
    * Last Modified Date : 03/08/2022
    * Description        : Get calender
    ***************************************************/
    initializeCalendar() {
        try {
            const ele = this.template.querySelector('div.fullcalendarjs');
            const modal = this.template.querySelector('div.modalclass');
            var self = this;

            //To open the form with predefined fields
            //TODO: to be moved outside this function
            function openActivityForm(mainStartDate, mainEndDate, StartDateOL) {
                self.startDate;
                self.endDate;
                self.openModal = true;
                self.typeValue = 'Available';
            }

            let ScreenWidth = screen.width;
            let defaultViewCondition = 'agendaWeek';
            if (ScreenWidth <= 1024) {
                defaultViewCondition = 'agendaDay'; // For Ipad and Mobile View
            }
            $(ele).fullCalendar({
                header: {
                    left: 'prev',
                    center: 'title',
                    right: 'month,agendaWeek,agendaDay,today,next',
                },
                views: {
                    month: {
                        columnFormat: 'ddd',
                        // options apply to basicWeek and basicDay views
                    },
                    agendaWeek: {
                        // options apply to agendaWeek and agendaDay views
                        columnFormat: 'ddd D/M',
                    },
                    week: {
                        columnFormat: 'ddd D/M',
                        // options apply to basicWeek and agendaWeek views
                    },
                    day: {
                        // options apply to basicDay and agendaDay views
                    }
                },
                defaultDate: new Date(), // default day is today - to show the current date
                defaultView: defaultViewCondition, //To display the default view - as of now it is set to week view
                navLinks: true, // can click day/week names to navigate views
                selectHelper: true,
                firstDay: 1,
                selectable: true, //To select the period of time
                dragScroll: false,
                eventOverlap: false,
                slotEventOverlap: false,
                longPressDelay: 250,
                showNonCurrentDates: false,
                navLinkDayClick: function (date, jsEvent) {
                    self.selectedDateForAvaibilityList = date.format();
                    self.selectedDate = date.format().slice(8, 10) + " " + self.toMonthName(date.format().slice(5, 7));
                    self.getAllavaibilityData();
                    self.isDateClicked = true;
                    self.isMonthButtonClicked = false;
                },

                //To select the time period : https://fullcalendar.io/docs/v3/select-method
                select: function (startD, endD) {
                    // console.log('select function');
                    self.stRange = startD;
                    self.edRange = endD;

                    let stDate = startD.toJSON().slice(0, 10);
                    var today = new Date().toJSON().slice(0, 10);
                    if (stDate >= today) {
                        self.openModal = true;
                        var sDate = startD.toISOString() + ".000Z";
                        var sDate_hr = sDate.substring(11, 13) ;
                        var s = sDate_hr.toString().padStart(2, '0');

                        var edate = endD.toISOString() + ".000Z";
                        var eDate_hr = edate.substring(11, 13) ;
                        var es = eDate_hr.toString().padStart(2, '0');

                        // console.log(sDate+'<<>>'+edate);

                        if (sDate_hr == -1) {
                            var s = "23";
                            var fs = sDate.substring(0, 11) + s + sDate.substring(13, sDate.length);
                            var ea = edate.substring(8, 10);
                            if (sDate.substring(11, 16) == "00:30") {
                                var eb = Number(ea);
                            }
                            else {
                                var eb = Number(ea) - 1;
                                // var eb = Number(ea) ;
                            }

                            if (sDate.substring(14, 16) != "30") {
                                es = "23";
                                var fe = edate.substring(0, 8) + eb.toString().padStart(2, '0') + "T" + es + edate.substring(13, edate.length);
                            }
                            else {
                                var fe = edate.substring(0, 8) + eb.toString().padStart(2, '0') + "T" + es + edate.substring(13, edate.length);
                            }

                            if (sDate.substring(11, 16) == "00:00" || sDate.substring(11, 16) == "00:30") {
                                var sa = sDate.substring(8, 10);
                                var sb = Number(sa) - 1;
                                // var sb = Number(sa) ;
                                var fs = sDate.substring(0, 8) + sb.toString().padStart(2, '0') + "T" + s + sDate.substring(13, sDate.length);
                            }
                            else {
                                var fs = sDate.substring(0, 11) + s + sDate.substring(13, sDate.length);
                            }
                        }
                        else {
                            var fs = sDate.substring(0, 11) + s + sDate.substring(13, sDate.length);
                            var fe = edate.substring(0, 11) + es + edate.substring(13, edate.length);
                        }

                        if (sDate.substring(11, 16) == "23:30") {
                            es = "23";
                            var fe = "";
                        }
                        
                        if (fs.length == 24) {
                            self.startDate = fs;
                        }
                        else {
                            self.startDate = '';
                        }

                        if (fe.length == 24) {
                            self.endDate = fe;
                        }
                        else {
                            self.endDate = '';
                        }

                        // console.log(self.startDate+'<<>>'+self.endDate);
                    } else {
                        self.template.querySelector('c-ts_-tost-notification').showToast('error', 'Cannot create event for date less than today.', 3000);
                    }
                },

                //to identify log when clicked on the event
                eventClick: function (info, event, view) {
                    var eventObj = info.typeValue + ' ------------ ' + info.id;
                    self.openDeleteModal = true;
                    self.deletevalue = info.id;
                },
                viewRender: function (view, element) {
                    var vrSD = new Date(view.intervalStart._i);
                    var vrED = new Date(view.intervalEnd._i - 1000); // for substracting 1 second
                    self.viewTitle = view.title;
                    self.viewStartDate = vrSD.toISOString();
                    self.viewEndDate = vrED.toISOString();
                },

                eventLimit: true, // allow "more" link when too many events
                events: this.events, // all the events that are to be rendered - can be a duplicate statement here

                eventRender: function (info, element, event) {
                    var sdt = info.start._i.substring(0, 10).split("-").reverse().join("-") + "   " + info.start._i.substring(11, 16);
                    var edt = info.end._i.substring(0, 10).split("-").reverse().join("-") + "   " + info.end._i.substring(11, 16);

                    if (info.typeValue == undefined) {
                        info.typeValue = "";
                    }
                    element.find('.fc-content').append("<br/><b>Status:&nbsp;</b>" + info.typeValue);
                    element.find('.fc-content').append("<br/><b>Start Time:&nbsp;</b>" + sdt);
                    element.find('.fc-content').append("<br/><b>End Time:&nbsp;</b>" + edt);

                    //to set the colors of the events from typeValue
                    if (info.typeValue == 'Available') {
                        element.css('background-color', '#FAE7CA');
                    } else if (info.typeValue == 'Unavailable') {
                        element.css('background-color', '#EDE4F6');
                    } else if (info.typeValue == 'Interview') {
                        element.css('background-color', 'rgb(152 145 145)');
                    } else if (info.typeValue == 'Holiday') {
                        element.css('background-color', '#c9c9c9');
                    }
                    else if (info.typeValue == 'Sick') {
                        element.css('background-color', 'rgb(227 157 157)');
                    } else if (info.typeValue == 'Working for Another Agency') {
                        element.css('background-color', '#CBE3F5');
                    } else if (info.typeValue == 'Booked') {
                        element.css('background-color', '#D95252');
                    }
                },
            });



            // Month Button Clicked in Calendar
            const monthEle = this.template.querySelector('.fc-month-button');
            monthButtonClick();
            function monthButtonClick() {
                $(monthEle).click(function () {
                    self.getMonthWeekAvailiblityData(self.viewStartDate, self.viewEndDate);
                });
            }

            // week Button Clicked in Calendar
            const weekEle = this.template.querySelector('button.fc-agendaWeek-button');
            weekButtonClick();
            function weekButtonClick() {
                $(weekEle).click(function () {
                    self.getMonthWeekAvailiblityData(self.viewStartDate, self.viewEndDate);
                });
            }

            // Day Button Clicked in Calendar
            const dayEle = this.template.querySelector('button.fc-agendaDay-button');
            dayButtonClick();
            function dayButtonClick() {
                $(dayEle).click(function () {
                    self.getMonthWeekAvailiblityData(self.viewStartDate, self.viewEndDate);
                });
            }

            // Previous Button Clicked in Calendar
            const prevBtnEle = this.template.querySelector('button.fc-prev-button');
            prevButtonClick();
            function prevButtonClick() {
                $(prevBtnEle).click(function () {
                    self.getMonthWeekAvailiblityData(self.viewStartDate, self.viewEndDate);
                });
            }

            // Next Button Clicked in Calendar
            const nextBtnEle = this.template.querySelector('button.fc-next-button');
            nextButtonClick();
            function nextButtonClick() {
                $(nextBtnEle).click(function () {
                    self.getMonthWeekAvailiblityData(self.viewStartDate, self.viewEndDate);
                });
            }

            // today Button Clicked in Calendar
            const todayBtnEle = this.template.querySelector('button.fc-today-button');
            todayButtonClick();
            function todayButtonClick() {
                $(todayBtnEle).click(function () {
                    self.getMonthWeekAvailiblityData(self.viewStartDate, self.viewEndDate);
                });
            }


        } catch (errorinitializedfullcalender) {
            this.reloadpage = true;
            eval("$A.get('e.force:refreshView').fire();");
            window.location.reload();
        }
    }

    /***************************************************
    * Author             : Nitin
    * Created Date       : 29/07/2022
    * Last Modified Date : 03/08/2022
    * Description        : To close the modal form
    ***************************************************/
    handleCancel(event) {
        try {
            this.openModal = false;
            this.openDeleteModal = false;

            this.showRange = false;
        } catch (error) {
            this.reloadpage = true;
            this.template.querySelectorAll('c-ts_-error-component')[0].openModal();
        }
    }

    /***************************************************
    * Author             : Nitin
    * Created Date       : 29/07/2022
    * Last Modified Date : 29/07/2022
    * Description        : open the modal by nullifying the inputs and these events will be shows on left sidebar
    ***************************************************/
    addEvent(event) {
        try {
            this.startDate = null;
            this.endDate = null;
            this.title = null;
            this.typeValue = null;
            this.openModal = true;
        } catch (error) {
            this.reloadpage = true;
            this.template.querySelectorAll('c-ts_-error-component')[0].openModal();
        }
    }

    /***************************************************
    * Author             : -
    * Created Date       : 29/07/2022
    * Last Modified Date : 29/07/2022
    * Description        : Not Use Anywhere
    ***************************************************/
    handleKeyup(event) {
        try {
            this.title = event.target.value;
        } catch (error) {
            this.reloadpage = true;
            this.template.querySelectorAll('c-ts_-error-component')[0].openModal();
        }
    }

    /***************************************************
    * Author             : Nitin
    * Created Date       : 29/07/2022
    * Last Modified Date : 29/07/2022
    * Description        : set Availability, run on change Availability picklist
    ***************************************************/
    handleChange(event) {
        try {
            if (event.target.name == 'mon')
                this.mon = event.target.checked;
            else if (event.target.name == 'tue')
                this.tue = event.target.checked;
            else if (event.target.name == 'wed')
                this.wed = event.target.checked;
            else if (event.target.name == 'thu')
                this.thu = event.target.checked;
            else if (event.target.name == 'fri')
                this.fri = event.target.checked;
            else if (event.target.name == 'sat')
                this.sat = event.target.checked;
            else if (event.target.name == 'sun')
                this.sun = event.target.checked;
            else if (event.target.name == 'Type') {
                this.value = event.target.value;
                this.wrapp.TypeValue = this.value;
                this.typeValue = event.target.valuse; //?used to display it on the main pagee
            }
            this.wrapp.mon = this.mon;
            this.wrapp.tue = this.tue;
            this.wrapp.wed = this.wed;
            this.wrapp.thu = this.thu;
            this.wrapp.fri = this.fri;
            this.wrapp.sat = this.sat;
            this.wrapp.sun = this.sun;

        } catch (error) {
            this.reloadpage = true;
            this.template.querySelectorAll('c-ts_-error-component')[0].openModal();
        }
    }

    //Added for date range
    displayRange(event) {
        try {
            this.showRange = !this.showRange;  //Added for date range            

            const date = new Date(this.startDate);
            date.setDate(date.getDate() + parseInt(1));

            this.startDateDr = this.stRange.toJSON().slice(11, 16) != '00:00' ? this.startDate : date.toISOString();
            this.endDateDr = this.stRange.toJSON().slice(11, 16) != '00:00' ? this.endDate : date.toISOString();
            this.startTimeDr = this.stRange.toJSON().slice(11, 16);
            this.endTimeDr = this.edRange.toJSON().slice(11, 16);

        } catch (error) {
            this.reloadpage = true;
            this.template.querySelectorAll('c-ts_-error-component')[0].openModal();
        }
    }

    handleDateChange(event) {
        try {
            if (event.target.name == 'startdatedr') {
                this.startDateDr = event.target.value;
            }
            else if (event.target.name == 'enddatedr') {
                this.endDateDr = event.target.value;
            }
            else if (event.target.name == 'starttimedr') {
                this.startTimeDr = event.target.value;
            }
            else if (event.target.name == 'endtimedr') {
                this.endTimeDr = event.target.value;
            }
            var sd_dr = this.startDateDr.split("T")[0];
            var ed_dr = this.endDateDr.split("T")[0];
            var st_dr = this.startTimeDr;
            var et_dr = this.endTimeDr;

            this.wrapp.sd_dr = sd_dr;
            this.wrapp.ed_dr = ed_dr;
            this.wrapp.st_dr = st_dr;
            this.wrapp.et_dr = et_dr;

            this.wrapp.st_dttm = sd_dr + 'T' + st_dr + ':00.000Z';
            this.wrapp.ed_dttm = ed_dr + 'T' + ed_dr + ':00.000Z';

        } catch (error) {
            this.reloadpage = true;
            this.template.querySelectorAll('c-ts_-error-component')[0].openModal();        }
    }

    /***************************************************
    * Author             : Nitin
    * Created Date       : 29/07/2022
    * Last Modified Date : 29/07/2022
    * Description        : To save the event
    ***************************************************/
    handleSave(event) {
        if (this.showRange == true) {

            var sd_dr = this.startDateDr.split("T")[0];
            var ed_dr = this.endDateDr.split("T")[0];
            var st_dr = this.startTimeDr;
            var et_dr = this.endTimeDr;


            this.wrapp.sd_dr = sd_dr;
            this.wrapp.ed_dr = ed_dr;
            this.wrapp.st_dr = st_dr;
            this.wrapp.et_dr = et_dr;

            this.wrapp.st_dttm = sd_dr + 'T' + st_dr + ':00.000Z';
            this.wrapp.ed_dttm = ed_dr + 'T' + et_dr + ':00.000Z';

            var wrdata = JSON.stringify(this.wrapp);

            var eventCondition = true;
            var eventlst = this.allevent.data;

            var today = new Date();

            var td = this.wrapp.st_dttm;
            if (today.toISOString() > td) {

                this.template.querySelector('c-ts_-tost-notification').showToast('error', 'Cannot create event for date less than today.', 3000);
                this.openSpinner = false;
                eventCondition = false;
                this.openModal = false;
            }

            if (eventCondition) {
                this.wrapp.typeValue = this.value;
                if (this.wrapp.st_dttm == this.wrapp.ed_dttm) {
                    this.template.querySelector('c-ts_-tost-notification').showToast('error', 'Start date and End date can not be same.', 3000);
                    this.openSpinner = false;
                } else if (this.wrapp.typeValue == "" || this.wrapp.typeValue == null) {
                    this.template.querySelector('c-ts_-tost-notification').showToast('error', 'Type Can not be null.', 3000);
                    this.openSpinner = false;
                } else if (this.wrapp.st_dttm > this.wrapp.ed_dttm) {
                    this.template.querySelector('c-ts_-tost-notification').showToast('error', 'Start Date Should Be smaller than End Date.', 3000);
                    this.openSpinner = false;
                }
                else {
                    saveDateRange({ wrapperdata: wrdata })
                        .then((result) => {
                            const ele1 = this.template.querySelector('div.fullcalendarjs');

                            //To populate the event on fullcalendar object
                            //Id should be unique and useful to remove the event from UI - calendar

                            for (var i = 0; i < result.length; i++) {

                                let neweventdt = {
                                    title: this.title,
                                    typeValue: result[i].Type__c,
                                    start: result[i].Start_Date_Time__c,
                                    end: result[i].End_Date_Time__c,
                                    id: result[i].Id
                                };
                                $(ele1).fullCalendar('renderEvent', neweventdt, true);
                                this.events.push(neweventdt);
                            }

                            //To display on UI with id from server                        

                            //renderEvent is a fullcalendar method to add the event to calendar on UI
                            //Documentation: https://fullcalendar.io/docs/v3/renderEvent

                            this.template.querySelector('c-ts_-tost-notification').showToast('success', 'availability Created Successfuly.', 3000);
                            this.openModal = false;
                            this.getAllavaibilityData();
                            this.showRange = false;
                            this.openSpinner = false;
                        })
                        .catch((error) => {
                            this.template.querySelector('c-ts_-tost-notification').showToast('error', 'Something went wrong.', 3000);
                            this.openModal = false;
                            this.openSpinner = false;
                            this.showRange = false;
                        });
                }
            }

        }
        else {
            this.saveEvent();
        }
    }


    saveEvent(event) {
        try {
            let events = this.events;
            this.openSpinner = true;

            this.wrapp.typeValue = this.typeValue; //? for passing value to backend
            this.wrapp.startDate = this.startDate;
            this.wrapp.EndDate = this.endDate;

            var aaa = this.wrapp;

            this.template.querySelectorAll('lightning-combobox').forEach((ele) => {
                if (ele.name === 'Type') {
                    this.wrapp.typeValue = ele.value;
                }
            });

            //get all the field values - as of now they all are mandatory to create a standard event
            //TODO- you need to add your logic here.
            this.template.querySelectorAll('lightning-input').forEach((ele) => {
                if (ele.name === 'title') {

                    if (ele.value == undefined || ele.value == null) {
                        this.title = "";
                    }
                    else {
                        this.title = ele.value;
                    }
                }
                if (ele.name === 'start') {

                    if (ele.value == null) {
                        this.startDate = "";
                        this.wrapp.startDate = "";
                    }
                    else {// time difference emoved in date time value
                        var sdt = ele.value;
                        var stime_v = sdt.substring(11, 13);
                        if (stime_v == "23") {
                            stime_v = "-1";
                            var stime_up = Number(stime_v) + 1;
                            var sdt_a = Number(sdt.substring(8, 10)) ;
                            var final_sdt = sdt.substring(0, 8) + sdt_a.toString().padStart(2, '0') + "T" + stime_up.toString().padStart(2, '0') + sdt.substring(13, sdt.length);
                        }
                        else {
                            var stime_up = Number(stime_v);
                            var final_sdt = sdt.substring(0, 11) + stime_up.toString().padStart(2, '0') + sdt.substring(13, sdt.length);
                        }
                        this.startDate = final_sdt;
                        this.wrapp.startDate = final_sdt;
                    }
                }
                if (ele.name === 'end') {

                    if (ele.value == null) {
                        this.endDate = "";
                        this.wrapp.EndDate = "";
                    }
                    else {
                        // time difference emoved in date time value
                        var edt = ele.value;
                        var etime_v = edt.substring(11, 13);
                        if (etime_v == "23") {
                            etime_v = "-1";
                            var etime_up = Number(etime_v) + 1;
                            var edt_a = Number(edt.substring(8, 10)) ;
                            var final_edt = edt.substring(0, 8) + edt_a.toString().padStart(2, '0') + "T" + etime_up.toString().padStart(2, '0') + edt.substring(13, edt.length);
                        }
                        else {
                            var etime_up = Number(etime_v) ;
                            var final_edt = edt.substring(0, 11) + etime_up.toString().padStart(2, '0') + edt.substring(13, edt.length);
                        }
                        this.endDate = final_edt;
                        this.wrapp.EndDate = final_edt;
                    }
                }
            });

            if (this.wrapp.typeValue == undefined || this.wrapp.startDate.length != 24 || this.wrapp.EndDate.length != 24) {

                this.template.querySelector('c-ts_-tost-notification').showToast('error', 'Something went wrong.', 3000);
                this.openSpinner = false;
                this.openModal = false;
            }
            else {

                var event_condition = true;
                var eventlst = this.allevent.data;
                eventlst.forEach(element => {
                    var as = element.Start_Date_Time__c;
                    var ae = element.End_Date_Time__c;

                    var bs = this.wrapp.startDate;
                    var be = this.wrapp.EndDate;

                    if (as >= bs && be >= as && ae >= bs && be >= ae) {
                        this.template.querySelector('c-ts_-tost-notification').showToast('error', 'Overlapping Candidate Availability cannot be created.', 3000);
                        this.openSpinner = false;
                        event_condition = false;
                    }

                    if (ae >= bs && bs >= as && ae >= be && be >= as) {
                        this.template.querySelector('c-ts_-tost-notification').showToast('error', 'Overlapping Candidate Availability cannot be created.', 3000);
                        this.openSpinner = false;
                        event_condition = false;
                    }
                })

                var today = new Date();
                var td = this.wrapp.startDate;
                if (today.toISOString() > td) {
                    this.template.querySelector('c-ts_-tost-notification').showToast('error', 'Cannot create event for date less than today.', 3000);
                    this.openSpinner = false;
                    event_condition = false;
                }

                if (event_condition) {
                    //format as per fullcalendar event object to create and render
                    let newevent = {
                        title: this.title,
                        typeValue: this.wrapp.typeValue,
                        start: this.wrapp.startDate,
                        end: this.wrapp.EndDate,
                    };

                    //Close the modal
                    this.endDate = "";
                    this.openModal = false;

                    let wrapD = JSON.stringify(aaa);

                    var wrdata = JSON.stringify(this.wrapp);

                    if (this.wrapp.startDate == this.wrapp.EndDate) {
                        this.template.querySelector('c-ts_-tost-notification').showToast('error', 'Start date and End date can not be same.', 3000);
                        this.openSpinner = false;
                    } else if (this.wrapp.typeValue == "" || this.wrapp.typeValue == null) {
                        this.template.querySelector('c-ts_-tost-notification').showToast('error', 'Type Can not be null.', 3000);
                        this.openSpinner = false;
                    } else if (this.wrapp.startDate > this.wrapp.EndDate) {
                        this.template.querySelector('c-ts_-tost-notification').showToast('error', 'Start Date Should Be smaller than End Date.', 3000);
                        this.openSpinner = false;
                    } else {
                        saveCreateAvailRecord({ wrapperdata: wrdata })
                            .then((result) => {

                                const ele = this.template.querySelector('div.fullcalendarjs');

                                //To populate the event on fullcalendar object
                                //Id should be unique and useful to remove the event from UI - calendar
                                newevent.id = result;

                                //renderEvent is a fullcalendar method to add the event to calendar on UI
                                //Documentation: https://fullcalendar.io/docs/v3/renderEvent
                                $(ele).fullCalendar('renderEvent', newevent, true);

                                //To display on UI with id from server
                                this.events.push(newevent);

                                this.endDate = null;
                                this.startDate = null;
                                //To close spinner and modal
                                this.openSpinner = false;
                                this.template.querySelector('c-ts_-tost-notification').showToast('success', 'availability Created Successfuly.', 3000);
                                this.getAllavaibilityData();
                            })
                            .catch((error) => {
                                this.openSpinner = false;
                                this.template.querySelector('c-ts_-tost-notification').showToast('error', 'Something went wrong.', 3000);
                            });
                    }
                }
                else {
                    this.endDate = "";
                    this.openModal = false;

                    let wrapD = JSON.stringify(aaa);

                    var wrdata = JSON.stringify(this.wrapp);
                }
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
    * Description        : remove the event with id
    * documentation      : https://fullcalendar.io/docs/v3/removeEvents
    ***************************************************/
    removeEvent(event) {
        try {
            //open the spinner
            this.openSpinner = true;

            //delete the event from server and then remove from UI
            let eventid = event.target.value;

            deleteCalEvent({ eventid: eventid })
                .then((result) => {

                    const ele = this.template.querySelector('div.fullcalendarjs');
                    $(ele).fullCalendar('removeEvents', [eventid]);

                    this.openSpinner = false;
                    this.openDeleteModal = false;
                    this.getAllavaibilityData();
                    //refresh the grid
                    return refreshApex(this.eventOriginalData);

                })
                .catch((error) => {
                    this.openSpinner = false;
                    this.openDeleteModal = false;
                });
        } catch (error) {
            this.reloadpage = true;
            this.openDeleteModal = false;
            this.template.querySelectorAll('c-ts_-error-component')[0].openModal();
        }
    }

    /***************************************************
    * Author             : Nitin
    * Created Date       : 29/07/2022
    * Last Modified Date : 29/07/2022
    * Description        : For Displaying Events List In RightSide.
    ***************************************************/
    getDateInFormat() {
        try {
            var today = new Date();
            var dd = String(today.getDate()).padStart(2, '0');
            var mm = String(today.getMonth() + 1).padStart(2, '0'); 
            var yyyy = today.getFullYear();
            today = yyyy + '-' + mm + '-' + dd;

            this.selectedDate = dd + " " + this.toMonthName(mm); // For Current Date
            this.selectedDateForAvaibilityList = today;
            return today;
        } catch (error) {
            this.reloadpage = true;
            this.template.querySelectorAll('c-ts_-error-component')[0].openModal();
        }
    }

    /***************************************************
    * Author             : Nitin
    * Created Date       : 29/07/2022
    * Last Modified Date : 29/07/2022
    * Description        : for set month
    ***************************************************/
    toMonthName(monthNumber) {
        try {
            const date = new Date();
            date.setMonth(monthNumber - 1);

            // 👇️ using visitor's default locale
            return date.toLocaleString([], {
                month: 'long',
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
    * Description        : for set availablity data
    ***************************************************/
    getAllavaibilityData() {
        try {
            this.openSpinner = true;
            var dateofAvail = this.selectedDateForAvaibilityList;

            displaySelectedDateAvailability({ dateofAvail: dateofAvail })
                .then((result) => {
                    this.availiblityDataLst = result;
                    this.totalAvailiblityCount = result.length;

                    this.availableCount = 0;
                    this.unAvailableCount = 0;
                    this.bkdbyanthagency = 0;

                    for (const res of result) {

                        // console.log({res});
                        res["startTime"] = res.Start_Date_Time__c.substring(11, 16) + ' - ' + res.End_Date_Time__c.substring(11, 16);
                        var date1 = new Date(res.Start_Date_Time__c);
                        var date2 = new Date(res.End_Date_Time__c);
                        var Difference_In_Time = date2.getTime() - date1.getTime();
                        var Difference_In_Time = Difference_In_Time / (1000 * 60);
                        res["totalDuration"] = Difference_In_Time;

                        if (res.Type__c == "Available") {
                            this.availableCount = this.availableCount + 1;
                        } else if (res.Type__c == "Unavailable") {
                            this.unAvailableCount = this.unAvailableCount + 1;
                        } else if (res.Type__c == "Working for Another Agency") {
                            this.bkdbyanthagency = this.bkdbyanthagency + 1;
                        }
                    }
                    this.openSpinner = false;
                })
                .catch((error) => {
                    if (error) {
                        this.openSpinner = false;
                        if (Array.isArray(error.body)) {
                            this.errorMsg = error.body.map((e) => e.message).join(", ");
                        } else if (typeof error.body.message === "string") {
                            this.errorMsg = error.body.message;
                        }
                    }
                });
        } catch (error) {
            this.reloadpage = true;
            this.template.querySelectorAll('c-ts_-error-component')[0].openModal();
        }
    }

    /***************************************************
    * Author             : Nitin
    * Created Date       : 05/09/2022
    * Last Modified Date : 05/09/2022
    * Description        : Getting Avaibilty Data When Month and Week Button Clicked.
    ***************************************************/

    getMonthWeekAvailiblityData(startDateAvail, endDateAvail) {
        try {
            this.openSpinner = true;
            var startDateAvail = startDateAvail;
            var endDateAvail = endDateAvail;
            var mapData = [];
            var totalMapEventCount = 0;
            this.isDateClicked = false;
            displayMonthWeekAvailability({ startDateAvail: startDateAvail, endDateAvail: endDateAvail })
                .then((result) => {
                    this.availableCount = result.availableCount;
                    this.unAvailableCount = result.unavailableCount;
                    this.bkdbyanthagency = result.bookedByAnother;

                    for (let key in result.monthAvailMap) {
                        mapData.push({ value: result.monthAvailMap[key], key: key, totalAvailiblityCount: result.monthAvailMap[key].length });
                        for (const res of result.monthAvailMap[key]) {
                            res["startTime"] = res.Start_Date_Time__c.substring(11, 16) + ' - ' + res.End_Date_Time__c.substring(11, 16);
                            var date1 = new Date(res.Start_Date_Time__c);
                            var date2 = new Date(res.End_Date_Time__c);
                            var Difference_In_Time = date2.getTime() - date1.getTime();
                            var Difference_In_Time = Difference_In_Time / (1000 * 60);
                            res["totalDuration"] = Difference_In_Time;
                            totalMapEventCount += 1;
                        }
                    }

                    this.monthWiseAvailibilityData = mapData;
                    this.monthWiseAvailibilityDataSize = totalMapEventCount;
                    this.isMonthButtonClicked = true;
                    this.openSpinner = false;

                })
                .catch((error) => {
                    this.openSpinner = false;
                });
        } catch (error) {
            this.openSpinner = false;
            this.reloadpage = true;
            this.template.querySelectorAll('c-ts_-error-component')[0].openModal();
        }
    }


    /***************************************************
   * Author             : Mihir
   * Created Date       : 29/07/2022
   * Last Modified Date : 29/07/2022
   * Description        : Menubar closing event
   ***************************************************/
    check(event) {
        this.dispatchEvent(new CustomEvent('getmenu', { bubbles: true, detail: "profile" }));
    }

}