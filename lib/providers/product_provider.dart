import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:e_commerce_admin/models/product_model.dart';
import 'package:flutter/material.dart';

class ProductProvider with ChangeNotifier {
  final List<ProductModel> products = [];
  List<ProductModel> get getProducts {
    return products;
  }

  ProductModel? findByProdId(String productId) {
    if (products.where((element) => element.productId == productId).isEmpty) {
      return null;
    }
    return products.firstWhere(
      (element) => element.productId == productId,
    );
  }

  List<ProductModel> findByCategory({
    required String categoryName,
  }) {
    List<ProductModel> categoryList = products
        .where((element) => element.productCategory
            .toLowerCase()
            .contains(categoryName.toLowerCase()))
        .toList();
    return categoryList;
  }

  List<ProductModel> searchQuery(
      {required String searchText, required List<ProductModel> passedList}) {
    List<ProductModel> searchList = passedList
        .where((element) => element.productTitle
            .toLowerCase()
            .contains(searchText.toLowerCase()))
        .toList();
    return searchList;
  }

//get products from firebase
  final productDB = FirebaseFirestore.instance.collection("products");
  Future<List<ProductModel>> fetchProducta() async {
    try {
      await productDB.get().then(
        (productsSnapShot) {
          products.clear();
          for (var element in productsSnapShot.docs) {
            products.insert(
              0,
              ProductModel.formFirebase(element),
            );
          }
        },
      );
      notifyListeners();
      return products;
    } catch (error) {
      rethrow;
    }
  }
//get products from firebase

  Stream<List<ProductModel>> fetchProductsStream() {
    try {
      return productDB.snapshots().map((snapShot) {
        products.clear();
        for (var element in snapShot.docs) {
          products.insert(
            0,
            ProductModel.formFirebase(element),
          );
        }
        return products;
      });
    } catch (error) {
      rethrow;
    }
  }
}
