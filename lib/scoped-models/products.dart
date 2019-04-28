import 'dart:convert';

import 'package:http/http.dart' as http;

import './connected_product.dart';
import '../models/product.dart';

mixin ProductsModel on ConnectedProducts {
  bool _showFavorites = false;
  bool _isLoading = false;

  List<Product> get allProducts {
    return List.from(products);
  }

  List<Product> get displayedProducts {
    if (_showFavorites) {
      return List.from(
          products.where((Product product) => product.isFavourite).toList());
    }
    return List.from(products);
  }

  int get selectedProductIndex {
    return selProductIndex;
  }

  bool get displayFavoritesOnly {
    return _showFavorites;
  }

  Product get selectedProduct {
    if (selectedProductIndex == null) {
      return null;
    }
    return products[selectedProductIndex];
  }

  void updateProducts(
      String title, String description, String image, double price) {
    final Product updatedProduct = Product(
        title: title,
        description: description,
        price: price,
        image: image,
        userEmail: selectedProduct.userEmail,
        userId: selectedProduct.userId);
    products[selectedProductIndex] = updatedProduct;
    notifyListeners();
  }

  void deleteProduct() {
    products.removeAt(selectedProductIndex);

    notifyListeners();
  }

  void selectProduct(int index) {
    selProductIndex = index;
  }

  void toggleProductFavouriteStatus() {
    final bool isCurrentlyFavourite =
        products[selectedProductIndex].isFavourite;
    final bool newFavouriteStatus = !isCurrentlyFavourite;
    final Product updatedProduct = Product(
        title: selectedProduct.title,
        description: selectedProduct.description,
        price: selectedProduct.price,
        image: selectedProduct.image,
        userEmail: selectedProduct.userEmail,
        userId: selectedProduct.userId,
        isFavourite: newFavouriteStatus);
    products[selectedProductIndex] = updatedProduct;
    selProductIndex = null;
    notifyListeners();
  }

  void toggleDisplayMode() {
    _showFavorites = !_showFavorites;
    notifyListeners();
  }

  void fetchProducts() {
    _isLoading = true;
    http
        .get('https://new-firebase-82fdf.firebaseio.com/products.json')
        .then((http.Response response) {
      final List<Product> fetchedProductList = [];
      final Map<String, dynamic> productListData = json.decode(response.body);
      productListData.forEach((String productId, dynamic productData) {
        final Product product = Product(
            id: productId,
            title: productData['title'],
            description: productData['description'],
            price: productData['price'],
            image: productData['image'],
            userEmail: productData['userEmail'],
            userId: productData['userId']);
        fetchedProductList.add(product);
      });
      products = fetchedProductList;
      _isLoading = false;
      notifyListeners();
    });
  }
}
