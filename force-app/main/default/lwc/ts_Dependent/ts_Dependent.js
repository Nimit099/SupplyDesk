import { LightningElement,wire,track } from 'lwc';
import {getObjectInfo} from 'lightning/uiObjectInfoApi';
import QUAL_OBJECT from '@salesforce/schema/TR1__Associated_Qualification__c';
import {getPicklistValues} from 'lightning/uiObjectInfoApi';
import SLA_FIELD from '@salesforce/schema/TR1__Associated_Qualification__c.Qualification_Type2__c';
import UPSELL_FIELD from '@salesforce/schema/TR1__Associated_Qualification__c.Qualification_Type__c';
 
export default class Ts_Dependent extends LightningElement {

    @wire(getObjectInfo, {objectApiName: QUAL_OBJECT })
    accountInfo;

    @track slaOptions;
    @track upsellOptions;

    @track group2aIdType = '';

    @wire(getPicklistValues, {recordTypeId: '$accountInfo.data.defaultRecordTypeId', fieldApiName: UPSELL_FIELD })
    slaFieldInfo({ data, error }) {
        if (data) this.slaFieldData = data;
        
        // this.slaOptions = this.slaFieldData.values;
    }
    @wire(getPicklistValues, {recordTypeId:'$accountInfo.data.defaultRecordTypeId', fieldApiName: SLA_FIELD })
    upsellFieldInfo({ data, error }) {
        if (data) this.upsellOptions = data.values;
    }

    handleUpsellChange(event) {
        let key = this.slaFieldData.controllerValues[event.target.value];
        console.log({key});
        this.slaOptions = this.slaFieldData.values.filter(opt => opt.validFor.includes(key));
    }

    // handleChange(event){
    //     console.log({event});
    //     const docslst = Object.assign({}, event.detail.value);
    //     console.log('docslst>>',docslst);
    //     for(var k in docslst){
    //         this.group2aIdType += docslst[parseInt(k)]+';';
    //     } 
    //     console.log('this.group2aIdType>>>',this.group2aIdType);
    // }
}