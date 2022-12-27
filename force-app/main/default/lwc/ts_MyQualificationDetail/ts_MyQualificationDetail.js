import { LightningElement, api, track, wire } from 'lwc';
import { loadStyle, loadScript } from 'lightning/platformResourceLoader';
import { getPicklistValues, getObjectInfo } from 'lightning/uiObjectInfoApi';
import TR1__Associated_Qualification__c from '@salesforce/schema/TR1__Associated_Qualification__c';
import Permanent_Right_to_Work_in_UK__c from '@salesforce/schema/TR1__Associated_Qualification__c.Permanent_Right_to_Work_in_UK__c';
import Documents__c from '@salesforce/schema/TR1__Associated_Qualification__c.Documents__c';
import OverseasPolicecheck from '@salesforce/schema/TR1__Associated_Qualification__c.Overseas_Police_Check__c';
import OTQQualifications from '@salesforce/schema/TR1__Associated_Qualification__c.Overseas_Police_Check__c';
import Qualification_Type2__c from '@salesforce/schema/TR1__Associated_Qualification__c.Qualification_Type2__c';
import Qualification_Type__c from '@salesforce/schema/TR1__Associated_Qualification__c.Qualification_Type__c';
import NARICApprove from '@salesforce/schema/TR1__Associated_Qualification__c.NARIC_Approved__c';
import Group1IdType from '@salesforce/schema/TR1__Associated_Qualification__c.Group_1_ID_Type__c';
import Group2AIdType from '@salesforce/schema/TR1__Associated_Qualification__c.Group_2a_ID_Type__c';
import Group2bIdType from '@salesforce/schema/TR1__Associated_Qualification__c.Group_2b_ID_Type__c';
import NameChangeDocument from '@salesforce/schema/TR1__Associated_Qualification__c.Name_Change_Document__c';
import Update_Service_Status_Check__c from '@salesforce/schema/TR1__Associated_Qualification__c.Update_Service_Status_Check__c';
import Ref1Type from '@salesforce/schema/TR1__Associated_Qualification__c.Reference_1_Type__c';
import Ref1Rating from '@salesforce/schema/TR1__Associated_Qualification__c.Reference_1_Rating__c';
import Ref2Type from '@salesforce/schema/TR1__Associated_Qualification__c.Reference_2_Type__c';
import Ref2Rating from '@salesforce/schema/TR1__Associated_Qualification__c.Reference_2_Rating__c';
import Ref3Type from '@salesforce/schema/TR1__Associated_Qualification__c.Reference_3_Type__c';
import Ref3Rating from '@salesforce/schema/TR1__Associated_Qualification__c.Reference_3_Rating__c';
import { CurrentPageReference } from 'lightning/navigation';
import Qualificationcss from '@salesforce/resourceUrl/Qualificationcss';
import getContactId from '@salesforce/apex/ts_ProfileModule.getContactId';
import editQuali from '@salesforce/apex/ts_ProfileModule.editQuali';
import saveQualifiFile from '@salesforce/apex/ts_ProfileModule.saveQualifiFile';
import getqualifiFileData from '@salesforce/apex/ts_ProfileModule.getqualifiFileData';
import getQualifiData from '@salesforce/apex/ts_ProfileModule.getQualifiData';
import Choice_of_Country__c from '@salesforce/schema/TR1__Associated_Qualification__c.Choice_of_Country__c';
import commstyle from '@salesforce/resourceUrl/CommunityCSS';
import communityicon from '@salesforce/resourceUrl/communityicons';
import USRID from '@salesforce/schema/User.Id';
import { deleteRecord } from 'lightning/uiRecordApi';


export default class Ts_MyQualificationDetail extends LightningElement {


    dragFileImg = communityicon + '/communityicons/dragFileIcon.png';
    deleteImg = communityicon + '/communityicons/delete.png';

    saveImg = communityicon + '/communityicons/save.png';
    cancelImg = communityicon + '/communityicons/cancel.png';

    @track qName;
    @track contactId;

    @track cvId = '';

    @track cvList = [];

    //For Spinner
    @track isSpinner;

    // For Reload Page
    @track reloadpage;

    //For Result
    @track isResult;

    //For Hide/Show
    @track checkId;
    @track checkRtw;
    @track checkteacherQual;
    @track checkoverPc;
    @track checkoverTQ;
    @track checkCv;
    @track checkSafe;
    @track checkEme;
    @track checkDbs;
    @track checkPost16;
    @track checkEarly;
    @track checkSupport;
    @track checkInt;
    @track checkBarred;
    @track checkRefs;
    @track checkUpload;
    @track checkQualification;

    @track qualification = '';
    @track lstOptions = [];
    @track docOptions = [];

    docslst2 = [];

    @track l_All_Types;

    @track contactId;

    @track s = '';

    //For CV
    @track gapsExplanation;
    @track cvSubmitted;
    @track cvReceived;


    //For Perm Qualification
    @track nctlNum;
    @track setNum;
    @track qtls;

    //For Right to work
    @track workPermit;
    docs = [];
    @track workpermitdate;

    //For Overseas Teacher qualification
    @track naricApproveOps = [];

    @track OTQQFtypeval;
    @track naricApprove;
    @track otstranum;
    @track OTQteacherQualification = '';

    @track OTQteacherQualifications = [];

    //For teacher qualification
    @track teacherQFTypeOptions = [];
    @track teacherQualifications = [];

    @track teacherDual = [];

    @track teacherQftype;
    @track teacherDualVal = '';
    @track tranum;

    //For Overseas police check
    @track overseasPoliceOps = [];
    @track overseasVal;
    @track opcStdate;
    @track opcEddate;

    @track teacherQualificationsOver = [];

    //For Id Qualification
    @track groupTypes = [];
    @track nameChangeDocuments = [];
    @track Group2aIdTypes = [];
    @track Group2bIdTypes = [];

    @track group1IdTypeVal;
    @track namechangedocument;
    @track Group2aIdType1 = '';
    @track Group2bIdType1 = '';

    //For safeguarding
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
    @track dbsOptions;

    //for post 16 qualificaitons
    @track snumb;
    @track qValue;
    @track qList = [];
    @track expirDate;
    @track QtlsCheck;
    @track qualmultipick = '';
    @track qualopt = [];

    @track qualificationsPost16 = []

    //For international

    @track choiceOfCountryOps = [];

    @track country = '';
    @track seekIntPos;

    //For Early Year qualification

    @track earlyYearQFtype;
    @track earlyYearQualifications = '';
    @track earlyYearQualification = [];

    @track teacherQualificationsEarly = [];

    //For Support Qualification

    @track supportQFtype;
    @track supportQualifications = '';
    @track supportQualification = [];

    @track teacherQualificationsSupport = [];

    //For Barred List

    @track barredcheckurl;
    @track barredListResult;
    @track ewscheckeddate;
    @track ewsnextcheckeddate;
    @track barredlistdatecheck;
    @track barredlistexpirydate;
    @track DOB

    // For Combined Qualification

    @track combinedQualificationOptions = [];

    @track isOverSeasTeacherQual;
    @track isTeacherQual;
    @track isSupportQual;
    @track isPost16Qual;
    @track isYearlyQual;

    @track statusOfOverSeasTeacherQual;
    @track statusOfTeacherQual;
    @track statusOfSupportQual;
    @track statusOfPost16Qual;
    @track statusOfYearlyQual;

    @track exprDateOfOverSeasTeacherQual;
    @track exprDateOfTeacherQual;
    @track exprDateOfSupportQual;
    @track exprDateOfPost16Qual;
    @track exprDateOfYearlyQual;

    @track commbinedQFtype;
    @track combinnedQualificationsValue = [];

    @track commbinedQualStatus = '';
    @track commbinedQualExprDate = '';

    //References

    @track Ref1Types = [];
    @track Ref2Types = [];
    @track Ref3Types = [];
    @track Ref1Ratings = [];
    @track Ref2Ratings = [];
    @track Ref3Ratings = [];

    @track Ref2recdate;
    @track Ref1sentdate;
    @track Reference1name;
    @track Reference1RecDate;
    @track Reference1phone = '';
    @track Reference1daterangestart;
    @track Reference1email;
    @track Reference1daterangeend;
    @track Ref1Type;
    @track Ref1Rec;
    @track Ref1Rating;
    @track Ref2sentdate;
    @track Reference2name;
    @track Refrecdate;
    @track Ref2phone;
    @track Ref2daterangest;
    @track Ref2email;
    @track Ref2daterangeend;
    @track Ref2Type;
    @track Ref2rec;
    @track Ref2Rating;
    @track Ref3sentdate;
    @track Reference3Name;
    @track Ref3revdate;
    @track Reference3phone;
    @track Ref3daterangest;
    @track Ref3email;
    @track Ref3dtrangeend;
    @track Ref3type;
    @track Ref3received;
    @track Ref3rating;

    @track urlName = '';
    @track isShowModal = false;
    @track deleteCvId;
    @track getCvName;

    @track qualmultipicks = [];

    @wire(CurrentPageReference)
    getStateParameters(currentPageReference) {
        if (currentPageReference) {
            this.urlStateParameters = currentPageReference.state;
            this.setParametersBasedOnUrl();
        }
    }

    setParametersBasedOnUrl() {
        this.urlName = this.urlStateParameters.qualification || null;
    }

    // Get Object Info.
    @wire(getObjectInfo, { objectApiName: TR1__Associated_Qualification__c })
    qualObjectInfo;

    // Get Picklist values.


    @wire(getPicklistValues, { recordTypeId: '$qualObjectInfo.data.defaultRecordTypeId', fieldApiName: Documents__c })
    documents(data, error) {
        if (data && data.data && data.data.values) {
            this.documentTypes = data;
            data.data.values.forEach(objPicklist => {
                this.docOptions.push({
                    label: objPicklist.label,
                    value: objPicklist.value
                });
            });
        } else if (error) {
            console.log({error});
        }
    };

    @wire(getPicklistValues,
        {
            recordTypeId: '$qualObjectInfo.data.defaultRecordTypeId',
            fieldApiName: Permanent_Right_to_Work_in_UK__c
        }
    )
    workRightToWorkValues(data, error) {

        if (data && data.data && data.data.values) {
            let options = [];
            data.data.values.forEach(objPicklist => {
                options.push({ label: objPicklist.value, value: objPicklist.value });
            });
            this.lstOptions = options;
        } else if (error) {
            console.log({error});
        }
    };

    //get picklist for overseas police check
    @wire(getPicklistValues,
        {
            recordTypeId: '$qualObjectInfo.data.defaultRecordTypeId',
            fieldApiName: OverseasPolicecheck
        }
    )
    workRightValues(data, error) {

        if (data && data.data && data.data.values) {
            let options = [];
            data.data.values.forEach(objPicklist => {
                options.push({ label: objPicklist.value, value: objPicklist.value });
            });
            this.overseasPoliceOps = options;

        } else if (error) {
            console.log({error});
        }
    };

    //Get picklist values for overseas teacher qualification
    @wire(getPicklistValues,
        {
            recordTypeId: '$qualObjectInfo.data.defaultRecordTypeId',
            fieldApiName: NARICApprove
        }
    )

    overseasteacherOps(data, error) {
        if (data && data.data && data.data.values) {
            let options = [];
            data.data.values.forEach(objPicklist => {
                options.push({ label: objPicklist.value, value: objPicklist.value });
            });
            this.naricApproveOps = options;
        } else if (error) {
            console.log({error});
        }
    };

    //Get picklist values for teacher Qualification types
    @wire(getPicklistValues,
        {
            recordTypeId: '$qualObjectInfo.data.defaultRecordTypeId',
            fieldApiName: Qualification_Type2__c
        }
    )

    teacherQFTypeVal(data, error) {
        if (data && data.data && data.data.values) {
            let options = [];

            data.data.values.forEach(objPicklist => {
                options.push({ label: objPicklist.value, value: objPicklist.value });
            });
            this.teacherQFTypeOptions = options;
        } else if (error) {
            console.log({error});
        }
    };


    //Get picklist values for Teacher qualifications
    @wire(getPicklistValues,
        {
            recordTypeId: '$qualObjectInfo.data.defaultRecordTypeId',
            fieldApiName: Qualification_Type__c
        }
    )

    teacherQualificationsVal(data, error) {

        if (data && data.data && data.data.values) {
            this.qualTypes = data;
            data.data.values.forEach(objPicklist => {

                let key = this.qualTypes.data.controllerValues[this.teacherQftype];
                this.teacherQualifications = this.qualTypes.data.values.filter(opt => opt.validFor.includes(key));

                let key1 = this.qualTypes.data.controllerValues[this.OTQQFtypeval];
                this.teacherQualificationsOver = this.qualTypes.data.values.filter(opt => opt.validFor.includes(key1));
                let key2 = this.qualTypes.data.controllerValues[this.earlyYearQFtype];
                this.teacherQualificationsEarly = this.qualTypes.data.values.filter(opt => opt.validFor.includes(key2));
                let key3 = this.qualTypes.data.controllerValues[this.supportQFtype];
                this.teacherQualificationsSupport = this.qualTypes.data.values.filter(opt => opt.validFor.includes(key3));
                let key4 = this.qualTypes.data.controllerValues[this.qValue];
                this.qualificationsPost16 = this.qualTypes.data.values.filter(opt => opt.validFor.includes(key4));
            });
        } else if (error) {
            this.reloadpage = true;
            this.template.querySelectorAll('c-ts_-error-component')[0].openModal();        
        }
    };

    //Get picklist values for groupIdtype
    @wire(getPicklistValues,
        {
            recordTypeId: '$qualObjectInfo.data.defaultRecordTypeId',
            fieldApiName: Group1IdType
        }
    )
    groupTypeIdOptions(data, error) {
        if (data && data.data && data.data.values) {
            let options = [];
            data.data.values.forEach(objPicklist => {
                options.push({ label: objPicklist.value, value: objPicklist.value });
            });
            this.groupTypes = options;
        } else if (error) {
            this.reloadpage = true;
            this.template.querySelectorAll('c-ts_-error-component')[0].openModal();        
        }
    };

    //Get picklist values for NameChangeDocument
    @wire(getPicklistValues,
        {
            recordTypeId: '$qualObjectInfo.data.defaultRecordTypeId',
            fieldApiName: NameChangeDocument
        }
    )
    nameChangeDocumentsValues(data, error) {
        if (data && data.data && data.data.values) {
            let options = [];
            data.data.values.forEach(objPicklist => {
                options.push({ label: objPicklist.value, value: objPicklist.value });
            });
            this.nameChangeDocuments = options;

        } else if (error) {
            this.reloadpage = true;
            this.template.querySelectorAll('c-ts_-error-component')[0].openModal();        
        }
    };

    //Get picklist values for Group2aIdtype
    @wire(getPicklistValues, { recordTypeId: '$qualObjectInfo.data.defaultRecordTypeId', fieldApiName: Group2AIdType })
    groupTypesValues(data, error) {

        if (data && data.data && data.data.values) {
            data.data.values.forEach(objPicklist => {

                this.Group2aIdTypes.push({
                    label: objPicklist.label,
                    value: objPicklist.value
                });
            });
        } else if (error) {
            this.reloadpage = true;
            this.template.querySelectorAll('c-ts_-error-component')[0].openModal();        
        }
    };

    //Get picklist values for Group2bIdtype
    @wire(getPicklistValues, { recordTypeId: '$qualObjectInfo.data.defaultRecordTypeId', fieldApiName: Group2bIdType })
    languages(data, error) {
        if (data && data.data && data.data.values) {
            data.data.values.forEach(objPicklist => {
                this.Group2bIdTypes.push({
                    label: objPicklist.label,
                    value: objPicklist.value
                });
            });
        } else if (error) {
            this.reloadpage = true;
            this.template.querySelectorAll('c-ts_-error-component')[0].openModal();        
        }
    };

    //get picklist for dbs
    @wire(getPicklistValues,
        {
            recordTypeId: '$qualObjectInfo.data.defaultRecordTypeId',
            fieldApiName: Update_Service_Status_Check__c
        }
    )
    updateStatusCheck(data, error) {
        if (data && data.data && data.data.values) {
            let options = [];
            data.data.values.forEach(objPicklist => {
                options.push({ label: objPicklist.value, value: objPicklist.value });
            });
            this.dbsOptions = options;

        } else if (error) {
            this.reloadpage = true;
            this.template.querySelectorAll('c-ts_-error-component')[0].openModal();        
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
        if (data && data.data && data.data.values) {
            let options11 = [];
            data.data.values.forEach(objPicklist => {
                options11.push({ label: objPicklist.value, value: objPicklist.value });
            });
            this.qList = options11;

        } else if (error) {
            this.reloadpage = true;
            this.template.querySelectorAll('c-ts_-error-component')[0].openModal();        
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
        if (data && data.data && data.data.values) {
            let options = [];
            data.data.values.forEach(objPicklist => {
                options.push({ label: objPicklist.value, value: objPicklist.value });
            });
            this.qualopt = options;

        } else if (error) {
            this.reloadpage = true;
            this.template.querySelectorAll('c-ts_-error-component')[0].openModal();        
        }
    };

    //for international qulification
    @wire(getPicklistValues,
        {
            recordTypeId: '$qualObjectInfo.data.defaultRecordTypeId',
            fieldApiName: Choice_of_Country__c
        }
    )
    qualificationTypee(data, error) {
        if (data && data.data && data.data.values) {
            let options = [];
            data.data.values.forEach(objPicklist => {
                options.push({ label: objPicklist.value, value: objPicklist.value });
            });
            this.choiceOfCountryOps = options;

        } else if (error) {
            this.reloadpage = true;
            this.template.querySelectorAll('c-ts_-error-component')[0].openModal();        
        }
    };

    //For References
    @wire(getPicklistValues,
        {
            recordTypeId: '$qualObjectInfo.data.defaultRecordTypeId',
            fieldApiName: Ref1Type
        }
    )
    groupTypeOptionsRef1(data, error) {
        if (data && data.data && data.data.values) {
            let options = [];
            data.data.values.forEach(objPicklist => {
                options.push({ label: objPicklist.value, value: objPicklist.value });
            });
            this.Ref1Types = options;
        } else if (error) {
            this.reloadpage = true;
            this.template.querySelectorAll('c-ts_-error-component')[0].openModal();        
        }
    };

    @wire(getPicklistValues,
        {
            recordTypeId: '$qualObjectInfo.data.defaultRecordTypeId',
            fieldApiName: Ref1Rating
        }
    )
    groupTypeOptions1(data, error) {
        if (data && data.data && data.data.values) {
            let options = [];
            data.data.values.forEach(objPicklist => {
                options.push({ label: objPicklist.value, value: objPicklist.value });
            });
            this.Ref1Ratings = options;
        } else if (error) {
            this.reloadpage = true;
            this.template.querySelectorAll('c-ts_-error-component')[0].openModal();        
        }
    };

    @wire(getPicklistValues,
        {
            recordTypeId: '$qualObjectInfo.data.defaultRecordTypeId',
            fieldApiName: Ref2Type
        }
    )
    groupTypeOptions2(data, error) {
        if (data && data.data && data.data.values) {
            let options = [];
            data.data.values.forEach(objPicklist => {
                options.push({ label: objPicklist.value, value: objPicklist.value });
            });
            this.Ref2Types = options;
        } else if (error) {
            this.reloadpage = true;
            this.template.querySelectorAll('c-ts_-error-component')[0].openModal();        
        }
    };

    @wire(getPicklistValues,
        {
            recordTypeId: '$qualObjectInfo.data.defaultRecordTypeId',
            fieldApiName: Ref2Rating
        }
    )
    groupTypeOptions3(data, error) {
        if (data && data.data && data.data.values) {
            let options = [];
            data.data.values.forEach(objPicklist => {
                options.push({ label: objPicklist.value, value: objPicklist.value });
            });
            this.Ref2Ratings = options;
        } else if (error) {
            this.reloadpage = true;
            this.template.querySelectorAll('c-ts_-error-component')[0].openModal();        
        }
    };

    @wire(getPicklistValues,
        {
            recordTypeId: '$qualObjectInfo.data.defaultRecordTypeId',
            fieldApiName: Ref3Type
        }
    )
    groupTypeOptions4(data, error) {
        if (data && data.data && data.data.values) {
            let options = [];
            data.data.values.forEach(objPicklist => {
                options.push({ label: objPicklist.value, value: objPicklist.value });
            });
            this.Ref3Types = options;
        } else if (error) {
            this.reloadpage = true;
            this.template.querySelectorAll('c-ts_-error-component')[0].openModal();        
        }
    };

    @wire(getPicklistValues,
        {
            recordTypeId: '$qualObjectInfo.data.defaultRecordTypeId',
            fieldApiName: Ref3Rating
        }
    )
    groupTypeOptions(data, error) {
        if (data && data.data && data.data.values) {
            let options = [];
            data.data.values.forEach(objPicklist => {
                options.push({ label: objPicklist.value, value: objPicklist.value });
            });
            this.Ref3Ratings = options;
        } else if (error) {
            this.reloadpage = true;
            this.template.querySelectorAll('c-ts_-error-component')[0].openModal();        
        }
    };

    connectedCallback() {
        this.isSpinner = true;
        this.getAlldata();
        this.checkUrl();
        this.getConId();

        this.isSpinner = false;
    }

    currentPageReference = null;
    urlStateParameters = null;

    getAlldata() {
        try {
            this.teacherDual = [];
            this.qualmultipicks = [];
            this.supportQualification = [];
            this.earlyYearQualification = [];
            this.OTQteacherQualifications = [];

            getQualifiData({})
                .then(result => {
                    for (var i = 0; i < result.length; i++) {
                        if (result[i].qualificationName__c == 'CV') {
                            this.gapsExplanation = result[i].Gaps_Explanation__c;
                            this.cvSubmitted = result[i].CV_Submitted__c;
                            this.cvReceived = result[i].CV_Received__c;
                        }
                        else if (result[i].qualificationName__c == 'Teacher Qualification') {
                            this.tranum = result[i].NCTL_Number__c;
                            this.teacherQftype = result[i].Qualification_Type2__c;
                            this.statusOfTeacherQual = result[i].TR1__Status__c;

                            if (result[i].TR1__Expiration_Date__c != null) {
                                this.exprDateOfTeacherQual = result[i].TR1__Expiration_Date__c;
                            }

                            if (result[i].Qualification_Type__c != null) {
                                this.teacherDual = result[i].Qualification_Type__c.split(';');
                            }
                        }
                        else if (result[i].qualificationName__c == 'Overseas Police Check') {

                            this.overseasVal = result[i].Overseas_Police_Check__c;
                            this.opcStdate = result[i].Live_Worked_Overseas_Start_Date__c;
                            this.opcEddate = result[i].Live_Worked_Overseas_End_Date__c;
                        }
                        else if (result[i].qualificationName__c == 'Overseas Teacher Qualifications') {
                            this.OTQQFtypeval = result[i].Qualification_Type2__c;
                            this.naricApprove = result[i].NARIC_Approved__c;
                            this.otstranum = result[i].NCTL_Number__c;
                            this.statusOfOverSeasTeacherQual = result[i].TR1__Status__c;

                            if (result[i].TR1__Expiration_Date__c != null) {
                                this.exprDateOfOverSeasTeacherQual = result[i].TR1__Expiration_Date__c;
                            }
                            if (result[i].Qualification_Type__c != null) {
                                this.OTQteacherQualifications = result[i].Qualification_Type__c.split(';');
                            }
                        }
                        else if (result[i].qualificationName__c == 'Post 16 Qualifications') {
                            this.snumb = result[i].SET_Registration_Number__c;
                            this.expirDate = result[i].SET_Expiry_Date__c;
                            this.QtlsCheck = result[i].QTLS__c;
                            this.qValue = result[i].Qualification_Type2__c;
                            this.statusOfPost16Qual = result[i].TR1__Status__c;

                            if (result[i].TR1__Expiration_Date__c != null) {
                                this.exprDateOfPost16Qual = result[i].TR1__Expiration_Date__c;
                            }
                            if (result[i].Qualification_Type__c != null) {
                                this.qualmultipicks = result[i].Qualification_Type__c.split(';');
                            }
                        }
                        else if (result[i].qualificationName__c == 'Emergency Contact') {
                            this.Relate = result[i].Relationship_to_You__c;
                            this.eConAdd = result[i].Emergency_Contact_Address__c;
                            this.eConHome = result[i].Emergency_Contact_Home_Phone__c;
                            this.eConMobile = result[i].Emergency_Contact_Mobile_Phone__c;
                            this.eConWork = result[i].Emergency_Contact_Work_Phone__c;
                            this.eContactName = result[i].Emergency_Contact_Name__c;
                        }
                        else if (result[i].qualificationName__c == 'References') {

                            this.Ref1sentdate = result[i].Reference_Sent_Date__c;
                            this.Reference1name = result[i].Reference_1_Text_Name__c;
                            this.Reference1RecDate = result[i].Reference_Received_Date__c;
                            this.Reference1phone = result[i].Reference_1_Contact_Details__c;
                            this.Reference1daterangestart = result[i].Reference_1_Date_Range__c;
                            this.Reference1email = result[i].Reference_1_Email__c;
                            this.Reference1daterangeend = result[i].Reference_1_Date_Range_End__c;
                            this.Ref1Type = result[i].Reference_1_Type__c;
                            this.Ref1Rec = result[i].Reference_1_Received__c;
                            this.Ref1Rating = result[i].Reference_1_Rating__c;
                            this.Ref2sentdate = result[i].Reference_2_Sent_Date__c;
                            this.Reference2name = result[i].Reference_2_Text_Name__c;
                            this.Ref2recdate = result[i].Reference_2_Received_Date__c;
                            this.Ref2phone = result[i].Reference_2_Contact_Details__c;
                            this.Ref2daterangest = result[i].Reference_2_Date_Rage__c;
                            this.Ref2email = result[i].Reference_2_Email__c;
                            this.Ref2daterangeend = result[i].Reference_2_Date_Range_End__c;
                            this.Ref2Type = result[i].Reference_2_Type__c;
                            this.Ref2rec = result[i].Reference_2_Received__c;
                            this.Ref2Rating = result[i].Reference_2_Rating__c;
                            this.Ref3sentdate = result[i].Reference_3_Sent_Date__c;
                            this.Reference3Name = result[i].Reference_3_Text_Name__c;
                            this.Ref3revdate = result[i].Reference_3_Received_Date__c;
                            this.Reference3phone = result[i].Reference_3_Contact_Details__c;
                            this.Ref3daterangest = result[i].Reference_3_Date_Range__c;
                            this.Ref3email = result[i].Reference_3_Email__c;
                            this.Ref3dtrangeend = result[i].Reference_3_Date_Range_End__c;
                            this.Ref3type = result[i].Reference_3_Type__c;
                            this.Ref3received = result[i].Reference_3_Received__c;
                            this.Ref3rating = result[i].Reference_3_Rating__c;

                        }
                        else if (result[i].qualificationName__c == 'Early Years Qualifications') {
                            this.earlyYearQFtype = result[i].Qualification_Type2__c;
                            this.statusOfYearlyQual = result[i].TR1__Status__c;

                            if (result[i].TR1__Expiration_Date__c != null) {
                                this.exprDateOfYearlyQual = result[i].TR1__Expiration_Date__c;
                            }
                            if (result[i].Qualification_Type__c != null) {
                                this.earlyYearQualification = result[i].Qualification_Type__c.split(';');
                            }
                        }
                        else if (result[i].qualificationName__c == 'Support Qualifications') {
                            this.supportQFtype = result[i].Qualification_Type2__c;
                            this.statusOfSupportQual = result[i].TR1__Status__c;

                            if (result[i].TR1__Expiration_Date__c != null) {
                                this.exprDateOfSupportQual = result[i].TR1__Expiration_Date__c;
                            }
                            if (result[i].Qualification_Type__c != null) {
                                this.supportQualification = result[i].Qualification_Type__c.split(';');
                            }
                        }
                    }
                })
                .catch(error => {
                })

        } catch (error) {
            this.reloadpage = true;
            this.template.querySelectorAll('c-ts_-error-component')[0].openModal();        
        }
    }


    getDocData() {
        try {
            getqualifiFileData({
                parentId: this.contactId,
                description: this.urlName
                }).then(result => {
                    this.cvList = result;
                })
                .catch(error => {
                })
        } catch (error) {
            this.reloadpage = true;
            this.template.querySelectorAll('c-ts_-error-component')[0].openModal();        
        }
    }


    checkUrl() {
        try {
            if (this.urlName == 'CV') {
                this.checkCv = true;
            }
            else if (this.urlName == 'Right to Work') {
                this.checkRtw = true;
            }
            else if (this.urlName == 'Teacher Qualification') {
                this.checkteacherQual = true;
            }
            else if (this.urlName == 'Overseas Police Check') {
                this.checkoverPc = true;
            }
            else if (this.urlName == 'Overseas Teacher Qualifications') {
                this.checkoverTQ = true;
            }
            else if (this.urlName == 'ID') {
                this.checkId = true;
            }
            else if (this.urlName == 'Safeguarding') {
                this.checkSafe = true;
            }
            else if (this.urlName == 'Emergency Contact') {
                this.checkEme = true;
            }
            else if (this.urlName == 'DBS') {
                this.checkDbs = true;
            }
            else if (this.urlName == 'Post 16 Qualifications') {
                this.checkPost16 = true;
            }
            else if (this.urlName == 'Early Years Qualifications') {
                this.checkEarly = true;
            }
            else if (this.urlName == 'Support Qualifications') {
                this.checkSupport = true;
            }
            else if (this.urlName == 'International') {
                this.checkInt = true;
            }
            else if (this.urlName == 'Barred List') {
                this.checkBarred = true;
            }
            else if (this.urlName == 'References') {
                this.checkRefs = true;
            }
            else if (this.urlName == 'Photo') {
                this.checkUpload = true;
            }
            else if (this.urlName == 'Qualifications') {
                this.checkQualification = true;
            }
        } catch (error) {
            this.reloadpage = true;
            this.template.querySelectorAll('c-ts_-error-component')[0].openModal();        
        }
    }

    getConId() {

        try {
            getContactId()
                .then(result => {
                    this.contactId = result;
                    this.getDocData();
                })
        } catch (error) {
            this.reloadpage = true;
            this.template.querySelectorAll('c-ts_-error-component')[0].openModal();        
        }

    }

    handleUpsellChange(event) {
        try {
            if (event.target.name == 'teacherQftype') {
                let key = this.qualTypes.data.controllerValues[event.target.value];
                this.teacherQualifications = this.qualTypes.data.values.filter(opt => opt.validFor.includes(key));
            }
            else if (event.target.name == 'OTQQFtypeval') {
                this.OTQQFtypeval = event.target.value;
                let key = this.qualTypes.data.controllerValues[event.target.value];
                this.teacherQualificationsOver = this.qualTypes.data.values.filter(opt => opt.validFor.includes(key));
            }
            else if (event.target.name == 'earlyYearQFtype') {
                let key = this.qualTypes.data.controllerValues[event.target.value];
                this.teacherQualificationsEarly = this.qualTypes.data.values.filter(opt => opt.validFor.includes(key));
            }
            else if (event.target.name == 'supportQFtype') {
                let key = this.qualTypes.data.controllerValues[event.target.value];
                this.teacherQualificationsSupport = this.qualTypes.data.values.filter(opt => opt.validFor.includes(key));
            }
            else if (event.target.name == 'quList') {
                let key = this.qualTypes.data.controllerValues[event.target.value];
                this.qualificationsPost16 = this.qualTypes.data.values.filter(opt => opt.validFor.includes(key));
            }
            else if (event.target.name == 'workPermit') {
                this.workPermit = event.target.value;
                let key = this.documentTypes.data.controllerValues[event.target.value];
                this.docOptions = this.documentTypes.data.values.filter(opt => opt.validFor.includes(key));
            }
            else if (event.target.name == 'combinedQFtype') {
                let key = this.qualTypes.data.controllerValues[event.target.value];
                this.combinedQualificationOptions = this.qualTypes.data.values.filter(opt => opt.validFor.includes(key));
                if (key == 0 || key == 1 || key == 2 || key == 3) {
                    this.isOverSeasTeacherQual = true;
                    this.isTeacherQual = false;
                    this.isSupportQual = false;
                    this.isPost16Qual = false;
                    this.isYearlyQual = false;

                    this.commbinedQFtype = event.target.value;
                    this.combinnedQualificationsValue = this.OTQteacherQualifications;
                    this.commbinedQualStatus = this.statusOfOverSeasTeacherQual;
                    this.commbinedQualExprDate = this.exprDateOfOverSeasTeacherQual;
                } else if (key == 4) {
                    this.isTeacherQual = true;
                    this.isSupportQual = false;
                    this.isOverSeasTeacherQual = false;
                    this.isPost16Qual = false;
                    this.isYearlyQual = false;

                    this.commbinedQFtype = event.target.value;
                    this.combinnedQualificationsValue = this.teacherDual;
                    this.commbinedQualStatus = this.statusOfTeacherQual;
                    this.commbinedQualExprDate = this.exprDateOfTeacherQual;
                } else if (key == 5) {
                    this.isSupportQual = true;
                    this.isOverSeasTeacherQual = false;
                    this.isTeacherQual = false;
                    this.isPost16Qual = false;
                    this.isYearlyQual = false;

                    this.commbinedQFtype = event.target.value;
                    this.combinnedQualificationsValue = this.supportQualification;
                    this.commbinedQualStatus = this.statusOfSupportQual;
                    this.commbinedQualExprDate = this.exprDateOfSupportQual;
                } else if (key == 6) {
                    this.isPost16Qual = true;
                    this.isSupportQual = false;
                    this.isOverSeasTeacherQual = false;
                    this.isTeacherQual = false;
                    this.isYearlyQual = false;

                    this.commbinedQFtype = event.target.value;
                    this.combinnedQualificationsValue = this.qualmultipicks;
                    this.commbinedQualStatus = this.statusOfPost16Qual;
                    this.commbinedQualExprDate = this.exprDateOfPost16Qual;
                } else if (key == 7) {
                    this.isYearlyQual = true;
                    this.isOverSeasTeacherQual = false;
                    this.isTeacherQual = false;
                    this.isPost16Qual = false;
                    this.isSupportQual = false;

                    this.commbinedQFtype = event.target.value;
                    this.combinnedQualificationsValue = this.earlyYearQualification;
                    this.commbinedQualStatus = this.statusOfYearlyQual;
                    this.commbinedQualExprDate = this.exprDateOfYearlyQual;
                }

                // for Updaload File parts
                var urlNameParam = this.urlName;
                if (urlNameParam == 'Qualifications') {
                    urlNameParam = this.commbinedQFtype;
                    if (this.commbinedQFtype.slice(0, 23) == 'Overseas Qualifications') {
                        urlNameParam = 'Overseas Teacher Qualifications';
                    }
                }
                getqualifiFileData({
                    parentId: this.contactId,
                    description: urlNameParam
                    }).then(result => {
                        this.cvList = result;
                    })
                    .catch(error => {
                    })

            }
        } catch (error) {
            this.reloadpage = true;
            this.template.querySelectorAll('c-ts_-error-component')[0].openModal();        
        }
    }

    onPrevious() {
        var url = window.location.origin;
        url = url + '/s/myqualifications';
        window.open(url, '_self');
    }

    //On change file
    handleFile(event) {

        try {
            var cvId = this.cvId;
            this.qName = event.target.name;
            this.isSpinner = true;
            let fileList = event.target.files;
            this.file = fileList[0];
            let fileUploader = this.template.querySelectorAll('.fileUploader');
            fileUploader.forEach(element => {
                element.value = '';
            });
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

    // upload CV
    cvUpload(event) {
        try {
            var file = this.file;
            var fileContents = this.fileContents;
            saveQualifiFile({
                parentId: this.contactId,
                description: this.qName,
                fileName: file.name,
                base64Data: encodeURIComponent(fileContents)
            })
                .then(result => {
                    if (result != null) {
                        this.cvId = result[0];
                        this.cvName = result[1];
                    }
                    if (this.urlName == 'Qualifications') {
                        var urlNameParam = this.urlName;
                        if (urlNameParam == 'Qualifications') {
                            urlNameParam = this.commbinedQFtype;
                            if (this.commbinedQFtype.slice(0, 23) == 'Overseas Qualifications') {
                                urlNameParam = 'Overseas Teacher Qualifications';
                            }
                        }
                        getqualifiFileData({
                            parentId: this.contactId,
                            description: urlNameParam
                        }).then(result => {
                            this.cvList = result;
                        })
                            .catch(error => {
                            })

                    } else {
                        this.getDocData();
                    }
                    this.isSpinner = false;
                    this.template.querySelector('c-ts_-tost-notification').showToast('success', 'Proof Added Successfully', 3000);
                })
                .catch(error => {
                    this.isSpinner = false;
                    this.template.querySelector('c-ts_-tost-notification').showToast('error', 'Something Went Wrong', 3000);
                });
        } catch (error) {
            this.reloadpage = true;
            this.template.querySelectorAll('c-ts_-error-component')[0].openModal();        }
    };

    // delete CV
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

    // confirmbox
    hideModalBox() {
        this.isShowModal = false;
    }

    // confirmbox
    yesDelete(event) {
        try {
            this.isShowModal = false;
            this.isSpinner = true;
            deleteRecord(this.deleteCvId)
                .then((result) => {
                    this.template.querySelector('c-ts_-tost-notification').showToast('success', 'Your Proof is deleted', 3000);
                    if (this.urlName == 'Qualifications') {
                        var urlNameParam = this.urlName;
                        if (urlNameParam == 'Qualifications') {
                            urlNameParam = this.commbinedQFtype;
                            if (this.commbinedQFtype.slice(0, 23) == 'Overseas Qualifications') {
                                urlNameParam = 'Overseas Teacher Qualifications';
                            }
                        }
                        getqualifiFileData({
                            parentId: this.contactId,
                            description: urlNameParam
                            }).then(result => {
                                this.cvList = result;
                            })
                            .catch(error => {
                            })

                    } else {
                        this.getDocData();
                    }

                    this.isSpinner = false;
                })
                .catch(error => {
                    this.template.querySelector('c-ts_-tost-notification').showToast('error', 'Something Went Wrong', 3000);
                    this.isSpinner = false;
                });
        } catch (error) {
            this.reloadpage = true;
            this.template.querySelectorAll('c-ts_-error-component')[0].openModal();        
        }
    }

    handleChange(event) {
        try {
            this.teacherDualVal = '';
            this.OTQteacherQualification = '';
            this.qualmultipick = '';
            this.supportQualifications = '';
            if (this.urlName == 'CV') {
                if (event.target.name == 'gapsExp') {
                    this.gapsExplanation = event.target.value;
                }
                else if (event.target.name == 'cvSub') {
                    this.cvSubmitted = event.target.checked;
                }
                else if (event.target.name == 'cvrec') {
                    this.cvReceived = event.target.checked;
                }
            }
            else if (this.urlName == 'Perm Qualification') {
                if (event.target.name == 'nctlNum') {
                    this.nctlNum = event.target.value;
                }
                else if (event.target.name == 'setNum') {
                    this.setNum = event.target.value;
                }
                else if (event.target.name == 'qtls') {
                    this.qtls = event.target.checked;
                }
            }
            else if (this.urlName == 'Right to Work') {
                if (event.target.name == 'workPermit') {
                }
                else if (event.target.name == 'rtwdocs') {

                    this.docs = event.detail.value;
                    const docslst = Object.assign({}, this.docs);
                    for (var k in docslst) {
                        this.s += docslst[parseInt(k)] + ';';
                    }
                }
                else if (event.target.name == 'workpermitdate') {
                    this.workpermitdate = event.target.value;
                }
            }
            else if (this.urlName == 'Teacher Qualification') {

                if (event.target.name == 'tranum') {
                    this.tranum = event.target.value;
                }
                else if (event.target.name == 'teacherQftype') {
                    this.teacherQftype = event.target.value;
                }
                else if (event.target.name == 'teacherDualVal') {

                    this.tcqs = event.detail.value;
                    const dc = Object.assign({}, this.tcqs);
                    for (var k in dc) {
                        this.teacherDualVal += dc[parseInt(k)] + ';';
                    }
                }
            }
            else if (this.urlName == 'Overseas Police Check') {

                if (event.target.name == 'overseasname') {
                    this.overseasVal = event.target.value;
                }
                else if (event.target.name == 'opcStdate') {
                    this.opcStdate = event.target.value;
                }
                else if (event.target.name == 'opcEddate') {
                    this.opcEddate = event.target.value;
                }
            }

            else if (this.urlName == 'Overseas Teacher Qualifications') {

                if (event.target.name == 'OTQQFtypeval') {
                    this.OTQQFtypeval = event.target.value;
                }
                else if (event.target.name == 'naricApprove') {
                    this.naricApprove = event.target.value;
                }
                else if (event.target.name == 'otstranum') {
                    this.otstranum = event.target.value;
                }
                else if (event.target.name == 'OTQteacherQualification') {

                    const docslst = Object.assign({}, event.detail.value);
                    var picklistData = '';
                    for (var k in docslst) {
                        picklistData += docslst[parseInt(k)] + ';';
                        this.OTQteacherQualification += docslst[parseInt(k)] + ';';
                    }
                }
            }

            else if (this.urlName == 'ID') {

                if (event.target.name == 'group1IdType') {
                    this.group1IdTypeVal = event.target.value;
                }
                else if (event.target.name == 'namechangedocument') {
                    this.namechangedocument = event.target.value;
                }
                else if (event.target.name == 'group2aIdType') {

                    const docslstG1 = Object.assign({}, event.detail.value);
                    for (var k in docslstG1) {
                        this.Group2aIdType1 += docslstG1[parseInt(k)] + ';';
                    }
                }
                else if (event.target.name == 'group2bIdType') {

                    const docslstG2 = Object.assign({}, event.detail.value);
                    for (var k in docslstG2) {
                        this.Group2bIdType1 += docslstG2[parseInt(k)] + ';';
                    }
                }
            }
            else if (this.urlName == 'Safeguarding') {
                if (event.target.name == 'safedate') {
                    this.safegDate = event.target.value;
                }
            }

            else if (this.urlName == 'Emergency Contact') {
                if (event.target.name == 'EconName') {
                    this.eContactName = event.target.value;
                } else if (event.target.name == 'EconMobile') {
                    this.eConMobile = event.target.value;
                } else if (event.target.name == 'EconWork') {
                    this.eConWork = event.target.value;
                } else if (event.target.name == 'Relation') {
                    this.Relate = event.target.value;
                } else if (event.target.name == 'EconHome') {
                    this.eConHome = event.target.value;
                } else if (event.target.name == 'EconAdd') {
                    this.eConAdd = event.target.value;
                }
            }

            else if (this.urlName == 'DBS') {
                if (event.target.name == 'dbnumber') {
                    this.dbNum = event.target.value;
                } else if (event.target.name == 'dbsname') {
                    this.dbsUpdateSer = event.target.value;
                }

            }

            else if (this.urlName == 'Post 16 Qualifications') {
                if (event.target.name == 'snumber') {
                    this.snumb = event.target.value;
                } else if (event.target.name == 'quList') {
                    this.qValue = event.detail.value;
                } else if (event.target.name == 'expDate') {
                    this.expirDate = event.target.value;
                } else if (event.target.name == 'qtl') {
                    this.QtlsCheck = event.target.checked;
                } else if (event.target.name == 'qualselect') {
                    const docspost16 = Object.assign({}, event.detail.value);
                    for (var k in docspost16) {
                        this.qualmultipick += docspost16[parseInt(k)] + ';';
                    }
                }

            }

            else if (this.urlName == 'International') {
                if (event.target.name == 'seekIntPos') {
                    this.seekIntPos = event.target.checked;
                } else if (event.target.name == 'country') {
                    var docslst1 = Object.assign({}, event.detail.value);
                    for (var k in docslst1) {
                        this.country += docslst1[parseInt(k)] + ';';
                    }
                }
            }

            else if (this.urlName == 'Early Years Qualifications') {

                if (event.target.name == 'earlyYearQFtype') {
                    this.earlyYearQFtype = event.target.value;
                } else if (event.target.name == 'earlyYearQualifications') {
                    const docslst = Object.assign({}, event.detail.value);
                    for (var k in docslst) {
                        this.earlyYearQualifications += docslst[parseInt(k)] + ';';
                    }
                }
            }

            else if (this.urlName == 'Support Qualifications') {
                if (event.target.name == 'supportQFtype') {
                    this.supportQFtype = event.target.value;
                } else if (event.target.name == 'supportQualifications') {
                    const docslst = Object.assign({}, event.detail.value);
                    for (var k in docslst) {
                        this.supportQualifications += docslst[parseInt(k)] + ';';
                    }
                }
            }

            else if (this.urlName == 'Barred List') {

                if (event.target.name == 'barredcheckurl') {
                    this.barredcheckurl = event.target.value;;
                }
                else if (event.target.name == 'barredListResult') {
                    this.barredListResult = event.target.value;
                }
                else if (event.target.name == 'ewscheckeddate') {
                    this.ewscheckeddate = event.target.value;
                }
                else if (event.target.name == 'ewsnextcheckeddate') {
                    this.ewsnextcheckeddate = event.target.value;
                }
                else if (event.target.name == 'barredlistdatecheck') {
                    this.barredlistdatecheck = event.target.value;
                }
                else if (event.target.name == 'barredlistexpirydate') {
                    this.barredlistexpirydate = event.target.value;
                }
                else if (event.target.name == 'DOB') {
                    this.DOB = event.target.value;
                }

            }

            else if (this.urlName == 'References') {

                if (event.target.name == 'Ref1sentdate') {
                    this.Ref1sentdate = event.target.value;
                }
                else if (event.target.name == 'Reference1name') {
                    this.Reference1name = event.target.value;
                }
                else if (event.target.name == 'Reference1recdate') {
                    this.Reference1RecDate = event.target.value;
                }
                else if (event.target.name == 'Reference1phone') {

                    this.Reference1phone = event.target.value;
                }
                else if (event.target.name == 'Reference1daterangestart') {
                    this.Reference1daterangestart = event.target.value;
                }
                else if (event.target.name == 'Reference1email') {
                    this.Reference1email = event.target.value;
                }
                else if (event.target.name == 'Reference1daterangeend') {
                    this.Reference1daterangeend = event.target.value;
                }
                else if (event.target.name == 'Ref1Type') {
                    this.Ref1Type = event.target.value;
                }
                else if (event.target.name == 'Ref1Rec') {
                    this.Ref1Rec = event.target.checked;
                }
                else if (event.target.name == 'Ref1Rating') {
                    this.Ref1Rating = event.target.value;
                }
                else if (event.target.name == 'Ref2sentdate') {
                    this.Ref2sentdate = event.target.value;
                }
                else if (event.target.name == 'Reference2name') {
                    this.Reference2name = event.target.value;
                }
                else if (event.target.name == 'Ref2recdate') {
                    this.Ref2recdate = event.target.value;
                }
                else if (event.target.name == 'Ref2phone') {
                    this.Ref2phone = event.target.value;
                }
                else if (event.target.name == 'Ref2daterangest') {
                    this.Ref2daterangest = event.target.value;
                }
                else if (event.target.name == 'Ref2email') {
                    this.Ref2email = event.target.value;
                }
                else if (event.target.name == 'Ref2daterangeend') {
                    this.Ref2daterangeend = event.target.value;
                }
                else if (event.target.name == 'Ref2Type') {
                    this.Ref2Type = event.target.value;
                }
                else if (event.target.name == 'Ref2rec') {
                    this.Ref2rec = event.target.checked;
                }
                else if (event.target.name == 'Ref2Rating') {
                    this.Ref2Rating = event.target.value;
                }
                else if (event.target.name == 'Ref3sentdate') {
                    this.Ref3sentdate = event.target.value;
                }
                else if (event.target.name == 'Reference3Name') {
                    this.Reference3Name = event.target.value;
                }
                else if (event.target.name == 'Ref3revdate') {
                    this.Ref3revdate = event.target.value;
                }
                else if (event.target.name == 'Reference3phone') {
                    this.Reference3phone = event.target.value;
                }
                else if (event.target.name == 'Ref3daterangest') {
                    this.Ref3daterangest = event.target.value;
                }
                else if (event.target.name == 'Ref3email') {
                    this.Ref3email = event.target.value;
                }
                else if (event.target.name == 'Ref3dtrangeend') {
                    this.Ref3dtrangeend = event.target.value;
                }
                else if (event.target.name == 'Ref3type') {
                    this.Ref3type = event.target.value;
                }
                else if (event.target.name == 'Ref3received') {
                    this.Ref3received = event.target.checked;
                }
                else if (event.target.name == 'Ref3rating') {
                    this.Ref3rating = event.target.value;
                }

            } else if (this.urlName == 'Qualifications') {
                if (this.commbinedQFtype == 'Teacher Qualification') {
                    if (event.target.name == 'tranum') {
                        this.tranum = event.target.value;
                    }
                    else if (event.target.name == 'combinedQFtype') {
                        this.teacherQftype = event.target.value;
                    }
                    else if (event.target.name == 'combinnedQualDualValue') {
                        this.teacherDualVal = '';
                        this.tcqs = event.detail.value;
                        const dc = Object.assign({}, this.tcqs);
                        for (var k in dc) {
                            this.teacherDualVal += dc[parseInt(k)] + ';';
                        }
                    }
                } else if (this.commbinedQFtype == 'Early Years Qualifications') {
                    if (event.target.name == 'combinedQFtype') {
                        this.earlyYearQFtype = event.target.value;
                    } else if (event.target.name == 'combinnedQualDualValue') {
                        this.earlyYearQualifications = '';
                        const docslst = Object.assign({}, event.detail.value);
                        for (var k in docslst) {
                            this.earlyYearQualifications += docslst[parseInt(k)] + ';';
                        }
                    }
                } else if (this.commbinedQFtype == 'Support Qualifications') {
                    if (event.target.name == 'combinedQFtype') {
                        this.supportQFtype = event.target.value;
                    } else if (event.target.name == 'combinnedQualDualValue') {
                        this.supportQualifications = '';
                        const docslst = Object.assign({}, event.detail.value);
                        for (var k in docslst) {
                            this.supportQualifications += docslst[parseInt(k)] + ';';
                        }
                    }
                } else if (this.commbinedQFtype == 'Post 16 Qualifications') {
                    if (event.target.name == 'snumber') {
                        this.snumb = event.target.value;
                    } else if (event.target.name == 'combinedQFtype') {
                        this.qValue = event.detail.value;
                    } else if (event.target.name == 'expDate') {
                        this.expirDate = event.target.value;
                    } else if (event.target.name == 'qtl') {
                        this.QtlsCheck = event.target.checked;
                    } else if (event.target.name == 'combinnedQualDualValue') {
                        this.qualmultipick = '';
                        const docspost16 = Object.assign({}, event.detail.value);
                        for (var k in docspost16) {
                            this.qualmultipick += docspost16[parseInt(k)] + ';';
                        }
                    }
                } else if (this.commbinedQFtype.slice(0, 23) == 'Overseas Qualifications') {

                    if (event.target.name == 'combinedQFtype') {
                        this.OTQQFtypeval = event.target.value;
                    }
                    else if (event.target.name == 'naricApprove') {
                        this.naricApprove = event.target.value;
                    }
                    else if (event.target.name == 'otstranum') {
                        this.otstranum = event.target.value;
                    }
                    else if (event.target.name == 'combinnedQualDualValue') {

                        this.OTQteacherQualification = '';
                        const docslst = Object.assign({}, event.detail.value);
                        var picklistData = '';
                        for (var k in docslst) {
                            picklistData += docslst[parseInt(k)] + ';';
                            this.OTQteacherQualification += docslst[parseInt(k)] + ';';
                        }
                    }
                }
            }

        } catch (error) {
            this.reloadpage = true;
            this.template.querySelectorAll('c-ts_-error-component')[0].openModal();       
        }
    }

    saveQualification() {

        try {
            this.isSpinner = true;
            let qualObj = { 'sobjectType': 'TR1__Associated_Qualification__c' };
            qualObj.qualificationName__c = this.urlName;
            if (this.urlName == 'CV') {
                qualObj.Gaps_Explanation__c = this.gapsExplanation;
                qualObj.CV_Submitted__c = this.cvSubmitted;
                qualObj.CV_Received__c = this.cvReceived;
            }
            else if (this.urlName == 'Perm Qualification') {
                qualObj.NCTL_Number__c = this.nctlNum;
                qualObj.SET_Registration_Number__c = this.setNum;
                qualObj.QTLS__c = this.qtls;
            }

            else if (this.urlName == 'Right to Work') {
                qualObj.Permanent_Right_to_Work_in_UK__c = this.workPermit;
                qualObj.Documents__c = this.s;
                qualObj.Work_Permit_OR_Visa_Expiry_Date__c = this.workpermitdate;
            }

            else if (this.urlName == 'Teacher Qualification') {
                qualObj.NCTL_Number__c = this.tranum;
                qualObj.Qualification_Type2__c = this.teacherQftype;
                qualObj.Qualification_Type__c = this.teacherDualVal;

            }

            else if (this.urlName == 'Overseas Teacher Qualifications') {
                qualObj.NCTL_Number__c = this.otstranum;
                qualObj.NARIC_Approved__c = this.naricApprove;
                qualObj.Qualification_Type2__c = this.OTQQFtypeval;
                qualObj.Qualification_Type__c = this.OTQteacherQualification;
            }

            else if (this.urlName == 'Overseas Police Check') {

                qualObj.Overseas_Police_Check__c = this.overseasVal;
                qualObj.Live_Worked_Overseas_Start_Date__c = this.opcStdate;
                qualObj.Live_Worked_Overseas_End_Date__c = this.opcEddate;
            }

            else if (this.urlName == 'ID') {
                qualObj.Group_1_ID_Type__c = this.group1IdTypeVal;
                qualObj.Name_Change_Document__c = this.namechangedocument;
                qualObj.Group_2a_ID_Type__c = this.Group2aIdType1;
                qualObj.Group_2b_ID_Type__c = this.Group2bIdType1;
            }

            else if (this.urlName == 'Safeguarding') {
                qualObj.Safeguarding_Date_Completed__c = this.safegDate;
            }

            else if (this.urlName == 'Emergency Contact') {
                qualObj.Relationship_to_You__c = this.Relate;
                qualObj.Emergency_Contact_Address__c = this.eConAdd;
                qualObj.Emergency_Contact_Home_Phone__c = this.eConHome;
                qualObj.Emergency_Contact_Mobile_Phone__c = this.eConMobile;
                qualObj.Emergency_Contact_Work_Phone__c = this.eConWork;
                qualObj.Emergency_Contact_Name__c = this.eContactName;
            }

            else if (this.urlName == 'DBS') {
                qualObj.DBS_Form_Number__c = this.dbNum;
                qualObj.Update_Service_Status_Check__c = this.dbsUpdateSer;

            }

            else if (this.urlName == 'Post 16 Qualifications') {
                qualObj.SET_Registration_Number__c = this.snumb;
                qualObj.Qualification_Type2__c = this.qValue;
                qualObj.SET_Expiry_Date__c = this.expirDate;
                qualObj.QTLS__c = this.QtlsCheck;
                qualObj.Qualification_Type__c = this.qualmultipick;
            }

            else if (this.urlName == 'International') {
                qualObj.Seeking_International_Position__c = this.seekIntPos;
                qualObj.Choice_of_Country__c = this.country;
            }

            else if (this.urlName == 'Early Years Qualifications') {
                qualObj.Qualification_Type2__c = this.earlyYearQFtype;
                qualObj.Qualification_Type__c = this.earlyYearQualifications;
            }

            else if (this.urlName == 'Support Qualifications') {
                qualObj.Qualification_Type2__c = this.supportQFtype;
                qualObj.Qualification_Type__c = this.supportQualifications;
            }

            else if (this.urlName == 'Barred List') {
                qualObj.Barred_Check_URL__c = this.barredcheckurl;
                qualObj.Barred_List_Results__c = this.barredListResult;
                qualObj.EWC_Registration_Checked_Date__c = this.ewscheckeddate;
                qualObj.EWC__c = this.ewsnextcheckeddate;
                qualObj.Barred_List_Date_Checked__c = this.barredlistdatecheck;
                qualObj.Barred_List_Expiry_Date_New__c = this.barredlistexpirydate;
            }

            else if (this.urlName == 'References') {
                qualObj.Reference_Sent_Date__c = this.Ref1sentdate;
                qualObj.Reference_1_Text_Name__c = this.Reference1name;
                qualObj.Reference_Received_Date__c = this.Reference1RecDate;
                qualObj.Reference_1_Contact_Details__c = this.Reference1phone;
                qualObj.Reference_1_Email__c = this.Reference1email;
                qualObj.Reference_1_Date_Range__c = this.Reference1daterangestart;
                qualObj.Reference_1_Date_Range_End__c = this.Reference1daterangeend;
                qualObj.Reference_1_Type__c = this.Ref1Type;
                qualObj.Reference_1_Received__c = this.Ref1Rec;
                qualObj.Reference_1_Rating__c = this.Ref1Rating;
                qualObj.Reference_2_Sent_Date__c = this.Ref2sentdate;
                qualObj.Reference_2_Text_Name__c = this.Reference2name;
                qualObj.Reference_2_Received_Date__c = this.Ref2recdate;
                qualObj.Reference_2_Contact_Details__c = this.Ref2phone;
                qualObj.Reference_2_Date_Rage__c = this.Ref2daterangest;
                qualObj.Reference_2_Email__c = this.Ref2email;
                qualObj.Reference_2_Date_Range_End__c = this.Ref2daterangeend;
                qualObj.Reference_2_Type__c = this.Ref2Type;
                qualObj.Reference_2_Received__c = this.Ref2rec;
                qualObj.Reference_2_Rating__c = this.Ref2Rating;
                qualObj.Reference_3_Sent_Date__c = this.Ref3sentdate;
                qualObj.Reference_3_Text_Name__c = this.Reference3Name;
                qualObj.Reference_3_Received_Date__c = this.Ref3revdate;
                qualObj.Reference_3_Contact_Details__c = this.Reference3phone;
                qualObj.Reference_3_Date_Range__c = this.Ref3daterangest;
                qualObj.Reference_3_Email__c = this.Ref3email;
                qualObj.Reference_3_Date_Range_End__c = this.Ref3dtrangeend;
                qualObj.Reference_3_Type__c = this.Ref3type;
                qualObj.Reference_3_Received__c = this.Ref3received;
                qualObj.Reference_3_Rating__c = this.Ref3rating;

            } else if (this.urlName == 'Qualifications') {
                if (this.commbinedQFtype == 'Teacher Qualification') {
                    qualObj.qualificationName__c = this.commbinedQFtype;
                    qualObj.NCTL_Number__c = this.tranum;
                    qualObj.Qualification_Type2__c = this.teacherQftype;
                    qualObj.Qualification_Type__c = this.teacherDualVal;
                } else if (this.commbinedQFtype == 'Early Years Qualifications') {
                    qualObj.qualificationName__c = this.commbinedQFtype;
                    qualObj.Qualification_Type2__c = this.earlyYearQFtype;
                    qualObj.Qualification_Type__c = this.earlyYearQualifications;
                } else if (this.commbinedQFtype == 'Support Qualifications') {
                    qualObj.qualificationName__c = this.commbinedQFtype;
                    qualObj.Qualification_Type2__c = this.supportQFtype;
                    qualObj.Qualification_Type__c = this.supportQualifications;

                } else if (this.commbinedQFtype == 'Post 16 Qualifications') {
                    qualObj.qualificationName__c = this.commbinedQFtype;
                    qualObj.SET_Registration_Number__c = this.snumb;
                    qualObj.Qualification_Type2__c = this.qValue;
                    qualObj.SET_Expiry_Date__c = this.expirDate;
                    qualObj.QTLS__c = this.QtlsCheck;
                    qualObj.Qualification_Type__c = this.qualmultipick;

                } else if (this.commbinedQFtype.slice(0, 23) == 'Overseas Qualifications') {
                    qualObj.qualificationName__c = 'Overseas Teacher Qualifications';
                    qualObj.NCTL_Number__c = this.otstranum;
                    qualObj.NARIC_Approved__c = this.naricApprove;
                    qualObj.Qualification_Type2__c = this.OTQQFtypeval;
                    qualObj.Qualification_Type__c = this.OTQteacherQualification;
                }
            }

            var urlNameParam = this.urlName;
            if (urlNameParam == 'Qualifications') {
                urlNameParam = this.commbinedQFtype;
                if (this.commbinedQFtype.slice(0, 23) == 'Overseas Qualifications') {
                    urlNameParam = 'Overseas Teacher Qualifications';
                }
            }

            if (this.urlName == 'Qualifications') {
                if (this.commbinedQualStatus != 'Submitted') {
                    editQuali({
                        conId: this.contactId,
                        qfname: urlNameParam,
                        qual: qualObj
                    })
                        .then(result => {
                            this.getAlldata();
                            this.isSpinner = false;
                            this.isResult = true;
                            this.template.querySelector('c-ts_-tost-notification').showToast('success', 'Proof Added Successfully', 3000);
                        })
                        .catch(error => {
                            this.template.querySelector('c-ts_-tost-notification').showToast('error', 'Something Went Wrong', 3000);
                        })
                } else {
                    this.isSpinner = false;
                    this.template.querySelector('c-ts_-tost-notification').showToast('error', 'You can not edit Submitted Qualifaction.', 3000);
                }
            } else {
                editQuali({
                    conId: this.contactId,
                    qfname: urlNameParam,
                    qual: qualObj
                })
                    .then(result => {
                        this.isSpinner = false;
                        this.isResult = true;
                        this.template.querySelector('c-ts_-tost-notification').showToast('success', 'Proof Added Successfully', 3000);
                    })
                    .catch(error => {
                        this.template.querySelector('c-ts_-tost-notification').showToast('error', 'Something Went Wrong', 3000);
                    })
            }
        } catch (error) {
            this.reloadpage = true;
            this.template.querySelectorAll('c-ts_-error-component')[0].openModal();
        }

    }

    get options() {
        return [
            { label: 'Early Year Qualification', value: 'Early Year Qualification' },
            { label: 'Testing', value: 'Testing' }
        ];
    }

    renderedCallback() {
        Promise.all([
            loadStyle(this, Qualificationcss)
            ]).then(() => {
            })
            .catch(error => {
            });

        Promise.all([
            loadStyle(this, commstyle)
            ]).then(() => {
            })
            .catch(error => {
                this.reloadpage = true;
                this.template.querySelectorAll('c-ts_-error-component')[0].openModal();
            });
    }

    previewHandler(event) {
        this[NavigationMixin.Navigate]({
            type: 'standard__namedPage',
            attributes: {
                pageName: 'filePreview'
            },
            state: {
                selectedRecordId: event.target.dataset.id
            }
        })
    }
}