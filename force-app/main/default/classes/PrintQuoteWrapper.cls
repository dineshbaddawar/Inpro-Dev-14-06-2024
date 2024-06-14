public class PrintQuoteWrapper {
    
    public Quote Quote;
    public Opportunity Opportunity;
    public List<Alternate__c> Alternates;
    public List<Contact> Contacts;
    public List<TaxExemptCertificateWrapper> TaxCertificates = new List<TaxExemptCertificateWrapper>();
    public List<Qualification__c> Qualifications;
    public List<QuoteLineItem> QuoteItems;
    public List<PicklistEntry> PaymentTerms;
    public string ContactEmail;
    public string IsPotentialCAD;

    public PrintQuoteWrapper()
    {
        Alternates = new List<Alternate__c>();
        Contacts = new List<Contact>();
        TaxCertificates = new List<TaxExemptCertificateWrapper>();
        Qualifications = new List<Qualification__c>();
        QuoteItems = new List<QuoteLineItem>();
        PaymentTerms = new List<PicklistEntry>();
    }

    public PrintQuoteWrapper(Quote q, 
                            Opportunity o,  
                            List<Alternate__c> alts,
                            List<Contact> contacts,
                            List<Tax_Exempt_Certificate__c> tCerts,
                            List<Qualification__c> quals, 
                            List<QuoteLineItem> qlis,
                            List<PicklistEntry> entries,
                            string contactEmail,
                            string isCad) 
    {
        this.Quote = q;
        this.Opportunity = o;
        this.Alternates = alts;
        this.Contacts = contacts;
        this.ContactEmail = contactEmail;
        this.IsPotentialCAD = isCad;

        for(Tax_Exempt_Certificate__c tec : tCerts)
        {
            TaxCertificates.add(
                new TaxExemptCertificateWrapper(
                    String.valueOf(tec.Id), 
                    tec.Certificate_Type__c,
                    tec.Effective_Date__c != null ? tec.Effective_Date__c.format() : '', 
                    tec.Expiration_Date__c != null ? tec.Expiration_Date__c.format() : '', 
                    tec.Note_Subject__c,
                    tec.Tax_Exempt__c, 
                    tec.Account__r.Name, 
                    String.valueOf(tec.Account__c), 
                    tec.States_Where_Valid__c,
                    tec.Tax_Reciprocity__c != null ? tec.Tax_Reciprocity__r.Name : ''
                )
            );
        }
        this.Qualifications = quals;
        this.QuoteItems = qlis;
        this.PaymentTerms = entries;
    }
}