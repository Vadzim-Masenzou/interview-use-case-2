/**
 * @File Name          : OrderDAO
 * @Description        : DAO Methods for Order Information
 * @Author             : Vadim Masenzov	
 * @Last Modified By   : Vadim Masenzov	
 * @Modification Log   : 
 * Ver         Date            Author      		    Modification
 * 1.0    	 05/10/2021     Vadim Masenzov	       Vadim Masenzov
 **/

public without sharing class OrderDAO {

    public static String getOrderPricebookId(String orderId){
        List<Order> ordersList = [SELECT    Id, 
                                            Pricebook2Id 
                                  FROM      Order 
                                  WHERE     Id =: orderId
        ];
        return (!ordersList.isEmpty() && ordersList[0].Pricebook2Id!= null) ? ordersList[0].Pricebook2Id : null;
    }
}
