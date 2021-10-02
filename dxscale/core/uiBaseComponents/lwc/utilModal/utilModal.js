import { LightningElement, api } from 'lwc';

export default class UtilModal extends LightningElement {
    @api showActionButton;
    @api showCancelButton;
    @api actionButtonLabel = 'Save';
    @api cancelButtonLabel = 'Cancel';
    @api showModal;

    @api styleWidthHeight="min-width: 900px;";
   //  @api styleWidthHeight;
   

    constructor() {
        super();
        this.showCancelButton = false;
        this.showActionButton = false;
        this.showModal = false;
    }

    handleAction() {
        this.dispatchEvent(new CustomEvent('action'));
    }

    handleCancel() {
        this.showModal = false;
        this.dispatchEvent(new CustomEvent('cancel'));
    }

    handleClose() {
        this.showModal = false;
        this.dispatchEvent(new CustomEvent('close'));
    }

    hideModalBox() {
        this.isShowModal = false;
    }
}