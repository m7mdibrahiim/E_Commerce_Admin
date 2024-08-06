import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dotted_border/dotted_border.dart';
import 'package:e_commerce_admin/consts/app_constants.dart';
import 'package:e_commerce_admin/helper/dialog_utils.dart';
import 'package:e_commerce_admin/helper/my_validator.dart';
import 'package:e_commerce_admin/models/product_model.dart';
import 'package:e_commerce_admin/services/my_app_method.dart';
import 'package:e_commerce_admin/widgets/title_text.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:image_picker/image_picker.dart';
import 'package:uuid/uuid.dart';

class EditUploadProductForm extends StatefulWidget {
  EditUploadProductForm({
    super.key,
    this.productModel,
  });
  static const routeName = "EditUploadProductForm";
  final ProductModel? productModel;

  @override
  State<EditUploadProductForm> createState() => _EditUploadProductFormState();
}

class _EditUploadProductFormState extends State<EditUploadProductForm> {
  final formKey = GlobalKey<FormState>();

  late TextEditingController titleController,
      priceController,
      descriptionController,
      quantityController;
  bool isLoading = false;
  String? categoryValue;
  XFile? _pickedImage;
  bool isEditing = false;
  String? productNetworkImage;
  String? productImageUrl;

  void initState() {
    if (widget.productModel != null) {
      isEditing = true;
      productNetworkImage = widget.productModel!.productImage;
      categoryValue = widget.productModel!.productCategory;
    }
    titleController =
        TextEditingController(text: widget.productModel?.productTitle);
    priceController =
        TextEditingController(text: widget.productModel?.productPrice);
    descriptionController =
        TextEditingController(text: widget.productModel?.productDescription);
    quantityController =
        TextEditingController(text: widget.productModel?.productQuantity);

    super.initState();
  }

  @override
  void dispose() {
    titleController.dispose();
    priceController.dispose();
    descriptionController.dispose();
    quantityController.dispose();
    super.dispose();
  }

  void clearForm() {
    titleController.clear();
    priceController.clear();
    quantityController.clear();
    descriptionController.clear();
    removePickedImage();
  }

// upload product to firebase
  Future<void> uploadFct() async {
    final isValid = formKey.currentState!.validate();
    FocusScope.of(context).unfocus();

    if (isValid) {
      formKey.currentState!.save();
      if (_pickedImage == null) {
        DialogUtils.showLoadingDialog(
          context,
          "make sure to upload your image",
          Icons.warning,
          true,
          () {
            Navigator.pop(context);
          },
        );
        return;
      }
      if (categoryValue == null) {
        DialogUtils.showLoadingDialog(
          context,
          "Category is empty",
          Icons.warning,
          true,
          () {
            Navigator.pop(context);
          },
        );
        return;
      }

      try {
        setState(() {
          isLoading = true;
        });
        final productId = Uuid().v4();

        final ref = FirebaseStorage.instance.ref().child("productImages").child(
              "$productId.jpg",
            );
        await ref.putFile(
          File(_pickedImage!.path),
        );
        productImageUrl = await ref.getDownloadURL();

        await FirebaseFirestore.instance
            .collection("products")
            .doc(productId)
            .set({
          'productId': productId,
          'productTitle': titleController.text,
          'productPrice': priceController.text,
          'productCategory': categoryValue,
          'productDescription': descriptionController.text,
          'productImage': productImageUrl,
          'productQuantity': quantityController.text,
          'createdAt': Timestamp.now(),
        });

        Fluttertoast.showToast(
            msg: "product has been added 👌",
            toastLength: Toast.LENGTH_SHORT,
            gravity: ToastGravity.CENTER,
            timeInSecForIosWeb: 1,
            backgroundColor: Color.fromARGB(255, 48, 217, 255),
            textColor: Colors.black,
            fontSize: 16.0);
        await MyAppMethods.showErrorORWarningDialog(
          isError: false,
          context: context,
          subtitle: "Clear form?",
          fct: () {
            clearForm();
          },
        );
      } on FirebaseException catch (error) {
        await DialogUtils.showLoadingDialog(
            context, "there is an error..  ${error.message}", Icons.error, true,
            () {
          Navigator.pop(context);
        });
      } catch (error) {
        await DialogUtils.showLoadingDialog(
            context, "there is an error.cc.  ${error}", Icons.error, true, () {
          Navigator.pop(context);
        });
      } finally {
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  Future<void> editProduct() async {
    final isValid = formKey.currentState!.validate();
    FocusScope.of(context).unfocus();

    if (isValid) {
      formKey.currentState!.save();
      if (_pickedImage == null && productNetworkImage == null) {
        MyAppMethods.showErrorORWarningDialog(
          context: context,
          subtitle: "Please upload an image",
          fct: () {},
        );
        return;
      }

      if (categoryValue == null) {
        DialogUtils.showLoadingDialog(
          context,
          "Category is empty",
          Icons.warning,
          true,
          () {
            Navigator.pop(context);
          },
        );
        return;
      }

      try {
        setState(() {
          isLoading = true;
        });
        if (_pickedImage != null) {
          final ref =
              FirebaseStorage.instance.ref().child("productImages").child(
                    "${widget.productModel!.productId}.jpg",
                  );
          await ref.putFile(
            File(_pickedImage!.path),
          );
          productImageUrl = await ref.getDownloadURL();
        }

        ;
        await FirebaseFirestore.instance
            .collection("products")
            .doc(widget.productModel!.productId)
            .update({
          'productId': widget.productModel!.productId,
          'productTitle': titleController.text,
          'productPrice': priceController.text,
          'productCategory': categoryValue,
          'productDescription': descriptionController.text,
          'productImage': productImageUrl ?? productNetworkImage,
          'productQuantity': quantityController.text,
          'createdAt': widget.productModel!.createdAt,
        });

        Fluttertoast.showToast(
            msg: "product has been edited ",
            toastLength: Toast.LENGTH_SHORT,
            gravity: ToastGravity.CENTER,
            timeInSecForIosWeb: 1,
            backgroundColor: const Color.fromARGB(255, 48, 217, 255),
            textColor: Colors.black,
            fontSize: 16.0);
        if (!mounted) return;
      } on FirebaseException catch (error) {
        await DialogUtils.showLoadingDialog(
            context, "there is an error..  ${error.message}", Icons.error, true,
            () {
          Navigator.pop(context);
        });
      } catch (error) {
        await DialogUtils.showLoadingDialog(
            context, "there is an error.cc.  ${error}", Icons.error, true, () {
          Navigator.pop(context);
        });
      } finally {
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  Future<void> localImagePicker() async {
    final ImagePicker picker = ImagePicker();
    await MyAppMethods.imagePickerDialog(
      context: context,
      cameraFCT: () async {
        _pickedImage = await picker.pickImage(source: ImageSource.camera);
        setState(() {
          productNetworkImage == null;
        });
      },
      galleryFCT: () async {
        _pickedImage = await picker.pickImage(source: ImageSource.gallery);
        setState(() {
          productNetworkImage == null;
        });
      },
      removeFCT: () {
        setState(() {
          _pickedImage = null;
        });
      },
    );
  }

  void removePickedImage() {
    setState(() {
      _pickedImage = null;
      productNetworkImage = null;
    });
  }

  @override
  @override
  Widget build(BuildContext context) {
    return Form(
      key: formKey,
      child: GestureDetector(
        onTap: () {
          FocusScope.of(context).unfocus();
        },
        child: Scaffold(
          bottomSheet: SizedBox(
            height: kBottomNavigationBarHeight + 10,
            child: Material(
              color: Theme.of(context).scaffoldBackgroundColor,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.all(12),
                      backgroundColor: Colors.red,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(
                          10,
                        ),
                      ),
                    ),
                    icon: const Icon(
                      Icons.clear,
                      color: Colors.black,
                    ),
                    label: const Text(
                      "Clear",
                      style: TextStyle(
                        fontSize: 20,
                        color: Colors.black,
                      ),
                    ),
                    onPressed: () {
                      MyAppMethods.showErrorORWarningDialog(
                          context: context,
                          isError: false,
                          subtitle: "Clear all ?",
                          fct: () {
                            clearForm();
                          });
                    },
                  ),
                  ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.all(12),
                      backgroundColor: Colors.blue,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(
                          10,
                        ),
                      ),
                    ),
                    icon: const Icon(
                      Icons.upload,
                      color: Colors.black,
                    ),
                    label: Text(
                      isEditing ? "Edit product" : "Upload Product",
                      style: const TextStyle(
                        fontSize: 20,
                        color: Colors.black,
                      ),
                    ),
                    onPressed: () {
                      if (isEditing) {
                        editProduct();
                      } else {
                        uploadFct();
                      }
                    },
                  ),
                ],
              ),
            ),
          ),
          appBar: AppBar(
            centerTitle: true,
            title: const TitlesTextWidget(
              label: "Upload a new product",
            ),
          ),
          body: Padding(
            padding: const EdgeInsets.all(8.0),
            child: SingleChildScrollView(
              child: Column(
                children: [
                  if (isEditing && productNetworkImage != null) ...[
                    ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Image.network(
                        productNetworkImage!,
                        // width: size.width * 0.7,
                        height: 170,
                        alignment: Alignment.center,
                      ),
                    ),
                  ] else if (_pickedImage == null) ...[
                    SizedBox(
                      width: 200,
                      height: 170,
                      child: DottedBorder(
                          color: Colors.blue,
                          radius: const Radius.circular(12),
                          child: Center(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                GestureDetector(
                                  onTap: () {
                                    localImagePicker();
                                  },
                                  child: const Icon(
                                    Icons.image_outlined,
                                    size: 90,
                                    color: Colors.blue,
                                  ),
                                ),
                                TextButton(
                                  onPressed: () {
                                    localImagePicker();
                                  },
                                  child: const Text(
                                    "Upload Product image",
                                    style: TextStyle(
                                        fontSize: 15, color: Colors.blue),
                                  ),
                                ),
                              ],
                            ),
                          )),
                    ),
                  ] else ...[
                    ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Image.file(
                        File(
                          _pickedImage!.path,
                        ),
                        // width: size.width * 0.7,
                        height: 170,
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
                            localImagePicker();
                          },
                          child: const Text(
                            "Upload another image",
                            style: TextStyle(fontSize: 15, color: Colors.blue),
                          ),
                        ),
                        TextButton(
                          onPressed: () {
                            removePickedImage();
                          },
                          child: const Text(
                            "Remove image",
                            style: TextStyle(fontSize: 15, color: Colors.red),
                          ),
                        ),
                      ],
                    ),
                  ],
                  const SizedBox(
                    height: 15,
                  ),
                  DropdownButton(
                      hint: Text(categoryValue ?? "select category"),
                      value: categoryValue,
                      items: AppConstants.categoriesDropDownList,
                      onChanged: (String? value) {
                        setState(() {
                          categoryValue = value;
                        });
                      }),
                  const SizedBox(
                    height: 10,
                  ),
                  TextFormField(
                    controller: titleController,
                    maxLength: 120,
                    validator: (value) {
                      return MyValidator.productNameValidator(value);
                    },
                    onFieldSubmitted: (value) {
                      uploadFct();
                    },
                    decoration: InputDecoration(
                      label: const Text("Product Name"),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(0),
                      ),
                    ),
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                  Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          controller: priceController,
                          keyboardType: TextInputType.number,
                          validator: (value) {
                            return MyValidator.priceValidator(value);
                          },
                          onFieldSubmitted: (value) {
                            uploadFct();
                          },
                          inputFormatters: <TextInputFormatter>[
                            FilteringTextInputFormatter.allow(
                              RegExp(r'^(\d+)?\.?\d{0,2}'),
                              //r'^(\d+)?\.?\d{0,2}'
                            ),
                          ],
                          decoration: InputDecoration(
                            label: const Text("Price"),
                            prefix: const TitlesTextWidget(
                              label: "\£ ",
                              fontSize: 18,
                              color: Colors.green,
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(0),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(
                        width: 10,
                      ),
                      Expanded(
                        child: TextFormField(
                          controller: quantityController,
                          keyboardType: TextInputType.number,
                          inputFormatters: <TextInputFormatter>[
                            FilteringTextInputFormatter.allow(
                              RegExp(r'^(\d+)?\d{0,2}'),
                            ),
                          ],
                          validator: (value) {
                            return MyValidator.quantityValidator(value);
                          },
                          onFieldSubmitted: (value) {
                            uploadFct();
                          },
                          decoration: InputDecoration(
                            label: const Text("Quantity"),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(0),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(
                    height: 30,
                  ),
                  TextFormField(
                    controller: descriptionController,
                    maxLength: 1000,
                    minLines: 1,
                    maxLines: 7,
                    validator: (value) {
                      return MyValidator.descriptionValidator(value);
                    },
                    onFieldSubmitted: (value) {
                      uploadFct();
                    },
                    decoration: InputDecoration(
                      label: const Text("Description"),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(0),
                      ),
                    ),
                  ),
                  const SizedBox(
                    height: 390,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
