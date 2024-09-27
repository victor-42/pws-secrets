import 'dart:io';

import 'package:app/state-manager.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

const String start_info_text =
    'Differently to the other secret types, the image is saved encrypted on the server. '
    'However, the decryption key is only present in the retrieved link.';

class ImageForm extends StatefulWidget {
  const ImageForm({Key? key, required this.onChanged, required this.onSaved})
      : super(key: key);

  final Function(ImageSecret) onChanged;
  final Function() onSaved;

  @override
  _ImageFormState createState() => _ImageFormState();
}

class _ImageFormState extends State<ImageForm> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _noteController = TextEditingController();
  File? _image;

  @override
  Widget build(BuildContext context) {
    return Form(
        key: _formKey,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            _image == null
                ? SizedBox(
                    width: double.infinity,
                    height: 300,
                    child: Card(
                      child: IconButton(
                        icon: Icon(Icons.add),
                        onPressed: _onAddImage,
                      ),
                    ),
                  )
                : SizedBox(
                    width: double.infinity,
                    child: Card(
                        clipBehavior: Clip.antiAlias,
                        child: Stack(children: [
                          Image.network(
                            _image!.path,
                          ),
                          Positioned(
                              right: 5,
                              top: 5,
                              child: InkWell(
                                child: Icon(
                                  Icons.delete,
                                  size: 20,
                                  color: Colors.red,
                                ),
                                onTap: () {
                                  setState(() {
                                    _image = null;
                                  });
                                },
                              ))
                        ])),
                  ),
            SizedBox(height: 20),
            TextFormField(
              controller: _noteController,
              decoration: InputDecoration(
                hintText: 'Note',
                border: OutlineInputBorder(),
              ),
              onChanged: (value) {
                if (_image != null) {
                  widget
                      .onChanged(ImageSecret(image: _image!.path, note: value));
                }
              },
              onFieldSubmitted: (value) {
                widget.onSaved();
              },
              maxLines: 5,
            ),
            SizedBox(height: 20)
          ],
        ));
  }

  _onAddImage() async {
    final pickedFile =
        await ImagePicker().pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      setState(() {
        widget.onChanged(ImageSecret(image: pickedFile.path, note: _noteController.text));
        _image = File(pickedFile.path);
      });
    }
  }
}
