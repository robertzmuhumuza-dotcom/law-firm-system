import 'dart:io';
import 'package:http/http.dart' as http;
import 'dart:convert';

class CaseService {
  // Replace with your actual local IP address
  final String baseUrl = "http://192.168.1.XX:5000"; 

  Future<Map<String, dynamic>> uploadDocument(File file, String caseId) async {
    try {
      var request = http.MultipartRequest('POST', Uri.parse('$baseUrl/cases/$caseId/upload'));
      request.files.add(await http.MultipartFile.fromPath('document', file.path));
      
      var response = await request.send();
      var responseData = await response.stream.bytesToString();
      
      return {
        "statusCode": response.statusCode,
        "data": json.decode(responseData)
      };
    } catch (e) {
      return {"statusCode": 500, "data": {"error": e.toString()}};
    }
  }
}