/*******************************************************
 * Name          : ts_ProfilePage
 * Author        : Karan
 * Create Date   : 26/07/2022
 * Description   : Used in ts_ProfilePage Component in community site
 *******************************************************/

import { LightningElement, track, wire } from 'lwc';
import { getRecord } from 'lightning/uiRecordApi';
import USER_ID from '@salesforce/user/Id';
import USRID from '@salesforce/schema/User.Id';
import { loadStyle, loadScript } from 'lightning/platformResourceLoader';
import profilePageCss from '@salesforce/resourceUrl/profilePageCss';
import saveData from '@salesforce/apex/ts_ProfileModule.saveData';
import getData from '@salesforce/apex/ts_ProfileModule.getData';
import saveFile from '@salesforce/apex/ts_ProfileModule.saveFile';
import fetchContact from '@salesforce/apex/ts_ProfileModule.fetchContact';
import getDocsData from '@salesforce/apex/ts_ProfileModule.getDocsData';
import deleteFile from '@salesforce/apex/ts_ProfileModule.deleteFile';
import saveCV from '@salesforce/apex/ts_ProfileModule.saveCV';
import communityicon from '@salesforce/resourceUrl/communityicons';
import { deleteRecord } from 'lightning/uiRecordApi';
import loginbg from '@salesforce/resourceUrl/loginbg';
export default class Ts_ProfilePage extends LightningElement {

    dragFileImg = communityicon + '/communityicons/dragFileIcon.png';
    saveImg = communityicon + '/communityicons/save.png';
    cancelImg = communityicon + '/communityicons/cancel.png';
    updateImg = communityicon + '/communityicons/update.png';
    deleteImg = communityicon + '/communityicons/delete.png';
    blankProgileImg = communityicon + '/communityicons/profilephoto.png';

    @track checkClient;
    @track reloadpage;
    @track imgUrl;
    @track usrId;
    @track fname;
    @track lname;
    @track email;
    @track businessphn;
    @track mobilephn;
    @track newImgFile;
    @track deletePfp = false;
    @track cvId;
    @track cvName;
    @track isSpinner;
    @track cvList;
    @track getCvName;
    @track validateIt = false;
    @track conId;
    @track schoolPostal;
    @track homephn;
    file;
    fileContents;
    fileReader;
    content;
    contype;
    isInvalid = false;

    @track isShowModal = false;
    @track deleteIt = false;
    @track deleteCvId;

    connectedCallback() {
        this.loadCv();
        getData()
            .then(result => {
                this.condata();
                if (result == null) {
                    this.template.querySelector('c-ts_-tost-notification').showToast('error', 'Something Went Wrong', 3000);
                } else {
                    this.fname = result.Contact.FirstName;
                    this.lname = result.Contact.LastName;
                    this.email = result.Contact.Email;
                    this.businessphn = result.Contact.Phone;
                    this.mobilephn = result.Contact.MobilePhone;
                    this.imgUrl = result.FullPhotoUrl;
                    this.conId = result.Contact.Id;
                    this.homephn = result.Contact.HomePhone;
                    this.schoolPostal = result.Account.Name;
                }
            })
    }

    conData() {

    }
    condata() {
        fetchContact()
            .then(result => {
                if (result != null) {
                    this.contype = result.Community_Contact_Type__c;
                    if (result.Community_Contact_Type__c == 'Client') {
                        this.checkClient = false;

                    } else {
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
    }

    renderedCallback() {
        Promise.all([
            loadStyle(this, profilePageCss)
        ]).then(() => { })
            .catch(error => {
                this.reloadpage = true;
                this.template.querySelectorAll('c-ts_-error-component')[0].openModal();
            });
    }

    /***************************************************
     * Author             : Krunal
     * Created Date       : 26/07/2022
     * Last Modified Date : 26/07/2022
     * Description        : get CV from apex for display on site
     ***************************************************/
    loadCv(evet) {
        try {
            getDocsData()
                .then(result => {
                    if (result != null) {
                        this.cvList = result;
                    }
                    this.isSpinner = false;
                })
                .catch(error => {
                    this.isSpinner = false;
                    this.template.querySelector('c-ts_-tost-notification').showToast('error', 'Something Went Wrong', 3000);
                })
        } catch (error) {
            this.reloadpage = true;
            this.template.querySelectorAll('c-ts_-error-component')[0].openModal();
        }
    }

    @wire(getRecord, {
        recordId: USER_ID,
        fields: [USRID]
    }) wireuser({
        error,
        data
    }) {
        if (error) {
            this.error = error;
        } else if (data) {
            this.usrId = data.fields.Id.value;
        }
    }

    get acceptedFormats() {
        return ['.png', '.jpg', '.jpeg'];
    }

    /***************************************************
     * Author             : Krunal
     * Created Date       : 26/07/2022
     * Last Modified Date : 26/07/2022
     * Description        : get data from file input for upload CV, Run in on change file upload
     ***************************************************/
    handleFile(event) {
        try {
            this.isSpinner = true;
            let fileList = event.target.files;
            this.file = fileList[0];
            let cvUploader = this.template.querySelector(`[data-id="cvUploader"]`);
            cvUploader.value = '';
            this.fileReader = new FileReader();
            this.fileReader.onloadend = (() => {
                this.fileContents = this.fileReader.result;
                let base64 = 'base64,';
                this.content = this.fileContents.indexOf(base64) + base64.length;
                this.fileContents = this.fileContents.substring(this.content);
                this.cvUpload();
            });
            this.fileReader.readAsDataURL(this.file);
        } catch (error) {
            this.reloadpage = true;
            this.template.querySelectorAll('c-ts_-error-component')[0].openModal();
        }
    }

    /***************************************************
     * Author             : Krunal
     * Created Date       : 26/07/2022
     * Last Modified Date : 26/07/2022
     * Description        : send CV data from js to apex for save CV in salesforce
     ***************************************************/
    cvUpload(event) {
        try {
            var pId = this.usrId;
            var file = this.file;
            var fileContents = this.fileContents;
            saveCV({
                parentId: pId,
                fileName: file.name,
                base64Data: encodeURIComponent(fileContents)
            })
                .then(result => {
                    this.isSpinner = false;
                    this.template.querySelector('c-ts_-tost-notification').showToast('success', 'Your CV is Uploaded', 3000);
                    this.loadCv();
                })
                .catch(error => {
                    this.isSpinner = false;
                    this.template.querySelector('c-ts_-tost-notification').showToast('error', 'Something Went Wrong', 3000);
                });
        } catch (error) {
            this.reloadpage = true;
            this.template.querySelectorAll('c-ts_-error-component')[0].openModal();
        }
    };

    /***************************************************
     * Author             : Karan
     * Created Date       : 26/07/2022
     * Last Modified Date : 26/07/2022
     * Description        : set user field data from input fields
     ***************************************************/
    handleChange(event) {
        try {
            if (event.target.name == 'schoolName') {
                this.schoolPostal = event.target.value;
                this.validateIt = false;

            } else if (event.target.name == 'emailaddress') {
                this.email = event.target.value;
                this.validateIt = false;

            } else if (event.target.name == 'businessphone') {
                this.businessphn = event.target.value;
                if (this.businessphn.length > 12 && isNaN(this.businessphn) || this.businessphn.length < 9 && this.businessphn.length != 0) {
                    this.validateIt = true;
                } else {
                    this.validateIt = false;

                }
            } else if (event.target.name == 'mobilephone') {
                this.mobilephn = event.target.value;
                if (this.mobilephn.length > 12 && isNaN(this.mobilephn) || this.mobilephn.length < 9 && this.mobilephn.length != 0) {
                    this.validateIt = true;

                } else {
                    this.validateIt = false;

                }
            } else if (event.target.name == 'homephone') {
                this.homephn = event.target.value;
                if (this.homephn.length > 12 && isNaN(this.homephn) || this.homephn.length < 9 && this.homephn.length != 0) {
                    this.validateIt = true;

                } else {
                    this.validateIt = false;

                }

            }
        } catch (error) {
            this.reloadpage = true;
            this.template.querySelectorAll('c-ts_-error-component')[0].openModal();
        }
    }

    /***************************************************
     * Author             : Karan
     * Created Date       : 26/07/2022
     * Last Modified Date : 26/07/2022
     * Description        : run method on save click
     ***************************************************/
    handleSave(event) {
        try {
            this.isSpinner = true;
            var file = this.newImgFile;
            if (this.isInvalid == true) {
                getData()
                    .then(result => {
                        this.condata();
                        if (result == null) {
                            this.template.querySelector('c-ts_-tost-notification').showToast('error', 'Something Went Wrong', 3000);
                        } else {
                            this.imgUrl = result.photoUrl;
                        }
                    })


            }
            if (file != undefined && this.deletePfp == false && this.isInvalid == false && this.validateIt == false) {
                this.file = file;
                this.fileReader = new FileReader();
                this.fileReader.onloadend = (() => {
                    this.fileContents = this.fileReader.result;
                    let base64 = 'base64,';
                    this.content = this.fileContents.indexOf(base64) + base64.length;
                    this.fileContents = this.fileContents.substring(this.content);
                    this.savePfp();
                });
                this.fileReader.readAsDataURL(this.file);
            } else if (this.validateIt == false && this.deletePfp == true) {
                deleteFile({ userId: this.usrId });
                this.saveUserData();

            } else if (this.validateIt == false && this.deletePfp == false) {
                this.saveUserData();
            }


            if (this.validateIt == true) {
                if (!isNaN(this.mobilephn) && this.mobilephn != undefined && this.mobilephn != '') {

                    if (this.mobilephn.length > 12 || this.mobilephn.length < 9) {
                        this.template.querySelector('c-ts_-tost-notification').showToast('error', 'Please Enter Valid Mobile number', 3000);
                    }
                } else if (isNaN(this.mobilephn) && this.mobilephn != undefined && this.mobilephn != '') {
                    this.template.querySelector('c-ts_-tost-notification').showToast('error', 'Please Enter Valid Mobile number', 3000);
                }

                if (this.checkClient == false) {
                    if (isNaN(this.businessphn) && this.businessphn != undefined && this.businessphn != '') {
                        this.template.querySelector('c-ts_-tost-notification').showToast('error', 'Please Enter Valid Phone number', 3000);
                    } else if (!isNaN(this.businessphn) && this.businessphn != undefined && this.businessphn != '') {
                        if (this.businessphn.length > 12 || this.businessphn.length < 9 || this.businessphn.length != 0) {
                            this.template.querySelector('c-ts_-tost-notification').showToast('error', 'Please Enter Valid Phone number', 3000);
                        }
                    }
                } else {
                    if (isNaN(this.homephn) && this.homephn != undefined && this.homephn != '') {
                        this.template.querySelector('c-ts_-tost-notification').showToast('error', 'Please Enter Valid Phone number', 3000);
                    } else if (!isNaN(this.homephn) && this.homephn != undefined && this.homephn != '') {
                        if (this.homephn.length > 12 || this.homephn.length < 9 || this.homephn.length != 0) {
                            this.template.querySelector('c-ts_-tost-notification').showToast('error', 'Please Enter Valid Phone number', 3000);
                        }
                    }

                }
                this.isSpinner = false;
            }

        } catch (error) {
            this.reloadpage = true;
            this.template.querySelectorAll('c-ts_-error-component')[0].openModal();
        }
    }

    /***************************************************
     * Author             : Sakina
     * Created Date       : 26/07/2022
     * Last Modified Date : 26/07/2022
     * Description        : cancel the updated changes
     ***************************************************/
    cancelChanges(event) {
        try {
            this.isSpinner = true;
            setTimeout(() => {
                getData()
                    .then(result => {
                        if (result == null) {
                            this.template.querySelector('c-ts_-tost-notification').showToast('error', 'Something Went Wrong', 3000);
                        } else {
                            this.fname = result.Contact.FirstName;
                            this.lname = result.Contact.LastName;
                            this.email = result.Contact.Email;
                            this.businessphn = result.Contact.Phone;
                            this.mobilephn = result.Contact.MobilePhone;
                            this.imgUrl = result.FullPhotoUrl;
                            this.conId = result.Contact.Id;
                            this.homephn = result.Contact.HomePhone;
                            this.schoolPostal = result.Account.Name;
                            this.isSpinner = false;
                        }
                    })
            }, 2000)
        } catch (error) {
            this.reloadpage = true;
            this.template.querySelectorAll('c-ts_-error-component')[0].openModal();
        }
    }

    /***************************************************
     * Author             : Krunal
     * Created Date       : 26/07/2022
     * Last Modified Date : 26/07/2022
     * Description        : save profile photo of user in salesforce after click in save button
     ***************************************************/
    savePfp(event) {
        try {
            var pId = this.usrId;
            var file = this.file;
            var fileContents = this.fileContents;
            saveFile({
                userId: pId,
                base64Data: encodeURIComponent(fileContents)
            })
                .then(result => {
                    this.isInvalid = false;
                    if (result == null) {
                        getData()
                            .then(result => {
                                if (result == null) {
                                    this.template.querySelector('c-ts_-tost-notification').showToast('error', 'Something Went Wrong', 3000);
                                } else {

                                    this.imgUrl = result.photoUrl;
                                }
                            })
                        this.template.querySelector('c-ts_-tost-notification').showToast('error', 'Something Went Wrong, Please Upload Other Photo', 3000);
                        this.isSpinner = false;
                    } else {
                        setTimeout(() => {
                            this.saveUserData();
                        }, 500);
                    }
                })
                .catch(error => {

                    getData()
                        .then(result => {
                            this.condata();
                            if (result == null) {
                                this.template.querySelector('c-ts_-tost-notification').showToast('error', 'Something Went Wrong', 3000);
                            } else {
                                this.imgUrl = result.photoUrl;
                            }
                        })
                    this.isInvalid = true;
                    this.template.querySelector('c-ts_-tost-notification').showToast('error', 'Something Went Wrong with this Image', 3000);
                    this.isSpinner = false;
                });

        } catch (error) {
            this.reloadpage = true;
            this.template.querySelectorAll('c-ts_-error-component')[0].openModal();
        }
    }

    /***************************************************
     * Author             : Krunal
     * Created Date       : 26/07/2022
     * Last Modified Date : 08/08/2022      // Mihir - Add validation in mobile and Phone number 
     * Description        : save all user data after click on save button
     ***************************************************/
    saveUserData(event) {
        try {
            var file = this.newImgFile;
            var phoneno = /(^\d{9}$|^\d{10}$|^\d{11}$|^\d{12}$)/;
            let conObj = { 'sobjectType': 'Contact' };
            conObj.Id = this.conId;
            conObj.FirstName = this.fname;
            conObj.LastName = this.lname;
            conObj.Email = this.email;
            conObj.Phone = this.businessphn;
            conObj.MobilePhone = this.mobilephn;
            conObj.HomePhone = this.homephn;

            var validation = true;
            for (var key in conObj) {
                if (this.checkClient == false) {
                    if (key == "Phone" && conObj[key] != undefined && conObj[key].length > 0) {
                        if (!phoneno.test(conObj[key])) {
                            this.template.querySelector('c-ts_-tost-notification').showToast('error', 'Please Enter Valid Phone number', 3000);
                            validation = false;
                            break;
                        }
                    }
                } else {
                    if (key == "HomePhone" && conObj[key] != undefined && conObj[key].length > 0) {
                        if (!phoneno.test(conObj[key])) {
                            this.template.querySelector('c-ts_-tost-notification').showToast('error', 'Please Enter Valid Phone number', 3000);
                            validation = false;
                            break;
                        }
                    }
                }
                if (key == "MobilePhone" && conObj[key] != undefined && conObj[key].length > 0) {
                    if (!phoneno.test(conObj[key])) {
                        this.template.querySelector('c-ts_-tost-notification').showToast('error', 'Please Enter Valid Mobile number', 3000);
                        validation = false;
                        break;
                    }
                }
            }
            if (validation) {
                saveData({ con: conObj })
                setTimeout(() => {
                    getData()
                        .then(result => {
                            var phn = result.Phone;
                            if (result == null) {
                                this.template.querySelector('c-ts_-tost-notification').showToast('error', 'Something Went Wrong', 3000);
                            } else {
                                this.fname = result.Contact.FirstName;
                                this.lname = result.Contact.LastName;
                                this.email = result.Contact.Email;
                                this.businessphn = result.Contact.Phone;
                                this.mobilephn = result.Contact.MobilePhone;
                                this.imgUrl = result.FullPhotoUrl;
                                this.conId = result.Contact.Id;
                                this.homephn = result.Contact.HomePhone;
                                this.schoolPostal = result.Account.Name;
                            }
                        })
                    this.template.querySelector('c-ts_-tost-notification').showToast('success', 'Your data is save successfully', 3000);
                    this.isSpinner = false;
                }, 5000);
            } else {
                this.isSpinner = false;
            }
        } catch (error) {
            this.reloadpage = true;
            this.template.querySelectorAll('c-ts_-error-component')[0].openModal();
        }
    }

    /***************************************************
     * Author             : Krunal
     * Created Date       : 26/07/2022
     * Last Modified Date : 26/07/2022
     * Description        : show save and cancel button in only first tab and hide in second tab
     ***************************************************/
    handleActive(event) {
        try {
            const tab = event.target.value;;
            var btns = this.template.querySelector('.btns');
            if (tab == 'tab1') {
                btns.style.display = 'flex';
                this.template.querySelector('.imageUpload').classList.remove('disableDiv');
            } else {
                btns.style.display = 'none';
                this.template.querySelector('.imageUpload').classList.add('disableDiv');
            }
        } catch (error) {
            this.reloadpage = true;
            this.template.querySelectorAll('c-ts_-error-component')[0].openModal();
        }
    }

    /***************************************************
     * Author             : Krunal
     * Created Date       : 26/07/2022
     * Last Modified Date : 26/07/2022
     * Description        : set view of new profile pic after upload new profile photo
     ***************************************************/
    savePfpHandle(event) {
        try {
            let file = event.target.files[0];
            if (file != undefined) {
                this.deletePfp = false;
                this.newImgFile = file;
                this.imgUrl = URL.createObjectURL(file);
                let pfpUploader = this.template.querySelector(`[data-id="pfpUploader"]`);
                pfpUploader.value = '';
            }
        } catch (error) {
            this.reloadpage = true;
            this.template.querySelectorAll('c-ts_-error-component')[0].openModal();
        }
    }

    /***************************************************
     * Author             : Krunal
     * Created Date       : 26/07/2022
     * Last Modified Date : 26/07/2022
     * Description        : delete profile photo
     ***************************************************/
    deletePfpHandle(event) {
        try {
            this.deletePfp = true;
            this.imgUrl = this.blankProgileImg;
        } catch (error) {
            this.reloadpage = true;
            this.template.querySelectorAll('c-ts_-error-component')[0].openModal();
        }
    }

    /***************************************************
     * Author             : Sakina
     * Created Date       : 26/07/2022
     * Last Modified Date : 26/07/2022
     * Description        : close model when click on cancel in confirm box
     ***************************************************/
    hideModalBox() {
        try {
            this.isShowModal = false;
            this.deleteIt = false;
        } catch (error) {
            this.reloadpage = true;
            this.template.querySelectorAll('c-ts_-error-component')[0].openModal();
        }
    }

    /***************************************************
     * Author             : Sakina
     * Created Date       : 26/07/2022
     * Last Modified Date : 26/07/2022
     * Description        : run method when click on yes in confirm box
     ***************************************************/
    yesDelete(event) {
        try {
            this.deleteIt = true;
            this.isShowModal = false;
            this.isSpinner = true;
            deleteRecord(this.deleteCvId)
                .then((result) => {
                    this.template.querySelector('c-ts_-tost-notification').showToast('success', 'Your CV is deleted', 3000);
                    this.loadCv();
                })
                .catch(error => {
                    this.template.querySelector('c-ts_-tost-notification').showToast('error', 'Something Went Wrong', 3000);
                });
            this.deleteIt = false;
        } catch (error) {
            this.reloadpage = true;
            this.template.querySelectorAll('c-ts_-error-component')[0].openModal();
        }
    }

    /***************************************************
     * Author             : Sakina
     * Created Date       : 26/07/2022
     * Last Modified Date : 26/07/2022
     * Description        : open confirm box afrer click on delete CV
     ***************************************************/
    deleteCv(event) {
        try {
            this.isShowModal = true;
            var cvId = event.target.name;
            var getName = event.target.title;
            this.getCvName = getName;
            this.deleteCvId = cvId;
        } catch (error) {
            this.reloadpage = true;
            this.template.querySelectorAll('c-ts_-error-component')[0].openModal();
        }
    }

    check(event) {
        this.dispatchEvent(new CustomEvent('getmenu', { bubbles: true, detail: "profile" }));
    }
}