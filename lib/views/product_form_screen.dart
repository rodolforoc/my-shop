import 'package:flutter/material.dart';
import '../providers/product.dart';
import '../providers/products.dart';
import 'package:provider/provider.dart';

class ProductFormScreen extends StatefulWidget {
  @override
  _ProductFormScreenState createState() => _ProductFormScreenState();
}

class _ProductFormScreenState extends State<ProductFormScreen> {
  final _imageURLFocusNode = FocusNode();
  final _imageURLController = TextEditingController();
  final _form = GlobalKey<FormState>();
  bool _isLoading = false;

  final _formData = Map<String, Object>();

  @override
  void initState() {
    super.initState();
    _imageURLFocusNode.addListener(updateImageURL);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    if (_formData.isEmpty) {
      final product = ModalRoute.of(context).settings.arguments as Product;
      if (product != null) {
        _formData['id'] = product.id;
        _formData['title'] = product.title;
        _formData['price'] = product.price;
        _formData['description'] = product.description;
        _formData['imageUrl'] = product.imageUrl;

        _imageURLController.text = _formData['imageUrl'];
      } else {
        _formData['price'] = '';
      }
    }
  }

  void updateImageURL() {
    if (isValidImageUrl(_imageURLController.text)) {
      setState(() {});
    }
  }

  bool isValidImageUrl(String url) {
    bool isValidProtocol = url.toLowerCase().startsWith('http://') ||
        url.toLowerCase().startsWith('https://');

    bool isValidImageExtension = url.toLowerCase().endsWith('.png') ||
        url.toLowerCase().endsWith('.jpg') ||
        url.toLowerCase().endsWith('.jpeg');

    return isValidProtocol && isValidImageExtension;
  }

  @override
  void dispose() {
    super.dispose();
    _imageURLFocusNode.removeListener(updateImageURL);
    _imageURLFocusNode.dispose();
  }

  Future<void> _saveForm() async {
    var isValid = _form.currentState.validate();

    if (!isValid) {
      return;
    }

    _form.currentState.save();

    final product = Product(
      id: _formData['id'],
      title: _formData['title'],
      price: _formData['price'],
      description: _formData['description'],
      imageUrl: _formData['imageUrl'],
    );

    setState(() {
      _isLoading = true;
    });

    final products = Provider.of<Products>(context, listen: false);
    if (_formData['id'] == null) {
      try {
        await products.addProduct(product);
        Navigator.of(context).pop();
      } catch (error) {
        await showDialog<Null>(
          context: context,
          builder: (ctx) => AlertDialog(
            title: Text('Ocorreu um erro'),
            content: Text('Ocorreu um erro para salvar o produto!'),
            actions: [
              FlatButton(
                child: Text('Fechar'),
                onPressed: () => Navigator.of(context).pop(),
              ),
            ],
          ),
        );
      } finally {
        setState(() {
          _isLoading = false;
        });
      }
    } else {
      products.updateProduct(product);
      setState(() {
        _isLoading = false;
      });
    }
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Formulário Produto'),
        actions: [
          IconButton(
            icon: Icon(Icons.save),
            onPressed: () {
              _saveForm();
            },
          )
        ],
      ),
      body: _isLoading
          ? Center(
              child: CircularProgressIndicator(),
            )
          : Padding(
              padding: const EdgeInsets.all(12.0),
              child: Form(
                key: _form,
                child: ListView(
                  children: [
                    TextFormField(
                      initialValue: _formData['title'],
                      decoration: InputDecoration(labelText: 'Título'),
                      textInputAction: TextInputAction.next,
                      onSaved: (value) => _formData['title'] = value,
                      validator: (value) {
                        bool isEmpty = value.trim().isEmpty;
                        bool isInvalid = value.trim().length < 3;
                        if (isEmpty) {
                          return 'Informe um título válido';
                        }

                        if (isInvalid) {
                          return 'Informe um título com no mínimo 3 letras';
                        }

                        return null;
                      },
                    ),
                    TextFormField(
                      initialValue: _formData['price'].toString(),
                      decoration: InputDecoration(labelText: 'Preço'),
                      keyboardType: TextInputType.numberWithOptions(
                        decimal: true,
                      ),
                      textInputAction: TextInputAction.next,
                      onSaved: (value) =>
                          _formData['price'] = double.parse(value),
                      validator: (value) {
                        bool isEmpty = value.trim().isEmpty;
                        var newPrice = double.tryParse(value);
                        bool isInvalid = newPrice == null || newPrice < 0;

                        if (isEmpty || isInvalid) {
                          return 'Informe um preço válido';
                        }

                        return null;
                      },
                    ),
                    TextFormField(
                      initialValue: _formData['description'],
                      decoration: InputDecoration(labelText: 'Descrição'),
                      maxLines: 3,
                      keyboardType: TextInputType.multiline,
                      onSaved: (value) => _formData['description'] = value,
                      validator: (value) {
                        bool isEmpty = value.trim().isEmpty;
                        bool isInvalid = value.trim().length < 10;
                        if (isEmpty) {
                          return 'Informe uma descrição válida';
                        }

                        if (isInvalid) {
                          return 'Informe um título com no mínimo 10 letras';
                        }

                        return null;
                      },
                    ),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Expanded(
                          child: TextFormField(
                            decoration:
                                InputDecoration(labelText: 'URL da Imagem'),
                            keyboardType: TextInputType.url,
                            textInputAction: TextInputAction.done,
                            focusNode: _imageURLFocusNode,
                            controller: _imageURLController,
                            onFieldSubmitted: (_) {
                              _saveForm();
                            },
                            onSaved: (value) => _formData['imageUrl'] = value,
                            validator: (value) {
                              bool isEmpty = value.trim().isEmpty;
                              bool isInvalid = !isValidImageUrl(value);

                              if (isEmpty || isInvalid) {
                                return 'Informe uma URL válida';
                              }

                              return null;
                            },
                          ),
                        ),
                        Container(
                          height: 100,
                          width: 100,
                          margin: EdgeInsets.only(
                            top: 8,
                            left: 10,
                          ),
                          decoration: BoxDecoration(
                            border: Border.all(
                              color: Colors.grey,
                              width: 1,
                            ),
                          ),
                          alignment: Alignment.center,
                          child: _imageURLController.text.isEmpty
                              ? Text('Informa a URL')
                              : Image.network(
                                  _imageURLController.text,
                                  fit: BoxFit.cover,
                                ),
                        )
                      ],
                    )
                  ],
                ),
              ),
            ),
    );
  }
}
