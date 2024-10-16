import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'Signin.dart';

class BlogManagementScreen extends StatefulWidget {
  @override
  _BlogManagementScreenState createState() => _BlogManagementScreenState();
}

class _BlogManagementScreenState extends State<BlogManagementScreen> {
  String blogTitle = "";
  String blogAuthor = "";
  String blogContent = "";
  DateTime publishDate = DateTime.now();

  final TextEditingController titleController = TextEditingController();
  final TextEditingController authorController = TextEditingController();
  final TextEditingController contentController = TextEditingController();

  bool isEditing = false;

  // Hàm đăng xuất
  void _signOut() async {
    await FirebaseAuth.instance.signOut();
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (context) => AuthPage()),
    );
  }

  // Tạo bài viết mới
  void createBlog() {
    DocumentReference documentReference =
    FirebaseFirestore.instance.collection("Blogs").doc(blogTitle);

    Map<String, dynamic> blogData = {
      "blogTitle": blogTitle,
      "blogAuthor": blogAuthor,
      "blogContent": blogContent,
      "publishDate": publishDate
    };

    documentReference.set(blogData).whenComplete(() {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("$blogTitle đã được thêm thành công")),
      );
      clearFields();
    }).catchError((error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Thêm thất bại: $error")),
      );
    });
  }

  // Cập nhật bài viết
  void updateBlog(String documentId) {
    DocumentReference documentReference =
    FirebaseFirestore.instance.collection("Blogs").doc(documentId);

    Map<String, dynamic> updatedData = {
      "blogTitle": blogTitle,
      "blogAuthor": blogAuthor,
      "blogContent": blogContent,
      "publishDate": publishDate
    };

    documentReference.update(updatedData).whenComplete(() {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("$blogTitle đã được cập nhật thành công")),
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

  // Xóa bài viết
  void deleteBlog(String documentId) {
    DocumentReference documentReference =
    FirebaseFirestore.instance.collection("Blogs").doc(documentId);

    documentReference.delete().whenComplete(() {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Bài viết đã được xóa")),
      );
    }).catchError((error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Xóa thất bại: $error")),
      );
    });
  }

  // Làm trống các trường nhập liệu
  void clearFields() {
    titleController.clear();
    authorController.clear();
    contentController.clear();

    setState(() {
      blogTitle = "";
      blogAuthor = "";
      blogContent = "";
      publishDate = DateTime.now();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Quản lý Blogger", style: TextStyle(color: Colors.white)),
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
              controller: titleController,
              decoration: InputDecoration(
                labelText: "Tiêu đề bài viết",
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              onChanged: (String title) {
                blogTitle = title;
              },
            ),
            SizedBox(height: 10),
            TextField(
              controller: authorController,
              decoration: InputDecoration(
                labelText: "Tác giả",
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              onChanged: (String author) {
                blogAuthor = author;
              },
            ),
            SizedBox(height: 10),
            TextField(
              controller: contentController,
              decoration: InputDecoration(
                labelText: "Nội dung",
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              maxLines: 5,
              onChanged: (String content) {
                blogContent = content;
              },
            ),
            SizedBox(height: 20),
            ElevatedButton(
              child: Text(isEditing ? "Sửa bài viết" : "Thêm bài viết"),
              onPressed: () {
                if (isEditing) {
                  updateBlog(titleController.text);
                } else {
                  createBlog();
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
              stream: FirebaseFirestore.instance.collection("Blogs").snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                }
                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return Center(child: Text("Không có bài viết nào"));
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
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  documentSnapshot["blogTitle"],
                                  style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 18,
                                      color: Colors.blue),
                                ),
                                Column(
                                  children: [
                                    IconButton(
                                      icon: Icon(Icons.edit),
                                      color: Colors.blue,
                                      onPressed: () {
                                        setState(() {
                                          blogTitle = documentSnapshot["blogTitle"];
                                          blogAuthor = documentSnapshot["blogAuthor"];
                                          blogContent = documentSnapshot["blogContent"];
                                          publishDate = documentSnapshot["publishDate"].toDate();
                                          isEditing = true;
                                        });

                                        titleController.text = blogTitle;
                                        authorController.text = blogAuthor;
                                        contentController.text = blogContent;
                                      },
                                    ),
                                    IconButton(
                                      icon: Icon(Icons.delete),
                                      color: Colors.red,
                                      onPressed: () {
                                        deleteBlog(documentSnapshot.id);
                                      },
                                    ),
                                  ],
                                ),
                              ],
                            ),
                            SizedBox(height: 5),
                            Text("Tác giả: ${documentSnapshot["blogAuthor"]}",
                                style: TextStyle(
                                    color: Colors.grey[600], fontSize: 14)),
                            SizedBox(height: 5),
                            Text(
                              documentSnapshot["blogContent"].length > 100
                                  ? documentSnapshot["blogContent"]
                                  .substring(0, 100) +
                                  "..."
                                  : documentSnapshot["blogContent"],
                              style: TextStyle(color: Colors.black87),
                            ),
                            SizedBox(height: 10),
                            Align(
                              alignment: Alignment.bottomRight,
                              child: Text(
                                "Ngày đăng: ${documentSnapshot["publishDate"].toDate()}",
                                style: TextStyle(color: Colors.grey),
                              ),
                            ),
                          ],
                        ),
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
