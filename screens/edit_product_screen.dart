import 'dart:ffi';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shopapp/providers/product.dart';
import 'package:shopapp/providers/products.dart';
import 'package:shopapp/widgets/app_drawer.dart';

class EditProductScreen extends StatefulWidget {
  static const routName = '/edit-product';

  @override
  State<EditProductScreen> createState() => _EditProductScreenState();
}

class _EditProductScreenState extends State<EditProductScreen> {
  final _priceFocusNode = FocusNode();

  final _descriptionFocusNode = FocusNode();

  final _imageUrlController = TextEditingController();

  final _imageUrlFocusNode = FocusNode();

  final _formKey = GlobalKey<FormState>();

  var _editedProduct =
      Product(id: null, title: '', description: '', price: 0, imageUrl: '');

  var _initailValues = {
    'title': '',
    'description': '',
    'price': '',
    'imageUrl': ''
  };

  var _isInit = true;

  var _isLoading = false;

  @override
  void initState() {
    super.initState();
    _imageUrlFocusNode.addListener(_updateImageUrl);
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    _imageUrlFocusNode.removeListener(_updateImageUrl);
    _imageUrlFocusNode.dispose();
    _priceFocusNode.dispose();
    _imageUrlController.dispose();
    _descriptionFocusNode.dispose();
  }

  void _updateImageUrl() {
    if (!_imageUrlFocusNode.hasFocus) {
      if (!_imageUrlController.text.startsWith('http') &&
              !_imageUrlController.text.startsWith('https') ||
          !_imageUrlController.text.endsWith('png') &&
              !_imageUrlController.text.endsWith('jpg') &&
              !_imageUrlController.text.endsWith('jpeg')) {
        return;
      }
    }
    setState(() {});
  }

  Future<void> _saveForm() async {
    final _isValid = _formKey.currentState?.validate();
    if (!_isValid!) {
      return;
    }
    _formKey.currentState?.save();
    setState(() {
      _isLoading = true;
    });
    if (_editedProduct != null) {
      await Provider.of<Products>(context, listen: false)
          .updateProduct(_editedProduct.id!, _editedProduct);
    } else {
      try {
        await Provider.of<Products>(context, listen: false)
            .addProduct(_editedProduct);
      } catch (e) {
        const errorMessage = 'Somthing went wrong! Please try later';
        _showMessageError(errorMessage);
      }
    }
    setState(() {
      _isLoading = false;
    });
    Navigator.of(context).pop();
  }

  void _showMessageError(String message) {
    showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
              title: Text("an error occured"),
              content: Text(message),
              actions: [
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30.0),
                      ),
                      primary: Theme.of(context).primaryColor,
                      textStyle: TextStyle(
                          color: Theme.of(context).textTheme.headline6?.color)),
                  onPressed: () => Navigator.of(ctx).pop(),
                  child: Text("okey"),
                )
              ],
            ));
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_isInit) {
      final productId = ModalRoute.of(context)?.settings.arguments as String;
      if (productId != null) {
        _editedProduct = Provider.of<Products>(context).findById(productId);
        _initailValues = {
          'title': _editedProduct.title!,
          'description': _editedProduct.description!,
          'price': _editedProduct.price!.toString(),
          'imageUrl': ''
        };
        _imageUrlController.text = _editedProduct.imageUrl!;
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Edit product'),
        actions: [
          IconButton(
            onPressed: () => _saveForm,
            icon: Icon(Icons.save),
          )
        ],
      ),
      body: _isLoading
          ? Center(
              child: CircularProgressIndicator(),
            )
          : Padding(
              padding: EdgeInsets.all(16),
              child: Form(
                key: _formKey,
                child: ListView(
                  children: [
                    TextFormField(
                      initialValue: _initailValues['title'],
                      decoration: InputDecoration(labelText: 'Title'),
                      textInputAction: TextInputAction.next,
                      onFieldSubmitted: (_) =>
                          FocusScope.of(context).requestFocus(_priceFocusNode),
                      validator: (val) {
                        if (val!.isEmpty) {
                          return 'Please provide a value!';
                        }
                        return null;
                      },
                      onSaved: (val) {
                        _editedProduct = Product(
                            id: _editedProduct.id,
                            title: val,
                            description: _editedProduct.description,
                            price: _editedProduct.price,
                            imageUrl: _editedProduct.imageUrl,
                            isFavorite: _editedProduct.isFavorite);
                      },
                    ),
                    TextFormField(
                      initialValue: _initailValues['price'],
                      decoration: InputDecoration(labelText: 'Price'),
                      textInputAction: TextInputAction.next,
                      keyboardType: TextInputType.number,
                      focusNode: _priceFocusNode,
                      onFieldSubmitted: (_) => FocusScope.of(context)
                          .requestFocus(_descriptionFocusNode),
                      validator: (val) {
                        if (val!.isEmpty) {
                          return 'Please enter a Price!';
                        }
                        if (double.tryParse(val) == null) {
                          return 'Please enter a valid number!';
                        }
                        if (double.parse(val) <= 0) {
                          return 'Please enter a number greatter than zeor!';
                        }
                        return null;
                      },
                      onSaved: (val) {
                        _editedProduct = Product(
                            id: _editedProduct.id,
                            title: _editedProduct.title,
                            description: _editedProduct.description,
                            price: double.parse(val!),
                            imageUrl: _editedProduct.imageUrl,
                            isFavorite: _editedProduct.isFavorite);
                      },
                    ),
                    TextFormField(
                      initialValue: _initailValues['description'],
                      decoration: InputDecoration(labelText: 'Description'),
                      maxLength: 3,
                      keyboardType: TextInputType.multiline,
                      focusNode: _descriptionFocusNode,
                      validator: (val) {
                        if (val!.isEmpty) {
                          return 'Please enter a description!';
                        }
                        return null;
                      },
                      onSaved: (val) {
                        _editedProduct = Product(
                            id: _editedProduct.id,
                            title: _editedProduct.title,
                            description: val,
                            price: _editedProduct.price,
                            imageUrl: _editedProduct.imageUrl,
                            isFavorite: _editedProduct.isFavorite);
                      },
                    ),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Container(
                          width: 100,
                          height: 100,
                          margin: EdgeInsets.only(top: 8, right: 10),
                          decoration: BoxDecoration(
                            border: Border.all(width: 1, color: Colors.grey),
                          ),
                          child: _imageUrlController.text.isEmpty
                              ? Text('Enter url')
                              : FittedBox(
                                  child:
                                      Image.network(_imageUrlController.text),
                                  fit: BoxFit.cover,
                                ),
                        ),
                        Expanded(
                          child: TextFormField(
                            controller: _imageUrlController,
                            decoration: InputDecoration(labelText: 'Image'),
                            keyboardType: TextInputType.url,
                            focusNode: _imageUrlFocusNode,
                            validator: (val) {
                              if (val!.isEmpty) {
                                return 'Please enter a url!';
                              }
                              if (!val.startsWith('http') &&
                                  !val.startsWith('https')) {
                                return 'Please enter a valid url!';
                              }
                              if (!val.endsWith('jpg') &&
                                  !val.endsWith('jpeg') &&
                                  !val.endsWith('png')) {
                                return 'Please enter a url end with jpg or jpeg or png!';
                              }
                              return null;
                            },
                            onSaved: (val) {
                              _editedProduct = Product(
                                  id: _editedProduct.id,
                                  title: _editedProduct.title,
                                  description: val,
                                  price: _editedProduct.price,
                                  imageUrl: _editedProduct.imageUrl,
                                  isFavorite: _editedProduct.isFavorite);
                            },
                          ),
                        )
                      ],
                    )
                  ],
                ),
              ),
            ),
      drawer: AppDrawer(),
    );
  }
}
