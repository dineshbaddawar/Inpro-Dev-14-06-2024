public class EDISvc {
    public class RunVentasResponse_element {
        public String RunVentasResult;
        private String[] RunVentasResult_type_info = new String[]{'RunVentasResult','http://www.inprocorp.com/EDI/ServiceLayer',null,'0','1','false'};
        private String[] apex_schema_type_info = new String[]{'http://www.inprocorp.com/EDI/ServiceLayer','true','false'};
        private String[] field_order_type_info = new String[]{'RunVentasResult'};
    }
    public class RetrieveGraingerMacolaParts_element {
        public String EDIHeaderID;
        public String StatusDetailID;
        private String[] EDIHeaderID_type_info = new String[]{'EDIHeaderID','http://www.inprocorp.com/EDI/ServiceLayer',null,'0','1','false'};
        private String[] StatusDetailID_type_info = new String[]{'StatusDetailID','http://www.inprocorp.com/EDI/ServiceLayer',null,'0','1','false'};
        private String[] apex_schema_type_info = new String[]{'http://www.inprocorp.com/EDI/ServiceLayer','true','false'};
        private String[] field_order_type_info = new String[]{'EDIHeaderID','StatusDetailID'};
    }    
    public class ProcessEggersPOResponse_element {
        public EDISvc.EDIJobStatus ProcessEggersPOResult;
        private String[] ProcessEggersPOResult_type_info = new String[]{'ProcessEggersPOResult','http://www.inprocorp.com/EDI/ServiceLayer',null,'0','1','false'};
        private String[] apex_schema_type_info = new String[]{'http://www.inprocorp.com/EDI/ServiceLayer','true','false'};
        private String[] field_order_type_info = new String[]{'ProcessEggersPOResult'};
    }
    public class CancelPO_element {
        public String EDIHeaderID;
        private String[] EDIHeaderID_type_info = new String[]{'EDIHeaderID','http://www.inprocorp.com/EDI/ServiceLayer',null,'0','1','false'};
        private String[] apex_schema_type_info = new String[]{'http://www.inprocorp.com/EDI/ServiceLayer','true','false'};
        private String[] field_order_type_info = new String[]{'EDIHeaderID'};
    }
    public class CheckOrdersInvoicedResponse_element {
        public EDISvc.EDIJobStatus CheckOrdersInvoicedResult;
        private String[] CheckOrdersInvoicedResult_type_info = new String[]{'CheckOrdersInvoicedResult','http://www.inprocorp.com/EDI/ServiceLayer',null,'0','1','false'};
        private String[] apex_schema_type_info = new String[]{'http://www.inprocorp.com/EDI/ServiceLayer','true','false'};
        private String[] field_order_type_info = new String[]{'CheckOrdersInvoicedResult'};
    }
    public class NotifyUsersNewPOPendingApproval_element {
        public String EDIHeaderID;
        private String[] EDIHeaderID_type_info = new String[]{'EDIHeaderID','http://www.inprocorp.com/EDI/ServiceLayer',null,'0','1','false'};
        private String[] apex_schema_type_info = new String[]{'http://www.inprocorp.com/EDI/ServiceLayer','true','false'};
        private String[] field_order_type_info = new String[]{'EDIHeaderID'};
    }
    public class PriceCheck_element {
        public String ItemNumber;
        public String AccountNumber;
        private String[] ItemNumber_type_info = new String[]{'ItemNumber','http://www.inprocorp.com/EDI/ServiceLayer',null,'0','1','false'};
        private String[] AccountNumber_type_info = new String[]{'AccountNumber','http://www.inprocorp.com/EDI/ServiceLayer',null,'0','1','false'};
        private String[] apex_schema_type_info = new String[]{'http://www.inprocorp.com/EDI/ServiceLayer','true','false'};
        private String[] field_order_type_info = new String[]{'ItemNumber','AccountNumber'};
    }
    public class ProcessPOOrderResponse_element {
        public EDISvc.EDIJobStatus ProcessPOOrderResult;
        private String[] ProcessPOOrderResult_type_info = new String[]{'ProcessPOOrderResult','http://www.inprocorp.com/EDI/ServiceLayer',null,'0','1','false'};
        private String[] apex_schema_type_info = new String[]{'http://www.inprocorp.com/EDI/ServiceLayer','true','false'};
        private String[] field_order_type_info = new String[]{'ProcessPOOrderResult'};
    }
    public class ProcessJJShippingAcknowledgementResponse_element {
        public EDISvc.EDIJobStatus ProcessJJShippingAcknowledgementResult;
        private String[] ProcessJJShippingAcknowledgementResult_type_info = new String[]{'ProcessJJShippingAcknowledgementResult','http://www.inprocorp.com/EDI/ServiceLayer',null,'0','1','false'};
        private String[] apex_schema_type_info = new String[]{'http://www.inprocorp.com/EDI/ServiceLayer','true','false'};
        private String[] field_order_type_info = new String[]{'ProcessJJShippingAcknowledgementResult'};
    }
    public class NotifyUsersManualInvoiceActionRequired_element {
        public String StatusID;
        public String EDIHeaderID;
        private String[] StatusID_type_info = new String[]{'StatusID','http://www.inprocorp.com/EDI/ServiceLayer',null,'0','1','false'};
        private String[] EDIHeaderID_type_info = new String[]{'EDIHeaderID','http://www.inprocorp.com/EDI/ServiceLayer',null,'0','1','false'};
        private String[] apex_schema_type_info = new String[]{'http://www.inprocorp.com/EDI/ServiceLayer','true','false'};
        private String[] field_order_type_info = new String[]{'StatusID','EDIHeaderID'};
    }    
    public class PriceCheckResponse_element {
        public Decimal PriceCheckResult;
        private String[] PriceCheckResult_type_info = new String[]{'PriceCheckResult','http://www.inprocorp.com/EDI/ServiceLayer',null,'1','1','false'};
        private String[] apex_schema_type_info = new String[]{'http://www.inprocorp.com/EDI/ServiceLayer','true','false'};
        private String[] field_order_type_info = new String[]{'PriceCheckResult'};
    }
    public class AcknowledgeCO_element {
        public String EDIHeaderID;
        private String[] EDIHeaderID_type_info = new String[]{'EDIHeaderID','http://www.inprocorp.com/EDI/ServiceLayer',null,'0','1','false'};
        private String[] apex_schema_type_info = new String[]{'http://www.inprocorp.com/EDI/ServiceLayer','true','false'};
        private String[] field_order_type_info = new String[]{'EDIHeaderID'};
    }
    public class AcknowledgeGraingerPOResponse_element {
        public EDISvc.EDIJobStatus AcknowledgeGraingerPOResult;
        private String[] AcknowledgeGraingerPOResult_type_info = new String[]{'AcknowledgeGraingerPOResult','http://www.inprocorp.com/EDI/ServiceLayer',null,'0','1','false'};
        private String[] apex_schema_type_info = new String[]{'http://www.inprocorp.com/EDI/ServiceLayer','true','false'};
        private String[] field_order_type_info = new String[]{'AcknowledgeGraingerPOResult'};
    }
    public class CreateEDIPOResponse_element {
        public EDISvc.EDIJobStatus CreateEDIPOResult;
        private String[] CreateEDIPOResult_type_info = new String[]{'CreateEDIPOResult','http://www.inprocorp.com/EDI/ServiceLayer',null,'0','1','false'};
        private String[] apex_schema_type_info = new String[]{'http://www.inprocorp.com/EDI/ServiceLayer','true','false'};
        private String[] field_order_type_info = new String[]{'CreateEDIPOResult'};
    }
    public class UploadEDIFiles_element {
        public String EDIHeaderID;
        public String DocumentType;
        private String[] EDIHeaderID_type_info = new String[]{'EDIHeaderID','http://www.inprocorp.com/EDI/ServiceLayer',null,'0','1','false'};
        private String[] DocumentType_type_info = new String[]{'DocumentType','http://www.inprocorp.com/EDI/ServiceLayer',null,'0','1','false'};
        private String[] apex_schema_type_info = new String[]{'http://www.inprocorp.com/EDI/ServiceLayer','true','false'};
        private String[] field_order_type_info = new String[]{'EDIHeaderID','DocumentType'};
    }
    public class DenyPOResponse_element {
        public EDISvc.EDIJobStatus DenyPOResult;
        private String[] DenyPOResult_type_info = new String[]{'DenyPOResult','http://www.inprocorp.com/EDI/ServiceLayer',null,'0','1','false'};
        private String[] apex_schema_type_info = new String[]{'http://www.inprocorp.com/EDI/ServiceLayer','true','false'};
        private String[] field_order_type_info = new String[]{'DenyPOResult'};
    }
    public class RunVentas_element {
        public String invNo;
        public String ediDocumentId;
        public String token;
        private String[] invNo_type_info = new String[]{'invNo','http://www.inprocorp.com/EDI/ServiceLayer',null,'0','1','false'};
        private String[] ediDocumentId_type_info = new String[]{'ediDocumentId','http://www.inprocorp.com/EDI/ServiceLayer',null,'0','1','false'};
        private String[] token_type_info = new String[]{'token','http://www.inprocorp.com/EDI/ServiceLayer',null,'0','1','false'};
        private String[] apex_schema_type_info = new String[]{'http://www.inprocorp.com/EDI/ServiceLayer','true','false'};
        private String[] field_order_type_info = new String[]{'invNo','ediDocumentId','token'};
    }
    public class NotifyUsersNewPOPendingApprovalResponse_element {
        public EDISvc.EDIJobStatus NotifyUsersNewPOPendingApprovalResult;
        private String[] NotifyUsersNewPOPendingApprovalResult_type_info = new String[]{'NotifyUsersNewPOPendingApprovalResult','http://www.inprocorp.com/EDI/ServiceLayer',null,'0','1','false'};
        private String[] apex_schema_type_info = new String[]{'http://www.inprocorp.com/EDI/ServiceLayer','true','false'};
        private String[] field_order_type_info = new String[]{'NotifyUsersNewPOPendingApprovalResult'};
    }
    public class CreateEDIPO_element {
        public String VendorID;
        public String SalesOrder;
        public String PurchaseOrder;
        private String[] VendorID_type_info = new String[]{'VendorID','http://www.inprocorp.com/EDI/ServiceLayer',null,'0','1','false'};
        private String[] SalesOrder_type_info = new String[]{'SalesOrder','http://www.inprocorp.com/EDI/ServiceLayer',null,'0','1','false'};
        private String[] PurchaseOrder_type_info = new String[]{'PurchaseOrder','http://www.inprocorp.com/EDI/ServiceLayer',null,'0','1','false'};
        private String[] apex_schema_type_info = new String[]{'http://www.inprocorp.com/EDI/ServiceLayer','true','false'};
        private String[] field_order_type_info = new String[]{'VendorID','SalesOrder','PurchaseOrder'};
    }
    public class ProcessJJPendingOrdersResponse_element {
        public EDISvc.EDIJobStatus ProcessJJPendingOrdersResult;
        private String[] ProcessJJPendingOrdersResult_type_info = new String[]{'ProcessJJPendingOrdersResult','http://www.inprocorp.com/EDI/ServiceLayer',null,'0','1','false'};
        private String[] apex_schema_type_info = new String[]{'http://www.inprocorp.com/EDI/ServiceLayer','true','false'};
        private String[] field_order_type_info = new String[]{'ProcessJJPendingOrdersResult'};
    }
    public class CancelPOResponse_element {
        public EDISvc.EDIJobStatus CancelPOResult;
        private String[] CancelPOResult_type_info = new String[]{'CancelPOResult','http://www.inprocorp.com/EDI/ServiceLayer',null,'0','1','false'};
        private String[] apex_schema_type_info = new String[]{'http://www.inprocorp.com/EDI/ServiceLayer','true','false'};
        private String[] field_order_type_info = new String[]{'CancelPOResult'};
    }
    public class ProcessJJShippingAcknowledgement_element {
        public String EDIHeaderID;
        private String[] EDIHeaderID_type_info = new String[]{'EDIHeaderID','http://www.inprocorp.com/EDI/ServiceLayer',null,'0','1','false'};
        private String[] apex_schema_type_info = new String[]{'http://www.inprocorp.com/EDI/ServiceLayer','true','false'};
        private String[] field_order_type_info = new String[]{'EDIHeaderID'};
    }
    public class ProcessCOResponse_element {
        public EDISvc.EDIJobStatus ProcessCOResult;
        private String[] ProcessCOResult_type_info = new String[]{'ProcessCOResult','http://www.inprocorp.com/EDI/ServiceLayer',null,'0','1','false'};
        private String[] apex_schema_type_info = new String[]{'http://www.inprocorp.com/EDI/ServiceLayer','true','false'};
        private String[] field_order_type_info = new String[]{'ProcessCOResult'};
    }
    public class DownloadEDIFiles_element {
        public String VendorName;
        private String[] VendorName_type_info = new String[]{'VendorName','http://www.inprocorp.com/EDI/ServiceLayer',null,'0','1','false'};
        private String[] apex_schema_type_info = new String[]{'http://www.inprocorp.com/EDI/ServiceLayer','true','false'};
        private String[] field_order_type_info = new String[]{'VendorName'};
    }
    public class AcknowledgeGraingerPO_element {
        public String EDIHeaderID;
        private String[] EDIHeaderID_type_info = new String[]{'EDIHeaderID','http://www.inprocorp.com/EDI/ServiceLayer',null,'0','1','false'};
        private String[] apex_schema_type_info = new String[]{'http://www.inprocorp.com/EDI/ServiceLayer','true','false'};
        private String[] field_order_type_info = new String[]{'EDIHeaderID'};
    }
    public class ProcessGraingerInvoiceResponse_element {
        public EDISvc.EDIJobStatus ProcessGraingerInvoiceResult;
        private String[] ProcessGraingerInvoiceResult_type_info = new String[]{'ProcessGraingerInvoiceResult','http://www.inprocorp.com/EDI/ServiceLayer',null,'0','1','false'};
        private String[] apex_schema_type_info = new String[]{'http://www.inprocorp.com/EDI/ServiceLayer','true','false'};
        private String[] field_order_type_info = new String[]{'ProcessGraingerInvoiceResult'};
    }
    public class UploadEDIFilesResponse_element {
        public EDISvc.EDIJobStatus UploadEDIFilesResult;
        private String[] UploadEDIFilesResult_type_info = new String[]{'UploadEDIFilesResult','http://www.inprocorp.com/EDI/ServiceLayer',null,'0','1','false'};
        private String[] apex_schema_type_info = new String[]{'http://www.inprocorp.com/EDI/ServiceLayer','true','false'};
        private String[] field_order_type_info = new String[]{'UploadEDIFilesResult'};
    }
    public class ProcessPOResponse_element {
        public EDISvc.EDIJobStatus ProcessPOResult;
        private String[] ProcessPOResult_type_info = new String[]{'ProcessPOResult','http://www.inprocorp.com/EDI/ServiceLayer',null,'0','1','false'};
        private String[] apex_schema_type_info = new String[]{'http://www.inprocorp.com/EDI/ServiceLayer','true','false'};
        private String[] field_order_type_info = new String[]{'ProcessPOResult'};
    }
    public class RetrieveXMLLineItemsResponse_element {
        public String RetrieveXMLLineItemsResult;
        private String[] RetrieveXMLLineItemsResult_type_info = new String[]{'RetrieveXMLLineItemsResult','http://www.inprocorp.com/EDI/ServiceLayer',null,'0','1','false'};
        private String[] apex_schema_type_info = new String[]{'http://www.inprocorp.com/EDI/ServiceLayer','true','false'};
        private String[] field_order_type_info = new String[]{'RetrieveXMLLineItemsResult'};
    }
    public class ProcessPOOrder_element {
        public String EDIHeaderID;
        private String[] EDIHeaderID_type_info = new String[]{'EDIHeaderID','http://www.inprocorp.com/EDI/ServiceLayer',null,'0','1','false'};
        private String[] apex_schema_type_info = new String[]{'http://www.inprocorp.com/EDI/ServiceLayer','true','false'};
        private String[] field_order_type_info = new String[]{'EDIHeaderID'};
    }
    public class ProcessInvoiceResponse_element {
        public EDISvc.EDIJobStatus ProcessInvoiceResult;
        private String[] ProcessInvoiceResult_type_info = new String[]{'ProcessInvoiceResult','http://www.inprocorp.com/EDI/ServiceLayer',null,'0','1','false'};
        private String[] apex_schema_type_info = new String[]{'http://www.inprocorp.com/EDI/ServiceLayer','true','false'};
        private String[] field_order_type_info = new String[]{'ProcessInvoiceResult'};
    }
    public class ProcessGraingerPO_element {
        public String EDIHeaderID;
        private String[] EDIHeaderID_type_info = new String[]{'EDIHeaderID','http://www.inprocorp.com/EDI/ServiceLayer',null,'0','1','false'};
        private String[] apex_schema_type_info = new String[]{'http://www.inprocorp.com/EDI/ServiceLayer','true','false'};
        private String[] field_order_type_info = new String[]{'EDIHeaderID'};
    }
    public class ProcessEggersPO_element {
        public String EDIHeaderID;
        private String[] EDIHeaderID_type_info = new String[]{'EDIHeaderID','http://www.inprocorp.com/EDI/ServiceLayer',null,'0','1','false'};
        private String[] apex_schema_type_info = new String[]{'http://www.inprocorp.com/EDI/ServiceLayer','true','false'};
        private String[] field_order_type_info = new String[]{'EDIHeaderID'};
    }
    public class ProcessCO_element {
        public String EDIHeaderID;
        private String[] EDIHeaderID_type_info = new String[]{'EDIHeaderID','http://www.inprocorp.com/EDI/ServiceLayer',null,'0','1','false'};
        private String[] apex_schema_type_info = new String[]{'http://www.inprocorp.com/EDI/ServiceLayer','true','false'};
        private String[] field_order_type_info = new String[]{'EDIHeaderID'};
    }
    public class ProcessInvoice_element {
        public String EDIHeaderID;
        public String StatusDetailID;
        private String[] EDIHeaderID_type_info = new String[]{'EDIHeaderID','http://www.inprocorp.com/EDI/ServiceLayer',null,'0','1','false'};
        private String[] StatusDetailID_type_info = new String[]{'StatusDetailID','http://www.inprocorp.com/EDI/ServiceLayer',null,'0','1','false'};
        private String[] apex_schema_type_info = new String[]{'http://www.inprocorp.com/EDI/ServiceLayer','true','false'};
        private String[] field_order_type_info = new String[]{'EDIHeaderID','StatusDetailID'};
    }
    public class NotifyUsersManualInvoiceActionRequiredResponse_element {
        public EDISvc.EDIJobStatus NotifyUsersManualInvoiceActionRequiredResult;
        private String[] NotifyUsersManualInvoiceActionRequiredResult_type_info = new String[]{'NotifyUsersManualInvoiceActionRequiredResult','http://www.inprocorp.com/EDI/ServiceLayer',null,'0','1','false'};
        private String[] apex_schema_type_info = new String[]{'http://www.inprocorp.com/EDI/ServiceLayer','true','false'};
        private String[] field_order_type_info = new String[]{'NotifyUsersManualInvoiceActionRequiredResult'};
    }
    public class AcknowledgePOResponse_element {
        public EDISvc.EDIJobStatus AcknowledgePOResult;
        private String[] AcknowledgePOResult_type_info = new String[]{'AcknowledgePOResult','http://www.inprocorp.com/EDI/ServiceLayer',null,'0','1','false'};
        private String[] apex_schema_type_info = new String[]{'http://www.inprocorp.com/EDI/ServiceLayer','true','false'};
        private String[] field_order_type_info = new String[]{'AcknowledgePOResult'};
    }
    public class DownloadEDIFilesResponse_element {
        public EDISvc.EDIJobStatus DownloadEDIFilesResult;
        private String[] DownloadEDIFilesResult_type_info = new String[]{'DownloadEDIFilesResult','http://www.inprocorp.com/EDI/ServiceLayer',null,'0','1','false'};
        private String[] apex_schema_type_info = new String[]{'http://www.inprocorp.com/EDI/ServiceLayer','true','false'};
        private String[] field_order_type_info = new String[]{'DownloadEDIFilesResult'};
    }
    public class RetrieveGraingerMacolaPartsResponse_element {
        public String RetrieveGraingerMacolaPartsResult;
        private String[] RetrieveGraingerMacolaPartsResult_type_info = new String[]{'RetrieveGraingerMacolaPartsResult','http://www.inprocorp.com/EDI/ServiceLayer',null,'0','1','false'};
        private String[] apex_schema_type_info = new String[]{'http://www.inprocorp.com/EDI/ServiceLayer','true','false'};
        private String[] field_order_type_info = new String[]{'RetrieveGraingerMacolaPartsResult'};
    }
    public class AcknowledgeCOResponse_element {
        public EDISvc.EDIJobStatus AcknowledgeCOResult;
        private String[] AcknowledgeCOResult_type_info = new String[]{'AcknowledgeCOResult','http://www.inprocorp.com/EDI/ServiceLayer',null,'0','1','false'};
        private String[] apex_schema_type_info = new String[]{'http://www.inprocorp.com/EDI/ServiceLayer','true','false'};
        private String[] field_order_type_info = new String[]{'AcknowledgeCOResult'};
    }
    public class UpdateXMLLineItemsResponse_element {
        public EDISvc.EDIJobStatus UpdateXMLLineItemsResult;
        private String[] UpdateXMLLineItemsResult_type_info = new String[]{'UpdateXMLLineItemsResult','http://www.inprocorp.com/EDI/ServiceLayer',null,'0','1','false'};
        private String[] apex_schema_type_info = new String[]{'http://www.inprocorp.com/EDI/ServiceLayer','true','false'};
        private String[] field_order_type_info = new String[]{'UpdateXMLLineItemsResult'};
    }
    public class ProcessJJPendingOrders_element {
        public Boolean IsDev;
        private String[] IsDev_type_info = new String[]{'IsDev','http://www.inprocorp.com/EDI/ServiceLayer',null,'1','1','false'};
        private String[] apex_schema_type_info = new String[]{'http://www.inprocorp.com/EDI/ServiceLayer','true','false'};
        private String[] field_order_type_info = new String[]{'IsDev'};
    }
    public class DenyPO_element {
        public String EDIHeaderID;
        private String[] EDIHeaderID_type_info = new String[]{'EDIHeaderID','http://www.inprocorp.com/EDI/ServiceLayer',null,'0','1','false'};
        private String[] apex_schema_type_info = new String[]{'http://www.inprocorp.com/EDI/ServiceLayer','true','false'};
        private String[] field_order_type_info = new String[]{'EDIHeaderID'};
    }
    public class ProcessGraingerPOResponse_element {
        public EDISvc.EDIJobStatus ProcessGraingerPOResult;
        private String[] ProcessGraingerPOResult_type_info = new String[]{'ProcessGraingerPOResult','http://www.inprocorp.com/EDI/ServiceLayer',null,'0','1','false'};
        private String[] apex_schema_type_info = new String[]{'http://www.inprocorp.com/EDI/ServiceLayer','true','false'};
        private String[] field_order_type_info = new String[]{'ProcessGraingerPOResult'};
    }
    public class RetrieveXMLLineItems_element {
        public String StatusID;
        public String EDIHeaderID;
        private String[] StatusID_type_info = new String[]{'StatusID','http://www.inprocorp.com/EDI/ServiceLayer',null,'0','1','false'};
        private String[] EDIHeaderID_type_info = new String[]{'EDIHeaderID','http://www.inprocorp.com/EDI/ServiceLayer',null,'0','1','false'};
        private String[] apex_schema_type_info = new String[]{'http://www.inprocorp.com/EDI/ServiceLayer','true','false'};
        private String[] field_order_type_info = new String[]{'StatusID','EDIHeaderID'};
    }
    public class UpdateXMLLineItems_element {
        public String StatusID;
        public String EDIHeaderID;
        public String XmlLineItemsJson;
        private String[] StatusID_type_info = new String[]{'StatusID','http://www.inprocorp.com/EDI/ServiceLayer',null,'0','1','false'};
        private String[] EDIHeaderID_type_info = new String[]{'EDIHeaderID','http://www.inprocorp.com/EDI/ServiceLayer',null,'0','1','false'};
        private String[] XmlLineItemsJson_type_info = new String[]{'XmlLineItemsJson','http://www.inprocorp.com/EDI/ServiceLayer',null,'0','1','false'};
        private String[] apex_schema_type_info = new String[]{'http://www.inprocorp.com/EDI/ServiceLayer','true','false'};
        private String[] field_order_type_info = new String[]{'StatusID','EDIHeaderID','XmlLineItemsJson'};
    }
    public class EDIJobStatus {
        public String Message;
        public Boolean Status;
        private String[] Message_type_info = new String[]{'Message','http://www.inprocorp.com/EDI/ServiceLayer',null,'0','1','false'};
        private String[] Status_type_info = new String[]{'Status','http://www.inprocorp.com/EDI/ServiceLayer',null,'1','1','false'};
        private String[] apex_schema_type_info = new String[]{'http://www.inprocorp.com/EDI/ServiceLayer','true','false'};
        private String[] field_order_type_info = new String[]{'Message','Status'};
    }
    public class AcknowledgePO_element {
        public String EDIHeaderID;
        private String[] EDIHeaderID_type_info = new String[]{'EDIHeaderID','http://www.inprocorp.com/EDI/ServiceLayer',null,'0','1','false'};
        private String[] apex_schema_type_info = new String[]{'http://www.inprocorp.com/EDI/ServiceLayer','true','false'};
        private String[] field_order_type_info = new String[]{'EDIHeaderID'};
    }
    public class ProcessPO_element {
        public String EDIHeaderID;
        private String[] EDIHeaderID_type_info = new String[]{'EDIHeaderID','http://www.inprocorp.com/EDI/ServiceLayer',null,'0','1','false'};
        private String[] apex_schema_type_info = new String[]{'http://www.inprocorp.com/EDI/ServiceLayer','true','false'};
        private String[] field_order_type_info = new String[]{'EDIHeaderID'};
    }
    public class ProcessGraingerInvoice_element {
        public String EDIHeaderID;
        public String StatusDetailID;
        private String[] EDIHeaderID_type_info = new String[]{'EDIHeaderID','http://www.inprocorp.com/EDI/ServiceLayer',null,'0','1','false'};
        private String[] StatusDetailID_type_info = new String[]{'StatusDetailID','http://www.inprocorp.com/EDI/ServiceLayer',null,'0','1','false'};
        private String[] apex_schema_type_info = new String[]{'http://www.inprocorp.com/EDI/ServiceLayer','true','false'};
        private String[] field_order_type_info = new String[]{'EDIHeaderID','StatusDetailID'};
    }
    public class CheckOrdersInvoiced_element {
        public Boolean FullRun;
        private String[] FullRun_type_info = new String[]{'FullRun','http://www.inprocorp.com/EDI/ServiceLayer',null,'1','1','false'};
        private String[] apex_schema_type_info = new String[]{'http://www.inprocorp.com/EDI/ServiceLayer','true','false'};
        private String[] field_order_type_info = new String[]{'FullRun'};
    }
    public class EDISvcSoap {
        public String endpoint_x = GlobalHelper.GetEDIServiceEndpoint();
        public Map<String,String> inputHttpHeaders_x;
        public Map<String,String> outputHttpHeaders_x;
        public String clientCertName_x;
        public String clientCert_x;
        public String clientCertPasswd_x;
        public Integer timeout_x;
        private String[] ns_map_type_info = new String[]{'http://www.inprocorp.com/EDI/ServiceLayer', 'EDISvc'};
        public EDISvc.EDIJobStatus NotifyUsersNewPOPendingApproval(String EDIHeaderID) {
            EDISvc.NotifyUsersNewPOPendingApproval_element request_x = new EDISvc.NotifyUsersNewPOPendingApproval_element();
            request_x.EDIHeaderID = EDIHeaderID;
            EDISvc.NotifyUsersNewPOPendingApprovalResponse_element response_x;
            Map<String, EDISvc.NotifyUsersNewPOPendingApprovalResponse_element> response_map_x = new Map<String, EDISvc.NotifyUsersNewPOPendingApprovalResponse_element>();
            response_map_x.put('response_x', response_x);
            WebServiceCallout.invoke(
              this,
              request_x,
              response_map_x,
              new String[]{endpoint_x,
              'http://www.inprocorp.com/EDI/ServiceLayer/NotifyUsersNewPOPendingApproval',
              'http://www.inprocorp.com/EDI/ServiceLayer',
              'NotifyUsersNewPOPendingApproval',
              'http://www.inprocorp.com/EDI/ServiceLayer',
              'NotifyUsersNewPOPendingApprovalResponse',
              'EDISvc.NotifyUsersNewPOPendingApprovalResponse_element'}
            );
            response_x = response_map_x.get('response_x');
            return response_x.NotifyUsersNewPOPendingApprovalResult;
        }
        public EDISvc.EDIJobStatus ProcessGraingerPO(String EDIHeaderID) {
            EDISvc.ProcessGraingerPO_element request_x = new EDISvc.ProcessGraingerPO_element();
            request_x.EDIHeaderID = EDIHeaderID;
            EDISvc.ProcessGraingerPOResponse_element response_x;
            Map<String, EDISvc.ProcessGraingerPOResponse_element> response_map_x = new Map<String, EDISvc.ProcessGraingerPOResponse_element>();
            response_map_x.put('response_x', response_x);
            WebServiceCallout.invoke(
              this,
              request_x,
              response_map_x,
              new String[]{endpoint_x,
              'http://www.inprocorp.com/EDI/ServiceLayer/ProcessGraingerPO',
              'http://www.inprocorp.com/EDI/ServiceLayer',
              'ProcessGraingerPO',
              'http://www.inprocorp.com/EDI/ServiceLayer',
              'ProcessGraingerPOResponse',
              'EDISvc.ProcessGraingerPOResponse_element'}
            );
            response_x = response_map_x.get('response_x');
            return response_x.ProcessGraingerPOResult;
        }
        public String RunVentas(String invNo,String ediDocumentId,String token) {
            EDISvc.RunVentas_element request_x = new EDISvc.RunVentas_element();
            request_x.invNo = invNo;
            request_x.ediDocumentId = ediDocumentId;
            request_x.token = token;
            EDISvc.RunVentasResponse_element response_x;
            Map<String, EDISvc.RunVentasResponse_element> response_map_x = new Map<String, EDISvc.RunVentasResponse_element>();
            response_map_x.put('response_x', response_x);
            WebServiceCallout.invoke(
              this,
              request_x,
              response_map_x,
              new String[]{endpoint_x,
              'http://www.inprocorp.com/EDI/ServiceLayer/RunVentas',
              'http://www.inprocorp.com/EDI/ServiceLayer',
              'RunVentas',
              'http://www.inprocorp.com/EDI/ServiceLayer',
              'RunVentasResponse',
              'EDISvc.RunVentasResponse_element'}
            );
            response_x = response_map_x.get('response_x');
            return response_x.RunVentasResult;
        }
        public EDISvc.EDIJobStatus AcknowledgeGraingerPO(String EDIHeaderID) {
            EDISvc.AcknowledgeGraingerPO_element request_x = new EDISvc.AcknowledgeGraingerPO_element();
            request_x.EDIHeaderID = EDIHeaderID;
            EDISvc.AcknowledgeGraingerPOResponse_element response_x;
            Map<String, EDISvc.AcknowledgeGraingerPOResponse_element> response_map_x = new Map<String, EDISvc.AcknowledgeGraingerPOResponse_element>();
            response_map_x.put('response_x', response_x);
            WebServiceCallout.invoke(
              this,
              request_x,
              response_map_x,
              new String[]{endpoint_x,
              'http://www.inprocorp.com/EDI/ServiceLayer/AcknowledgeGraingerPO',
              'http://www.inprocorp.com/EDI/ServiceLayer',
              'AcknowledgeGraingerPO',
              'http://www.inprocorp.com/EDI/ServiceLayer',
              'AcknowledgeGraingerPOResponse',
              'EDISvc.AcknowledgeGraingerPOResponse_element'}
            );
            response_x = response_map_x.get('response_x');
            return response_x.AcknowledgeGraingerPOResult;
        }
        public EDISvc.EDIJobStatus UploadEDIFiles(String EDIHeaderID,String DocumentType) {
            EDISvc.UploadEDIFiles_element request_x = new EDISvc.UploadEDIFiles_element();
            request_x.EDIHeaderID = EDIHeaderID;
            request_x.DocumentType = DocumentType;
            EDISvc.UploadEDIFilesResponse_element response_x;
            Map<String, EDISvc.UploadEDIFilesResponse_element> response_map_x = new Map<String, EDISvc.UploadEDIFilesResponse_element>();
            response_map_x.put('response_x', response_x);
            WebServiceCallout.invoke(
              this,
              request_x,
              response_map_x,
              new String[]{endpoint_x,
              'http://www.inprocorp.com/EDI/ServiceLayer/UploadEDIFiles',
              'http://www.inprocorp.com/EDI/ServiceLayer',
              'UploadEDIFiles',
              'http://www.inprocorp.com/EDI/ServiceLayer',
              'UploadEDIFilesResponse',
              'EDISvc.UploadEDIFilesResponse_element'}
            );
            response_x = response_map_x.get('response_x');
            return response_x.UploadEDIFilesResult;
        }
        public EDISvc.EDIJobStatus UpdateXMLLineItems(String StatusID,String EDIHeaderID,String XmlLineItemsJson) {
            EDISvc.UpdateXMLLineItems_element request_x = new EDISvc.UpdateXMLLineItems_element();
            request_x.StatusID = StatusID;
            request_x.EDIHeaderID = EDIHeaderID;
            request_x.XmlLineItemsJson = XmlLineItemsJson;
            EDISvc.UpdateXMLLineItemsResponse_element response_x;
            Map<String, EDISvc.UpdateXMLLineItemsResponse_element> response_map_x = new Map<String, EDISvc.UpdateXMLLineItemsResponse_element>();
            response_map_x.put('response_x', response_x);
            WebServiceCallout.invoke(
              this,
              request_x,
              response_map_x,
              new String[]{endpoint_x,
              'http://www.inprocorp.com/EDI/ServiceLayer/UpdateXMLLineItems',
              'http://www.inprocorp.com/EDI/ServiceLayer',
              'UpdateXMLLineItems',
              'http://www.inprocorp.com/EDI/ServiceLayer',
              'UpdateXMLLineItemsResponse',
              'EDISvc.UpdateXMLLineItemsResponse_element'}
            );
            response_x = response_map_x.get('response_x');
            return response_x.UpdateXMLLineItemsResult;
        }
        public EDISvc.EDIJobStatus NotifyUsersManualInvoiceActionRequired(String StatusID,String EDIHeaderID) {
            EDISvc.NotifyUsersManualInvoiceActionRequired_element request_x = new EDISvc.NotifyUsersManualInvoiceActionRequired_element();
            request_x.StatusID = StatusID;
            request_x.EDIHeaderID = EDIHeaderID;
            EDISvc.NotifyUsersManualInvoiceActionRequiredResponse_element response_x;
            Map<String, EDISvc.NotifyUsersManualInvoiceActionRequiredResponse_element> response_map_x = new Map<String, EDISvc.NotifyUsersManualInvoiceActionRequiredResponse_element>();
            response_map_x.put('response_x', response_x);
            WebServiceCallout.invoke(
              this,
              request_x,
              response_map_x,
              new String[]{endpoint_x,
              'http://www.inprocorp.com/EDI/ServiceLayer/NotifyUsersManualInvoiceActionRequired',
              'http://www.inprocorp.com/EDI/ServiceLayer',
              'NotifyUsersManualInvoiceActionRequired',
              'http://www.inprocorp.com/EDI/ServiceLayer',
              'NotifyUsersManualInvoiceActionRequiredResponse',
              'EDISvc.NotifyUsersManualInvoiceActionRequiredResponse_element'}
            );
            response_x = response_map_x.get('response_x');
            return response_x.NotifyUsersManualInvoiceActionRequiredResult;
        }
        public EDISvc.EDIJobStatus ProcessPO(String EDIHeaderID) {
            EDISvc.ProcessPO_element request_x = new EDISvc.ProcessPO_element();
            request_x.EDIHeaderID = EDIHeaderID;
            EDISvc.ProcessPOResponse_element response_x;
            Map<String, EDISvc.ProcessPOResponse_element> response_map_x = new Map<String, EDISvc.ProcessPOResponse_element>();
            response_map_x.put('response_x', response_x);
            WebServiceCallout.invoke(
              this,
              request_x,
              response_map_x,
              new String[]{endpoint_x,
              'http://www.inprocorp.com/EDI/ServiceLayer/ProcessPO',
              'http://www.inprocorp.com/EDI/ServiceLayer',
              'ProcessPO',
              'http://www.inprocorp.com/EDI/ServiceLayer',
              'ProcessPOResponse',
              'EDISvc.ProcessPOResponse_element'}
            );
            response_x = response_map_x.get('response_x');
            return response_x.ProcessPOResult;
        }
        public EDISvc.EDIJobStatus ProcessJJShippingAcknowledgement(String EDIHeaderID) {
            EDISvc.ProcessJJShippingAcknowledgement_element request_x = new EDISvc.ProcessJJShippingAcknowledgement_element();
            request_x.EDIHeaderID = EDIHeaderID;
            EDISvc.ProcessJJShippingAcknowledgementResponse_element response_x;
            Map<String, EDISvc.ProcessJJShippingAcknowledgementResponse_element> response_map_x = new Map<String, EDISvc.ProcessJJShippingAcknowledgementResponse_element>();
            response_map_x.put('response_x', response_x);
            WebServiceCallout.invoke(
              this,
              request_x,
              response_map_x,
              new String[]{endpoint_x,
              'http://www.inprocorp.com/EDI/ServiceLayer/ProcessJJShippingAcknowledgement',
              'http://www.inprocorp.com/EDI/ServiceLayer',
              'ProcessJJShippingAcknowledgement',
              'http://www.inprocorp.com/EDI/ServiceLayer',
              'ProcessJJShippingAcknowledgementResponse',
              'EDISvc.ProcessJJShippingAcknowledgementResponse_element'}
            );
            response_x = response_map_x.get('response_x');
            return response_x.ProcessJJShippingAcknowledgementResult;
        }
        public EDISvc.EDIJobStatus DenyPO(String EDIHeaderID) {
            EDISvc.DenyPO_element request_x = new EDISvc.DenyPO_element();
            request_x.EDIHeaderID = EDIHeaderID;
            EDISvc.DenyPOResponse_element response_x;
            Map<String, EDISvc.DenyPOResponse_element> response_map_x = new Map<String, EDISvc.DenyPOResponse_element>();
            response_map_x.put('response_x', response_x);
            WebServiceCallout.invoke(
              this,
              request_x,
              response_map_x,
              new String[]{endpoint_x,
              'http://www.inprocorp.com/EDI/ServiceLayer/DenyPO',
              'http://www.inprocorp.com/EDI/ServiceLayer',
              'DenyPO',
              'http://www.inprocorp.com/EDI/ServiceLayer',
              'DenyPOResponse',
              'EDISvc.DenyPOResponse_element'}
            );
            response_x = response_map_x.get('response_x');
            return response_x.DenyPOResult;
        }
        public String RetrieveXMLLineItems(String StatusID,String EDIHeaderID) {
            EDISvc.RetrieveXMLLineItems_element request_x = new EDISvc.RetrieveXMLLineItems_element();
            request_x.StatusID = StatusID;
            request_x.EDIHeaderID = EDIHeaderID;
            EDISvc.RetrieveXMLLineItemsResponse_element response_x;
            Map<String, EDISvc.RetrieveXMLLineItemsResponse_element> response_map_x = new Map<String, EDISvc.RetrieveXMLLineItemsResponse_element>();
            response_map_x.put('response_x', response_x);
            WebServiceCallout.invoke(
              this,
              request_x,
              response_map_x,
              new String[]{endpoint_x,
              'http://www.inprocorp.com/EDI/ServiceLayer/RetrieveXMLLineItems',
              'http://www.inprocorp.com/EDI/ServiceLayer',
              'RetrieveXMLLineItems',
              'http://www.inprocorp.com/EDI/ServiceLayer',
              'RetrieveXMLLineItemsResponse',
              'EDISvc.RetrieveXMLLineItemsResponse_element'}
            );
            response_x = response_map_x.get('response_x');
            return response_x.RetrieveXMLLineItemsResult;
        }
        
        public EDISvc.EDIJobStatus ProcessPOOrder(String EDIHeaderID) {
            EDISvc.ProcessPOOrder_element request_x = new EDISvc.ProcessPOOrder_element();
            request_x.EDIHeaderID = EDIHeaderID;
            EDISvc.ProcessPOOrderResponse_element response_x;
            Map<String, EDISvc.ProcessPOOrderResponse_element> response_map_x = new Map<String, EDISvc.ProcessPOOrderResponse_element>();
            response_map_x.put('response_x', response_x);
            WebServiceCallout.invoke(
              this,
              request_x,
              response_map_x,
              new String[]{endpoint_x,
              'http://www.inprocorp.com/EDI/ServiceLayer/ProcessPOOrder',
              'http://www.inprocorp.com/EDI/ServiceLayer',
              'ProcessPOOrder',
              'http://www.inprocorp.com/EDI/ServiceLayer',
              'ProcessPOOrderResponse',
              'EDISvc.ProcessPOOrderResponse_element'}
            );
            response_x = response_map_x.get('response_x');
            return response_x.ProcessPOOrderResult;
        }
        public EDISvc.EDIJobStatus ProcessInvoice(String EDIHeaderID,String StatusDetailID) {
            EDISvc.ProcessInvoice_element request_x = new EDISvc.ProcessInvoice_element();
            request_x.EDIHeaderID = EDIHeaderID;
            request_x.StatusDetailID = StatusDetailID;
            EDISvc.ProcessInvoiceResponse_element response_x;
            Map<String, EDISvc.ProcessInvoiceResponse_element> response_map_x = new Map<String, EDISvc.ProcessInvoiceResponse_element>();
            response_map_x.put('response_x', response_x);
            WebServiceCallout.invoke(
              this,
              request_x,
              response_map_x,
              new String[]{endpoint_x,
              'http://www.inprocorp.com/EDI/ServiceLayer/ProcessInvoice',
              'http://www.inprocorp.com/EDI/ServiceLayer',
              'ProcessInvoice',
              'http://www.inprocorp.com/EDI/ServiceLayer',
              'ProcessInvoiceResponse',
              'EDISvc.ProcessInvoiceResponse_element'}
            );
            response_x = response_map_x.get('response_x');
            return response_x.ProcessInvoiceResult;
        }
        public EDISvc.EDIJobStatus CreateEDIPO(String VendorID,String SalesOrder,String PurchaseOrder) {
            EDISvc.CreateEDIPO_element request_x = new EDISvc.CreateEDIPO_element();
            request_x.VendorID = VendorID;
            request_x.SalesOrder = SalesOrder;
            request_x.PurchaseOrder = PurchaseOrder;
            EDISvc.CreateEDIPOResponse_element response_x;
            Map<String, EDISvc.CreateEDIPOResponse_element> response_map_x = new Map<String, EDISvc.CreateEDIPOResponse_element>();
            response_map_x.put('response_x', response_x);
            WebServiceCallout.invoke(
              this,
              request_x,
              response_map_x,
              new String[]{endpoint_x,
              'http://www.inprocorp.com/EDI/ServiceLayer/CreateEDIPO',
              'http://www.inprocorp.com/EDI/ServiceLayer',
              'CreateEDIPO',
              'http://www.inprocorp.com/EDI/ServiceLayer',
              'CreateEDIPOResponse',
              'EDISvc.CreateEDIPOResponse_element'}
            );
            response_x = response_map_x.get('response_x');
            return response_x.CreateEDIPOResult;
        }
        public Decimal PriceCheck(String ItemNumber,String AccountNumber) {
            EDISvc.PriceCheck_element request_x = new EDISvc.PriceCheck_element();
            request_x.ItemNumber = ItemNumber;
            request_x.AccountNumber = AccountNumber;
            EDISvc.PriceCheckResponse_element response_x;
            Map<String, EDISvc.PriceCheckResponse_element> response_map_x = new Map<String, EDISvc.PriceCheckResponse_element>();
            response_map_x.put('response_x', response_x);
            WebServiceCallout.invoke(
              this,
              request_x,
              response_map_x,
              new String[]{endpoint_x,
              'http://www.inprocorp.com/EDI/ServiceLayer/PriceCheck',
              'http://www.inprocorp.com/EDI/ServiceLayer',
              'PriceCheck',
              'http://www.inprocorp.com/EDI/ServiceLayer',
              'PriceCheckResponse',
              'EDISvc.PriceCheckResponse_element'}
            );
            response_x = response_map_x.get('response_x');
            return response_x.PriceCheckResult;
        }
        public EDISvc.EDIJobStatus ProcessJJPendingOrders(Boolean IsDev) {
            EDISvc.ProcessJJPendingOrders_element request_x = new EDISvc.ProcessJJPendingOrders_element();
            request_x.IsDev = IsDev;
            EDISvc.ProcessJJPendingOrdersResponse_element response_x;
            Map<String, EDISvc.ProcessJJPendingOrdersResponse_element> response_map_x = new Map<String, EDISvc.ProcessJJPendingOrdersResponse_element>();
            response_map_x.put('response_x', response_x);
            WebServiceCallout.invoke(
              this,
              request_x,
              response_map_x,
              new String[]{endpoint_x,
              'http://www.inprocorp.com/EDI/ServiceLayer/ProcessJJPendingOrders',
              'http://www.inprocorp.com/EDI/ServiceLayer',
              'ProcessJJPendingOrders',
              'http://www.inprocorp.com/EDI/ServiceLayer',
              'ProcessJJPendingOrdersResponse',
              'EDISvc.ProcessJJPendingOrdersResponse_element'}
            );
            response_x = response_map_x.get('response_x');
            return response_x.ProcessJJPendingOrdersResult;
        }
        public EDISvc.EDIJobStatus AcknowledgePO(String EDIHeaderID) {
            EDISvc.AcknowledgePO_element request_x = new EDISvc.AcknowledgePO_element();
            request_x.EDIHeaderID = EDIHeaderID;
            EDISvc.AcknowledgePOResponse_element response_x;
            Map<String, EDISvc.AcknowledgePOResponse_element> response_map_x = new Map<String, EDISvc.AcknowledgePOResponse_element>();
            response_map_x.put('response_x', response_x);
            WebServiceCallout.invoke(
              this,
              request_x,
              response_map_x,
              new String[]{endpoint_x,
              'http://www.inprocorp.com/EDI/ServiceLayer/AcknowledgePO',
              'http://www.inprocorp.com/EDI/ServiceLayer',
              'AcknowledgePO',
              'http://www.inprocorp.com/EDI/ServiceLayer',
              'AcknowledgePOResponse',
              'EDISvc.AcknowledgePOResponse_element'}
            );
            response_x = response_map_x.get('response_x');
            return response_x.AcknowledgePOResult;
        }
        public EDISvc.EDIJobStatus CancelPO(String EDIHeaderID) {
            EDISvc.CancelPO_element request_x = new EDISvc.CancelPO_element();
            request_x.EDIHeaderID = EDIHeaderID;
            EDISvc.CancelPOResponse_element response_x;
            Map<String, EDISvc.CancelPOResponse_element> response_map_x = new Map<String, EDISvc.CancelPOResponse_element>();
            response_map_x.put('response_x', response_x);
            WebServiceCallout.invoke(
              this,
              request_x,
              response_map_x,
              new String[]{endpoint_x,
              'http://www.inprocorp.com/EDI/ServiceLayer/CancelPO',
              'http://www.inprocorp.com/EDI/ServiceLayer',
              'CancelPO',
              'http://www.inprocorp.com/EDI/ServiceLayer',
              'CancelPOResponse',
              'EDISvc.CancelPOResponse_element'}
            );
            response_x = response_map_x.get('response_x');
            return response_x.CancelPOResult;
        }
        public String RetrieveGraingerMacolaParts(String EDIHeaderID,String StatusDetailID) {
            EDISvc.RetrieveGraingerMacolaParts_element request_x = new EDISvc.RetrieveGraingerMacolaParts_element();
            request_x.EDIHeaderID = EDIHeaderID;
            request_x.StatusDetailID = StatusDetailID;
            EDISvc.RetrieveGraingerMacolaPartsResponse_element response_x;
            Map<String, EDISvc.RetrieveGraingerMacolaPartsResponse_element> response_map_x = new Map<String, EDISvc.RetrieveGraingerMacolaPartsResponse_element>();
            response_map_x.put('response_x', response_x);
            WebServiceCallout.invoke(
              this,
              request_x,
              response_map_x,
              new String[]{endpoint_x,
              'http://www.inprocorp.com/EDI/ServiceLayer/RetrieveGraingerMacolaParts',
              'http://www.inprocorp.com/EDI/ServiceLayer',
              'RetrieveGraingerMacolaParts',
              'http://www.inprocorp.com/EDI/ServiceLayer',
              'RetrieveGraingerMacolaPartsResponse',
              'EDISvc.RetrieveGraingerMacolaPartsResponse_element'}
            );
            response_x = response_map_x.get('response_x');
            return response_x.RetrieveGraingerMacolaPartsResult;
        }
        public EDISvc.EDIJobStatus DownloadEDIFiles(String VendorName) {
            EDISvc.DownloadEDIFiles_element request_x = new EDISvc.DownloadEDIFiles_element();
            request_x.VendorName = VendorName;
            EDISvc.DownloadEDIFilesResponse_element response_x;
            Map<String, EDISvc.DownloadEDIFilesResponse_element> response_map_x = new Map<String, EDISvc.DownloadEDIFilesResponse_element>();
            response_map_x.put('response_x', response_x);
            WebServiceCallout.invoke(
              this,
              request_x,
              response_map_x,
              new String[]{endpoint_x,
              'http://www.inprocorp.com/EDI/ServiceLayer/DownloadEDIFiles',
              'http://www.inprocorp.com/EDI/ServiceLayer',
              'DownloadEDIFiles',
              'http://www.inprocorp.com/EDI/ServiceLayer',
              'DownloadEDIFilesResponse',
              'EDISvc.DownloadEDIFilesResponse_element'}
            );
            response_x = response_map_x.get('response_x');
            return response_x.DownloadEDIFilesResult;
        }
        public EDISvc.EDIJobStatus CheckOrdersInvoiced(Boolean FullRun) {
            EDISvc.CheckOrdersInvoiced_element request_x = new EDISvc.CheckOrdersInvoiced_element();
            request_x.FullRun = FullRun;
            EDISvc.CheckOrdersInvoicedResponse_element response_x;
            Map<String, EDISvc.CheckOrdersInvoicedResponse_element> response_map_x = new Map<String, EDISvc.CheckOrdersInvoicedResponse_element>();
            response_map_x.put('response_x', response_x);
            WebServiceCallout.invoke(
              this,
              request_x,
              response_map_x,
              new String[]{endpoint_x,
              'http://www.inprocorp.com/EDI/ServiceLayer/CheckOrdersInvoiced',
              'http://www.inprocorp.com/EDI/ServiceLayer',
              'CheckOrdersInvoiced',
              'http://www.inprocorp.com/EDI/ServiceLayer',
              'CheckOrdersInvoicedResponse',
              'EDISvc.CheckOrdersInvoicedResponse_element'}
            );
            response_x = response_map_x.get('response_x');
            return response_x.CheckOrdersInvoicedResult;
        }
        public EDISvc.EDIJobStatus ProcessGraingerInvoice(String EDIHeaderID,String StatusDetailID) {
            EDISvc.ProcessGraingerInvoice_element request_x = new EDISvc.ProcessGraingerInvoice_element();
            request_x.EDIHeaderID = EDIHeaderID;
            request_x.StatusDetailID = StatusDetailID;
            EDISvc.ProcessGraingerInvoiceResponse_element response_x;
            Map<String, EDISvc.ProcessGraingerInvoiceResponse_element> response_map_x = new Map<String, EDISvc.ProcessGraingerInvoiceResponse_element>();
            response_map_x.put('response_x', response_x);
            WebServiceCallout.invoke(
              this,
              request_x,
              response_map_x,
              new String[]{endpoint_x,
              'http://www.inprocorp.com/EDI/ServiceLayer/ProcessGraingerInvoice',
              'http://www.inprocorp.com/EDI/ServiceLayer',
              'ProcessGraingerInvoice',
              'http://www.inprocorp.com/EDI/ServiceLayer',
              'ProcessGraingerInvoiceResponse',
              'EDISvc.ProcessGraingerInvoiceResponse_element'}
            );
            response_x = response_map_x.get('response_x');
            return response_x.ProcessGraingerInvoiceResult;
        }
        public EDISvc.EDIJobStatus ProcessEggersPO(String EDIHeaderID) {
            EDISvc.ProcessEggersPO_element request_x = new EDISvc.ProcessEggersPO_element();
            request_x.EDIHeaderID = EDIHeaderID;
            EDISvc.ProcessEggersPOResponse_element response_x;
            Map<String, EDISvc.ProcessEggersPOResponse_element> response_map_x = new Map<String, EDISvc.ProcessEggersPOResponse_element>();
            response_map_x.put('response_x', response_x);
            WebServiceCallout.invoke(
              this,
              request_x,
              response_map_x,
              new String[]{endpoint_x,
              'http://www.inprocorp.com/EDI/ServiceLayer/ProcessEggersPO',
              'http://www.inprocorp.com/EDI/ServiceLayer',
              'ProcessEggersPO',
              'http://www.inprocorp.com/EDI/ServiceLayer',
              'ProcessEggersPOResponse',
              'EDISvc.ProcessEggersPOResponse_element'}
            );
            response_x = response_map_x.get('response_x');
            return response_x.ProcessEggersPOResult;
        }
        public EDISvc.EDIJobStatus AcknowledgeCO(String EDIHeaderID) {
            EDISvc.AcknowledgeCO_element request_x = new EDISvc.AcknowledgeCO_element();
            request_x.EDIHeaderID = EDIHeaderID;
            EDISvc.AcknowledgeCOResponse_element response_x;
            Map<String, EDISvc.AcknowledgeCOResponse_element> response_map_x = new Map<String, EDISvc.AcknowledgeCOResponse_element>();
            response_map_x.put('response_x', response_x);
            WebServiceCallout.invoke(
              this,
              request_x,
              response_map_x,
              new String[]{endpoint_x,
              'http://www.inprocorp.com/EDI/ServiceLayer/AcknowledgeCO',
              'http://www.inprocorp.com/EDI/ServiceLayer',
              'AcknowledgeCO',
              'http://www.inprocorp.com/EDI/ServiceLayer',
              'AcknowledgeCOResponse',
              'EDISvc.AcknowledgeCOResponse_element'}
            );
            response_x = response_map_x.get('response_x');
            return response_x.AcknowledgeCOResult;
        }
        public EDISvc.EDIJobStatus ProcessCO(String EDIHeaderID) {
            EDISvc.ProcessCO_element request_x = new EDISvc.ProcessCO_element();
            request_x.EDIHeaderID = EDIHeaderID;
            EDISvc.ProcessCOResponse_element response_x;
            Map<String, EDISvc.ProcessCOResponse_element> response_map_x = new Map<String, EDISvc.ProcessCOResponse_element>();
            response_map_x.put('response_x', response_x);
            WebServiceCallout.invoke(
              this,
              request_x,
              response_map_x,
              new String[]{endpoint_x,
              'http://www.inprocorp.com/EDI/ServiceLayer/ProcessCO',
              'http://www.inprocorp.com/EDI/ServiceLayer',
              'ProcessCO',
              'http://www.inprocorp.com/EDI/ServiceLayer',
              'ProcessCOResponse',
              'EDISvc.ProcessCOResponse_element'}
            );
            response_x = response_map_x.get('response_x');
            return response_x.ProcessCOResult;
        }
    }
}