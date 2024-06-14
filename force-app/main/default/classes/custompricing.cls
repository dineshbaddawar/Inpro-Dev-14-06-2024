//Generated by wsdl2apex

public class custompricing {
    public class SubmitCustomPricingActivities_element {
        public String userId;
        public String quoteProducts;
        public String token;
        private String[] userId_type_info = new String[]{'userId','CustomPricing.com',null,'0','1','false'};
        private String[] quoteProducts_type_info = new String[]{'quoteProducts','CustomPricing.com',null,'0','1','false'};
        private String[] token_type_info = new String[]{'token','CustomPricing.com',null,'0','1','false'};
        private String[] apex_schema_type_info = new String[]{'CustomPricing.com','true','false'};
        private String[] field_order_type_info = new String[]{'userId','quoteProducts','token'};
    }
    public class CreateCustomPricingActivitiesResponse_element {
        public custompricing.Result CreateCustomPricingActivitiesResult;
        private String[] CreateCustomPricingActivitiesResult_type_info = new String[]{'CreateCustomPricingActivitiesResult','CustomPricing.com',null,'0','1','false'};
        private String[] apex_schema_type_info = new String[]{'CustomPricing.com','true','false'};
        private String[] field_order_type_info = new String[]{'CreateCustomPricingActivitiesResult'};
    }
    public class ArrayOfString {
        public String[] string_x;
        private String[] string_x_type_info = new String[]{'string','CustomPricing.com',null,'0','-1','true'};
        private String[] apex_schema_type_info = new String[]{'CustomPricing.com','true','false'};
        private String[] field_order_type_info = new String[]{'string_x'};
    }
    public class CreateCustomPricingActivities_element {
        public String userId;
        public custompricing.ArrayOfString quoteProducts;
        public String token;
        private String[] userId_type_info = new String[]{'userId','CustomPricing.com',null,'0','1','false'};
        private String[] quoteProducts_type_info = new String[]{'quoteProducts','CustomPricing.com',null,'0','1','false'};
        private String[] token_type_info = new String[]{'token','CustomPricing.com',null,'0','1','false'};
        private String[] apex_schema_type_info = new String[]{'CustomPricing.com','true','false'};
        private String[] field_order_type_info = new String[]{'userId','quoteProducts','token'};
    }
    public class SubmitCustomPricingActivitiesResponse_element {
        public custompricing.Result SubmitCustomPricingActivitiesResult;
        private String[] SubmitCustomPricingActivitiesResult_type_info = new String[]{'SubmitCustomPricingActivitiesResult','CustomPricing.com',null,'0','1','false'};
        private String[] apex_schema_type_info = new String[]{'CustomPricing.com','true','false'};
        private String[] field_order_type_info = new String[]{'SubmitCustomPricingActivitiesResult'};
    }
    public class Result {
        public String Message;
        public Boolean Status;
        private String[] Message_type_info = new String[]{'Message','CustomPricing.com',null,'0','1','false'};
        private String[] Status_type_info = new String[]{'Status','CustomPricing.com',null,'1','1','false'};
        private String[] apex_schema_type_info = new String[]{'CustomPricing.com','true','false'};
        private String[] field_order_type_info = new String[]{'Message','Status'};
    }
    public class CustomPricingServiceSoap {
        public String endpoint_x = 'https://cloudproxy.inprocorp.com:34772/CustomPricing/CustomPricingService.asmx';
        public Map<String,String> inputHttpHeaders_x;
        public Map<String,String> outputHttpHeaders_x;
        public String clientCertName_x;
        public String clientCert_x;
        public String clientCertPasswd_x;
        public Integer timeout_x;
        private String[] ns_map_type_info = new String[]{'CustomPricing.com', 'custompricing'};
        public custompricing.Result SubmitCustomPricingActivities(String userId,String quoteProducts,String token) {
            custompricing.SubmitCustomPricingActivities_element request_x = new custompricing.SubmitCustomPricingActivities_element();
            request_x.userId = userId;
            request_x.quoteProducts = quoteProducts;
            request_x.token = token;
            custompricing.SubmitCustomPricingActivitiesResponse_element response_x;
            Map<String, custompricing.SubmitCustomPricingActivitiesResponse_element> response_map_x = new Map<String, custompricing.SubmitCustomPricingActivitiesResponse_element>();
            response_map_x.put('response_x', response_x);
            WebServiceCallout.invoke(
              this,
              request_x,
              response_map_x,
              new String[]{endpoint_x,
              'CustomPricing.com/SubmitCustomPricingActivities',
              'CustomPricing.com',
              'SubmitCustomPricingActivities',
              'CustomPricing.com',
              'SubmitCustomPricingActivitiesResponse',
              'custompricing.SubmitCustomPricingActivitiesResponse_element'}
            );
            response_x = response_map_x.get('response_x');
            return response_x.SubmitCustomPricingActivitiesResult;
        }
        public custompricing.Result CreateCustomPricingActivities(String userId,custompricing.ArrayOfString quoteProducts,String token) {
            custompricing.CreateCustomPricingActivities_element request_x = new custompricing.CreateCustomPricingActivities_element();
            request_x.userId = userId;
            request_x.quoteProducts = quoteProducts;
            request_x.token = token;
            custompricing.CreateCustomPricingActivitiesResponse_element response_x;
            Map<String, custompricing.CreateCustomPricingActivitiesResponse_element> response_map_x = new Map<String, custompricing.CreateCustomPricingActivitiesResponse_element>();
            response_map_x.put('response_x', response_x);
            WebServiceCallout.invoke(
              this,
              request_x,
              response_map_x,
              new String[]{endpoint_x,
              'CustomPricing.com/CreateCustomPricingActivities',
              'CustomPricing.com',
              'CreateCustomPricingActivities',
              'CustomPricing.com',
              'CreateCustomPricingActivitiesResponse',
              'custompricing.CreateCustomPricingActivitiesResponse_element'}
            );
            response_x = response_map_x.get('response_x');
            return response_x.CreateCustomPricingActivitiesResult;
        }
    }
}