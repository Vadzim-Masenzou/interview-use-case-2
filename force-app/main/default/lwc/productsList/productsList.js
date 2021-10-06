import { LightningElement, api, wire } from 'lwc';
import getAvailableProducts from '@salesforce/apex/ProductsController.getAvailableProducts';
import { publish, MessageContext } from 'lightning/messageService';
import PRODUCT_SELECTED_CHANNEL from '@salesforce/messageChannel/Product_Selected__c';
import { getRecord, getFieldValue } from 'lightning/uiRecordApi';

import STATUS_FIELD from '@salesforce/schema/Order.Status';

const fields = [STATUS_FIELD];

export default class ProductsList extends LightningElement {

    @api
    recordId;

    productsExist = true;
    infoMessage = '';
    addProductInterval = 100;
    addProductTimer;

    products = [];

    rowLimit = 100;
    offset = 0;
    allProductsLoaded = false;

    isLoaded = false;

    @wire(getRecord, { recordId: '$recordId', fields })
    order;

    get isOrderActivated() {
        return getFieldValue(this.order.data, STATUS_FIELD) == 'Activated' ? true : false;
    }

    get addBtnOpacity() {
        return getFieldValue(this.order.data, STATUS_FIELD) == 'Activated' ? 'opacity: 0.5' : 'opacity: 1'
    }

    //method for retrieving all available products for an order
    @wire(getAvailableProducts, {recordId: '$recordId', offset: '$offset', rowLimit: '$rowLimit'})
    getProducts({ data, error }) {
        if(data){
            let loadedProducts = JSON.parse(data);
            this.products = this.products.concat(loadedProducts);
            this.allProductsLoaded = loadedProducts.length > 0 ? false : true;
            this.isLoaded = true;
        } else if(error){
            this.productsExist = false;
            this.infoMessage = error.body.message;
            this.isLoaded = true;
        }
    }

    @wire(MessageContext)
    messageContext;

    handleAddProduct(event){
        let pbEntryId = event.currentTarget.dataset.targetId;
        clearTimeout(this.addProductTimer);
        this.addProductTimer = setTimeout(() => {
            this.addProductToOrder(pbEntryId);
        }, this.addProductInterval);
        
    }

    //method which sends selected product info to LMS messaging channel
    addProductToOrder(pbEntryId){
        let selectedProduct = this.products.find(prod => prod.Id == pbEntryId);
        const payload = { 
            productEntryId: selectedProduct.Id,
            productId: selectedProduct.Product2.Id,
            productPrice: selectedProduct.UnitPrice,
            productName: selectedProduct.Product2.Name
        };
        publish(this.messageContext, PRODUCT_SELECTED_CHANNEL, payload);
    }

    //lazy-loading of remaining products
    loadMoreProducts(){
        this.isLoaded = false;
        clearTimeout(this.addProductTimer);
        this.addProductTimer = setTimeout(() => {
            this.offset+= this.rowLimit;
        }, this.addProductInterval);
    }

    //scroll event methods which calculating scroll offset in order to start lazy loading correctly
    onscrollHandle(e){
        if((this.getScrollHeight() - this.getScrollTop()) <= this.getScrollOuterHeight()){
            if(!this.allProductsLoaded){
                this.loadMoreProducts();
            }
        }
    }

    getScrollTop() {
        const element = this.template.querySelector('.custom-table');
        return element.scrollTop;
    }

    getScrollHeight() {
        const element = this.template.querySelector('.custom-table');
        return element.scrollHeight;
    }

    getScrollOuterHeight() {
        const element = this.template.querySelector('.custom-table');
        return element.offsetHeight;
    }
}