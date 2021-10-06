import { api, LightningElement, wire } from 'lwc';

import upsertOrderItems from '@salesforce/apex/OrderProductsController.upsertOrderItems';
import deleteOrderItems from '@salesforce/apex/OrderProductsController.deleteOrderItems';
import confirmOrder from '@salesforce/apex/OrderProductsController.confirmOrder';
import updateOrderStatus from '@salesforce/apex/OrderProductsController.updateOrderStatus';


import getOrderedProducts from '@salesforce/apex/OrderProductsController.getOrderedProducts';

import { refreshApex } from '@salesforce/apex';
import { getRecord, getFieldValue } from 'lightning/uiRecordApi';
import { subscribe, MessageContext } from 'lightning/messageService';

import PRODUCT_SELECTED_CHANNEL from '@salesforce/messageChannel/Product_Selected__c';

import STATUS_FIELD from '@salesforce/schema/Order.Status';
import TYPE_FIELD from '@salesforce/schema/Order.Type';
import ORDER_NUMBER_FIELD from '@salesforce/schema/Order.OrderNumber';
import ACCOUNT_NUMBER_FIELD from '@salesforce/schema/Order.Account.AccountNumber';

const fields = [STATUS_FIELD, TYPE_FIELD, ORDER_NUMBER_FIELD, ACCOUNT_NUMBER_FIELD];

import { ShowToastEvent } from 'lightning/platformShowToastEvent';

export default class OrderProducts extends LightningElement {

    @api
    recordId;

    productEntryId;
    wiredOrderItemsList = [];

    columns = [
        { label: 'Name', fieldName: 'Name' },
        { label: 'Unit Price', fieldName: 'UnitPrice', type: 'currency' },
        { label: 'Quantity', fieldName: 'Quantity', type: 'number' },
        { label: 'Total Price', fieldName: 'TotalPrice', type: 'currency' }
    ];

    orderItemsData = [];
    selectedRows = [];

    totalPrice = 0;
    isLoaded = false;

    @wire(getRecord, { recordId: '$recordId', fields })
    order;

    @wire(MessageContext)
    messageContext;

    get isProductsLoaded(){
        return this.orderItemsData.length > 0 ? true : false;
    }

    get hasItemsToDelete(){
        return this.selectedRows.length > 0 ? true : false;
    }
    
    get orderStatus() {
        return getFieldValue(this.order.data, STATUS_FIELD);
    }

    get orderType() {
        return getFieldValue(this.order.data, TYPE_FIELD);
    }

    get orderNumber() {
        return getFieldValue(this.order.data, ORDER_NUMBER_FIELD);
    }

    get accountNumber() {
        return getFieldValue(this.order.data, ACCOUNT_NUMBER_FIELD);
    }
    
    get isOrderActivated() {
        return getFieldValue(this.order.data, STATUS_FIELD) == 'Activated' ? true : false;
    }

    connectedCallback() {
        //methods which subscribes to LMS messaging channel 
        //to recieve selected product from productsList component
        this.subscribeToMessageChannel();
    }

    //method which retrieves currently added products to the Order
    @wire(getOrderedProducts, {recordId : '$recordId'})
    getOrderedProducts(result) {
        this.wiredOrderItemsList = result;
        if(result.data){
            let orderItems = JSON.parse(result.data);
            this.orderItemsData = orderItems.map(oItem => {
                return {
                    Id: oItem.Id,
                    Name: oItem.Product2.Name,
                    UnitPrice: oItem.UnitPrice,
                    Quantity: oItem.Quantity,
                    TotalPrice: oItem.TotalPrice,
                    PricebookEntryId: oItem.PricebookEntryId,
                    OrderId: oItem.OrderId,
                    ProductCode: oItem.Product2.ProductCode,
                    Status: oItem.Status
                }
            });
            this.recalculateTotal();
            this.isLoaded = true;
        } else if(result.error){
        }
    }

    subscribeToMessageChannel() {
        this.subscription = subscribe(
            this.messageContext,
            PRODUCT_SELECTED_CHANNEL,
            (message) => this.handleMessage(message)
        );
    }

    handleMessage(message) {
        this.isLoaded = false;
        this.updateOrderItems(message);
    }

    updateOrderItems(message){
        this.allocateOrderItem(message);
        upsertOrderItems({orderItems : JSON.stringify(this.orderItemsData)})
            .then(() =>{
                return refreshApex(this.wiredOrderItemsList);
            }).catch(e => {
                console.error(e);
            })
    }

    onHandleSubmit(){
        this.isLoaded = false;
        let orderData = this.prepareConfirmationOrder();
        confirmOrder({requestData: JSON.stringify(orderData)})
            .then(resp => new Promise((resolve, reject) => {
                let confResp = JSON.parse(resp);
                return confResp.statusCode == 200 ? resolve(this.updateOrderStatus()) : reject(new Error('Unable to confirm an order'));
            })).then(() => {
                this.showInfoMessage('Success', 'Order has been succesfully confirmed', 'success');
                this.isLoaded = true;
                return refreshApex(this.order);
            }).catch(e => {
                this.showInfoMessage('Error', e.body.message, 'error');
                this.isLoaded = true;
            })
    }

    prepareConfirmationOrder(){
        let orderData = {
            accountNumber: this.accountNumber ? this.accountNumber : '',
            orderNumber: this.orderNumber ? this.orderNumber : '',
            type: this.orderType ? this.orderType : '',
            status: this.orderStatus ? this.orderStatus : ''
        };

        let orderProducts = this.orderItemsData.map(oItem => {
            return {
                name: oItem.Name ? oItem.Name : '',
                code: oItem.ProductCode ? oItem.ProductCode : '',
                unitPrice:  oItem.UnitPrice.toFixed(2),
                quantity: oItem.Quantity
            }
        })
        orderData.orderProducts = orderProducts;
        return orderData;
    }

    updateOrderStatus(){
        return updateOrderStatus({orderId: this.recordId, orderItems: JSON.stringify(this.orderItemsData)})
    }

    onHandleDelete(){
        this.isLoaded = false;
        deleteOrderItems({orderItems : JSON.stringify(this.selectedRows)})
            .then(() => {
                this.selectedRows = [];
                return refreshApex(this.wiredOrderItemsList);
            }).catch(e => {
                console.error(e);
            })
    }

    //method which identifies if selected product already exist on the Order
    //increases quantity if product exist or adds new
    allocateOrderItem(message){
        let existingOrderItem = this.orderItemsData.find(oItem => oItem.PricebookEntryId == message.productEntryId);
        if(existingOrderItem){
            this.orderItemsData = this.orderItemsData.map(oItem => {
                if(oItem.PricebookEntryId == message.productEntryId){
                    oItem.Quantity+= 1;
                    oItem.TotalPrice+= oItem.UnitPrice;
                }
                return oItem;
            });
        } else {
            let orderItem = {
                PricebookEntryId: message.productEntryId,
                Product2Id: message.productId,
                UnitPrice: message.productPrice,
                Quantity: 1,
                TotalPrice: message.productPrice,
                OrderId: this.recordId
            }
            this.orderItemsData.push(orderItem);
        }
    }

    handleSelectedRows(event){
        this.selectedRows = event.detail.selectedRows;
    }

    recalculateTotal(){
        this.totalPrice = this.orderItemsData.reduce((sum, item) => {
            return sum + item.TotalPrice;
        }, 0);
    }

    onscrollHandle(e){
        if((this.getScrollHeight() - this.getScrollTop()) < this.getScrollOuterHeight()){
            console.log('load more data...');
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

    showInfoMessage(title, message, variant){
        const evt = new ShowToastEvent({
            title: title,
            message: message,
            variant: variant,
        });
        this.dispatchEvent(evt);
    }
}