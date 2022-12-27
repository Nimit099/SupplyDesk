import { LightningElement } from 'lwc';
import SDlogoErrorPage from '@salesforce/resourceUrl/SDlogoErrorPage';

export default class Ts_ErrorPage extends LightningElement {

    sderrorpage = SDlogoErrorPage;

    connectedCallback() {

        var meta = document.createElement("meta");
        meta.setAttribute("name", "viewport");
        meta.setAttribute("content", "width=device-width, initial-scale=1.0");
        document.getElementsByTagName('head')[0].appendChild(meta);


        setTimeout(() => {

            var path2 = this.template.querySelectorAll('.cube');
            var four = this.template.querySelectorAll('.four');

            four.forEach(element => {
                element.classList.add('color_anim');
            });

            path2.forEach(element => {
                element.classList.add('color_anim');
            });

            var svg = this.template.querySelector('.svg-a');
            svg.classList.add('hang');
        }, 500);

    }
}