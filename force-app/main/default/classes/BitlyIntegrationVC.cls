public class BitlyIntegrationVC {
    public String client_id  {get;set;}
    public String redirect_uri {get;set;}
    
    public void BitlyIntegration(){
        client_id  		=	LunchandLearnUtils.GetMetadataValue('Client_Id__c');
        redirect_uri 	=	LunchandLearnUtils.GetMetadataValue('Redirect_URI__c');
        String bitlycode = apexpages.currentpage().getparameters().get('code');
        system.debug('bitlycodeinVF::'+bitlycode);
        if(bitlycode!=null){
            BitlyIntegrationRest BitlyIntegration  =new BitlyIntegrationRest();
            BitlyIntegration.ReturnAccessToken(bitlycode);
            
        }
        
    }

}