public with sharing class AccountRecordTypeWrapper {
    public AccountRecordTypeWrapper(string arcId,string boId,string comId,
        string disId,string gcId,string scId,string gpoId) 
    {
        this.ArchitectId = arcId;
        this.BuildingOwnerId = boId;
        this.CompetitorId = comId;
        this.DistributorId = disId;
        this.GCId = gcId;
        this.SCId = scId;
        this.GPOId = gpoId;
    }

    public string ArchitectId;
    public string BuildingOwnerId;
    public string CompetitorId;
    public string DistributorId;
    public string GCId;
    public string SCId;
    public string GPOId;
}