/**
* Lightning conteoller class for the SelectPriceBook Component
*/
public with sharing class SelectPriceBookLTCtrl {
     /**
    * Returns active pricebooks filter by Currency.
    * EUR/GBP -> Default to UKI pricebook
    * excludedPriceBooks: Pricebook name.
    */
    //EAD-2266
   @AuraEnabled
   public static List<Pricebook2> getPricebooksCurrency(String currencyIsoCode, String excludedPriceBookNames) 
    { 
        List<Pricebook2> pb;
	    String excludes = '%' + excludedPriceBookNames + '%';
        if (currencyIsoCode.equals('EUR'))
        	{ 
               currencyIsoCode = 'GBP';
            }    
        try{           
           pb = [select id,Name,CurrencyIsoCode from Pricebook2 where IsActive = true 
                                              and CurrencyIsoCode = :currencyIsoCode 
                                    and (NOT Name like :excludes)  WITH SECURITY_ENFORCED LIMIT 1];
        }
            
        catch(Exception e){
            throw new AuraHandledException('Do not have Permission to read Pricebook '+ e.getMessage());
        }   
        return pb;
    }

    
    /**
    * Returns active pricebooks.
    */
   @AuraEnabled
   public static List<Pricebook2> getPricebooks() 
    {
        // TODO this will probably need to use the user id 
        //check for read permission as per clayton scan
        
         try{ 
            List<Pricebook2> listpb = [select id,Name,CurrencyIsoCode from Pricebook2 where IsActive = true  WITH SECURITY_ENFORCED ];
            return listpb;  
         }catch(Exception e){
            throw new AuraHandledException('Do not have Permission to read Pricebook '+ e.getMessage());
         }      
    }

}