import 'package:dynamic_height_grid_view/dynamic_height_grid_view.dart';
import 'package:flutter/material.dart';
import 'package:ionicons/ionicons.dart';
import 'package:provider/provider.dart';

import '../consts/theme_data.dart';
import '../models/product_model.dart';
import '../providers/products_provider.dart';
import '../providers/theme_provider.dart';
import '../widgets/product_widget.dart';
import '../widgets/title_text.dart';

class SearchScreen extends StatefulWidget {
  static const routeName = "/search-screen";
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  late TextEditingController searchTextController;
  List<ProductModel> productListSearch = [];
  @override
  void initState() {
    searchTextController = TextEditingController();
    super.initState();
  }

  @override
  void dispose() {
    searchTextController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context, listen: false);
    final productsProvider =
        Provider.of<ProductsProvider>(context, listen: false);

    Map<String, String>? passedCategory =
        ModalRoute.of(context)!.settings.arguments as Map<String, String>?;
    String? passedCategoryName = passedCategory?['name'];

    List<ProductModel> productList = passedCategory == null
        ? productsProvider.products
        : productsProvider.findByCategory(categoryName: passedCategoryName!);
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        appBar: AppBar(
          title:
              TitlesTextWidget(label: passedCategoryName ?? "Search Products"),
          systemOverlayStyle: statusBarTheme(themeProvider),
        ),
        body: StreamBuilder<List<ProductModel>>(
            stream: productsProvider.fetchProductsStream(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(
                  child: CircularProgressIndicator(),
                );
              } else if (snapshot.hasError) {
                return Center(
                  child: SelectableText(snapshot.error.toString()),
                );
              } else if (snapshot.data == null) {
                return const Center(
                  child: FittedBox(
                    child: Column(
                      children: [
                        TitlesTextWidget(
                            label: "No products has been added", fontSize: 22),
                        Icon(
                          Ionicons.sad_outline,
                          size: 28,
                        ),
                      ],
                    ),
                  ),
                );
              }
              return Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  children: [
                    TextField(
                      controller: searchTextController,
                      decoration: InputDecoration(
                        filled: true,
                        hintText: "Search",
                        prefixIcon: const Icon(Icons.search),
                        suffixIcon: GestureDetector(
                            onTap: () {
                              searchTextController.clear();
                              FocusScope.of(context).unfocus();
                            },
                            child: const Icon(Icons.clear)),
                        border: const OutlineInputBorder(
                          borderSide: BorderSide.none,
                          borderRadius: BorderRadius.all(
                            Radius.circular(20.0),
                          ),
                        ),
                      ),
                      // onChanged: (value) {
                      //   setState(() {
                      //     productListSearch = productsProvider.searchQuery(
                      //         searchText: searchTextController.text,
                      //         passedList: productList);
                      //   });
                      // },
                      onSubmitted: (value) {
                        setState(() {
                          productListSearch = productsProvider.searchQuery(
                              searchText: searchTextController.text,
                              passedList: productList);
                        });
                      },
                    ),
                    const SizedBox(
                      height: 15.0,
                    ),
                    if (searchTextController.text.isNotEmpty &&
                        productListSearch.isEmpty) ...[
                      const Center(
                        child: FittedBox(
                          child: Column(
                            children: [
                              TitlesTextWidget(
                                  label: "No Product Found", fontSize: 22),
                              Icon(
                                Ionicons.sad_outline,
                                size: 28,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                    Expanded(
                      child: DynamicHeightGridView(
                        itemCount: searchTextController.text.isNotEmpty
                            ? productListSearch.length
                            : productList.length,
                        crossAxisCount: 2,
                        mainAxisSpacing: 12,
                        crossAxisSpacing: 12,
                        builder: (context, index) {
                          return ProductWidget(
                            productId: searchTextController.text.isNotEmpty
                                ? productListSearch[index].productId
                                : productList[index].productId,
                          );
                        },
                      ),
                    )
                  ],
                ),
              );
            }),
      ),
    );
  }
}
