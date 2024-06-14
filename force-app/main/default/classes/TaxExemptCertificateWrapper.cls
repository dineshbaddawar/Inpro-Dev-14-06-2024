public class TaxExemptCertificateWrapper{
    public string Id;
    public string CertificateType;
    public string EffectiveDate;
    public string ExpirationDate;
    public string NoteSubject;
    public string Name;
    public string AccountName;
    public string AccountId;
    public string StatesWhereValid;
    public string StateOfIssue;

    public TaxExemptCertificateWrapper(string id, string cert, string effDate, 
        string expDate, string note, string taxExempt, string accName, string accId, string states, string issuedState) {
            this.Id = id;
            this.CertificateType = cert;
            this.EffectiveDate = effDate;
            this.ExpirationDate = expDate;
            this.NoteSubject = note;
            this.Name = taxExempt;
            this.AccountId = accId;
            this.AccountName = accName;
            this.StatesWhereValid = states;
            this.StateOfIssue = issuedState;
    }
}