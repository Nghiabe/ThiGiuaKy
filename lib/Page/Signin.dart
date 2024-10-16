import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'Home.dart';
class AuthPage extends StatefulWidget {
  @override
  _AuthPageState createState() => _AuthPageState();
}

class _AuthPageState extends State<AuthPage> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  String errorMessage = ""; // Lưu thông báo lỗi

  bool isLogin = true; // Biến để xác định chế độ đăng nhập hay đăng ký

  // Kiểm tra email hợp lệ
  bool _isValidEmail(String email) {
    final emailRegex = RegExp(r'^[^@]+@[^@]+\.[^@]+');
    return emailRegex.hasMatch(email);
  }

  // Kiểm tra mật khẩu hợp lệ (ít nhất 6 ký tự)
  bool _isValidPassword(String password) {
    return password.length >= 6;
  }

  void _submit() async {
    String email = emailController.text.trim();
    String password = passwordController.text.trim();

    // Kiểm tra email hợp lệ
    if (email.isEmpty || !_isValidEmail(email)) {
      setState(() {
        errorMessage = "Vui lòng nhập email hợp lệ.";
      });
      return;
    }

    // Kiểm tra mật khẩu hợp lệ
    if (password.isEmpty || !_isValidPassword(password)) {
      setState(() {
        errorMessage = "Mật khẩu phải có ít nhất 6 ký tự.";
      });
      return;
    }

    try {
      if (isLogin) {
        // Đăng nhập
        await _auth.signInWithEmailAndPassword(
          email: email,
          password: password,
        );
      } else {
        // Đăng ký
        await _auth.createUserWithEmailAndPassword(
          email: email,
          password: password,
        );
        // Chuyển về chế độ đăng nhập sau khi đăng ký thành công
        setState(() {
          isLogin = true; // Đặt lại trạng thái là đăng nhập
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Đăng ký thành công!")),
        );
        return; // Ngăn không cho tiếp tục chuyển hướng ngay lập tức
      }
      // Chuyển hướng đến trang Home nếu thành công
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) =>HomeScreen()), // Sử dụng Home từ Home.dart
      );
    } catch (e) {
      // Hiển thị thông báo lỗi
      setState(() {
        errorMessage = e.toString();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(isLogin ? "Đăng Nhập" : "Đăng Ký"),
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
              child: SingleChildScrollView(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    SizedBox(height: 30),
                    TextField(
                      controller: emailController,
                      decoration: InputDecoration(
                        labelText: "Email",
                        labelStyle: TextStyle(color: Colors.white),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                        filled: true,
                        fillColor: Colors.white.withOpacity(0.7),
                      ),
                      style: TextStyle(color: Colors.black),
                    ),
                    SizedBox(height: 10),
                    TextField(
                      controller: passwordController,
                      decoration: InputDecoration(
                        labelText: "Mật Khẩu",
                        labelStyle: TextStyle(color: Colors.white),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                        filled: true,
                        fillColor: Colors.white.withOpacity(0.7),
                      ),
                      obscureText: true,
                      style: TextStyle(color: Colors.black),
                    ),
                    SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: _submit,
                      child: Text(isLogin ? "Đăng Nhập" : "Đăng Ký"),
                      style: ElevatedButton.styleFrom(
                        padding: EdgeInsets.symmetric(horizontal: 100, vertical: 15),
                        backgroundColor: Colors.greenAccent,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                      ),
                    ),
                    TextButton(
                      onPressed: () {
                        setState(() {
                          isLogin = !isLogin; // Chuyển giữa đăng nhập và đăng ký
                        });
                      },
                      child: Text(
                        isLogin ? "Chưa có tài khoản? Đăng ký" : "Đã có tài khoản? Đăng nhập",
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                    // Hiển thị thông báo lỗi nếu có
                    if (errorMessage.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text(
                          errorMessage,
                          style: TextStyle(color: Colors.red),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
