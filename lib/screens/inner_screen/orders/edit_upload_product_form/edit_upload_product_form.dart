import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dotted_border/dotted_border.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import '/consts/theme_data.dart';
import '/screens/dashboard_screen.dart';
import '/screens/loading_manager.dart';
import 'package:uuid/uuid.dart';
import '/providers/theme_provider.dart';
import '/providers/products_provider.dart';
import '/consts/app_constants.dart';
import '/models/product_model.dart';
import '/services/my_app_functions.dart';

import './form_fields.dart';
import '/widgets/title_text.dart';

class EditOrUploadProductScreen extends StatefulWidget {
  static const routeName = '/EditOrUploadProductScreen';

  const EditOrUploadProductScreen({super.key, this.productModel});
  final ProductModel? productModel;
  @override
  State<EditOrUploadProductScreen> createState() =>
      _EditOrUploadProductScreenState();
}

class _EditOrUploadProductScreenState extends State<EditOrUploadProductScreen> {
  final _formKey = GlobalKey<FormState>();
  XFile? _pickedImage;
  late TextEditingController _titleController,
      _priceController,
      _descriptionController,
      _quantityController;
  String? _categoryValue;
  String? productNetworkImage;
  String? productImageUrl;
  bool isEditing = false;
  bool isLoading = false;
  @override
  void initState() {
    if (widget.productModel != null) {
      isEditing = true;
      productNetworkImage = widget.productModel!.productImage;
      _categoryValue = widget.productModel!.productCategory;
    }
    _titleController =
        TextEditingController(text: widget.productModel?.productTitle);
    _priceController =
        TextEditingController(text: widget.productModel?.productPrice);
    _descriptionController =
        TextEditingController(text: widget.productModel?.productDescription);
    _quantityController =
        TextEditingController(text: widget.productModel?.productQuantity);

    super.initState();
  }

  @override
  void dispose() {
    _titleController.dispose();
    _priceController.dispose();
    _descriptionController.dispose();
    _quantityController.dispose();
    super.dispose();
  }

  void clearForm() {
    _titleController.clear();
    _priceController.clear();
    _descriptionController.clear();
    _quantityController.clear();
    removePickedImage();
  }

  void removePickedImage() {
    setState(() {
      _pickedImage = null;
      productNetworkImage = null;
    });
  }

// Upload Product
  Future<void> _uploadProduct() async {
    final isValid = _formKey.currentState!.validate();
    FocusScope.of(context).unfocus();

    if (_pickedImage == null) {
      MyAppFunctions.showErrorOrWarningDialog(
          context: context,
          subtitle: "Please upload an image for your account.",
          fct: () {});
      return;
    }

    if (isValid) {
      try {
        setState(() {
          isLoading = true;
        });
        final newProductId = const Uuid().v4();
        final ref = FirebaseStorage.instance
            .ref()
            .child("productsImages")
            .child("${'${_titleController.text}----$newProductId'}.jpg");
        await ref.putFile(File(_pickedImage!.path));
        productImageUrl = await ref.getDownloadURL();
        await FirebaseFirestore.instance
            .collection("products")
            .doc(newProductId)
            .set({
          'productId': newProductId,
          'productTitle': _titleController.text,
          'productPrice': _priceController.text,
          'productCategory': _categoryValue,
          'productDescription': _descriptionController.text,
          'productImage': productImageUrl,
          'productQuantity': _quantityController.text,
          'createdAt': Timestamp.now(),
        });
        Fluttertoast.showToast(
          msg: "Product uploaded successfully!",
          backgroundColor: Colors.blue,
        );
        if (!mounted) return;
        Navigator.pushReplacementNamed(context, DashboardScreen.routeName);
      } on FirebaseException catch (error) {
        await MyAppFunctions.showErrorOrWarningDialog(
            context: context, subtitle: error.message.toString(), fct: () {});
      } catch (error) {
        await MyAppFunctions.showErrorOrWarningDialog(
            context: context, subtitle: error.toString(), fct: () {});
      } finally {
        isLoading = false;
      }
    }
  }

// Edit Product
  Future<void> _editProduct() async {
    final isValid = _formKey.currentState!.validate();
    FocusScope.of(context).unfocus();

    if (_pickedImage == null && productNetworkImage == null) {
      MyAppFunctions.showErrorOrWarningDialog(
        context: context,
        subtitle: "Please pick up an image",
        fct: () {},
      );
      return;
    }

    if (isValid) {
      try {
        setState(() {
          isLoading = true;
        });

        if (_pickedImage != null) {
          final ref = FirebaseStorage.instance
              .ref()
              .child("productsImages")
              .child("${widget.productModel!.productId}.jpg");
          await ref.putFile(File(_pickedImage!.path));
          productImageUrl = await ref.getDownloadURL();
        }

        await FirebaseFirestore.instance
            .collection("products")
            .doc(widget.productModel!.productId)
            .update({
          'productId': widget.productModel!.productId,
          'productTitle': _titleController.text,
          'productPrice': _priceController.text,
          'productCategory': _categoryValue,
          'productDescription': _descriptionController.text,
          'productImage': productImageUrl ?? productNetworkImage,
          'productQuantity': _quantityController.text,
          'createdAt': widget.productModel!.createdAt,
        });
        Fluttertoast.showToast(
          msg: "Product edited successfully!",
          backgroundColor: Colors.green,
        );
        if (!mounted) return;
        Navigator.pushReplacementNamed(context, DashboardScreen.routeName);
      } on FirebaseException catch (error) {
        await MyAppFunctions.showErrorOrWarningDialog(
            context: context, subtitle: error.message.toString(), fct: () {});
      } catch (error) {
        await MyAppFunctions.showErrorOrWarningDialog(
            context: context, subtitle: error.toString(), fct: () {});
      } finally {
        isLoading = false;
      }
    }
  }

  Future<void> localImagePicker() async {
    final ImagePicker picker = ImagePicker();
    await MyAppFunctions.imagePickerDialog(
      context: context,
      cameraFCT: () async {
        _pickedImage = await picker.pickImage(source: ImageSource.camera);
        setState(() {});
      },
      galleryFCT: () async {
        _pickedImage = await picker.pickImage(source: ImageSource.gallery);
        setState(() {});
      },
      removeFCT: () {
        setState(() {
          _pickedImage = null;
        });
      },
    );
  }

// ********************** Build **********************
  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final themeProvider = Provider.of<ThemeProvider>(context);
    final productProvider = Provider.of<ProductsProvider>(context);
    return LoadingManager(
      isLoading: isLoading,
      child: GestureDetector(
        onTap: () {
          FocusScope.of(context).unfocus();
        },
        child: Scaffold(
          bottomSheet: bottomSheet(context, themeProvider),
          appBar: AppBar(
            centerTitle: true,
            title: TitlesTextWidget(
              label: isEditing ? "Edit Product" : "Upload a new product",
            ),
            systemOverlayStyle: statusBarTheme(themeProvider),
          ),
          body: SingleChildScrollView(
            child: Column(
              children: [
                const SizedBox(
                  height: 20,
                ),

                // Image Picker
                // Upload ImageUrl from Network
                if (isEditing && productNetworkImage != null) ...[
                  ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.network(
                      productNetworkImage!,
                      height: size.width * 0.5,
                      alignment: Alignment.center,
                      fit: BoxFit.cover,
                    ),
                  ),
                ] else if (_pickedImage == null) ...[
                  // No image picked
                  SizedBox(
                    width: size.width * 0.4 + 10,
                    height: size.width * 0.4,
                    child: GestureDetector(
                      onTap: () => localImagePicker(),
                      child: DottedBorder(
                        borderType: BorderType.RRect,
                        radius: const Radius.circular(20),
                        color: Theme.of(context).colorScheme.primary,
                        child: Center(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              Icon(
                                Icons.image_outlined,
                                size: 80,
                                color: Theme.of(context).colorScheme.primary,
                              ),
                              const Text("Pick Product Image"),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ] else ...[
                  // Image picked from gallary or camera
                  ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.file(
                      File(
                        _pickedImage!.path,
                      ),
                      height: size.width * 0.5,
                      alignment: Alignment.center,
                    ),
                  ),
                ],
                if (_pickedImage != null || productNetworkImage != null) ...[
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      TextButton(
                        onPressed: () {
                          removePickedImage();
                        },
                        child: const Text(
                          "Remove image",
                          style: TextStyle(color: Colors.red),
                        ),
                      ),
                      TextButton(
                        onPressed: () {
                          localImagePicker();
                        },
                        child: const Text("Pick another image"),
                      ),
                    ],
                  )
                ],

                const SizedBox(height: 25),

                SizedBox(
                  width: size.width * 0.5,
                  child: DropdownButtonFormField<String>(
                    decoration: InputDecoration(
                      // filled: true,
                      labelText: "Choose a Category",
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(50.0),
                      ),
                    ),
                    value: _categoryValue,
                    items: AppConstants.categoriesDropDownList,
                    onChanged: (String? value) {
                      setState(() {
                        _categoryValue = value;
                      });
                    },
                  ),
                ),

                const SizedBox(height: 25),

                // Form Fields
                Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 0),
                  child: FormFields(
                    formKey: _formKey,
                    titleController: _titleController,
                    priceController: _priceController,
                    quantityController: _quantityController,
                    descriptionController: _descriptionController,
                  ),
                ),

                const SizedBox(height: 25),
                isEditing
                    ? ElevatedButton.icon(
                        icon: const Icon(Icons.delete),
                        label: const Text("Delete The Product"),
                        style: ButtonStyle(
                          backgroundColor:
                              MaterialStateProperty.all<Color>(Colors.red),
                          foregroundColor: MaterialStateProperty.all<Color>(
                            themeProvider.getIsDarkTheme
                                ? Colors.black
                                : Colors.white,
                          ),
                        ),
                        onPressed: () {
                          MyAppFunctions.showErrorOrWarningDialog(
                            isError: false,
                            context: context,
                            subtitle: "Delete the product permanently?",
                            buttonText: "Delete",
                            fct: () async {
                              productProvider
                                  .removeProduct(
                                      productId: widget.productModel!.productId)
                                  .then(
                                    (value) => Navigator.pushReplacementNamed(
                                        context, DashboardScreen.routeName),
                                  );
                            },
                          );
                        },
                      )
                    : Container(),

                const SizedBox(height: kBottomNavigationBarHeight + 10),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // BUTTONS
  bottomSheet(BuildContext context, ThemeProvider themeProvider) {
    return SizedBox(
      height: kBottomNavigationBarHeight + 10,
      child: Material(
        color: Theme.of(context).scaffoldBackgroundColor,
        child: Row(
          children: [
            Flexible(
              flex: 1,
              fit: FlexFit.tight,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8.0),
                child: OutlinedButton.icon(
                  style: ButtonStyle(
                    padding:
                        MaterialStateProperty.all(const EdgeInsets.all(12)),
                  ),
                  icon: const Icon(
                    Icons.clear_rounded,
                  ),
                  label: const Text(
                    "Clear",
                    style: TextStyle(
                      fontSize: 20,
                    ),
                  ),
                  onPressed: () {
                    clearForm();
                  },
                ),
              ),
            ),
            Flexible(
              flex: 2,
              fit: FlexFit.tight,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8.0),
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.all(12),
                    backgroundColor: Theme.of(context).colorScheme.primary,
                    elevation: 4,
                  ),
                  icon: Icon(
                    Icons.upload,
                    color: themeProvider.getIsDarkTheme
                        ? Colors.black
                        : Colors.white,
                  ),
                  label: Text(
                    isEditing ? "Edit Product" : "Upload Product",
                    style: TextStyle(
                      fontSize: 20,
                      color: themeProvider.getIsDarkTheme
                          ? Colors.black
                          : Colors.white,
                    ),
                  ),
                  onPressed: () {
                    if (isEditing) {
                      _editProduct();
                    } else {
                      _uploadProduct();
                    }
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
