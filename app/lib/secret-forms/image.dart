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
  dynamic _image;

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
              onChanged: (value)  async {
                if (_image != null) {
                  widget.onChanged(
                      ImageSecret(imageFileName: _image!.name,
                          imageBytes: await _image!.readAsBytes(),
                          note: value));
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
      ImageSecret secret = ImageSecret(
          imageFileName: pickedFile.name,
          imageBytes: await pickedFile.readAsBytes(),
          note: _noteController.text ?? '');
      setState(() {
        widget.onChanged(secret);
        _image = pickedFile;
      });
    }
  }
}
