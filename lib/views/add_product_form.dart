import 'dart:io';

import 'package:firebase_app/models/product_dao.dart';
import 'package:firebase_app/providers/firebase_provider.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart' as path;

class AddProductForm extends StatefulWidget {
  AddProductForm({Key? key}) : super(key: key);

  @override
  State<AddProductForm> createState() => _AddProductFormState();
}

class _AddProductFormState extends State<AddProductForm> {
  
  late FirebaseProvider _firebase;
  UploadTask? _upload;
  bool upploadInProgress = false;

  File? image;
  late XFile temporalImage;
  bool imageSelected = false;
  
  var _formKey = GlobalKey<FormState>();
  TextEditingController _nombre = TextEditingController();
  TextEditingController _desc = TextEditingController();

  Future upload() async{
    if (image == null) return;
    String filename = path.basename(image!.path);
    String url = 'products/$filename';
    _upload = _firebase.uploadImage(image!, url);
    setState(() {
      upploadInProgress = true;
    });
    
    if(_upload == null) return;
    final upload = await _upload!.whenComplete(() {});
    final urlImage = await upload.ref.getDownloadURL();
    return urlImage;
  }
  
  Future<void> _pickImage(ImageSource source) async {
    try {
      XFile? temporalImage = await ImagePicker().pickImage(source: source);
      if (temporalImage == null) return;

      final image = File(temporalImage.path);
      setState(() {
        this.image = image;
        this.temporalImage = temporalImage;
        imageSelected = true;
      }); 
    } on PlatformException catch(e) {
      print(e);
    }
  }

  @override
  void initState() {
    // TODO: implement initState
    image = null;
    _firebase = FirebaseProvider();
    upploadInProgress = false;
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Colors.white,
      child: SizedBox(
        height: MediaQuery.of(context).size.height / 1.6 + MediaQuery.of(context).viewInsets.bottom,
        child: Form(
          key: _formKey,
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Center(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: const [
                        Text('Add Product ',style: TextStyle(fontSize: 20),),
                        Icon(Icons.add_to_photos_rounded)
                      ],
                    ),
                  ),
                ),
                const SizedBox(
                  height: 8,
                ), 
                InkWell(
                  onTap: (){
                    showDialog(
                      context: context, 
                      builder: (BuildContext context){
                        return SimpleDialog(
                          title: const Text('Select a image source'),
                          children: [
                            SimpleDialogOption(
                              child: Row(
                                children: const [
                                  Text('Camera'),
                                  Spacer(),
                                  Icon(Icons.camera_alt)
                                ],
                              ),
                              onPressed: (){
                                Navigator.pop(context);
                                _pickImage(ImageSource.camera);
                              },
                            ),
                            SimpleDialogOption(
                              child: Row(
                                children: const [
                                  Text('Gallery'),
                                  Spacer(),
                                  Icon(Icons.photo_library)
                                ],
                              ),
                              onPressed: (){
                                Navigator.pop(context);
                                _pickImage(ImageSource.gallery);
                              },
                            )
                          ],
                        );
                      } 
                    );
                  },
                  child: image != null ?
                    ClipOval(
                      child: Image.file(
                        image!,
                        width: 140,
                        height: 140,
                        fit: BoxFit.cover,
                      )
                    ): const FlutterLogo(
                      size: 140
                    ),
                ),
                const SizedBox(
                  height: 8,
                ), 
                TextFormField(
                  keyboardType: TextInputType.text,
                  controller: _nombre,
                  maxLength: 25,
                  decoration: InputDecoration(
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10.0),
                    ),
                    labelText: 'Product name',
                    contentPadding: const EdgeInsets.all(10.0),
                  ),
                  validator: (value){
                    if(value!.isEmpty){
                      return 'Please enter a name';
                    }
                  }
                ),
                const SizedBox(
                  height: 15,
                ),
                TextFormField(
                  keyboardType: TextInputType.text,
                  controller: _desc,
                  maxLength: 180,
                  maxLines: 5,
                  decoration: InputDecoration(
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10.0),
                    ),
                    labelText: 'Product description',
                    contentPadding: const EdgeInsets.all(10.0),
                  ),
                  validator: (value){
                    if(value!.isEmpty){
                      return 'Please enter a description';
                    }
                  }
                ),
                const Divider(
                  height: 20,
                  thickness: 1,
                  indent: 20,
                  endIndent: 20,
                ),
                const SizedBox(
                  height: 15,
                ),
                ElevatedButton(
                  onPressed: () async {
                    //!
                    if(_formKey.currentState!.validate()){
                      final urlImage = await upload() ?? 'https://firebasestorage.googleapis.com/v0/b/patm2021-a1120.appspot.com/o/products%2Fno-image.png?alt=media&token=598d3cbd-b05e-4f54-92b6-655b66bbb04f';
                      final product = ProductDAO(
                        cveprod: _nombre.text,
                        descprod: _desc.text,
                        imgprod: urlImage,
                      );
                      await _firebase.saveProduc(product);
                      Navigator.pop(context);
                    }
                    // final imgRef = await upload();
                    // final newProd = ProductDAO(
                    //   cveprod: _nombre.text,
                    //   descprod: _desc.text,
                    //   imgprod: imgRef,
                    // );
                    // await _firebase.saveProduc(newProd);
                    // Navigator.pop(context);
                  }, 
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      upploadInProgress ? const Text('Uploading ') : const Text('Save'),
                      Padding(
                        padding: const EdgeInsets.all(4.0),
                        child: upploadInProgress ?
                          const CircularProgressIndicator(
                            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                          ) :
                          const Icon(Icons.save_rounded),
                      )
                    ],
                  )
                ),    
              ],
            ),
          )
        ),
      ),
    );
  }
}