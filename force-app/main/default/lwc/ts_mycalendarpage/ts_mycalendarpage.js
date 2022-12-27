import { LightningElement } from 'lwc';
import getContactId from '@salesforce/apex/ts_mycalendar.getContactId';
export default class Ts_mycalendarpage extends LightningElement {

    connectedCallback(){
        this.callmainmethod();
    }

    // callCommunitypage(){
    //     this.dispatchEvent(
    //   new CustomEvent('pass', {
    //     detail: true,
    //   })
    // );
    // }
    
    callmainmethod(){

        getContactId({})
        .then((result)=>{
            console.log({result});
            // let variable = result[0].Id;

            // console.log(variable);
        })
    }

}