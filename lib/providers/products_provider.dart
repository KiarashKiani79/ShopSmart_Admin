import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

import '../models/product_model.dart';

class ProductsProvider with ChangeNotifier {
  List<ProductModel> products = [];
  List<ProductModel> get getProducts {
    return products;
  }

// ************************ Firebase ************************
  final productsDb = FirebaseFirestore.instance.collection('products');

// Fetch - FireStore - Future
  Future<List<ProductModel>> fetchProducts() async {
    try {
      await productsDb.get().then((productSnapshot) {
        products.clear();
        for (var element in productSnapshot.docs) {
          products.insert(0, ProductModel.fromFirestore(element));
        }
      });
      notifyListeners();
      return products;
    } catch (e) {
      rethrow;
    }
  }

// Fetch - FireStore - Stream
  Stream<List<ProductModel>> fetchProductsStream() {
    try {
      return productsDb.snapshots().map((snapshot) {
        products.clear();

        for (var element in snapshot.docs) {
          products.insert(0, ProductModel.fromFirestore(element));
        }
        return products;
      });
    } catch (e) {
      rethrow;
    }
  }

// Remove - Firestore
  Future<void> removeProduct({required String productId}) async {
    try {
      await productsDb.doc(productId).delete();
      products.removeWhere((element) => element.productId == productId);
      notifyListeners();
      Fluttertoast.showToast(msg: "Removed successfully");
    } catch (e) {
      rethrow;
    }
  }

// ************************ Localy ************************

// Find By ID
  ProductModel? findByProdId(String productId) {
    if (products.where((element) => element.productId == productId).isEmpty) {
      return null;
    }
    return products.firstWhere((element) => element.productId == productId);
  }

// Find By Category
  List<ProductModel> findByCategory({required String categoryName}) {
    List<ProductModel> categoryList = products
        .where(
          (element) => element.productCategory.toLowerCase().contains(
                categoryName.toLowerCase(),
              ),
        )
        .toList();
    return categoryList;
  }

// Search
  List<ProductModel> searchQuery(
      {required String searchText, required List<ProductModel> passedList}) {
    List<ProductModel> searchList = passedList
        .where(
          (element) => element.productTitle.toLowerCase().contains(
                searchText.toLowerCase(),
              ),
        )
        .toList();
    return searchList;
  }
}
