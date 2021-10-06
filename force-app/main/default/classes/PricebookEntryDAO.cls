/**
 * @File Name          : PricebookEntryDAO
 * @Description        : DAO Methods for PricebookEntry Information
 * @Author             : Vadim Masenzov	
 * @Last Modified By   : Vadim Masenzov	
 * @Modification Log   : 
 * Ver         Date            Author      		    Modification
 * 1.0    	 05/10/2021     Vadim Masenzov	       Vadim Masenzov
 **/

public without sharing class PricebookEntryDAO {

    public static Map<Id, PricebookEntry> getPricebookEntriesByPb(String orderPbId, Integer offset, Integer rowLimit){
        Map<Id, PricebookEntry> productsMap = new Map<Id, PricebookEntry>();
        List<PricebookEntry> pbEntriesList = [SELECT    Id,
                                                        Product2Id,
                                                        Product2.Name,
                                                        UnitPrice
                                              FROM      PricebookEntry
                                              WHERE     IsActive = true
                                              AND       Pricebook2Id =: orderPbId
                                              LIMIT     :rowLimit
                                              OFFSET    :offset                   
        ];
        for(PricebookEntry pbEntry : pbEntriesList){
            if(!productsMap.containsKey(pbEntry.Product2Id)){
                productsMap.put(pbEntry.Product2Id, pbEntry);
            }
        }
        return productsMap; 
    }
}
