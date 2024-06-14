public class LandLEventCertificateController {
    
    public String StandardBodyName { get; set; }
    public String AttendeeName { get; set; }
    public String StandardBodyRegistrationNumber { get; set; }
    public String Coursecredit { get; set; }
    public String DateCompleted { get; set; }
    public String CourseName { get; set; }
    public String CourseNumber { get; set; }
    public String ProviderName { get; set; }
    public String ProviderNumber { get; set; }
    public String ContactInfo { get; set; }
    public String OwnerName { get; set; }
    public String StandardBodyLogo { get; set; }
    public String ProviderLogo { get; set; }
    public ImageInfo StandardBodyLogoInfo { get; set; }
    public ImageInfo ProviderLogoInfo { get; set; }
    
    public LandLEventCertificateController() {
        StandardBodyName = ApexPages.currentPage().getParameters().get('StandardBodyName');
        AttendeeName = ApexPages.currentPage().getParameters().get('AttendeeName');
        StandardBodyRegistrationNumber =ApexPages.currentPage().getParameters().get('StandardBodyRegistrationNumber');
        Coursecredit =ApexPages.currentPage().getParameters().get('Coursecredit');
        DateCompleted=ApexPages.currentPage().getParameters().get('DateCompleted');
        CourseName=ApexPages.currentPage().getParameters().get('CourseName');
        CourseNumber=ApexPages.currentPage().getParameters().get('CourseNumber');
        ProviderName=ApexPages.currentPage().getParameters().get('ProviderName');
        ProviderNumber=ApexPages.currentPage().getParameters().get('ProviderNumber');
        ContactInfo=ApexPages.currentPage().getParameters().get('ContactInfo');
        OwnerName=ApexPages.currentPage().getParameters().get('OwnerName');
        StandardBodyLogo = ApexPages.currentPage().getParameters().get('StandardBodyLogo');
        ProviderLogo = ApexPages.currentPage().getParameters().get('ProviderLogo');
        
        if(StandardBodyRegistrationNumber == null)
            StandardBodyRegistrationNumber = '-';
        
        StandardBodyLogoInfo = getImageSize(StandardBodyLogo);
        ProviderLogoInfo = getImageSize(ProviderLogo);
        
        system.debug('StandardBodyLogoInfo'+StandardBodyLogoInfo);
        system.debug('ProviderLogoInfo'+ProviderLogoInfo);
        
        if(StandardBodyLogoInfo.success){
            if(StandardBodyLogoInfo.width == StandardBodyLogoInfo.height){
                StandardBodyLogoInfo.width =100;
                StandardBodyLogoInfo.height = 100;
            }
            else{
                double ratio = StandardBodyLogoInfo.width/100.00;
                StandardBodyLogoInfo.width = Integer.valueOf(StandardBodyLogoInfo.width/ratio);
                StandardBodyLogoInfo.height = Integer.valueOf(StandardBodyLogoInfo.height/ratio);
            }
        }
        
        if(ProviderLogoInfo.success){
            if(ProviderLogoInfo.width == ProviderLogoInfo.height){
                ProviderLogoInfo.width =100;
                ProviderLogoInfo.height = 100;
            }
            else{
                double ratio = ProviderLogoInfo.width/100.00;
                ProviderLogoInfo.width = Integer.valueOf(ProviderLogoInfo.width/ratio);
                ProviderLogoInfo.height = Integer.valueOf(ProviderLogoInfo.height/ratio);
            }
        }
        
        system.debug('StandardBodyLogoInfo'+StandardBodyLogoInfo);
        system.debug('ProviderLogoInfo'+ProviderLogoInfo);
    }
    
    
    public static ImageInfo getImageSize(string url) {
        ImageInfo imginfo = new ImageInfo();
        imginfo.success = false;
        imginfo.width = 0;
        imginfo.height = 0;
        imginfo.url = url;
        if(url != null){
            pagereference page = new pagereference(url);
            Blob imgdata ;
            if(test.isRunningTest()){
                imgdata = Blob.valueOf('test');
            }
            else{
                imgdata = page.getContent();
            }
            // Can't substring a blob, have to do the ugly and double the size as a hex string
            // When parsing the hex string, all offsets must be doubled, requiring *2 below
            string imgstring = EncodingUtil.convertToHex(imgdata);
            imginfo.format = 'UNKNOWN "' + imgstring.substring(0,16) + '"';
            
            if (imgstring.substring(0,8) == '89504e47') {
                // PNG
                imginfo.success = true;
                imginfo.format = 'PNG';
                imginfo.width = hexToInt(imgstring.substring(16*2,20*2));
                imginfo.height = hexToInt(imgstring.substring(20*2,24*2));
            } else if (imgstring.substring(0,4) == 'ffd8') {
                // JPEG
                // Might need a lot of the imgstring, but don't want to pass it by value
                // due to limited heap space.  Instead, just parse it all here.
                imginfo.format = 'JPEG';
                imginfo.width = 0;
                imginfo.height = 0;
                imginfo.success = false;
                integer offset = 2 *2; // Skip past the SOI marker that we already found
                while (offset < imgstring.length()) {
                    if (imgstring.substring(offset, offset+3) == 'ffc') { // SOFn
                        imginfo.success = true;
                        imginfo.height = hexToInt(imgstring.substring(offset+5*2, offset+7*2));
                        imginfo.width = hexToInt(imgstring.substring(offset+7*2, offset+9*2));
                        break;
                    } else if (imgstring.substring(offset, offset+2*2) == 'ffd8' // SOI (may appear after thumbnail)
                               || imgstring.substring(offset, offset+2*2) == 'ffd9' // EOF (maybe end of thumbnail, keep going)
                              ) {
                                  offset += 2 *2;
                              } else if (imgstring.substring(offset, offset+2) == 'ff') {
                                  // Most blocks are variable length, find the length and skip it
                                  integer blocklen = hexToInt(imgstring.substring(offset+4, offset+8));
                                  offset += (blocklen+2) * 2;
                              } else { // Not a header, either bad data or bad parsing, stop reading.
                                  break;
                              }
                }
            } else if (imgstring.substring(0, 8) == '47494638') {
                // GIF
                imginfo.success = true;
                imginfo.format = 'GIF';
                imginfo.width  = hexToInt(imgstring.substring(7*2,  8*2) + imgstring.substring(6*2, 7*2));
                imginfo.height = hexToInt(imgstring.substring(9*2, 10*2) + imgstring.substring(8*2, 9*2));
            } else if (imgstring.substring(0, 8) == '52494646' && imgstring.substring(16,24) == '57454250') {
                // WebP
                integer offset = 12*2; // Skip past the RIFF header and WEBP identifier (already matched above)
                imginfo.format = 'WebP';
                while (offset < imgstring.length()) {
                    string chunk = imgstring.substring(offset, offset + 4*2);
                    offset += 4*2;
                    if (chunk == '56503820') {
                        // "VP8 " - lossy
                        imginfo.success = true;
                        // 16-bit unsigned, little endian, with 2 bits reserved.
                        imginfo.width  = hexToInt(imgstring.substring(offset+11*2, offset+12*2) + imgstring.substring(offset+10*2, offset+11*2)) & 16383;
                        imginfo.height = hexToInt(imgstring.substring(offset+13*2, offset+14*2) + imgstring.substring(offset+12*2, offset+13*2)) & 16383;
                        break;
                    } else if (chunk == '5650384c') {
                        // "VP8L" - lossless
                        imginfo.success = true;
                        // Horrible: https://developers.google.com/speed/webp/docs/webp_lossless_bitstream_specification
                        imginfo.width  = hexToInt(imgstring.substring(offset+5*2, offset+6*2)) + ((hexToInt(imgstring.substring(offset+6*2, offset+7*2)) & 63) << 8) + 1;
                        imginfo.height = (hexToInt(imgstring.substring(offset+6*2, offset+7*2)) >> 6) + (hexToInt(imgstring.substring(offset+7*2, offset+8*2)) << 2) + ((hexToInt(imgstring.substring(offset+8*2, offset+9*2)) & 15) << 10) + 1;
                        break;
                    } else if (chunk == '414e4d46') {
                        // "ANMF" - don't skip it, find the size of the 1st frame inside
                        offset += 20*2;
                    } else {
                        // Skip all other chunks
                        integer chunklen = hexToInt(imgstring.substring(offset+3*2,offset+4*2) + imgstring.substring(offset+2*2,offset+3*2) + imgstring.substring(offset+1*2,offset+2*2) + imgstring.substring(offset,offset+1*2));
                        offset += (chunklen+4)*2;
                    }
                }
            }
        }
        
        return imginfo;
    }
    
    public static final List<String> hex = '0123456789abcdef'.split('');
    public static Integer hexToInt(String str) {
        str = str.toLowerCase();
        String[] hexValue = str.split('');
        Integer retVal = 0;
        for(Integer i = 0; i < hexValue.size(); i++) {
            retVal = (retVal << 4) + hex.indexOf(hexValue[i]);
        }
        return retVal;
    }
    
    public class ImageInfo {
        public boolean success{ get; set; }
        public string format{ get; set; }
        public integer width{ get; set; }
        public integer height{ get; set; }
        public string url{ get; set; }
    }
}