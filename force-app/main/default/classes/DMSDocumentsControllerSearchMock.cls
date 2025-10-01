@isTest
global class DMSDocumentsControllerSearchMock implements HttpCalloutMock{
    
    global HTTPResponse respond(HTTPRequest request){
        HttpResponse response = new HttpResponse();
        response.setHeader('Content-Type', 'application/json');
        response.setBody('[{"error": "N","error_msg": "Search Successfully","status": "OK","dealRoom_id": "1","im_id": "7","imv_id": "5056","auto_inc_no": "","third_party_id": "","imfName": ["SALES ORDER NUMBER"],"ivalue_status": "IM : search","master_value_details": {"SALES ORDER NUMBER": "945800004","CUSTOMER CODE": "101","UNIT NO": "TB-904","CUSTOMER NAME": "Mr. MAHESH GAIKWAD","COMPANY CODE": "2001","WING/TOWER": "WING A","PROJECT NAME": "BLISS"},"uploadedDocuments": {"error": "N","error_msg": " ","status": "OK","dealRoom_id": "1","document_details": [{"error": "N","error_msg": "","primary_doc_id": "O%2Fz0wsNbAtGSjuyMVdfFv%2BgAAA%3D%3D","doc_id": "2.2.1.3","document_name": "test_file9.pdf","docSetName": "CRM Documents Type=KYC", "doc_preview_uri": "https://dms.runwalgroup.in/runwal_dms/API/ws_preview_document.php?doc_id=O%2Fz0wsNbAtGSjuyMVdfFv%2BgAAA%3D%3D", "doc_download_uri":"https://dms.runwalgroup.in/runwal_dms/API/ws_download_document.php?doc_id=O%2Fz0wsNbAtGSjuyMVdfFv%2BgAAA%3D%3D"},{"error": "N","error_msg": "","primary_doc_id": "09hycMesD6oeRQK1PHpMTT4A","doc_id": "2.2.1.4","document_name": "test_file10.pdf","docSetName": "CRM Documents Type=APPLICATION FORM","doc_preview_uri":"https://dms.runwalgroup.in/runwal_dms/API/ws_preview_document.php?doc_id=09hycMesD6oeRQK1PHpMTT4A","doc_download_uri": "https://dms.runwalgroup.in/runwal_dms/API/ws_download_document.php?doc_id=09hycMesD6oeRQK1PHpMTT4A"}]}}]');
        response.setStatusCode(200);
        return response; 
    }
    
    

}