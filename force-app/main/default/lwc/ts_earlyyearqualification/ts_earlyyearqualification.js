import { LightningElement, track, wire, api } from 'lwc';
// import { loadStyle, loadScript } from 'lightning/platformResourceLoader';
import Update_Service_Status_Check__c from '@salesforce/schema/TR1__Associated_Qualification__c.Update_Service_Status_Check__c';
import Qualification_Type2__c from '@salesforce/schema/TR1__Associated_Qualification__c.Qualification_Type2__c';
import Qualification_Type__c from '@salesforce/schema/TR1__Associated_Qualification__c.Qualification_Type__c';
import { getPicklistValues, getObjectInfo } from 'lightning/uiObjectInfoApi';
import TR1__Associated_Qualification__c from '@salesforce/schema/TR1__Associated_Qualification__c';
import getContactId from '@salesforce/apex/ts_earlyyearqualification.getContactId';
import editQuali from '@salesforce/apex/ts_earlyyearqualification.editQuali';


export default class Ts_earlyyearqualification extends LightningElement {

    // @track urlName = 'Perm DBS';
    // @track urlName = 'Safeguarding';
    // @track urlName = 'Emergency Contact';
    // @track urlName = 'DBS';
    @track urlName = 'Post 16 Qualifications';
    @track contactId;
    @api dbsValue;

    @track permtext;
    @track safegDate;

    //for emergency contact
    @track eContactName;
    @track eConMobile;
    @track eConWork;
    @track Relate;
    @track eConHome;
    @track eConAdd;

    //for dbs
    @track dbNum;
    @track dbsUpdateSer;
    @track lstOptions = [];

    //for post 16 qualificaitons
    @track snumb;
    @track qValue;
    @track qList = [];
    @track expirDate;
    @track QtlsCheck;
    @track qualmultipick;
    @track qualopt = [];


    checked = false;

    // get options() {
    //     return [
    //         { label: 'Yes', value: 'Yes' },
    //         { label: 'Current No Info', value: 'Current No Info' },
    //         { label: 'Current Info Held', value: 'Current Info Held' },
    //         { label: 'No Longer Current', value: 'No Longer Current' },
    //     ];
    // }

    get options() {
        return [
            { label: 'Overseas Qualifications - Aus/NZ	', value: 'Overseas Qualifications - Aus/NZ	' },
            { label: 'Overseas Qualifications - Canada	', value: 'Overseas Qualifications - Canada	' },
            { label: 'Overseas Qualifications - USA	', value: 'Overseas Qualifications - USA	' },
            { label: 'Overseas Qualifications - Other	', value: 'Overseas Qualifications - Other	' },
            { label: 'Teacher Qualification', value: 'Teacher Qualification' },
            { label: 'Support Qualifications', value: 'Support Qualifications' },
            { label: 'Post 16 Qualifications', value: 'Post 16 Qualifications' },
            { label: 'Early Years Qualifications', value: 'Early Years Qualifications' },
        ];
    }


    connectedCallback() {
        console.log('In the connected callback');
        this.getconID();
        this.updateStatusCheck();
        // this.editQ();
    }

    getconID() {
        getContactId({})
            .then((result) => {
                this.contactId = result;
                console.log({ result });
            })
    }

    // Get Object Info.
    @wire(getObjectInfo, { objectApiName: TR1__Associated_Qualification__c })
    qualObjectInfo;

    //get picklist for dbs
    @wire(getPicklistValues,
        {
            recordTypeId: '$qualObjectInfo.data.defaultRecordTypeId',
            fieldApiName: Update_Service_Status_Check__c
        }
    )
    updateStatusCheck(data, error) {
        console.log({ data });
        if (data && data.data && data.data.values) {
            let options = [];
            data.data.values.forEach(objPicklist => {
                options.push({ label: objPicklist.value, value: objPicklist.value });
            });
            this.lstOptions = options;

        } else if (error) {
            console.log(error);
        }
    };

    //get picklist for post 16 qualifications
    @wire(getPicklistValues,
        {
            recordTypeId: '$qualObjectInfo.data.defaultRecordTypeId',
            fieldApiName: Qualification_Type2__c
        }
    )
    qualificationType(data, error) {
        console.log({ data });
        if (data && data.data && data.data.values) {
            let options11 = [];
            data.data.values.forEach(objPicklist => {
                options11.push({ label: objPicklist.value, value: objPicklist.value });
            });
            this.qList = options11;

        } else if (error) {
            console.log(error);
        }
    };

    // for multi picklist
    @wire(getPicklistValues,
        {
            recordTypeId: '$qualObjectInfo.data.defaultRecordTypeId',
            fieldApiName: Qualification_Type__c
        }
    )
    qualificationTypee(data, error) {
        console.log({ data });
        if (data && data.data && data.data.values) {
            let options = [];
            data.data.values.forEach(objPicklist => {
                options.push({ label: objPicklist.value, value: objPicklist.value });
            });
            this.qualopt = options;

        } else if (error) {
            console.log(error);
        }
    };

    handleChange(event) {
        console.log({ event });
        if (this.urlName == 'Perm DBS') {
            if (event.target.name == 'permDBS') {
                this.permtext = event.target.value;
                console.log('this.permtext ---->' + this.permtext);
            }
        }
        if (this.urlName == 'Safeguarding') {
            if (event.target.name == 'safedate') {
                this.safegDate = event.target.value;
                console.log('this.safegDate ---->' + this.safegDate);
            }
        }
        else if (this.urlName == 'Emergency Contact') {
            if (event.target.name == 'EconName') {
                this.eContactName = event.target.value;
                console.log('this.eContac ---> ' + this.eContactName);
            } else if (event.target.name == 'EconMobile') {
                this.eConMobile = event.target.value;
                console.log('this.eConMobile ---> ' + this.eConMobile);
            } else if (event.target.name == 'EconWork') {
                this.eConWork = event.target.value;
                console.log('this.eConWork ->' + this.eConWork);
            } else if (event.target.name == 'Relation') {
                this.Relate = event.target.value;
                console.log('this.Relate --->' + this.Relate);
            } else if (event.target.name == 'EconHome') {
                this.eConHome = event.target.value;
                console.log('this.eConHome --->' + this.eConHome);

            } else if (event.target.name == 'EconAdd') {
                this.eConAdd = event.target.value;
                console.log('this.eConAdd --->' + this.eConAdd);

            }
        }
        else if (this.urlName == 'DBS') {
            if (event.target.name == 'dbnumber') {
                this.dbNum = event.target.value;
                console.log('this.dbNum --->' + this.dbNum);
            } else if (event.target.name == 'dbsname') {
                this.dbsUpdateSer = event.detail.value;
                console.log('this.dbsUpdateSer -------->' + this.dbsUpdateSer);
            }

        }
        else if (this.urlName == 'Post 16 Qualifications') {
            if (event.target.name == 'snumber') {
                this.snumb = event.target.value;
                console.log('this.snumb --->' + this.snumb);
            } else if (event.target.name == 'quList') {
                this.qValue = event.detail.value;
                console.log('this.qValue --->' + this.qValue);
            } else if (event.target.name == 'expDate') {
                this.expirDate = event.target.value;
                console.log('this.expirDate -------->' + this.expirDate);
            } else if (event.target.name == 'qtl') {
                this.QtlsCheck = event.target.checked;
                console.log('this.QtlsCheck --->' + this.QtlsCheck);
            } else if (event.target.name == 'qualselect') {
                this.qualmultipick = event.detail.value;
                console.log('this.qualmultipick --->' + this.qualmultipick);
            }

        }

    }

    saveQualification() {
        console.log('In saveQualification');
        let qualObj = { 'sobjectType': 'TR1__Associated_Qualification__c' };
        qualObj.qualificationName__c = this.urlName;
        console.log({ qualObj });
        if (this.urlName == 'Perm DBS') {
            qualObj.Gaps_Explanation__c = this.gapsExplanation;
            qualObj.CV_Submitted__c = this.cvSubmitted;
        }
        else if (this.urlName == 'Safeguarding') {
            qualObj.Safeguarding_Date_Completed__c = this.safegDate;
            console.log('qualObj.Safeguarding_Date_Completed__c ----> ' + qualObj.Safeguarding_Date_Completed__c);
        }
        else if (this.urlName == 'Emergency Contact') {
            qualObj.Relationship_to_You__c = this.Relate;
            qualObj.Emergency_Contact_Address__c = this.eConAdd;
            qualObj.Emergency_Contact_Home_Phone__c = this.eConHome;
            qualObj.Emergency_Contact_Mobile_Phone__c = this.eConMobile;
            qualObj.Emergency_Contact_Work_Phone__c = this.eConWork;
            qualObj.Emergency_Contact_Name__c = this.eContactName;
            console.log('qualObj.Emergency_Contact_Name__c ----> ' + qualObj.Emergency_Contact_Name__c);

        } else if (this.urlName == 'DBS') {
            qualObj.DBS_Form_Number__c = this.dbNum;
            qualObj.Update_Service_Status_Check__c = this.lstOptions;

        } else if (this.urlName == 'Post 16 Qualifications') {
            qualObj.SET_Registration_Number__c = this.snumb;
            qualObj.Qualification_Type2__c = this.qList;
            qualObj.SET_Expiry_Date__c = this.expirDate;
            qualObj.QTLS__c = this.QtlsCheck;
            qualObj.Qualification_Type__c = this.qualmultipick;
        }

        console.log('this.contactId>>', this.contactId);
        console.log('this.urlName>>', this.urlName);
        editQuali({
            conId: this.contactId,
            qfname: this.urlName,
            qual: qualObj
        })
            .then(result => {
                console.log({ result });
                alert('Save Successfully');
            })
    }
}