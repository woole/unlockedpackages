import { LightningElement, api } from 'lwc';

export default class KeyInfoCard extends LightningElement {

@api title;
@api cardinfo;
@api cardname;

@api cssname;


@api iconname = "standard:groups";



}