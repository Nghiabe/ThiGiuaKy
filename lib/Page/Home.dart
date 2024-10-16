import 'package:flutter/material.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'Product.dart';
import 'Blogger.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.light,
        primaryColor: Colors.blueAccent,
        hintColor: Colors.cyanAccent,
        scaffoldBackgroundColor: Colors.grey[200],
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.greenAccent,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
          ),
        ),
      ),
      home: HomeScreen(),
    );
  }
}
class HomeScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Trang Chủ"),
        backgroundColor: Colors.blueAccent,
      ),
      body: Stack(
        children: [
          // Nền Gradient
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.purple, Colors.blueAccent],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(height: 30),
                  // Nút Quản lý sản phẩm
                  ElevatedButton.icon(
                    onPressed: () {
                      // Điều hướng đến trang quản lý sản phẩm
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => ProductManagementScreen()),
                      );
                    },
                    icon: Icon(Icons.shopping_cart, size: 24), // Thêm icon
                    label: Text("Quản lý sản phẩm", style: TextStyle(fontSize: 18)),
                    style: ElevatedButton.styleFrom(
                      padding: EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                      backgroundColor: Colors.lightBlueAccent,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                      elevation: 5, // Hiệu ứng bóng đổ
                    ),
                  ),
                  SizedBox(height: 20),
                  // Nút Quản lý Blogger
                  ElevatedButton.icon(
                    onPressed: () {
                      // Điều hướng đến trang quản lý blogger
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => BlogManagementScreen()),
                      );
                    },
                    icon: Icon(Icons.person, size: 24), // Thêm icon
                    label: Text("Quản lý Blogger", style: TextStyle(fontSize: 18)),
                    style: ElevatedButton.styleFrom(
                      padding: EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                      backgroundColor: Colors.lightBlueAccent,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                      elevation: 5, // Hiệu ứng bóng đổ
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
