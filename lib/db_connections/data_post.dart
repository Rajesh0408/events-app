import 'dart:convert';
import 'package:http/http.dart' as http;
Future<bool> postData(String jwt, String e_id,String title, String details, String date, String time, String prize_money, String entry_pass, String image_link ) async {
  print(
      "$e_id , $title , $details, $time , $prize_money, $entry_pass, $image_link, $date");


  Map<String,dynamic> Details={
    'eId': e_id,
    'title': title,
    'details' : details,
    'date': date,
    'time': time,
    'prizeMoney': prize_money,
    'entryPass': entry_pass,
    'imageLink': image_link,

  };
  String jsonData = json.encode(Details);
  http.Response response = await http.post(
    Uri.parse('https://techofes-website-api.onrender.com/api/t77admin/saas-events/enterEvent'), // Replace with your actual API endpoint
    headers: <String, String>{
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $jwt',
    },
    body: jsonData,
  );
  if (response.statusCode == 200) {
    print('Data posted successfully');
    print(response.body);
    return true;
  } else {
    print('Failed to post data. Error ${response.statusCode}: ${response.body}');
    return false;
  }
}
