global with sharing class IDRFlowHelper 
{
    @invocablemethod(label='Delete Sign Images')
    public static void deleteSignImages(List<string> quoteDetailIds)
    {
        sfdata.sfDataWebServiceSoap service = new sfdata.sfDataWebServiceSoap();
        service.timeout_x = 120000;
        string quoteId = '';

        List<string> qliIds = new List<string>();
        //Get quote Id from QLI
        if (quoteDetailIds.size() > 0)
        {
            qliIds = quoteDetailIds[0].split(',');
            QuoteLineItem qli = [SELECT Id, Alternate__r.QuoteId__c FROM QuoteLineItem WHERE Id = :qliIds[0]];
            quoteId = qli.Alternate__r.QuoteId__c;
        }
        //If Quote found
        if (quoteId != '')
        {
            //Get metadata to retrieve Image Ids
            sfdata.RetrieveSavedImagesResult imageResults = service.RetrieveSavedImages(quoteId, 'dsj8U73_3nv3Dhba');
            if (imageResults.Status)
            {
                //Iterate through
                for(sfdata.SavedImage imageDTO : imageResults.SavedImages.SavedImage)
                {
                    //Find image to delete
                    if (qliIds.contains(imageDTO.QuoteDetailId))
                    {
                        sfdata.Result results = service.DeleteSavedImage(imageDTO.ImageId, 'dsj8U73_3nv3Dhba');  
                    }
                }
            }
        }
    }
}