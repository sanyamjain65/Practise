import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:scoped_model/scoped_model.dart';

import '../models/product.dart';
import '../models/user.dart';

mixin ConnectedProducts on Model {
  List<Product> products = [];
  User authenticatedUser;
  String selProductId;
  bool _postisLoading = false;

  bool get postIsLoading {
    return _postisLoading;
  }

  Future<bool> addProducts(
      String title, String description, String image, double price) async {
    _postisLoading = true;
    notifyListeners();
    final Map<String, dynamic> productData = {
      'title': title,
      'description': description,
      'image':
          'https://cdn1.harryanddavid.com/wcsstore/HarryAndDavid/images/catalog/18_26468_30J_01ex.jpg',
      'price': price,
      'userEmail': authenticatedUser.email,
      'userId': authenticatedUser.id
    };
    try {
      final http.Response response = await http.post(
          'https://new-firebase-82fdf.firebaseio.com/products.json',
          body: json.encode(productData));
      if (response.statusCode != 200 && response.statusCode != 201) {
        _postisLoading = false;
        notifyListeners();
        return false;
      }
      print(response.statusCode);
      final Map<String, dynamic> responseData = json.decode(response.body);
      print(responseData);
      final Product newProduct = Product(
          id: responseData['name'],
          title: title,
          description: description,
          price: price,
          image: image,
          userEmail: authenticatedUser.email,
          userId: authenticatedUser.id);
      products.add(newProduct);
      _postisLoading = false;
      notifyListeners();
      return true;
    } catch (error) {
      _postisLoading = false;
      notifyListeners();
      return false;
    }
  }
}
