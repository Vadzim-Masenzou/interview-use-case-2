@isTest
public class OrderProductsControllerTest {
    @testSetup
    static void init(){
        Account testAcc = new Account(
            Name = 'Test Acc'
        );
        insert testAcc;

        Contract ct = new Contract(
            AccountId = testAcc.Id,
            Status = 'Draft',
            Pricebook2Id = Test.getStandardPricebookId()
        );

        insert ct;

        List<Product2> newProducts = new List<Product2>();
        newProducts.add(new Product2(Family = 'Batteries', Name = '10 Storage Container'));  
        newProducts.add(new Product2(Family = 'Panels', Name = 'Panel'));  
        newProducts.add(new Product2(Family = 'Labour', Name = 'COGS - Solar Analytics'));  
        insert newProducts;

        List<PricebookEntry> priceBookEntry = new List<PricebookEntry>();
        for(Product2 prod : newProducts){
            priceBookEntry.add(new PriceBookEntry(
                Product2Id = prod.Id, 
                Pricebook2Id=Test.getStandardPricebookId(), 
                UnitPrice = 6, 
                IsActive = true)
            );
        }
        insert priceBookEntry;

        Order testOrder = new Order(
            Pricebook2Id = Test.getStandardPricebookId(),
            Status = 'Draft',
            AccountId = testAcc.Id,
            ContractId = ct.Id,
            EffectiveDate = Date.today()
        );

        insert testOrder;

        List<OrderItem> orderItems = new List<OrderItem>();
        orderItems.add(new OrderItem(
            Product2Id = priceBookEntry[0].Product2Id, 
            Description = 'Deliver to vendor', 
            Quantity = 1, 
            OrderId = testOrder.Id, 
            PricebookEntryId = priceBookEntry[0].Id, 
            UnitPrice = 2)
        );
        insert orderItems;
    }

    @isTest
    static void getOrderedProductsTest(){
        List<Order> orders = [SELECT Id, Status FROM Order];
        String orderItems = OrderProductsController.getOrderedProducts(orders[0].Id);
        List<OrderItem> oItems = (List<OrderItem>)JSON.deserialize(orderItems, List<OrderItem>.class);
        System.assert(oItems.size() > 0);
    }

    @isTest
    static void upsertOrderItemsTest(){
        List<Order> orders = [SELECT Id, Pricebook2Id, Status FROM Order];
        List<PricebookEntry> pbEntries = PricebookEntryDAO.getPricebookEntriesByPb(orders[0].Pricebook2Id, 0, 10).values();
        List<OrderItem> orderItems = new List<OrderItem>();
        orderItems.add(new OrderItem(
            Product2Id = pbEntries[0].Product2Id, 
            Description = 'New Order Item', 
            Quantity = 1, 
            OrderId = orders[0].Id, 
            PricebookEntryId = pbEntries[0].Id, 
            UnitPrice = 5)
        );
        insert orderItems;
        OrderProductsController.upsertOrderItems(JSON.serialize(orderItems));
        List<OrderItem> newOrderItems = [SELECT Id FROM OrderItem];
        System.assert(newOrderItems.size() == 2);

        try{
            OrderProductsController.upsertOrderItems('test');
        } catch(Exception e) {
            System.assertEquals('Error while inserting order items', e.getMessage());
        }
    }

    @isTest
    static void deleteOrderItemsTest(){
        List<OrderItem> orderItemsToDelete = [SELECT Id FROM OrderItem];
        OrderProductsController.deleteOrderItems(JSON.serialize(orderItemsToDelete));
        List<OrderItem> allOrderItems = [SELECT Id FROM OrderItem];
        System.assert(allOrderItems.size() == 0);

        try{
            OrderProductsController.deleteOrderItems('test');
        } catch(Exception e) {
            System.assertEquals('Error while deleting order items', e.getMessage());
        }
    }

    @isTest
    static void updateOrderStatusTest(){
        List<Order> orders = [SELECT Id, Status FROM Order LIMIT 1];
        List<Contract> contract = [SELECT Id, Status FROM Contract LIMIT 1];
        try{
            OrderProductsController.updateOrderStatus(orders[0].Id, null);
        } catch(Exception e){
            System.assertEquals('System.DmlException', e.getMessage());
        }
    
        contract[0].Status = 'Activated';
        update contract;

        OrderProductsController.updateOrderStatus(orders[0].Id, null);

        orders = [SELECT Id, Status FROM Order LIMIT 1];
        System.assertEquals('Activated', orders[0].Status);
    }

    @isTest
    static void confirmOrderTest(){
        Test.startTest();
            HttpMockupService mock = new HttpMockupService('OK', 200);
            Test.setMock(HttpCalloutMock.class, mock);
            String jsonBody = '{"accountNumber": "","orderNumber": "","type": "order type","status": "order status","orderProducts": [{"name": "product name","code": "product code","unitPrice": 10.00,"quantity": 1}]}';
            String response = OrderProductsController.confirmOrder(jsonBody);
            OrderProductsController.ConfirmationResponse resp = (OrderProductsController.ConfirmationResponse)JSON.deserialize(response, OrderProductsController.ConfirmationResponse.class);
            System.assert(resp.statusCode == 200);
        Test.stopTest();
    }

}
