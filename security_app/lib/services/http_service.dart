import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:security_app/models/item_model.dart';

class HttpService {
  final String url = "https://webserver-ti5.onrender.com/item";
  //final String url = "https://jsonplaceholder.typicode.com/posts";

  Future<List<Item>> getItems() async {
    final res = await http.get(Uri.parse(url)).timeout(
      const Duration(seconds: 3),
      onTimeout: () {
        // Time has run out, do what you wanted to do.
        return http.Response('Error', 408); // Request Timeout response status code
      },
    );

    if (res.statusCode == 200) {
      List<dynamic> body = jsonDecode(res.body);

      List<Item> items = body
          .map(
            (dynamic item) => Item.fromJson(item),
      )
          .toList();

      return items;
    } else {
      throw "Unable to retrieve posts.";
    }
  }
}