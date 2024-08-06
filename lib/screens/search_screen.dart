import 'dart:async';
import 'package:dynamic_height_grid_view/dynamic_height_grid_view.dart';
import 'package:e_commerce_admin/models/product_model.dart';
import 'package:e_commerce_admin/providers/product_provider.dart';
import 'package:e_commerce_admin/widgets/product_widget.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class SearchScreen extends StatefulWidget {
  static const routeName = '/SearchScreen';
  const SearchScreen({super.key});
  static String id = "Search_Screen";

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  late TextEditingController searchTextController;
  List<ProductModel> productListSearch = [];
  late List<ProductModel> productList;
  late ProductProvider productProvider;
  late Timer _debounce;

  @override
  void initState() {
    super.initState();
    searchTextController = TextEditingController();
    _debounce = Timer(const Duration(milliseconds: 300), () {});
  }

  @override
  void dispose() {
    searchTextController.dispose();
    _debounce.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final productProvider = Provider.of<ProductProvider>(context);
    String? passedCategory =
        ModalRoute.of(context)!.settings.arguments as String?;
    productList = passedCategory == null
        ? productProvider.getProducts
        : productProvider.findByCategory(categoryName: passedCategory);

    return Scaffold(
      appBar: AppBar(
        title: Text(passedCategory ?? "Search"),
        centerTitle: true,
        leading: Image.asset("assets/images/appbar_icon.png"),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8.0),
        child: Column(
          children: [
            const SizedBox(height: 4),
            TextField(
              onChanged: (value) {
                setState(() {
                  productListSearch = productProvider.searchQuery(
                    searchText: searchTextController.text,
                    passedList: productList,
                  );
                });
              },
              onSubmitted: (value) {
                setState(() {
                  productListSearch = productProvider.searchQuery(
                    searchText: searchTextController.text,
                    passedList: productList,
                  );
                });
              },
              controller: searchTextController,
              decoration: InputDecoration(
                enabledBorder: UnderlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide(color: Colors.grey.shade500, width: 2),
                ),
                fillColor: Theme.of(context).scaffoldBackgroundColor,
                hintText: "Search",
                prefixIcon: const Icon(Icons.search),
                suffixIcon: GestureDetector(
                  child: const Icon(Icons.clear),
                  onTap: () {
                    searchTextController.clear();
                    FocusScope.of(context).unfocus();
                    setState(() {
                      productListSearch = [];
                    });
                  },
                ),
              ),
            ),
            const SizedBox(height: 10),
            Expanded(
              child: StreamBuilder<List<ProductModel>>(
                stream: productProvider.fetchProductsStream(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  } else if (snapshot.hasError) {
                    return Center(
                        child: Text(snapshot.error.toString(),
                            style: const TextStyle(fontSize: 15)));
                  } else if (!snapshot.hasData) {
                    return const Center(
                        child: Text("No products found",
                            style: TextStyle(fontSize: 24)));
                  }

                  final products = searchTextController.text.isNotEmpty
                      ? productListSearch
                      : snapshot.data!;

                  return DynamicHeightGridView(
                      builder: (context, index) {
                        return ProductWidget(
                          productId: searchTextController.text.isNotEmpty
                              ? productListSearch[index].productId
                              : productList[index].productId,
                        );
                      },
                      itemCount: searchTextController.text.isNotEmpty
                          ? productListSearch.length
                          : productList.length,
                      crossAxisCount: 2);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
