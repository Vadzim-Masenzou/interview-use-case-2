@isTest
public class ProductsControllerTest {

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
    }

    @isTest
    static void getAvailableProductsTest(){
        List<Order> orders = [SELECT Id, Status FROM Order];
        String prods = ProductsController.getAvailableProducts(orders[0].Id, 0, 10);
        List<PricebookEntry> oItems = (List<PricebookEntry>)JSON.deserialize(prods, List<PricebookEntry>.class);
        System.assert(oItems.size() > 0);
    }

    @isTest
    static void getInactiveProductsTest(){
        List<Order> orders = [SELECT Id, Status FROM Order];
        List<PriceBookEntry> pbEntries = [SELECT Id, IsActive FROM PricebookEntry];
        for(PricebookEntry pbEntry: pbEntries){
            pbEntry.IsActive = false;
        }
        update pbEntries;
        try{
            String prods = ProductsController.getAvailableProducts(orders[0].Id, 0, 10);
        } catch(Exception e){
            System.assertEquals('No active products available', e.getMessage());
        }
    
    }

    @isTest
    static void getProductsWithoutOrderPbTest(){
        List<Order> orders = [SELECT Id, Status, Pricebook2Id FROM Order];
        orders[0].Pricebook2Id = null;
        update orders;
        try{
            String prods = ProductsController.getAvailableProducts(orders[0].Id, 0, 10);
        } catch(Exception e){
            System.assertEquals('There is no Price Book assigned to this Order', e.getMessage());
        }
    
    }
}
