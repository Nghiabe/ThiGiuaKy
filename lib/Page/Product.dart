import 'dart:io';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'Signin.dart';

class ProductManagementScreen extends StatefulWidget {
  @override
  _ProductManagementScreenState createState() => _ProductManagementScreenState();
}

class _ProductManagementScreenState extends State<ProductManagementScreen> {
  String productName = "";
  String productType = "";
  String productImage = "";
  int productPrice = 0;

  final TextEditingController nameController = TextEditingController();
  final TextEditingController typeController = TextEditingController();
  final TextEditingController priceController = TextEditingController();
  final TextEditingController imageController = TextEditingController();

  File? _selectedImage;
  final ImagePicker _picker = ImagePicker();

  bool isEditing = false;

  // Hàm đăng xuất
  void _signOut() async {
    await FirebaseAuth.instance.signOut();
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (context) => AuthPage()),
    );
  }

  // Chọn và tải lên hình ảnh
  Future<void> _pickAndUploadImage() async {
    final XFile? pickedImage = await _picker.pickImage(source: ImageSource.gallery);

    if (pickedImage != null) {
      File imageFile = File(pickedImage.path);
      setState(() {
        _selectedImage = imageFile;
      });

      String fileName = DateTime.now().millisecondsSinceEpoch.toString();
      Reference storageReference = FirebaseStorage.instance.ref().child('images/$fileName');

      UploadTask uploadTask = storageReference.putFile(imageFile);

      uploadTask.whenComplete(() async {
        try {
          String downloadUrl = await storageReference.getDownloadURL();
          setState(() {
            productImage = downloadUrl;
          });
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("Hình ảnh đã được tải lên thành công")),
          );
        } catch (error) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("Tải lên thất bại: $error")),
          );
        }
      });
    }
  }

  void createData() {
    DocumentReference documentReference =
    FirebaseFirestore.instance.collection("Products").doc(productName);

    Map<String, dynamic> productData = {
      "productName": productName,
      "productType": productType,
      "productPrice": productPrice,
      "productImage": productImage
    };

    documentReference.set(productData).whenComplete(() {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("$productName đã được thêm thành công")),
      );
      clearFields();
    }).catchError((error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Thêm thất bại: $error")),
      );
    });
  }

  void updateData(String documentId) {
    DocumentReference documentReference =
    FirebaseFirestore.instance.collection("Products").doc(documentId);

    Map<String, dynamic> updatedData = {
      "productName": productName,
      "productType": productType,
      "productPrice": productPrice,
      "productImage": productImage
    };

    documentReference.update(updatedData).whenComplete(() {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("$productName đã được cập nhật thành công")),
      );
      clearFields();
      setState(() {
        isEditing = false;
      });
    }).catchError((error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Cập nhật thất bại: $error")),
      );
    });
  }

  void deleteData(String documentId) {
    DocumentReference documentReference =
    FirebaseFirestore.instance.collection("Products").doc(documentId);

    documentReference.delete().whenComplete(() {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Sản phẩm đã được xóa")),
      );
    }).catchError((error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Xóa thất bại: $error")),
      );
    });
  }

  void clearFields() {
    nameController.clear();
    typeController.clear();
    priceController.clear();
    imageController.clear();

    setState(() {
      productName = "";
      productType = "";
      productPrice = 0;
      productImage = "";
      _selectedImage = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Quản lý sản phẩm", style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.blueAccent,
        actions: [
          IconButton(
            icon: Icon(Icons.logout),
            onPressed: _signOut,
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            TextField(
              controller: nameController,
              decoration: InputDecoration(
                labelText: "Tên sản phẩm",
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              onChanged: (String name) {
                productName = name;
              },
            ),
            SizedBox(height: 10),
            TextField(
              controller: typeController,
              decoration: InputDecoration(
                labelText: "Loại sản phẩm",
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              onChanged: (String type) {
                productType = type;
              },
            ),
            SizedBox(height: 10),
            TextField(
              controller: priceController,
              decoration: InputDecoration(
                labelText: "Giá tiền",
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              keyboardType: TextInputType.number,
              onChanged: (String price) {
                productPrice = int.tryParse(price) ?? 0;
              },
            ),
            SizedBox(height: 10),
            ElevatedButton(
              onPressed: _pickAndUploadImage,
              child: Text("Chọn hình ảnh"),
            ),
            SizedBox(height: 10),
            _selectedImage != null
                ? Image.file(
              _selectedImage!,
              height: 200,
              width: 200,
              fit: BoxFit.cover,
            )
                : productImage.isNotEmpty
                ? Image.network(
              productImage,
              height: 200,
              width: 200,
              fit: BoxFit.cover,
            )
                : Container(
              height: 200,
              width: 200,
              color: Colors.grey[200],
              child: Icon(
                Icons.image,
                size: 100,
                color: Colors.grey[400],
              ),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              child: Text(isEditing ? "Sửa sản phẩm" : "Thêm sản phẩm"),
              onPressed: () {
                if (isEditing) {
                  updateData(nameController.text);
                } else {
                  createData();
                }
              },
              style: ElevatedButton.styleFrom(
                padding: EdgeInsets.symmetric(horizontal: 50, vertical: 15),
                backgroundColor: Colors.greenAccent,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
              ),
            ),
            SizedBox(height: 20),
            StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance.collection("Products").snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                }
                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return Center(child: Text("Không có sản phẩm nào"));
                }
                return ListView.builder(
                  shrinkWrap: true,
                  physics: NeverScrollableScrollPhysics(),
                  itemCount: snapshot.data!.docs.length,
                  itemBuilder: (context, index) {
                    DocumentSnapshot documentSnapshot = snapshot.data!.docs[index];
                    return Card(
                      elevation: 3,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      margin: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                      child: Row(
                        children: [
                          Expanded(
                            flex: 3, // 3 cột cho hình ảnh
                            child: documentSnapshot["productImage"] != null
                                ? Image.network(
                              documentSnapshot["productImage"],
                              height: 100,
                              fit: BoxFit.cover,
                            )
                                : SizedBox(),
                          ),
                          Expanded(
                            flex: 7, // 7 cột cho thông tin sản phẩm
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    documentSnapshot["productName"],
                                    style: TextStyle(fontWeight: FontWeight.bold),
                                  ),
                                  Text("Loại: ${documentSnapshot["productType"]}"),
                                  Text("Giá: ${documentSnapshot["productPrice"]}"),
                                ],
                              ),
                            ),
                          ),
                          Expanded(
                            flex: 2, // 2 cột cho các nút sửa, xóa
                            child: Column(
                              children: [
                                IconButton(
                                  icon: Icon(Icons.edit),
                                  color: Colors.blue,
                                  onPressed: () {
                                    setState(() {
                                      productName = documentSnapshot["productName"];
                                      productType = documentSnapshot["productType"];
                                      productPrice = documentSnapshot["productPrice"];
                                      productImage = documentSnapshot["productImage"];
                                      isEditing = true;
                                    });

                                    nameController.text = productName;
                                    typeController.text = productType;
                                    priceController.text = productPrice.toString();
                                    imageController.text = productImage;
                                  },
                                ),
                                IconButton(
                                  icon: Icon(Icons.delete),
                                  color: Colors.red,
                                  onPressed: () {
                                    deleteData(documentSnapshot.id);
                                  },
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
