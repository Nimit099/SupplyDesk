/*******************************************************
* Name          : ts_NavigationTheme
* Author        : RAVI MODI
* Create Date   : 01/07/2022
* UsedBy        : Used in community site components
* Description   : For Community Theme Layout, Horizontal and Vertical Navigation Bar

================================================================================
Change No.          Developer Name              Date                Description     
1.                  Mihir Ramoliya              18/07/2022          Design Changes, my Qualification button functionality add, menubar close when clicked outside menubar

*******************************************************/

import { LightningElement, track, api } from 'lwc';
import { NavigationMixin } from 'lightning/navigation';
import fetchContact from '@salesforce/apex/ts_ProfileModule.fetchContact';          //Get Contact Record to check client or not.
import communityicon from '@salesforce/resourceUrl/communityicons';                 //For Community Images

export default class Ts_NavigationTheme extends NavigationMixin(LightningElement) {

    // account_icon = communityicon + '/communityicons/menumyaccount.png';
    // timesheet_icon = communityicon + '/communityicons/menutimesheet.png';
    // compliance_icon = communityicon + '/communityicons/menucompliance.png';
    // scheduler_icon = communityicon + '/communityicons/menuscheduler.png';
    // qualification_icon = communityicon + '/communityicons/menumyqualification.png';
    account_icon = communityicon + '/communityicons/myaccount.png';
    timesheet_icon = communityicon + '/communityicons/timesheet.png';
    compliance_icon = communityicon + '/communityicons/compliance.png';
    scheduler_icon = communityicon + '/communityicons/scheduler.png';
    qualification_icon = communityicon + '/communityicons/MyQualificationImg.png';
    home_icon = communityicon + '/communityicons/homepage.png';
    fb_icon = communityicon + '/communityicons/facebookIcon2.png';
    in_icon = communityicon + '/communityicons/linkedinIcon2.png';
    help_icon = communityicon + '/communityicons/help.png';
    help_icon2 = communityicon + '/communityicons/questionicon2.png';
    logout_icon = communityicon + '/communityicons/logout.png';
    logout_icon2 = communityicon + '/communityicons/logouticon2.png';
    menu_icon = communityicon + '/communityicons/menubar.png';
    @track checkClient;                                                             // Check user client or candidate
    @track reloadpage;                                                              // For Reload Page


    // For Get Value of Selected Tab From Home Page                                 //RAVI MODI     //20/07/2022
    @api
    getselectedtab(detaildata) {
        try {
            this.isSpinner = true;
            var tab = this.template.querySelectorAll('[data-name="' + detaildata + '"]');
            tab.forEach(element => {
                element.classList.add('selected_tab');
            });
            this.isSpinner = false;
        } catch (error) {
            this.isSpinner = false;
            this.reloadpage = true;
            this.template.querySelectorAll('c-ts_-error-component')[0].openModal();
        }
    }

    /***************************************************
    * Author             : Mihir
    * Created Date       : 22/08/2022
    * Last Modified Date : 22/08/2022
    * Description        : Menubar closing when click outside div
    ***************************************************/
    @api check2() {
        try {
            var btn_clk = this.template.querySelector('.maincls');
            var navi_clk = this.template.querySelector('.navicon_cls');
            var home_clk = this.template.querySelector('.home_cls');
            var fbin_remove1 = this.template.querySelector('.fbin1');
            var fbin_remove2 = this.template.querySelector('.fbin2');
            if (btn_clk.classList.length == '1') {
                btn_clk.classList.add('closed-menu');
                navi_clk.classList.remove('hide_cls');
                home_clk.classList.remove('width_cls');
                if (window.screen.width < 400) {
                    fbin_remove1.classList.remove('fbin_remove');
                    fbin_remove2.classList.remove('fbin_remove');
                }
            }
        } catch (error) {
            this.reloadpage = true;
            this.template.querySelectorAll('c-ts_-error-component')[0].openModal();
        }
    }

    @api changeMessage(strString) {
        var btn_clk = this.template.querySelector('.maincls');
        var navi_clk = this.template.querySelector('.navicon_cls');
        var home_clk = this.template.querySelector('.home_cls');
        var fbin_remove1 = this.template.querySelector('.fbin1');
        var fbin_remove2 = this.template.querySelector('.fbin2');
        if (btn_clk.classList.length == '1') {
            btn_clk.classList.add('closed-menu');
            navi_clk.classList.remove('hide_cls');
            home_clk.classList.remove('width_cls');
            if (window.screen.width < 400) {
                fbin_remove1.classList.remove('fbin_remove');
                fbin_remove2.classList.remove('fbin_remove');
            }
        }
    }

    /***************************************************
    * Author             : Ravi Modi
    * Created Date       : 01/07/2022
    * Last Modified Date : 01/07/2022
    * Description        : Called when Page is loaded 
    ***************************************************/
    connectedCallback() {
        try {
            this.isSpinner = true;
            var meta = document.createElement("meta");
            meta.setAttribute("name", "viewport");
            meta.setAttribute("content", "width=device-width, initial-scale=1.0");
            document.getElementsByTagName('head')[0].appendChild(meta);

            fetchContact()
                .then(result => {
                    if (result != null) {
                        if (result.Community_Contact_Type__c == 'Client') {
                            this.checkClient = false;
                        }
                        else {
                            this.checkClient = true;
                        }
                    }
                    this.isSpinner = false;
                })
                .catch(error => {
                    this.isSpinner = false;
                    this.reloadpage = true;
                    this.template.querySelectorAll('c-ts_-error-component')[0].openModal();
                });
        } catch (error) {
            this.isSpinner = false;
            this.reloadpage = true;
            this.template.querySelectorAll('c-ts_-error-component')[0].openModal();
        }
    }

    /***************************************************
    * Author             : Ravi Modi
    * Created Date       : 01/07/2022
    * Last Modified Date : 01/07/2022
    * Description        : For Selected tab color change when Page is load
    ***************************************************/
    renderedCallback() {

        try {
            this.isSpinner = true;
            const queryString = window.location.href;
            let tab;
            if (queryString.toLowerCase().includes('profile')) {
                tab = this.template.querySelectorAll('[data-name="profile"]');
                tab.forEach(element => {
                    element.classList.add('selected_tab');
                });
            } else if (queryString.toLowerCase().includes('timesheet')) {
                tab = this.template.querySelectorAll('[data-name="timesheet"]');
                tab.forEach(element => {
                    element.classList.add('selected_tab');
                });
            } else if (queryString.toLowerCase().includes('compliance')) {
                tab = this.template.querySelectorAll('[data-name="compliance"]');
                tab.forEach(element => {
                    element.classList.add('selected_tab');
                });
            } else if (queryString.toLowerCase().includes('myqualifications')) {
                tab = this.template.querySelectorAll('[data-name="myqualifications"]');
                tab.forEach(element => {
                    element.classList.add('selected_tab');
                });
            } else if (queryString.toLowerCase().includes('myavailability')) {
                tab = this.template.querySelectorAll('[data-name="scheduler"]');
                tab.forEach(element => {
                    element.classList.add('selected_tab');
                });
            }
            this.isSpinner = false;
        } catch (error) {
            this.isSpinner = false;
            this.reloadpage = true;
            this.template.querySelectorAll('c-ts_-error-component')[0].openModal();
        }
    }

    /***************************************************
    * Author             : Ravi Modi
    * Created Date       : 02/07/2022
    * Last Modified Date : 02/07/2022
    * Description        : For Open and Close Navigation Panel
    ***************************************************/
    buttonclick() {

        try {
            this.isSpinner = true;
            var btn_clk = this.template.querySelector('.maincls');
            var navi_clk = this.template.querySelector('.navicon_cls');
            var home_clk = this.template.querySelector('.home_cls');
            var fbin_remove1 = this.template.querySelector('.fbin1');
            var fbin_remove2 = this.template.querySelector('.fbin2');
            if (btn_clk.classList.length == '1') {
                btn_clk.classList.add('closed-menu');
                navi_clk.classList.remove('hide_cls');
                home_clk.classList.remove('width_cls');
                if (window.screen.width < 400) {
                    fbin_remove1.classList.remove('fbin_remove');
                    fbin_remove2.classList.remove('fbin_remove');
                }
            }
            else {
                btn_clk.classList.remove('closed-menu');
                navi_clk.classList.add('hide_cls');
                home_clk.classList.add('width_cls');
                if (window.screen.width < 400) {
                    fbin_remove1.classList.add('fbin_remove');
                    fbin_remove2.classList.add('fbin_remove');
                }
            }
            this.isSpinner = false;

        } catch (error) {
            this.isSpinner = false;
            this.reloadpage = true;
            this.template.querySelectorAll('c-ts_-error-component')[0].openModal();
        }
    }

    /***************************************************
    * Author             : Ravi Modi
    * Created Date       : 02/07/2022
    * Last Modified Date : 02/07/2022
    * Description        : For Navigate Page
    ***************************************************/
    redirectpage(event) {

        try {
            this.isSpinner = true;
            var nameval = event.currentTarget.dataset.name;
            var urlValue = '/s/';
            let rmv_tab = this.template.querySelectorAll('.icon_cls');
            rmv_tab.forEach(element => {
                if (element.classList.length > 1) {
                    element.classList.remove('selected_tab');
                }
            });

            let tab = this.template.querySelectorAll('[data-name="' + nameval + '"]');
            var pageapiname;

            tab.forEach(element => {

                if (nameval == 'profile') {
                    urlValue = urlValue + 'profile';
                    pageapiname = 'Profile__c';
                    element.classList.add('selected_tab');
                } else if (nameval == 'timesheet') {
                    urlValue = urlValue + 'timesheet';
                    pageapiname = 'TimeSheet__c';
                    element.classList.add('selected_tab');
                } else if (nameval == 'scheduler') {
                    urlValue = urlValue + 'myavailability';
                    pageapiname = 'myAvailability__c';
                    element.classList.add('selected_tab');
                } else if (nameval == 'Home') {
                    urlValue = urlValue + '';
                    pageapiname = 'Home';
                } else if (nameval == 'Help') {
                    urlValue = urlValue + 'help';
                    pageapiname = 'Help__c';
                } else if (nameval == 'myqualifications') {
                    urlValue = urlValue + 'myqualifications';
                    pageapiname = 'MyQualifications__c';
                    element.classList.add('selected_tab');
                } else if (nameval == 'compliance') {
                    urlValue = urlValue + 'compliance';
                    pageapiname = 'Compliance__c';
                    element.classList.add('selected_tab');
                } else if (nameval == 'Logout') {
                    this[NavigationMixin.Navigate]({
                        type: 'comm__loginPage',
                        attributes: {
                            actionName: 'logout'
                        },
                    });
                }
            });

            this[NavigationMixin.Navigate]({
                type: 'comm__namedPage',
                attributes: {
                    name: pageapiname,
                    url: urlValue
                },
            });

            var btn_clk = this.template.querySelector('.maincls');
            var navi_clk = this.template.querySelector('.navicon_cls');
            var home_clk = this.template.querySelector('.home_cls');
            btn_clk.classList.add('closed-menu');
            navi_clk.classList.remove('hide_cls');
            home_clk.classList.remove('width_cls');
            this.isSpinner = false;
        } catch (error) {
            this.isSpinner = false;
            this.reloadpage = true;
            this.template.querySelectorAll('c-ts_-error-component')[0].openModal();
        }
    }


    /***************************************************
    * Author             : Mihir
    * Created Date       : 18/07/2022
    * Last Modified Date : 18/07/2022
    * Description        : Menubar closing when click outside div
    ***************************************************/
    check(event) {

        try {

            if (event.target.name != 'menuname') {
                var btn_clk = this.template.querySelector('.maincls');
                var navi_clk = this.template.querySelector('.navicon_cls');
                var home_clk = this.template.querySelector('.home_cls');
                var fbin_remove1 = this.template.querySelector('.fbin1');
                var fbin_remove2 = this.template.querySelector('.fbin2');
                if (btn_clk.classList.length == '1') {
                    btn_clk.classList.add('closed-menu');
                    navi_clk.classList.remove('hide_cls');
                    home_clk.classList.remove('width_cls');
                    if (window.screen.width < 400) {
                        fbin_remove1.classList.remove('fbin_remove');
                        fbin_remove2.classList.remove('fbin_remove');
                    }
                }
            }
        } catch (error) {
            this.reloadpage = true;
            this.template.querySelectorAll('c-ts_-error-component')[0].openModal();
        }
    }

}