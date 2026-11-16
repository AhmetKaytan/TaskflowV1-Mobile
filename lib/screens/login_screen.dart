import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/auth_provider.dart';
import 'tasks_screen.dart';

import 'register_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  //Stateful widget olduğu için createState metodu ile state oluşturuyoruz
  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  //Global key ile formu yönetiyoruz
  final _formKey = GlobalKey<FormState>();

  //TextEditingController'lar ile kullanıcıdan alınan verileri yönetiyoruz
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();

  // Şifreyi gizleyip göstermek için kullanılan değişken
  // true ise şifre gizli, false ise şifre görünür olacak
  bool _obscurePassword = true;

  //Ekran dispose edildiğinde controller'ları temizliyoruz
  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  //Kullanıcı giriş işlemini gerçekleştiren fonksiyon (Form doğrulaması yapar ve AuthProvider üzerinden login işlemini gerçekleştirir)
  Future<void> _login() async {
    //Form geçerli değilse işlemi durdur
    if (!_formKey.currentState!.validate()) {
      return;
    }

    //AuthProvider'ı alıyoruz
    final authProvider = context.read<AuthProvider>();

    //provider üzerinden login işlemini gerçekleştiriyoruz
    final success = await authProvider.login(
      username: _usernameController.text.trim(),
      password: _passwordController.text,
    );

    if (!mounted) return;
    if (success) {
      // Eğer login başarılı ise TasksScreen'e yönlendiriyoruz
      // pushAndRemoveUntil ile TasksScreen'e yönlendiriyoruz ve önceki ekranları temizliyoruz
      // Böylece kullanıcı geri tuşuna bastığında login ekranına dönemez.
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => const TasksScreen()),
        (route) => false,
      );
    } else {
      // Eğer login başarısız ise kullanıcıya hata mesajı gösteriyoruz (ScaffoldMessenger üzerinden)
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(authProvider.errorMessage ?? 'Login failed.'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    //Loading durumunu alıyoruz
    final isLoading = context.watch<AuthProvider>().isLoading;
    return Scaffold(
      appBar: AppBar(title: const Text('Login')),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Icon(Icons.task_alt, size: 70, color: Colors.indigo),
                const SizedBox(height: 20),

                const Text(
                  'Welcome Back!',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
                ),

                const SizedBox(height: 30),

                //Kullanıcı adı alanı
                TextFormField(
                  controller: _usernameController,
                  decoration: const InputDecoration(
                    labelText: 'Username',
                    prefixIcon: Icon(Icons.person_outline),
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Username is required';
                    }
                    return null;
                  },
                ),

                const SizedBox(height: 16),

                //Şifre alanı
                TextFormField(
                  controller: _passwordController,
                  obscureText: _obscurePassword,
                  decoration: InputDecoration(
                    labelText: 'Password',
                    prefixIcon: const Icon(Icons.lock_outline),
                    border: const OutlineInputBorder(),
                    //Şifreyi göster/gizle butonu
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscurePassword
                            ? Icons.visibility
                            : Icons.visibility_off,
                      ),
                      onPressed: () {
                        setState(() {
                          _obscurePassword = !_obscurePassword;
                        });
                      },
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Password is required';
                    }
                    return null;
                  },
                ),

                const SizedBox(height: 24),

                //Giriş butonu (Eğer yükleniyorsa yükleme göstergesi gösteriyoruz)
                ElevatedButton(
                  onPressed: isLoading ? null : _login,
                  child: isLoading
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Text('Login'),
                ),

                const SizedBox(height: 16),

                //Kayıt olma yönlendirmesi
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text("Don't have an account?"),
                    TextButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const RegisterScreen(),
                          ),
                        );
                      },
                      child: const Text('Register'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
