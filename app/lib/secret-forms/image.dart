import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

const String start_info_text = 'Differently to the other secret types, the image is saved encrypted on the server. '
    'However, the decryption key is only present in the retrieved link.';

class ImageForm extends StatefulWidget {
  const ImageForm({Key? key}) : super(key: key);


  @override
  _ImageFormState createState() => _ImageFormState();
}

class _ImageFormState extends State<ImageForm> {
  final _formKey = GlobalKey<FormState>();
  File? _image;

  @override
  Widget build(BuildContext context) {
    return Form(
        key: _formKey,
        child: Column(
          children: [
            _image == null ?
            SizedBox(
              width: double.infinity,
              height: 300,
              child: Card(
                child: IconButton(
                  icon: Icon(Icons.add),
                  onPressed: _onAddImage,),
              ),
            ) : Card(
                clipBehavior: Clip.antiAlias,
                child: Stack(
                    children: [
                      Image.file(_image!, width: 300,),
                      Positioned(
                          right: 5,
                          top: 5,
                          child: InkWell(
                            child: Icon(Icons.remove_circle, size: 20, color: Colors.red,),
                            onTap: () {
                              setState(() {
                                _image = null;
                              });
                            },
                          ))
                    ]
                )
            ),
            SizedBox(height: 20),
          ],
        ));
  }

  _onAddImage() async {
    final pickedFile = await ImagePicker().pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      setState(() {
        _image = File(pickedFile.path);
      });
    }
  }
}


