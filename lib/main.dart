import 'dart:async';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:csv/csv.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:universal_html/html.dart' as html;
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'screens/journal_screen.dart';
import 'utils/currency_service.dart';

// --- CONFIGURATION ---
const firebaseOptions = FirebaseOptions(
  apiKey: "AIzaSyCUYfhXTvTL9XGImXm3DOrMeM4iOQF8aLs",
  authDomain: "notariflow.firebaseapp.com",
  projectId: "notariflow",
  storageBucket: "notariflow.firebasestorage.app",
  messagingSenderId: "719123758188",
  appId: "1:719123758188:web:a7e70ae35fcd5a1780ac49",
);

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await CurrencyService().load();
  try {
    await Firebase.initializeApp(options: firebaseOptions);
    // Enable offline persistence for rural areas
    FirebaseFirestore.instance.settings = const Settings(persistenceEnabled: true);
  } catch (e) {
    await Firebase.initializeApp();
  }
  runApp(const NotaryFlowApp());
}

class NotaryFlowApp extends StatelessWidget {
  const NotaryFlowApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'NotaryFlow',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.indigo,
        scaffoldBackgroundColor: const Color(0xFFF8FAFC),
        useMaterial3: true,
        cardTheme: CardThemeData(
          surfaceTintColor: Colors.white,
          color: Colors.white,
          elevation: 2,
        ),
      ),
      home: const AuthWrapper(),
    );
  }
}

// --- AUTH WRAPPER ---
class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(body: Center(child: CircularProgressIndicator()));
        }
        if (snapshot.hasData) {
          return const MainLayout();
        }
        return const LoginScreen();
      },
    );
  }
}

// --- LOGIN SCREEN ---
class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  bool _isLoading = false;
  bool _obscurePassword = true;

  Future<void> _login() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: _emailCtrl.text.trim(),
        password: _passwordCtrl.text,
      );
    } on FirebaseAuthException catch (e) {
      String message = 'Login failed';
      if (e.code == 'user-not-found') {
        message = 'No account found with this email';
      } else if (e.code == 'wrong-password') {
        message = 'Incorrect password';
      } else if (e.code == 'invalid-email') {
        message = 'Invalid email address';
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(message),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 400),
            child: Card(
              elevation: 8,
              child: Padding(
                padding: const EdgeInsets.all(32),
                child: Form(
                  key: _formKey,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Image.asset(
                        'assets/images/logo.png',
                        width: 100,
                        height: 100,
                        errorBuilder: (context, error, stackTrace) {
                          return const Icon(Icons.work, size: 64, color: Colors.indigo);
                        },
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        'NotaryFlow',
                        style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Professional Notary Management',
                        style: TextStyle(color: Colors.grey.shade600),
                      ),
                      const SizedBox(height: 32),
                      TextFormField(
                        controller: _emailCtrl,
                        decoration: const InputDecoration(
                          labelText: 'Email',
                          prefixIcon: Icon(Icons.email),
                          border: OutlineInputBorder(),
                        ),
                        keyboardType: TextInputType.emailAddress,
                        validator: (value) {
                          if (value == null || value.isEmpty) return 'Required';
                          if (!value.contains('@')) return 'Invalid email';
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _passwordCtrl,
                        decoration: InputDecoration(
                          labelText: 'Password',
                          prefixIcon: const Icon(Icons.lock),
                          border: const OutlineInputBorder(),
                          suffixIcon: IconButton(
                            icon: Icon(_obscurePassword ? Icons.visibility : Icons.visibility_off),
                            onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                          ),
                        ),
                        obscureText: _obscurePassword,
                        validator: (value) {
                          if (value == null || value.isEmpty) return 'Required';
                          if (value.length < 6) return 'At least 6 characters';
                          return null;
                        },
                      ),
                      const SizedBox(height: 24),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: _isLoading ? null : _login,
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 16),
                          ),
                          child: _isLoading
                              ? const SizedBox(
                                  height: 20,
                                  width: 20,
                                  child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                                )
                              : const Text('Login', style: TextStyle(fontSize: 16)),
                        ),
                      ),
                      const SizedBox(height: 16),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text("Don't have an account?"),
                          TextButton(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(builder: (_) => const SignupScreen()),
                              );
                            },
                            child: const Text('Sign Up'),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// --- SIGNUP SCREEN ---
class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  final _confirmPasswordCtrl = TextEditingController();
  bool _isLoading = false;
  bool _obscurePassword = true;
  bool _obscureConfirm = true;

  Future<void> _signup() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final credential = await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: _emailCtrl.text.trim(),
        password: _passwordCtrl.text,
      );

      await credential.user!.updateDisplayName(_nameCtrl.text.trim());

      // Create initial profile
      await FirebaseFirestore.instance
          .doc('artifacts/notaryflow-v2/users/${credential.user!.uid}/profile/business_info')
          .set({
        'businessName': _nameCtrl.text.trim(),
        'email': _emailCtrl.text.trim(),
        'createdAt': FieldValue.serverTimestamp(),
      });

      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Account created successfully!'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } on FirebaseAuthException catch (e) {
      String message = 'Signup failed';
      if (e.code == 'weak-password') {
        message = 'Password is too weak';
      } else if (e.code == 'email-already-in-use') {
        message = 'Email already in use';
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(message),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Create Account'),
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 400),
            child: Card(
              elevation: 8,
              child: Padding(
                padding: const EdgeInsets.all(32),
                child: Form(
                  key: _formKey,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text(
                        'Sign Up',
                        style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 24),
                      TextFormField(
                        controller: _nameCtrl,
                        decoration: const InputDecoration(
                          labelText: 'Business Name',
                          prefixIcon: Icon(Icons.business),
                          border: OutlineInputBorder(),
                        ),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) return 'Required';
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _emailCtrl,
                        decoration: const InputDecoration(
                          labelText: 'Email',
                          prefixIcon: Icon(Icons.email),
                          border: OutlineInputBorder(),
                        ),
                        keyboardType: TextInputType.emailAddress,
                        validator: (value) {
                          if (value == null || value.isEmpty) return 'Required';
                          if (!value.contains('@')) return 'Invalid email';
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _passwordCtrl,
                        decoration: InputDecoration(
                          labelText: 'Password',
                          prefixIcon: const Icon(Icons.lock),
                          border: const OutlineInputBorder(),
                          suffixIcon: IconButton(
                            icon: Icon(_obscurePassword ? Icons.visibility : Icons.visibility_off),
                            onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                          ),
                        ),
                        obscureText: _obscurePassword,
                        validator: (value) {
                          if (value == null || value.isEmpty) return 'Required';
                          if (value.length < 6) return 'At least 6 characters';
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _confirmPasswordCtrl,
                        decoration: InputDecoration(
                          labelText: 'Confirm Password',
                          prefixIcon: const Icon(Icons.lock_outline),
                          border: const OutlineInputBorder(),
                          suffixIcon: IconButton(
                            icon: Icon(_obscureConfirm ? Icons.visibility : Icons.visibility_off),
                            onPressed: () => setState(() => _obscureConfirm = !_obscureConfirm),
                          ),
                        ),
                        obscureText: _obscureConfirm,
                        validator: (value) {
                          if (value == null || value.isEmpty) return 'Required';
                          if (value != _passwordCtrl.text) return 'Passwords do not match';
                          return null;
                        },
                      ),
                      const SizedBox(height: 24),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: _isLoading ? null : _signup,
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 16),
                          ),
                          child: _isLoading
                              ? const SizedBox(
                                  height: 20,
                                  width: 20,
                                  child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                                )
                              : const Text('Create Account', style: TextStyle(fontSize: 16)),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// --- MAIN LAYOUT ---
class MainLayout extends StatefulWidget {
  const MainLayout({super.key});

  @override
  State<MainLayout> createState() => _MainLayoutState();
}

class _MainLayoutState extends State<MainLayout> {
  int _selectedIndex = 0;

  // Desktop: Full Navigation Rail
  final List<Widget> _desktopScreens = [
    const DashboardScreen(),
    const AnalyticsScreen(),
    const InvoicesScreen(),
    const ExpensesScreen(),
    const ClientsScreen(),
    const MileageScreen(),
    const CalculatorScreen(),
    const JournalScreen(),
    const SettingsScreen(),
  ];

  // Mobile: Simplified Bottom Nav
  final List<Widget> _mobileScreens = [
    const DashboardScreen(),
    const InvoicesScreen(),
    const JournalScreen(),
    const MileageScreen(),
    const MoreScreen(),
  ];

  String _getScreenTitle(int index, bool isMobile) {
    if (isMobile) {
      switch (index) {
        case 0: return 'Dashboard';
        case 1: return 'Invoices';
        case 2: return 'Journal';
        case 3: return 'Mileage';
        case 4: return 'Menu';
        default: return 'NotaryFlow';
      }
    } else {
      switch (index) {
        case 0: return 'Dashboard';
        case 1: return 'Analytics';
        case 2: return 'Invoices';
        case 3: return 'Expenses';
        case 4: return 'Clients';
        case 5: return 'Mileage';
        case 6: return 'Calculator';
        case 7: return 'Journal';
        case 8: return 'Settings';
        default: return 'NotaryFlow';
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        bool isWide = constraints.maxWidth > 800;
        
        // Safety check for index when switching modes
        int activeIndex = _selectedIndex;
        if (isWide && activeIndex >= _desktopScreens.length) activeIndex = 0;
        if (!isWide && activeIndex >= _mobileScreens.length) activeIndex = 0;

        final currentScreen = isWide ? _desktopScreens[activeIndex] : _mobileScreens[activeIndex];

        return Scaffold(
          body: Row(
            children: [
              if (isWide)
                NavigationRail(
                  selectedIndex: activeIndex,
                  onDestinationSelected: (int index) => setState(() => _selectedIndex = index),
                  backgroundColor: const Color(0xFF0F172A),
                  indicatorColor: Colors.indigo,
                  selectedIconTheme: const IconThemeData(color: Colors.white),
                  unselectedIconTheme: const IconThemeData(color: Colors.grey),
                  selectedLabelTextStyle: const TextStyle(color: Colors.white),
                  unselectedLabelTextStyle: const TextStyle(color: Colors.grey),
                  extended: true,
                  leading: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 24.0),
                    child: Row(
                      children: [
                        Image.asset(
                          'assets/images/logo.png',
                          width: 32,
                          height: 32,
                          errorBuilder: (context, error, stackTrace) {
                            return const Icon(Icons.work, color: Colors.white);
                          },
                        ),
                        const SizedBox(width: 8),
                        const Text("NotaryFlow", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18)),
                      ],
                    ),
                  ),
                  destinations: const [
                    NavigationRailDestination(icon: Icon(Icons.dashboard), label: Text('Dashboard')),
                    NavigationRailDestination(icon: Icon(Icons.analytics), label: Text('Analytics')),
                    NavigationRailDestination(icon: Icon(Icons.receipt_long), label: Text('Invoices')),
                    NavigationRailDestination(icon: Icon(Icons.attach_money), label: Text('Expenses')),
                    NavigationRailDestination(icon: Icon(Icons.people), label: Text('Clients')),
                    NavigationRailDestination(icon: Icon(Icons.directions_car), label: Text('Mileage')),
                    NavigationRailDestination(icon: Icon(Icons.calculate), label: Text('Calculator')),
                    NavigationRailDestination(icon: Icon(Icons.book), label: Text('Journal')),
                    NavigationRailDestination(icon: Icon(Icons.settings), label: Text('Settings')),
                  ],
                ),
              Expanded(
                child: Column(
                  children: [
                    Container(
                      color: Colors.white,
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            _getScreenTitle(activeIndex, !isWide),
                            style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.black87),
                          ),
                          StreamBuilder<DocumentSnapshot>(
                            stream: FirebaseFirestore.instance
                                .doc('artifacts/notaryflow-v2/users/${FirebaseAuth.instance.currentUser!.uid}/profile/business_info')
                                .snapshots(),
                            builder: (context, snapshot) {
                              String initial = 'U';
                              String? photoUrl;
                              String email = FirebaseAuth.instance.currentUser?.email ?? '';

                              if (snapshot.hasData && snapshot.data!.exists) {
                                final data = snapshot.data!.data() as Map<String, dynamic>;
                                final name = data['businessName'] as String?;
                                if (name != null && name.isNotEmpty) {
                                  initial = name[0].toUpperCase();
                                }
                                photoUrl = data['logoUrl'] as String?;
                              } else {
                                final authName = FirebaseAuth.instance.currentUser?.displayName;
                                if (authName != null && authName.isNotEmpty) {
                                  initial = authName[0].toUpperCase();
                                }
                              }

                              return PopupMenuButton<String>(
                                child: CircleAvatar(
                                  backgroundColor: Colors.indigo,
                                  backgroundImage: photoUrl != null ? NetworkImage(photoUrl) : null,
                                  child: photoUrl == null
                                      ? Text(
                                          initial,
                                          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                                        )
                                      : null,
                                ),
                                itemBuilder: (context) => <PopupMenuEntry<String>>[
                                  PopupMenuItem(
                                    child: Text(email),
                                    enabled: false,
                                  ),
                                  const PopupMenuDivider(),
                                  PopupMenuItem(
                                    child: const Row(
                                      children: [
                                        Icon(Icons.logout, size: 20),
                                        SizedBox(width: 12),
                                        Text('Logout'),
                                      ],
                                    ),
                                    onTap: () async {
                                      await FirebaseAuth.instance.signOut();
                                    },
                                  ),
                                ],
                              );
                            },
                          ),
                        ],
                      ),
                    ),
                    const Divider(height: 1),
                    Expanded(child: currentScreen),
                  ],
                ),
              ),
            ],
          ),
          bottomNavigationBar: isWide
              ? null
              : BottomNavigationBar(
                  currentIndex: activeIndex,
                  onTap: (index) => setState(() => _selectedIndex = index),
                  type: BottomNavigationBarType.fixed,
                  selectedItemColor: Colors.indigo,
                  unselectedItemColor: Colors.grey,
                  selectedFontSize: 12,
                  unselectedFontSize: 11,
                  items: const [
                    BottomNavigationBarItem(icon: Icon(Icons.dashboard), label: 'Home'),
                    BottomNavigationBarItem(icon: Icon(Icons.receipt_long), label: 'Invoices'),
                    BottomNavigationBarItem(icon: Icon(Icons.book), label: 'Journal'),
                    BottomNavigationBarItem(icon: Icon(Icons.directions_car), label: 'Mileage'),
                    BottomNavigationBarItem(icon: Icon(Icons.grid_view), label: 'Menu'),
                  ],
                ),
        );
      },
    );
  }
}

// --- DASHBOARD (QUICK STATS) ---
class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final uid = FirebaseAuth.instance.currentUser!.uid;

    return StreamBuilder(
      stream: FirebaseFirestore.instance
          .collection('artifacts/notaryflow-v2/users/$uid/invoices')
          .snapshots(),
      builder: (context, invSnapshot) {
        return StreamBuilder(
          stream: FirebaseFirestore.instance
              .collection('artifacts/notaryflow-v2/users/$uid/trips')
              .snapshots(),
          builder: (context, tripSnapshot) {
            return StreamBuilder(
              stream: FirebaseFirestore.instance
                  .collection('artifacts/notaryflow-v2/users/$uid/expenses')
                  .snapshots(),
              builder: (context, expSnapshot) {
                if (!invSnapshot.hasData || !tripSnapshot.hasData || !expSnapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }

                final invoices = invSnapshot.data!.docs;
                final trips = tripSnapshot.data!.docs;
                final expenses = expSnapshot.data!.docs;

                double totalIncome = 0;
                double pendingIncome = 0;
                double paidIncome = 0;

                for (var doc in invoices) {
                  final amount = (doc['amount'] as num).toDouble();
                  totalIncome += amount;
                  if (doc['status'] == 'Pending') pendingIncome += amount;
                  if (doc['status'] == 'Paid') paidIncome += amount;
                }

                double totalExpenses = 0;
                for (var doc in expenses) {
                  totalExpenses += (doc['amount'] as num).toDouble();
                }

                double totalMiles = 0;
                for (var doc in trips) {
                  totalMiles += (doc['miles'] as num).toDouble();
                }
                double taxDed = totalMiles * 0.67;
                
                double netProfit = paidIncome - totalExpenses;

                return SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      Wrap(
                        spacing: 16,
                        runSpacing: 16,
                        children: [
                          _StatCard(title: "Total Revenue", value: "${CurrencyService().currencySymbol}${totalIncome.toStringAsFixed(2)}", icon: Icons.attach_money, color: Colors.green),
                          _StatCard(title: "Net Profit", value: "${CurrencyService().currencySymbol}${netProfit.toStringAsFixed(2)}", icon: Icons.account_balance_wallet, color: Colors.blue),
                          _StatCard(title: "Expenses", value: "${CurrencyService().currencySymbol}${totalExpenses.toStringAsFixed(2)}", icon: Icons.money_off, color: Colors.red),
                          _StatCard(title: "Pending", value: "${CurrencyService().currencySymbol}${pendingIncome.toStringAsFixed(2)}", icon: Icons.access_time, color: Colors.orange),
                          _StatCard(title: "Tax Deductions", value: "${CurrencyService().currencySymbol}${taxDed.toStringAsFixed(2)}", icon: Icons.directions_car, color: Colors.purple),
                        ],
                      ),
                  const SizedBox(height: 24),
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text("Recent Invoices", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                          const SizedBox(height: 16),
                          if (invoices.isEmpty)
                            _EmptyState(
                              icon: Icons.receipt_long,
                              title: "No invoices yet",
                              message: "Create your first invoice to get started!",
                            )
                          else
                            ...invoices.take(5).map((doc) => ListTile(
                              leading: CircleAvatar(
                                backgroundColor: Colors.indigo.shade50,
                                child: const Icon(Icons.receipt, color: Colors.indigo),
                              ),
                              title: Text(doc['description'] ?? 'Unknown', style: const TextStyle(fontWeight: FontWeight.w600)),
                              subtitle: Text(doc['date'] ?? ''),
                              trailing: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  Text("${CurrencyService().currencySymbol}${doc['amount']}", style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                                  _StatusBadge(status: doc['status']),
                                ],
                              ),
                            )),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
      },
    );
  }
}

class _StatCard extends StatelessWidget {
  final String title, value;
  final IconData icon;
  final Color color;
  const _StatCard({required this.title, required this.value, required this.icon, required this.color});

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: const BoxConstraints(minWidth: 280, maxWidth: 350),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10)],
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: const TextStyle(color: Colors.grey, fontSize: 14)),
                  const SizedBox(height: 8),
                  Text(value, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: color, size: 28),
            ),
          ],
        ),
      ),
    );
  }
}

class _StatusBadge extends StatelessWidget {
  final String status;
  const _StatusBadge({required this.status});

  @override
  Widget build(BuildContext context) {
    Color color;
    switch (status) {
      case 'Paid':
        color = Colors.green;
        break;
      case 'Overdue':
        color = Colors.red;
        break;
      default:
        color = Colors.orange;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        status,
        style: TextStyle(
          fontSize: 11,
          color: color,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

// --- ANALYTICS SCREEN ---
class AnalyticsScreen extends StatefulWidget {
  const AnalyticsScreen({super.key});

  @override
  State<AnalyticsScreen> createState() => _AnalyticsScreenState();
}

class _AnalyticsScreenState extends State<AnalyticsScreen> {
  @override
  Widget build(BuildContext context) {
    final uid = FirebaseAuth.instance.currentUser!.uid;

    return StreamBuilder(
      stream: FirebaseFirestore.instance
          .collection('artifacts/notaryflow-v2/users/$uid/invoices')
          .orderBy('date')
          .snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }

        final invoices = snapshot.data!.docs;

        if (invoices.isEmpty) {
          return _EmptyState(
            icon: Icons.analytics,
            title: "No data yet",
            message: "Create invoices to see analytics",
          );
        }

        // Group by month
        Map<String, double> monthlyRevenue = {};
        Map<String, int> statusCounts = {'Paid': 0, 'Pending': 0, 'Overdue': 0};

        for (var doc in invoices) {
          final date = doc['date'] as String;
          final amount = (doc['amount'] as num).toDouble();
          final status = doc['status'] as String;

          // Extract month (e.g., "2025-01")
          final monthKey = date.substring(0, 7);
          monthlyRevenue[monthKey] = (monthlyRevenue[monthKey] ?? 0) + amount;

          statusCounts[status] = (statusCounts[status] ?? 0) + 1;
        }

        // Sort months
        final sortedMonths = monthlyRevenue.keys.toList()..sort();
        final revenueData = sortedMonths.map((month) => monthlyRevenue[month]!).toList();

        // Fix for "weird" chart: Ensure at least 2 points for a line, or use BarChart
        // If only 1 month, add a dummy previous month with 0 revenue
        if (sortedMonths.length == 1) {
           // This is a hack to make the line chart look okay with 1 point
           // But BarChart is better for discrete monthly data. Let's switch to BarChart.
        }

        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Summary Cards Row
              Wrap(
                spacing: 16,
                runSpacing: 16,
                children: [
                  _AnalyticsCard(
                    title: "Total Revenue",
                    value: "${CurrencyService().currencySymbol}${monthlyRevenue.values.fold(0.0, (sum, val) => sum + val).toStringAsFixed(0)}",
                    icon: Icons.trending_up,
                    color: Colors.green,
                  ),
                  _AnalyticsCard(
                    title: "Paid Invoices",
                    value: "${statusCounts['Paid']}",
                    icon: Icons.check_circle,
                    color: Colors.blue,
                  ),
                  _AnalyticsCard(
                    title: "Pending",
                    value: "${statusCounts['Pending']}",
                    icon: Icons.schedule,
                    color: Colors.orange,
                  ),
                ],
              ),
              const SizedBox(height: 24),
              const Text("Monthly Revenue", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              const SizedBox(height: 16),
              Card(
                elevation: 2,
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: SizedBox(
                    height: 280,
                    child: BarChart(
                      BarChartData(
                        alignment: BarChartAlignment.spaceAround,
                        maxY: (revenueData.isEmpty ? 100 : revenueData.reduce((a, b) => a > b ? a : b)) * 1.15,
                        barTouchData: BarTouchData(
                          enabled: true,
                          touchTooltipData: BarTouchTooltipData(
                            getTooltipColor: (group) => Colors.indigo.shade700,
                            tooltipPadding: const EdgeInsets.all(8),
                            tooltipMargin: 8,
                            getTooltipItem: (group, groupIndex, rod, rodIndex) {
                              final date = DateTime.parse("${sortedMonths[group.x.toInt()]}-01");
                              return BarTooltipItem(
                                '${DateFormat('MMM yyyy').format(date)}\n${CurrencyService().currencySymbol}${rod.toY.toStringAsFixed(0)}',
                                const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12),
                              );
                            },
                          ),
                        ),
                        titlesData: FlTitlesData(
                          show: true,
                          bottomTitles: AxisTitles(
                            sideTitles: SideTitles(
                              showTitles: true,
                              getTitlesWidget: (value, meta) {
                                if (value.toInt() >= 0 && value.toInt() < sortedMonths.length) {
                                  final date = DateTime.parse("${sortedMonths[value.toInt()]}-01");
                                  return Padding(
                                    padding: const EdgeInsets.only(top: 10.0),
                                    child: Text(
                                      DateFormat('MMM\nyy').format(date),
                                      style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, height: 1.2),
                                      textAlign: TextAlign.center,
                                    ),
                                  );
                                }
                                return const Text('');
                              },
                              reservedSize: 38,
                            ),
                          ),
                          leftTitles: AxisTitles(
                            sideTitles: SideTitles(
                              showTitles: true,
                              reservedSize: 45,
                              getTitlesWidget: (value, meta) {
                                if (value == 0) return const Text('');
                                return Text(
                                  value >= 1000 ? '\$${(value/1000).toStringAsFixed(1)}k' : '\$${value.toInt()}',
                                  style: const TextStyle(fontSize: 11, color: Colors.grey, fontWeight: FontWeight.w500),
                                );
                              },
                            ),
                          ),
                          topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                          rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                        ),
                        gridData: FlGridData(
                          show: true,
                          drawVerticalLine: false,
                          horizontalInterval: (revenueData.isEmpty ? 100 : revenueData.reduce((a, b) => a > b ? a : b)) / 4,
                          getDrawingHorizontalLine: (value) {
                            return FlLine(
                              color: Colors.grey.shade200,
                              strokeWidth: 1,
                            );
                          },
                        ),
                        borderData: FlBorderData(show: false),
                        barGroups: List.generate(sortedMonths.length, (index) {
                          return BarChartGroupData(
                            x: index,
                            barRods: [
                              BarChartRodData(
                                toY: revenueData[index],
                                gradient: LinearGradient(
                                  colors: [Colors.indigo.shade400, Colors.indigo.shade700],
                                  begin: Alignment.bottomCenter,
                                  end: Alignment.topCenter,
                                ),
                                width: 24,
                                borderRadius: const BorderRadius.vertical(top: Radius.circular(6)),
                              ),
                            ],
                          );
                        }),
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              const Text("Invoice Status", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              const SizedBox(height: 16),
              Wrap(
                spacing: 16,
                runSpacing: 16,
                children: [
                  _StatCard(title: "Paid", value: "${statusCounts['Paid']}", icon: Icons.check_circle, color: Colors.green),
                  _StatCard(title: "Pending", value: "${statusCounts['Pending']}", icon: Icons.access_time, color: Colors.orange),
                  _StatCard(title: "Overdue", value: "${statusCounts['Overdue']}", icon: Icons.warning, color: Colors.red),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}

class _AnalyticsCard extends StatelessWidget {
  final String title, value;
  final IconData icon;
  final Color color;
  const _AnalyticsCard({required this.title, required this.value, required this.icon, required this.color});

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: const BoxConstraints(minWidth: 160, maxWidth: 200),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withOpacity(0.3), width: 2),
          boxShadow: [BoxShadow(color: color.withOpacity(0.1), blurRadius: 8, offset: const Offset(0, 2))],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(icon, color: color, size: 20),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(value, style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: color)),
            const SizedBox(height: 4),
            Text(title, style: const TextStyle(fontSize: 12, color: Colors.grey)),
          ],
        ),
      ),
    );
  }
}

class _LegendItem extends StatelessWidget {
  final Color color;
  final String label;
  const _LegendItem({required this.color, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 16,
          height: 16,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 8),
        Text(label, style: const TextStyle(fontWeight: FontWeight.w600)),
      ],
    );
  }
}

// --- MILEAGE SCREEN WITH GPS & GOOGLE MAPS ---
class MileageScreen extends StatefulWidget {
  const MileageScreen({super.key});

  @override
  State<MileageScreen> createState() => _MileageScreenState();
}

class _MileageScreenState extends State<MileageScreen> {
  final _formKey = GlobalKey<FormState>();
  final _locationCtrl = TextEditingController();
  final _milesCtrl = TextEditingController();
  final _purposeCtrl = TextEditingController();

  bool _isTracking = false;
  bool _showForm = false;
  DateTime? _startTime;
  Position? _startPosition;
  bool _isSaving = false;
  String? _gpsError;
  
  GoogleMapController? _mapController;
  final Set<Marker> _markers = {};
  final Set<Polyline> _polylines = {};
  final List<LatLng> _routePoints = [];
  StreamSubscription<Position>? _positionStream;

  static const CameraPosition _kInitialPosition = CameraPosition(
    target: LatLng(37.7749, -122.4194), // San Francisco Default
    zoom: 14.4746,
  );

  // Disable GPS tracking on Web
  bool get _isGpsAvailable => !kIsWeb;

  @override
  void dispose() {
    _positionStream?.cancel();
    _mapController?.dispose();
    super.dispose();
  }

  void _startTrip() async {
    setState(() => _gpsError = null);
    
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        setState(() => _gpsError = 'Location services are disabled. Please enable them or use Manual Entry.');
        return;
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          setState(() => _gpsError = 'Location permission denied. Please use Manual Entry.');
          return;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        setState(() => _gpsError = 'Location permissions are permanently denied. Please use Manual Entry.');
        return;
      }

      // Web specific check
      if (kIsWeb && html.window.location.protocol != 'https:' && !html.window.location.hostname!.contains('localhost')) {
         setState(() => _gpsError = 'GPS requires HTTPS on web. Please use Manual Entry.');
         return;
      }

      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      ).timeout(const Duration(seconds: 10));
      
      setState(() {
        _isTracking = true;
        _startTime = DateTime.now();
        _startPosition = position;
        _gpsError = null;
        _routePoints.clear();
        _routePoints.add(LatLng(position.latitude, position.longitude));
        _markers.add(Marker(
          markerId: const MarkerId('start'),
          position: LatLng(position.latitude, position.longitude),
          infoWindow: const InfoWindow(title: 'Start Point'),
          icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen),
        ));
      });

      // Move map to start
      _mapController?.animateCamera(CameraUpdate.newLatLngZoom(
        LatLng(position.latitude, position.longitude), 16
      ));

      // Start listening to position updates
      _positionStream = Geolocator.getPositionStream(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
          distanceFilter: 10,
        ),
      ).listen((Position pos) {
        setState(() {
          _routePoints.add(LatLng(pos.latitude, pos.longitude));
          _polylines.add(Polyline(
            polylineId: const PolylineId('route'),
            points: _routePoints,
            color: Colors.blue,
            width: 5,
          ));
        });
        _mapController?.animateCamera(CameraUpdate.newLatLng(LatLng(pos.latitude, pos.longitude)));
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Trip started! GPS tracking enabled.'), backgroundColor: Colors.green),
        );
      }
    } catch (e) {
      setState(() {
        _gpsError = 'GPS Error: $e. Please use Manual Entry.';
      });
    }
  }

  void _stopTrip() async {
    _positionStream?.cancel();
    
    if (_startPosition != null) {
      try {
        final endPosition = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high,
        ).timeout(const Duration(seconds: 10));

        // Calculate distance in miles
        final distanceInMeters = Geolocator.distanceBetween(
          _startPosition!.latitude,
          _startPosition!.longitude,
          endPosition.latitude,
          endPosition.longitude,
        );
        final distanceInMiles = (distanceInMeters / 1609.344).toStringAsFixed(2);

        _milesCtrl.text = distanceInMiles;
        
        setState(() {
          _markers.add(Marker(
            markerId: const MarkerId('end'),
            position: LatLng(endPosition.latitude, endPosition.longitude),
            infoWindow: const InfoWindow(title: 'End Point'),
            icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
          ));
        });

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Distance tracked: $distanceInMiles miles'), backgroundColor: Colors.green),
          );
        }
      } catch (e) {
        setState(() => _gpsError = 'Could not calculate end position. Please enter miles manually.');
      }
    }

    setState(() {
      _isTracking = false;
      _showForm = true;
    });
  }

  Future<void> _saveTrip() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSaving = true);

    try {
      final uid = FirebaseAuth.instance.currentUser!.uid;
      await FirebaseFirestore.instance
          .collection('artifacts/notaryflow-v2/users/$uid/trips')
          .add({
        'date': DateFormat('yyyy-MM-dd').format(DateTime.now()),
        'location': _locationCtrl.text.trim(),
        'miles': double.parse(_milesCtrl.text),
        'purpose': _purposeCtrl.text.trim(),
        'timestamp': FieldValue.serverTimestamp(),
        'gpsTracked': _startPosition != null,
      });

      _locationCtrl.clear();
      _milesCtrl.clear();
      _purposeCtrl.clear();
      _startPosition = null;
      _gpsError = null;
      _markers.clear();
      _polylines.clear();
      _routePoints.clear();

      setState(() => _showForm = false);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Row(children: [Icon(Icons.check, color: Colors.white), SizedBox(width: 8), Text('Trip saved!')]), backgroundColor: Colors.green),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
        );
      }
    } finally {
      setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final uid = FirebaseAuth.instance.currentUser!.uid;

    return StreamBuilder(
      stream: FirebaseFirestore.instance
          .collection('artifacts/notaryflow-v2/users/$uid/trips')
          .orderBy('timestamp', descending: true)
          .snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }

        final trips = snapshot.data!.docs;

        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              // --- GPS / MANUAL TOGGLE CARD ---
              Card(
                color: Colors.white,
                clipBehavior: Clip.antiAlias,
                child: Column(
                  children: [
                    // Map View
                    SizedBox(
                      height: 250,
                      width: double.infinity,
                      child: Stack(
                        children: [
                          if (_isGpsAvailable)
                            GoogleMap(
                              mapType: MapType.normal,
                              initialCameraPosition: _kInitialPosition,
                              onMapCreated: (GoogleMapController controller) {
                                _mapController = controller;
                                // Try to get current location to center map initially
                                Geolocator.getCurrentPosition().then((pos) {
                                  controller.animateCamera(CameraUpdate.newLatLng(LatLng(pos.latitude, pos.longitude)));
                                }).catchError((e) {});
                              },
                              markers: _markers,
                              polylines: _polylines,
                              myLocationEnabled: true,
                              myLocationButtonEnabled: true,
                            )
                          else
                            Container(
                              color: Colors.grey.shade100,
                              child: Center(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(Icons.map, size: 64, color: Colors.grey.shade400),
                                    const SizedBox(height: 12),
                                    Text(
                                      'GPS Tracking Not Available on Web',
                                      style: TextStyle(fontSize: 16, color: Colors.grey.shade600, fontWeight: FontWeight.bold),
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      'Please use Manual Entry or download the mobile app',
                                      style: TextStyle(fontSize: 12, color: Colors.grey.shade500),
                                      textAlign: TextAlign.center,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          if (_gpsError != null)
                            Container(
                              color: Colors.white.withOpacity(0.9),
                              child: Center(
                                child: Padding(
                                  padding: const EdgeInsets.all(16.0),
                                  child: Text(_gpsError!, style: const TextStyle(color: Colors.red), textAlign: TextAlign.center),
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                    
                    Padding(
                      padding: const EdgeInsets.all(24.0),
                      child: Column(
                        children: [
                          if (!_showForm) ...[
                            const Text("Choose Tracking Method", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                            const SizedBox(height: 20),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                // GPS Button
                                Expanded(
                                  child: Column(
                                    children: [
                                      ElevatedButton(
                                        onPressed: _isGpsAvailable ? (_isTracking ? _stopTrip : _startTrip) : null,
                                        style: ElevatedButton.styleFrom(
                                          shape: const CircleBorder(),
                                          padding: const EdgeInsets.all(28),
                                          backgroundColor: _isTracking ? Colors.red : Colors.green,
                                          foregroundColor: Colors.white,
                                          elevation: 4,
                                        ),
                                        child: Icon(_isTracking ? Icons.stop : Icons.gps_fixed, size: 36),
                                      ),
                                      const SizedBox(height: 12),
                                      Text(
                                        _isTracking ? "Stop GPS" : "GPS Tracking",
                                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                                        textAlign: TextAlign.center,
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        _isGpsAvailable
                                            ? (_isTracking ? "Tap to finish" : "Auto-calculate miles")
                                            : "Mobile Only",
                                        style: TextStyle(fontSize: 11, color: Colors.grey.shade600),
                                        textAlign: TextAlign.center,
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(width: 16),
                                // Manual Button
                                Expanded(
                                  child: Column(
                                    children: [
                                      ElevatedButton(
                                        onPressed: _isTracking ? null : () {
                                          setState(() {
                                            _showForm = true;
                                            _startPosition = null;
                                          });
                                        },
                                        style: ElevatedButton.styleFrom(
                                          shape: const CircleBorder(),
                                          padding: const EdgeInsets.all(28),
                                          backgroundColor: Colors.blue, // Changed to Blue to pop
                                          foregroundColor: Colors.white,
                                          elevation: 4,
                                        ),
                                        child: const Icon(Icons.edit, size: 36), // Changed to Pencil icon
                                      ),
                                      const SizedBox(height: 12),
                                      const Text(
                                        "Manual Entry",
                                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                                        textAlign: TextAlign.center,
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        "Enter miles & tax",
                                        style: TextStyle(fontSize: 11, color: Colors.grey.shade600),
                                        textAlign: TextAlign.center,
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            if (_isTracking) ...[
                              const SizedBox(height: 24),
                              Container(
                                padding: const EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  color: Colors.green.shade50,
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(color: Colors.green.shade200),
                                ),
                                child: Column(
                                  children: [
                                    const Icon(Icons.navigation, color: Colors.green, size: 32),
                                    const SizedBox(height: 8),
                                    const Text("Tracking in Progress...", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                                    const SizedBox(height: 4),
                                    Text("Started: ${DateFormat('h:mm a').format(_startTime!)}", style: const TextStyle(color: Colors.grey)),
                                  ],
                                ),
                              ),
                            ],
                          ],
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              
              const SizedBox(height: 24),
              
              // --- ENTRY FORM ---
              if (_showForm) ...[
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              const Text("Log Trip Details", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                              const Spacer(),
                              if (_startPosition != null)
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: Colors.green.shade100,
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: const Row(
                                    children: [
                                      Icon(Icons.gps_fixed, size: 14, color: Colors.green),
                                      SizedBox(width: 4),
                                      Text('GPS Tracked', style: TextStyle(fontSize: 11, color: Colors.green, fontWeight: FontWeight.bold)),
                                    ],
                                  ),
                                )
                              else
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: Colors.indigo.shade100,
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: const Row(
                                    children: [
                                      Icon(Icons.edit, size: 14, color: Colors.indigo),
                                      SizedBox(width: 4),
                                      Text('Manual Entry', style: TextStyle(fontSize: 11, color: Colors.indigo, fontWeight: FontWeight.bold)),
                                    ],
                                  ),
                                ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          TextFormField(
                            controller: _locationCtrl,
                            decoration: const InputDecoration(labelText: "Location/Client Name", border: OutlineInputBorder()),
                            validator: (v) => v == null || v.trim().isEmpty ? 'Required' : null,
                          ),
                          const SizedBox(height: 12),
                          TextFormField(
                            controller: _milesCtrl,
                            decoration: InputDecoration(
                              labelText: "Distance (Miles/KM)",
                              border: const OutlineInputBorder(),
                              suffixIcon: _startPosition != null 
                                ? const Icon(Icons.gps_fixed, color: Colors.green)
                                : null,
                              helperText: "Enter total distance for round trip if applicable",
                            ),
                            keyboardType: TextInputType.number,
                            validator: (v) {
                              if (v == null || v.isEmpty) return 'Required';
                              final miles = double.tryParse(v);
                              if (miles == null || miles <= 0) return 'Enter valid distance';
                              return null;
                            },
                          ),
                          const SizedBox(height: 12),
                          TextFormField(
                            controller: _purposeCtrl,
                            decoration: const InputDecoration(labelText: "Purpose", border: OutlineInputBorder()),
                            validator: (v) => v == null || v.trim().isEmpty ? 'Required' : null,
                          ),
                          const SizedBox(height: 16),
                          Row(
                            children: [
                              Expanded(
                                child: ElevatedButton(
                                  onPressed: _isSaving ? null : _saveTrip,
                                  child: _isSaving
                                      ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                                      : const Text("Save Trip"),
                                ),
                              ),
                              const SizedBox(width: 8),
                              TextButton(
                                onPressed: () => setState(() => _showForm = false),
                                child: const Text("Cancel"),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 24),
              ],
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text("Trip History", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 16),
                      if (trips.isEmpty)
                        _EmptyState(
                          icon: Icons.directions_car,
                          title: "No trips yet",
                          message: "Start tracking your mileage",
                        )
                      else
                        ...trips.map((doc) => ListTile(
                          leading: CircleAvatar(
                            backgroundColor: doc['gpsTracked'] == true ? Colors.green.shade100 : Colors.indigo.shade100,
                            child: Icon(
                              doc['gpsTracked'] == true ? Icons.gps_fixed : Icons.edit,
                              color: doc['gpsTracked'] == true ? Colors.green : Colors.indigo,
                            ),
                          ),
                          title: Text(doc['location'], style: const TextStyle(fontWeight: FontWeight.w600)),
                          subtitle: Text("${doc['purpose']} • ${doc['date']}"),
                          trailing: Text("${doc['miles']} mi", style: const TextStyle(fontWeight: FontWeight.bold)),
                        )),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

// --- INVOICES SCREEN ---
class InvoicesScreen extends StatefulWidget {
  const InvoicesScreen({super.key});

  @override
  State<InvoicesScreen> createState() => _InvoicesScreenState();
}

class _InvoicesScreenState extends State<InvoicesScreen> {
  final _searchCtrl = TextEditingController();
  String _searchQuery = '';

  Future<void> _exportCSV(List<QueryDocumentSnapshot> invoices) async {
    List<List<dynamic>> rows = [
      ['Date', 'Client', 'Description', 'Amount', 'Status'],
      ...invoices.map((doc) => [
        doc['date'],
        doc['clientName'] ?? 'N/A',
        doc['description'],
        doc['amount'],
        doc['status'],
      ]),
    ];

    String csv = const ListToCsvConverter().convert(rows);
    final bytes = html.Blob([csv], 'text/csv');
    final url = html.Url.createObjectUrlFromBlob(bytes);
    final anchor = html.AnchorElement(href: url)
      ..setAttribute('download', 'invoices_${DateFormat('yyyy-MM-dd').format(DateTime.now())}.csv')
      ..click();
    html.Url.revokeObjectUrl(url);

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('CSV exported!'), backgroundColor: Colors.green),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final uid = FirebaseAuth.instance.currentUser!.uid;

    return StreamBuilder(
      stream: FirebaseFirestore.instance
          .collection('artifacts/notaryflow-v2/users/$uid/invoices')
          .orderBy('date', descending: true)
          .snapshots(),
      builder: (context, invSnapshot) {
        return StreamBuilder(
          stream: FirebaseFirestore.instance
              .collection('artifacts/notaryflow-v2/users/$uid/clients')
              .snapshots(),
          builder: (context, clientSnapshot) {
            if (!invSnapshot.hasData || !clientSnapshot.hasData) {
              return const Center(child: CircularProgressIndicator());
            }

            final clients = clientSnapshot.data!.docs;
            Map<String, String> clientMap = {for (var c in clients) c.id: c['name']};

            var invoices = invSnapshot.data!.docs;

            // Filter by search
            if (_searchQuery.isNotEmpty) {
              invoices = invoices.where((doc) {
                final clientName = clientMap[doc['clientId']] ?? '';
                final desc = doc['description'] ?? '';
                final amount = doc['amount'].toString();
                final query = _searchQuery.toLowerCase();
                return clientName.toLowerCase().contains(query) ||
                    desc.toLowerCase().contains(query) ||
                    amount.contains(query);
              }).toList();
            }

            return Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _searchCtrl,
                          decoration: InputDecoration(
                            hintText: 'Search invoices...',
                            prefixIcon: const Icon(Icons.search),
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                            filled: true,
                            fillColor: Colors.white,
                            suffixIcon: _searchQuery.isNotEmpty
                                ? IconButton(
                                    icon: const Icon(Icons.clear),
                                    onPressed: () {
                                      _searchCtrl.clear();
                                      setState(() => _searchQuery = '');
                                    },
                                  )
                                : null,
                          ),
                          onChanged: (value) => setState(() => _searchQuery = value),
                        ),
                      ),
                      const SizedBox(width: 8),
                      IconButton.filled(
                        onPressed: invoices.isEmpty ? null : () => _exportCSV(invoices),
                        icon: const Icon(Icons.file_download),
                        tooltip: 'Export CSV',
                      ),
                      const SizedBox(width: 8),
                      FilledButton.icon(
                        onPressed: () => _showInvoiceDialog(context, null, clientMap),
                        icon: const Icon(Icons.add),
                        label: const Text("Add Invoice"),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: invoices.isEmpty
                      ? _EmptyState(
                          icon: Icons.receipt_long,
                          title: _searchQuery.isEmpty ? "No invoices yet" : "No matching invoices",
                          message: _searchQuery.isEmpty ? "Create your first invoice" : "Try a different search",
                        )
                      : ListView.builder(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          itemCount: invoices.length,
                          itemBuilder: (context, i) {
                            final doc = invoices[i];
                            final clientName = clientMap[doc['clientId']] ?? 'Unknown Client';

                            return Card(
                              margin: const EdgeInsets.only(bottom: 12),
                              child: ListTile(
                                leading: const CircleAvatar(child: Icon(Icons.receipt)),
                                title: Text(clientName, style: const TextStyle(fontWeight: FontWeight.bold)),
                                subtitle: Text("${doc['description']} • ${doc['date']}"),
                                trailing: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Column(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      crossAxisAlignment: CrossAxisAlignment.end,
                                      children: [
                                        Text("${CurrencyService().currencySymbol}${doc['amount']}", style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                                        _StatusBadge(status: doc['status']),
                                      ],
                                    ),
                                    PopupMenuButton(
                                      itemBuilder: (context) => [
                                        const PopupMenuItem(value: 'pdf', child: Row(children: [Icon(Icons.picture_as_pdf), SizedBox(width: 8), Text('Generate PDF')])),
                                        const PopupMenuItem(value: 'status', child: Row(children: [Icon(Icons.edit), SizedBox(width: 8), Text('Change Status')])),
                                        const PopupMenuItem(value: 'edit', child: Row(children: [Icon(Icons.edit_note), SizedBox(width: 8), Text('Edit')])),
                                        const PopupMenuItem(value: 'delete', child: Row(children: [Icon(Icons.delete, color: Colors.red), SizedBox(width: 8), Text('Delete', style: TextStyle(color: Colors.red))])),
                                      ],
                                      onSelected: (value) async {
                                        if (value == 'pdf') {
                                          await _generatePDF(doc, clientName);
                                        } else if (value == 'status') {
                                          _showStatusDialog(context, doc);
                                        } else if (value == 'edit') {
                                          _showInvoiceDialog(context, doc, clientMap);
                                        } else if (value == 'delete') {
                                          _deleteInvoice(context, doc);
                                        }
                                      },
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Future<void> _generatePDF(QueryDocumentSnapshot invoice, String clientName) async {
    final uid = FirebaseAuth.instance.currentUser!.uid;
    final businessDoc = await FirebaseFirestore.instance
        .doc('artifacts/notaryflow-v2/users/$uid/profile/business_info')
        .get();

    final businessName = businessDoc.data()?['businessName'] ?? 'NotaryFlow Business';
    final businessEmail = businessDoc.data()?['email'] ?? '';
    final businessPhone = businessDoc.data()?['phone'] ?? '';

    final pdf = pw.Document();

    pdf.addPage(
      pw.Page(
        build: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Text('INVOICE', style: pw.TextStyle(fontSize: 32, fontWeight: pw.FontWeight.bold)),
              pw.SizedBox(height: 20),
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Text('From:', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                      pw.Text(businessName),
                      if (businessEmail.isNotEmpty) pw.Text(businessEmail),
                      if (businessPhone.isNotEmpty) pw.Text(businessPhone),
                    ],
                  ),
                  pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.end,
                    children: [
                      pw.Text('To:', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                      pw.Text(clientName),
                    ],
                  ),
                ],
              ),
              pw.SizedBox(height: 30),
              pw.Divider(),
              pw.SizedBox(height: 10),
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Text('Date:', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                  pw.Text(invoice['date']),
                ],
              ),
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Text('Status:', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                  pw.Text(invoice['status']),
                ],
              ),
              pw.SizedBox(height: 20),
              pw.Divider(),
              pw.SizedBox(height: 20),
              pw.Text('Description:', style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 16)),
              pw.Text(invoice['description']),
              pw.SizedBox(height: 30),
              pw.Divider(),
              pw.SizedBox(height: 10),
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Text('TOTAL:', style: pw.TextStyle(fontSize: 20, fontWeight: pw.FontWeight.bold)),
                  pw.Text('${CurrencyService().currencySymbol}${invoice['amount']}', style: pw.TextStyle(fontSize: 20, fontWeight: pw.FontWeight.bold)),
                ],
              ),
            ],
          );
        },
      ),
    );

    final bytes = await pdf.save();
    final blob = html.Blob([bytes], 'application/pdf');
    final url = html.Url.createObjectUrlFromBlob(blob);
    final anchor = html.AnchorElement(href: url)
      ..setAttribute('download', 'invoice_${invoice['date']}_$clientName.pdf')
      ..click();
    html.Url.revokeObjectUrl(url);

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('PDF generated!'), backgroundColor: Colors.green),
      );
    }
  }

  void _showStatusDialog(BuildContext context, QueryDocumentSnapshot invoice) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Change Invoice Status'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: ['Pending', 'Paid', 'Overdue'].map((status) {
            return ListTile(
              title: Text(status),
              leading: Radio<String>(
                value: status,
                groupValue: invoice['status'],
                onChanged: (value) async {
                  await invoice.reference.update({'status': value});
                  if (context.mounted) {
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Status updated to $value'), backgroundColor: Colors.green),
                    );
                  }
                },
              ),
            );
          }).toList(),
        ),
      ),
    );
  }

  void _showInvoiceDialog(BuildContext context, QueryDocumentSnapshot? existingInvoice, Map<String, String> clientMap) {
    showDialog(
      context: context,
      builder: (context) => _InvoiceDialog(existingInvoice: existingInvoice, clientMap: clientMap),
    );
  }

  void _deleteInvoice(BuildContext context, QueryDocumentSnapshot invoice) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Invoice'),
        content: const Text('Are you sure you want to delete this invoice?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              await invoice.reference.delete();
              if (context.mounted) {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Invoice deleted'), backgroundColor: Colors.green),
                );
              }
            },
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}

class _InvoiceDialog extends StatefulWidget {
  final QueryDocumentSnapshot? existingInvoice;
  final Map<String, String> clientMap;

  const _InvoiceDialog({this.existingInvoice, required this.clientMap});

  @override
  State<_InvoiceDialog> createState() => _InvoiceDialogState();
}

class _InvoiceDialogState extends State<_InvoiceDialog> {
  final _formKey = GlobalKey<FormState>();
  final _descCtrl = TextEditingController();
  final _amountCtrl = TextEditingController();
  String? _selectedClientId;
  String _selectedStatus = 'Pending';
  DateTime _selectedDate = DateTime.now();
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    if (widget.existingInvoice != null) {
      _descCtrl.text = widget.existingInvoice!['description'];
      _amountCtrl.text = widget.existingInvoice!['amount'].toString();
      _selectedClientId = widget.existingInvoice!['clientId'];
      _selectedStatus = widget.existingInvoice!['status'];
      _selectedDate = DateFormat('yyyy-MM-dd').parse(widget.existingInvoice!['date']);
    }
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate() || _selectedClientId == null) {
      if (_selectedClientId == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please select a client'), backgroundColor: Colors.red),
        );
      }
      return;
    }

    setState(() => _isSaving = true);

    try {
      final uid = FirebaseAuth.instance.currentUser!.uid;
      final data = {
        'clientId': _selectedClientId,
        'clientName': widget.clientMap[_selectedClientId],
        'description': _descCtrl.text.trim(),
        'amount': double.parse(_amountCtrl.text),
        'status': _selectedStatus,
        'date': DateFormat('yyyy-MM-dd').format(_selectedDate),
        'timestamp': FieldValue.serverTimestamp(),
      };

      if (widget.existingInvoice != null) {
        await widget.existingInvoice!.reference.update(data);
      } else {
        await FirebaseFirestore.instance
            .collection('artifacts/notaryflow-v2/users/$uid/invoices')
            .add(data);
      }

      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(widget.existingInvoice != null ? 'Invoice updated!' : 'Invoice created!'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.existingInvoice != null ? 'Edit Invoice' : 'New Invoice'),
      content: SizedBox(
        width: 400,
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                DropdownButtonFormField<String>(
                  value: _selectedClientId,
                  decoration: const InputDecoration(labelText: "Client", border: OutlineInputBorder()),
                  items: widget.clientMap.entries
                      .map((e) => DropdownMenuItem(value: e.key, child: Text(e.value)))
                      .toList(),
                  onChanged: (value) => setState(() => _selectedClientId = value),
                  validator: (v) => v == null ? 'Required' : null,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _descCtrl,
                  decoration: const InputDecoration(labelText: "Description", border: OutlineInputBorder()),
                  validator: (v) => v == null || v.trim().isEmpty ? 'Required' : null,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _amountCtrl,
                  decoration: InputDecoration(labelText: "Amount", prefixText: CurrencyService().currencySymbol, border: const OutlineInputBorder()),
                  keyboardType: TextInputType.number,
                  validator: (v) {
                    if (v == null || v.isEmpty) return 'Required';
                    final amount = double.tryParse(v);
                    if (amount == null || amount <= 0) return 'Enter valid amount';
                    return null;
                  },
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<String>(
                  value: _selectedStatus,
                  decoration: const InputDecoration(labelText: "Status", border: OutlineInputBorder()),
                  items: ['Pending', 'Paid', 'Overdue']
                      .map((s) => DropdownMenuItem(value: s, child: Text(s)))
                      .toList(),
                  onChanged: (value) => setState(() => _selectedStatus = value!),
                ),
                const SizedBox(height: 12),
                ListTile(
                  title: const Text("Date"),
                  subtitle: Text(DateFormat('yyyy-MM-dd').format(_selectedDate)),
                  trailing: const Icon(Icons.calendar_today),
                  onTap: () async {
                    final date = await showDatePicker(
                      context: context,
                      initialDate: _selectedDate,
                      firstDate: DateTime(2020),
                      lastDate: DateTime(2030),
                    );
                    if (date != null) setState(() => _selectedDate = date);
                  },
                ),
              ],
            ),
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: _isSaving ? null : _save,
          child: _isSaving
              ? const SizedBox(height: 16, width: 16, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
              : const Text('Save'),
        ),
      ],
    );
  }
}

// --- EXPENSES SCREEN ---
class ExpensesScreen extends StatefulWidget {
  const ExpensesScreen({super.key});

  @override
  State<ExpensesScreen> createState() => _ExpensesScreenState();
}

class _ExpensesScreenState extends State<ExpensesScreen> {
  final _formKey = GlobalKey<FormState>();
  final _descCtrl = TextEditingController();
  final _amountCtrl = TextEditingController();
  final _categoryCtrl = TextEditingController();
  DateTime _selectedDate = DateTime.now();
  bool _isSaving = false;

  Future<void> _addExpense() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSaving = true);

    try {
      final uid = FirebaseAuth.instance.currentUser!.uid;
      await FirebaseFirestore.instance
          .collection('artifacts/notaryflow-v2/users/$uid/expenses')
          .add({
        'description': _descCtrl.text.trim(),
        'amount': double.parse(_amountCtrl.text),
        'category': _categoryCtrl.text.trim(),
        'date': DateFormat('yyyy-MM-dd').format(_selectedDate),
        'timestamp': FieldValue.serverTimestamp(),
      });

      _descCtrl.clear();
      _amountCtrl.clear();
      _categoryCtrl.clear();
      setState(() => _selectedDate = DateTime.now());

      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Expense added!'), backgroundColor: Colors.green),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
        );
      }
    } finally {
      setState(() => _isSaving = false);
    }
  }

  void _showAddDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add Expense'),
        content: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: _descCtrl,
                decoration: const InputDecoration(labelText: 'Description (e.g. Toner)', border: OutlineInputBorder()),
                validator: (v) => v!.isEmpty ? 'Required' : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _amountCtrl,
                decoration: InputDecoration(labelText: 'Amount', prefixText: CurrencyService().currencySymbol, border: const OutlineInputBorder()),
                keyboardType: TextInputType.number,
                validator: (v) => v!.isEmpty ? 'Required' : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _categoryCtrl,
                decoration: const InputDecoration(labelText: 'Category (e.g. Supplies)', border: OutlineInputBorder()),
              ),
              const SizedBox(height: 12),
              ListTile(
                title: const Text("Date"),
                subtitle: Text(DateFormat('yyyy-MM-dd').format(_selectedDate)),
                trailing: const Icon(Icons.calendar_today),
                onTap: () async {
                  final date = await showDatePicker(
                    context: context,
                    initialDate: _selectedDate,
                    firstDate: DateTime(2020),
                    lastDate: DateTime(2030),
                  );
                  if (date != null) setState(() => _selectedDate = date);
                },
              ),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          FilledButton(onPressed: _addExpense, child: const Text('Add')),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final uid = FirebaseAuth.instance.currentUser!.uid;

    return Scaffold(
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddDialog,
        child: const Icon(Icons.add),
      ),
      body: StreamBuilder(
        stream: FirebaseFirestore.instance
            .collection('artifacts/notaryflow-v2/users/$uid/expenses')
            .orderBy('date', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());

          final docs = snapshot.data!.docs;

          if (docs.isEmpty) {
            return _EmptyState(
              icon: Icons.money_off,
              title: "No expenses",
              message: "Track your business spending here",
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: docs.length,
            itemBuilder: (context, index) {
              final doc = docs[index];
              return Card(
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: Colors.red.shade50,
                    child: const Icon(Icons.attach_money, color: Colors.red),
                  ),
                  title: Text(doc['description']),
                  subtitle: Text('${doc['category']} • ${doc['date']}'),
                  trailing: Text(
                    '-${CurrencyService().currencySymbol}${doc['amount']}',
                    style: const TextStyle(color: Colors.red, fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  onLongPress: () async {
                    // Simple delete on long press
                    await doc.reference.delete();
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }
}

// --- CLIENTS SCREEN ---
class ClientsScreen extends StatefulWidget {
  const ClientsScreen({super.key});

  @override
  State<ClientsScreen> createState() => _ClientsScreenState();
}

class _ClientsScreenState extends State<ClientsScreen> {
  final _searchCtrl = TextEditingController();
  String _searchQuery = '';

  Future<void> _exportCSV(List<QueryDocumentSnapshot> clients) async {
    List<List<dynamic>> rows = [
      ['Name', 'Email', 'Phone'],
      ...clients.map((doc) => [
        doc['name'],
        doc['email'] ?? '',
        doc['phone'] ?? '',
      ]),
    ];

    String csv = const ListToCsvConverter().convert(rows);
    final bytes = html.Blob([csv], 'text/csv');
    final url = html.Url.createObjectUrlFromBlob(bytes);
    final anchor = html.AnchorElement(href: url)
      ..setAttribute('download', 'clients_${DateFormat('yyyy-MM-dd').format(DateTime.now())}.csv')
      ..click();
    html.Url.revokeObjectUrl(url);

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('CSV exported!'), backgroundColor: Colors.green),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final uid = FirebaseAuth.instance.currentUser!.uid;

    return StreamBuilder(
      stream: FirebaseFirestore.instance
          .collection('artifacts/notaryflow-v2/users/$uid/clients')
          .snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }

        var clients = snapshot.data!.docs;

        // Filter by search
        if (_searchQuery.isNotEmpty) {
          clients = clients.where((doc) {
            final name = doc['name'] ?? '';
            final email = doc['email'] ?? '';
            final phone = doc['phone'] ?? '';
            final query = _searchQuery.toLowerCase();
            return name.toLowerCase().contains(query) ||
                email.toLowerCase().contains(query) ||
                phone.toLowerCase().contains(query);
          }).toList();
        }

        return Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _searchCtrl,
                      decoration: InputDecoration(
                        hintText: 'Search clients...',
                        prefixIcon: const Icon(Icons.search),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                        filled: true,
                        fillColor: Colors.white,
                        suffixIcon: _searchQuery.isNotEmpty
                            ? IconButton(
                                icon: const Icon(Icons.clear),
                                onPressed: () {
                                  _searchCtrl.clear();
                                  setState(() => _searchQuery = '');
                                },
                              )
                            : null,
                      ),
                      onChanged: (value) => setState(() => _searchQuery = value),
                    ),
                  ),
                  const SizedBox(width: 8),
                  IconButton.filled(
                    onPressed: clients.isEmpty ? null : () => _exportCSV(clients),
                    icon: const Icon(Icons.file_download),
                    tooltip: 'Export CSV',
                  ),
                  const SizedBox(width: 8),
                  FilledButton.icon(
                    onPressed: () => _showClientDialog(context, null),
                    icon: const Icon(Icons.add),
                    label: const Text("Add Client"),
                  ),
                ],
              ),
            ),
            Expanded(
              child: clients.isEmpty
                  ? _EmptyState(
                      icon: Icons.people,
                      title: _searchQuery.isEmpty ? "No clients yet" : "No matching clients",
                      message: _searchQuery.isEmpty ? "Add your first client" : "Try a different search",
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      itemCount: clients.length,
                      itemBuilder: (context, i) {
                        final doc = clients[i];
                        return Card(
                          margin: const EdgeInsets.only(bottom: 12),
                          child: ListTile(
                            leading: const CircleAvatar(child: Icon(Icons.person)),
                            title: Text(doc['name'], style: const TextStyle(fontWeight: FontWeight.bold)),
                            subtitle: Text("${doc['email'] ?? 'No email'}\n${doc['phone'] ?? 'No phone'}"),
                            isThreeLine: true,
                            trailing: IconButton(
                              icon: const Icon(Icons.delete, color: Colors.red),
                              onPressed: () => _deleteClient(context, doc),
                            ),
                          ),
                        );
                      },
                    ),
            ),
          ],
        );
      },
    );
  }

  void _showClientDialog(BuildContext context, QueryDocumentSnapshot? existing) {
    final formKey = GlobalKey<FormState>();
    final nameCtrl = TextEditingController(text: existing?['name']);
    final emailCtrl = TextEditingController(text: existing?['email']);
    final phoneCtrl = TextEditingController(text: existing?['phone']);
    bool isSaving = false;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: Text(existing != null ? 'Edit Client' : 'New Client'),
          content: Form(
            key: formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: nameCtrl,
                  decoration: const InputDecoration(labelText: "Name", border: OutlineInputBorder()),
                  validator: (v) => v == null || v.trim().isEmpty ? 'Required' : null,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: emailCtrl,
                  decoration: const InputDecoration(labelText: "Email", border: OutlineInputBorder()),
                  keyboardType: TextInputType.emailAddress,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: phoneCtrl,
                  decoration: const InputDecoration(labelText: "Phone", border: OutlineInputBorder()),
                  keyboardType: TextInputType.phone,
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: isSaving
                  ? null
                  : () async {
                      if (!formKey.currentState!.validate()) return;
                      setState(() => isSaving = true);

                      try {
                        final uid = FirebaseAuth.instance.currentUser!.uid;
                        final data = {
                          'name': nameCtrl.text.trim(),
                          'email': emailCtrl.text.trim(),
                          'phone': phoneCtrl.text.trim(),
                        };

                        if (existing != null) {
                          await existing.reference.update(data);
                        } else {
                          await FirebaseFirestore.instance
                              .collection('artifacts/notaryflow-v2/users/$uid/clients')
                              .add(data);
                        }

                        if (context.mounted) {
                          Navigator.pop(context);
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(existing != null ? 'Client updated!' : 'Client added!'),
                              backgroundColor: Colors.green,
                            ),
                          );
                        }
                      } catch (e) {
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
                          );
                        }
                      } finally {
                        setState(() => isSaving = false);
                      }
                    },
              child: isSaving
                  ? const SizedBox(height: 16, width: 16, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                  : const Text('Save'),
            ),
          ],
        ),
      ),
    );
  }

  void _deleteClient(BuildContext context, QueryDocumentSnapshot client) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Client'),
        content: const Text('Are you sure? This will not delete associated invoices.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              await client.reference.delete();
              if (context.mounted) {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Client deleted'), backgroundColor: Colors.green),
                );
              }
            },
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}

// --- CALCULATOR SCREEN WITH REGIONAL RATES ---
class CalculatorScreen extends StatefulWidget {
  const CalculatorScreen({super.key});

  @override
  State<CalculatorScreen> createState() => _CalculatorScreenState();
}

class _CalculatorScreenState extends State<CalculatorScreen> {
  final _signaturesCtrl = TextEditingController();
  final _milesCtrl = TextEditingController();
  double _estimate = 0;
  
  // Rates configuration
  String _selectedCountry = 'USA';
  String? _selectedState;
  double _signatureRate = 15.0;
  double _mileageRate = 0.67;

  // Simplified Country List (USA Only + Other)
  final Map<String, Map<String, double>> _countryRates = {
    'USA': {'signature': 15.0, 'mileage': 0.67},
    'Other': {'signature': 10.0, 'mileage': 0.50},
  };

  // Expanded US State/City List
  final Map<String, double> _usStateRates = {
    'Standard (Most States)': 5.0,
    'Alabama': 5.0,
    'Alaska': 5.0,
    'Arizona': 10.0,
    'Arkansas': 5.0,
    'California': 15.0,
    'Colorado': 5.0,
    'Connecticut': 5.0,
    'Delaware': 5.0,
    'Florida': 10.0,
    'Georgia': 2.0,
    'Hawaii': 5.0,
    'Idaho': 5.0,
    'Illinois': 1.0,
    'Indiana': 10.0,
    'Iowa': 5.0,
    'Kansas': 5.0,
    'Kentucky': 0.50,
    'Louisiana': 5.0,
    'Maine': 5.0,
    'Maryland': 4.0,
    'Massachusetts': 1.25,
    'Michigan': 10.0,
    'Minnesota': 5.0,
    'Mississippi': 5.0,
    'Missouri': 5.0,
    'Montana': 10.0,
    'Nebraska': 5.0,
    'Nevada': 15.0,
    'New Hampshire': 10.0,
    'New Jersey': 2.50,
    'New Mexico': 5.0,
    'New York': 2.0,
    'North Carolina': 10.0,
    'North Dakota': 5.0,
    'Ohio': 5.0,
    'Oklahoma': 5.0,
    'Oregon': 10.0,
    'Pennsylvania': 5.0,
    'Rhode Island': 5.0,
    'South Carolina': 5.0,
    'South Dakota': 10.0,
    'Tennessee': 0.0,
    'Texas': 6.0,
    'Utah': 10.0,
    'Vermont': 5.0,
    'Virginia': 5.0,
    'Washington': 10.0,
    'West Virginia': 10.0,
    'Wisconsin': 5.0,
    'Wyoming': 10.0,
    'Los Angeles (City)': 15.0,
    'New York (City)': 2.0,
    'Chicago (City)': 1.0,
    'Houston (City)': 6.0,
    'Phoenix (City)': 10.0,
    'Philadelphia (City)': 5.0,
    'San Antonio (City)': 6.0,
    'San Diego (City)': 15.0,
    'Dallas (City)': 6.0,
    'San Jose (City)': 15.0,
  };

  @override
  void initState() {
    super.initState();
    _loadSavedRates();
  }

  Future<void> _loadSavedRates() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _selectedCountry = prefs.getString('selected_country') ?? 'USA';
      _selectedState = prefs.getString('selected_state');
      _signatureRate = prefs.getDouble('signature_rate') ?? 15.0;
      _mileageRate = prefs.getDouble('mileage_rate') ?? 0.67;
    });
  }

  Future<void> _saveRates() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('selected_country', _selectedCountry);
    if (_selectedState != null) await prefs.setString('selected_state', _selectedState!);
    await prefs.setDouble('signature_rate', _signatureRate);
    await prefs.setDouble('mileage_rate', _mileageRate);
    
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Rates saved!'), backgroundColor: Colors.green),
      );
    }
  }

  void _calculate() {
    final sigs = int.tryParse(_signaturesCtrl.text) ?? 0;
    final miles = double.tryParse(_milesCtrl.text) ?? 0;
    setState(() {
      _estimate = (sigs * _signatureRate) + (miles * _mileageRate);
    });
  }

  void _showRateSettings() {
    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: const Text('Configure Rates'),
          content: SizedBox(
            width: 300,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  DropdownButtonFormField<String>(
                    value: _selectedCountry,
                    decoration: const InputDecoration(
                      labelText: "Region/Country",
                      border: OutlineInputBorder(),
                    ),
                    items: _countryRates.keys.map((country) {
                      return DropdownMenuItem(value: country, child: Text(country));
                    }).toList(),
                    onChanged: (value) {
                      setDialogState(() {
                        _selectedCountry = value!;
                        if (value != 'USA') {
                          _signatureRate = _countryRates[value]!['signature']!;
                          _mileageRate = _countryRates[value]!['mileage']!;
                          _selectedState = null;
                        } else if (value == 'USA') {
                           _mileageRate = _countryRates['USA']!['mileage']!;
                        }
                      });
                    },
                  ),
                  if (_selectedCountry == 'USA') ...[
                    const SizedBox(height: 16),
                    DropdownButtonFormField<String>(
                      value: _selectedState,
                      decoration: const InputDecoration(
                        labelText: "State / City",
                        border: OutlineInputBorder(),
                        helperText: "Sets max fee per signature",
                      ),
                      items: _usStateRates.keys.map((state) {
                        return DropdownMenuItem(value: state, child: Text(state));
                      }).toList(),
                      onChanged: (value) {
                        setDialogState(() {
                          _selectedState = value;
                          if (value != null) {
                            _signatureRate = _usStateRates[value]!;
                          }
                        });
                      },
                    ),
                  ],
                  const SizedBox(height: 16),
                  TextFormField(
                    key: ValueKey("sig_$_signatureRate"), // Force rebuild on change
                    initialValue: _signatureRate.toStringAsFixed(2),
                    decoration: const InputDecoration(
                      labelText: "Rate per Signature (\$)",
                      border: OutlineInputBorder(),
                      helperText: "You can override this rate",
                    ),
                    keyboardType: TextInputType.number,
                    enabled: true,
                    onChanged: (value) {
                      // Update local variable without rebuilding dialog to avoid cursor jump
                      _signatureRate = double.tryParse(value) ?? 0.0;
                    },
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    key: ValueKey("mil_$_mileageRate"),
                    initialValue: _mileageRate.toStringAsFixed(2),
                    decoration: const InputDecoration(
                      labelText: "Rate per Mile (\$)",
                      border: OutlineInputBorder(),
                      helperText: "You can override this rate",
                    ),
                    keyboardType: TextInputType.number,
                    enabled: true,
                    onChanged: (value) {
                      _mileageRate = double.tryParse(value) ?? 0.0;
                    },
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () {
                setState(() {
                  // Update main state
                });
                _saveRates();
                _calculate();
                Navigator.pop(context);
              },
              child: const Text('Save'),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 500),
          child: Card(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text("Fee Estimator", style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                      IconButton(
                        onPressed: _showRateSettings,
                        icon: const Icon(Icons.settings),
                        tooltip: 'Configure Rates',
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.indigo.shade50,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.info_outline, size: 16, color: Colors.indigo),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            "Region: $_selectedCountry ${_selectedState != null ? '($_selectedState)' : ''} | \$${_signatureRate.toStringAsFixed(2)}/sig • \$${_mileageRate.toStringAsFixed(2)}/mi",
                            style: const TextStyle(fontSize: 12, color: Colors.indigo),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  TextField(
                    controller: _signaturesCtrl,
                    decoration: InputDecoration(
                      labelText: "Number of Signatures",
                      border: const OutlineInputBorder(),
                      helperText: "\$${_signatureRate.toStringAsFixed(2)} per signature",
                    ),
                    keyboardType: TextInputType.number,
                    onChanged: (_) => _calculate(),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: _milesCtrl,
                    decoration: InputDecoration(
                      labelText: "Miles Driven",
                      border: const OutlineInputBorder(),
                      helperText: "\$${_mileageRate.toStringAsFixed(2)} per mile",
                    ),
                    keyboardType: TextInputType.number,
                    onChanged: (_) => _calculate(),
                  ),
                  const SizedBox(height: 32),
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [Colors.indigo.shade600, Colors.indigo.shade400],
                      ),
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.indigo.withOpacity(0.3),
                          blurRadius: 8,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text("Estimated Total:", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
                        Text("\$${_estimate.toStringAsFixed(2)}", style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.white)),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    "💡 Tip: Configure rates for your region using the settings button above",
                    style: TextStyle(fontSize: 12, color: Colors.grey.shade600, fontStyle: FontStyle.italic),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// --- SETTINGS SCREEN ---
class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final _formKey = GlobalKey<FormState>();
  final _businessNameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  final _addressCtrl = TextEditingController();
  final _commissionNumberCtrl = TextEditingController();
  final _commissionExpCtrl = TextEditingController();
  String? _logoUrl;
  bool _isSaving = false;
  bool _isLoading = true;
  bool _isUploading = false;
  String _selectedPlan = 'yearly'; // Default to yearly

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    try {
      final uid = FirebaseAuth.instance.currentUser!.uid;
      final doc = await FirebaseFirestore.instance
          .doc('artifacts/notaryflow-v2/users/$uid/profile/business_info')
          .get();

      if (mounted) {
        if (doc.exists) {
          setState(() {
            _businessNameCtrl.text = doc['businessName'] ?? '';
            _emailCtrl.text = doc['email'] ?? '';
            _phoneCtrl.text = doc['phone'] ?? '';
            _addressCtrl.text = doc['address'] ?? '';
            _commissionNumberCtrl.text = doc['commissionNumber'] ?? '';
            _commissionExpCtrl.text = doc['commissionExp'] ?? '';
            _logoUrl = doc['logoUrl'];
            _isLoading = false;
          });
        } else {
          setState(() => _isLoading = false);
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _launchPaymentUrl(String urlString) async {
    try {
      if (kIsWeb) {
        html.window.open(urlString, '_blank');
      } else {
        final Uri url = Uri.parse(urlString);
        if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Could not launch payment page.')),
            );
          }
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    }
  }

  Future<void> _pickAndUploadImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);
    
    if (image == null) return;

    setState(() => _isUploading = true);

    try {
      final uid = FirebaseAuth.instance.currentUser!.uid;
      final ref = FirebaseStorage.instance
          .ref()
          .child('users/$uid/logo.jpg');
      
      if (kIsWeb) {
        await ref.putData(await image.readAsBytes(), SettableMetadata(contentType: 'image/jpeg'));
      } else {
        await ref.putFile(File(image.path));
      }

      final url = await ref.getDownloadURL();
      
      setState(() {
        _logoUrl = url;
        _isUploading = false;
      });

      // Auto-save the new logo URL to profile
      await FirebaseFirestore.instance
          .doc('artifacts/notaryflow-v2/users/$uid/profile/business_info')
          .set({'logoUrl': url}, SetOptions(merge: true));

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Logo updated!'), backgroundColor: Colors.green),
        );
      }
    } catch (e) {
      setState(() => _isUploading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Upload failed: $e. Ensure Firebase Storage is enabled.'), backgroundColor: Colors.red),
        );
      }
    }
  }

  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSaving = true);

    try {
      final uid = FirebaseAuth.instance.currentUser!.uid;
      await FirebaseFirestore.instance
          .doc('artifacts/notaryflow-v2/users/$uid/profile/business_info')
          .set({
        'businessName': _businessNameCtrl.text.trim(),
        'email': _emailCtrl.text.trim(),
        'phone': _phoneCtrl.text.trim(),
        'address': _addressCtrl.text.trim(),
        'commissionNumber': _commissionNumberCtrl.text.trim(),
        'commissionExp': _commissionExpCtrl.text.trim(),
        'logoUrl': _logoUrl,
        'updatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Profile saved!'), backgroundColor: Colors.green),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
        );
      }
    } finally {
      setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 600),
          child: Card(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text("Business Profile", style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 24),
                    
                    // --- LOGO UPLOAD ---
                    Center(
                      child: Stack(
                        children: [
                          CircleAvatar(
                            radius: 50,
                            backgroundColor: Colors.indigo.shade50,
                            backgroundImage: _logoUrl != null ? NetworkImage(_logoUrl!) : null,
                            child: _logoUrl == null
                                ? Text(
                                    _businessNameCtrl.text.isNotEmpty ? _businessNameCtrl.text[0].toUpperCase() : 'B',
                                    style: const TextStyle(fontSize: 40, fontWeight: FontWeight.bold, color: Colors.indigo),
                                  )
                                : null,
                          ),
                          Positioned(
                            bottom: 0,
                            right: 0,
                            child: InkWell(
                              onTap: _isUploading ? null : _pickAndUploadImage,
                              child: CircleAvatar(
                                radius: 18,
                                backgroundColor: Colors.white,
                                child: _isUploading
                                    ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2))
                                    : const Icon(Icons.camera_alt, size: 20, color: Colors.indigo),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),

                    TextFormField(
                      controller: _businessNameCtrl,
                      decoration: const InputDecoration(labelText: "Business Name", border: OutlineInputBorder()),
                      validator: (v) => v == null || v.trim().isEmpty ? 'Required' : null,
                      onChanged: (val) => setState(() {}), // Update avatar preview
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _emailCtrl,
                      decoration: const InputDecoration(labelText: "Email", border: OutlineInputBorder()),
                      keyboardType: TextInputType.emailAddress,
                      validator: (v) {
                        if (v == null || v.isEmpty) return 'Required';
                        if (!v.contains('@')) return 'Invalid email';
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _phoneCtrl,
                      decoration: const InputDecoration(labelText: "Phone", border: OutlineInputBorder()),
                      keyboardType: TextInputType.phone,
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _addressCtrl,
                      decoration: const InputDecoration(labelText: "Address", border: OutlineInputBorder()),
                      maxLines: 2,
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: TextFormField(
                            controller: _commissionNumberCtrl,
                            decoration: const InputDecoration(labelText: "Commission Number", border: OutlineInputBorder()),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: TextFormField(
                            controller: _commissionExpCtrl,
                            decoration: const InputDecoration(labelText: "Expiration Date", border: OutlineInputBorder(), hintText: "MM/DD/YYYY"),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    // --- PREMIUM SUBSCRIPTION SECTION ---
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.amber.shade50,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: Colors.amber.shade200),
                        boxShadow: [
                          BoxShadow(color: Colors.amber.withOpacity(0.1), blurRadius: 10, offset: const Offset(0, 4)),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Row(
                            children: [
                              Icon(Icons.star, color: Colors.amber, size: 28),
                              SizedBox(width: 12),
                              Text("Go Premium", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.black87)),
                            ],
                          ),
                          const SizedBox(height: 12),
                          const Text("Unlock unlimited invoices, cloud sync, and advanced analytics.", style: TextStyle(fontSize: 14, color: Colors.black54)),
                          const SizedBox(height: 20),
                          Row(
                            children: [
                              Expanded(
                                child: InkWell(
                                  onTap: () => setState(() => _selectedPlan = 'monthly'),
                                  child: Container(
                                    padding: const EdgeInsets.all(12),
                                    decoration: BoxDecoration(
                                      color: _selectedPlan == 'monthly' ? Colors.amber.shade100 : Colors.white,
                                      borderRadius: BorderRadius.circular(8),
                                      border: Border.all(
                                        color: _selectedPlan == 'monthly' ? Colors.amber : Colors.amber.shade200,
                                        width: _selectedPlan == 'monthly' ? 2 : 1,
                                      ),
                                    ),
                                    child: Column(
                                      children: [
                                        Text("Monthly", style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: _selectedPlan == 'monthly' ? Colors.brown : Colors.grey)),
                                        const SizedBox(height: 4),
                                        const Text("\$14.99", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black)),
                                        if (_selectedPlan == 'monthly')
                                          const Icon(Icons.check_circle, color: Colors.amber, size: 16),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: InkWell(
                                  onTap: () => setState(() => _selectedPlan = 'yearly'),
                                  child: Container(
                                    padding: const EdgeInsets.all(12),
                                    decoration: BoxDecoration(
                                      color: _selectedPlan == 'yearly' ? Colors.amber.shade100 : Colors.white,
                                      borderRadius: BorderRadius.circular(8),
                                      border: Border.all(
                                        color: _selectedPlan == 'yearly' ? Colors.amber : Colors.amber.shade200,
                                        width: _selectedPlan == 'yearly' ? 2 : 1,
                                      ),
                                    ),
                                    child: Column(
                                      children: [
                                        Text("Yearly (Save 17%)", style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: _selectedPlan == 'yearly' ? Colors.brown : Colors.grey)),
                                        const SizedBox(height: 4),
                                        const Text("\$149.00", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black)),
                                        if (_selectedPlan == 'yearly')
                                          const Icon(Icons.check_circle, color: Colors.amber, size: 16),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 20),
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              onPressed: () {
                                final url = _selectedPlan == 'monthly'
                                    ? 'https://notariflow.lemonsqueezy.com/buy/101bec89-b835-4862-a493-526855bde384'
                                    : 'https://notariflow.lemonsqueezy.com/buy/74996c57-0a9e-4890-b424-86bd3aac606d';
                                _launchPaymentUrl(url);
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.black,
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(vertical: 16),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                              ),
                              child: Text("Subscribe ${_selectedPlan == 'monthly' ? 'Monthly' : 'Yearly'}", style: const TextStyle(fontWeight: FontWeight.bold)),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _isSaving ? null : _saveProfile,
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                        ),
                        child: _isSaving
                            ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                            : const Text("Save Profile"),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// --- EMPTY STATE WIDGET ---
class _EmptyState extends StatelessWidget {
  final IconData icon;
  final String title;
  final String message;

  const _EmptyState({required this.icon, required this.title, required this.message});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(48.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 80, color: Colors.grey.shade300),
            const SizedBox(height: 16),
            Text(title, style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.grey.shade600)),
            const SizedBox(height: 8),
            Text(message, style: TextStyle(color: Colors.grey.shade500), textAlign: TextAlign.center),
          ],
        ),
      ),
    );
  }
}

// --- MORE SCREEN (Mobile Menu) ---
class MoreScreen extends StatelessWidget {
  const MoreScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GridView.count(
        crossAxisCount: 2,
        padding: const EdgeInsets.all(16),
        mainAxisSpacing: 16,
        crossAxisSpacing: 16,
        children: [
          _MenuCard(
            icon: Icons.analytics, 
            title: 'Analytics', 
            color: Colors.purple,
            onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => Scaffold(appBar: AppBar(title: const Text('Analytics')), body: const AnalyticsScreen()))),
          ),
          _MenuCard(
            icon: Icons.attach_money, 
            title: 'Expenses', 
            color: Colors.red,
            onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => Scaffold(appBar: AppBar(title: const Text('Expenses')), body: const ExpensesScreen()))),
          ),
          _MenuCard(
            icon: Icons.people, 
            title: 'Clients', 
            color: Colors.orange,
            onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => Scaffold(appBar: AppBar(title: const Text('Clients')), body: const ClientsScreen()))),
          ),
          _MenuCard(
            icon: Icons.calculate, 
            title: 'Calculator', 
            color: Colors.teal,
            onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => Scaffold(appBar: AppBar(title: const Text('Fee Calculator')), body: const CalculatorScreen()))),
          ),
          _MenuCard(
            icon: Icons.settings, 
            title: 'Settings', 
            color: Colors.grey,
            onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => Scaffold(appBar: AppBar(title: const Text('Settings')), body: const SettingsScreen()))),
          ),
        ],
      ),
    );
  }
}

class _MenuCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final Color color;
  final VoidCallback onTap;

  const _MenuCard({required this.icon, required this.title, required this.color, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, size: 32, color: color),
            ),
            const SizedBox(height: 12),
            Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          ],
        ),
      ),
    );
  }
}
