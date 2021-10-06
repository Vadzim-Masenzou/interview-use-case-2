/**
 * @File Name          : OrderItemDAO
 * @Description        : DAO Methods for OrderItem Information
 * @Author             : Vadim Masenzov	
 * @Last Modified By   : Vadim Masenzov	
 * @Modification Log   : 
 * Ver         Date            Author      		    Modification
 * 1.0    	 05/10/2021     Vadim Masenzov	       Vadim Masenzov
 **/

public without sharing class OrderItemDAO {
    
    public static List<OrderItem> getOrderItemsByOrderId(String recordId){
        return [SELECT    Id,
                          Product2Id,
                          PricebookEntryId,
                          Product2.Name,
                          Product2.ProductCode,
                          ListPrice,
                          UnitPrice,
                          TotalPrice,
                          Quantity,
                          OrderId,
                          LastModifiedDate
                FROM      OrderItem
                WHERE     OrderId =: recordId
                ORDER BY  CreatedDate
                DESC
        ];
    }
}
