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
import 'package:universal_html/html.dart' as html;
import 'package:geolocator/geolocator.dart';
import 'package:shared_preferences/shared_preferences.dart';

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
  try {
    await Firebase.initializeApp(options: firebaseOptions);
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

  final List<Widget> _screens = [
    const DashboardScreen(),
    const AnalyticsScreen(),
    const InvoicesScreen(),
    const ClientsScreen(),
    const MileageScreen(),
    const CalculatorScreen(),
    const SettingsScreen(),
  ];

  // Mobile optimized screens (same as desktop now - simplified)
  final List<Widget> _mobileScreens = [
    const DashboardScreen(),
    const AnalyticsScreen(),
    const InvoicesScreen(),
    const ClientsScreen(),
    const MileageScreen(),
    const CalculatorScreen(),
    const SettingsScreen(),
  ];

  String _getScreenTitle(int index, bool isMobile) {
    switch (index) {
      case 0: return 'Dashboard';
      case 1: return 'Analytics';
      case 2: return 'Invoices';
      case 3: return 'Clients';
      case 4: return 'Mileage';
      case 5: return 'Calculator';
      case 6: return 'Settings';
      default: return 'NotaryFlow';
    }
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        bool isWide = constraints.maxWidth > 800;
        final screens = isWide ? _screens : _mobileScreens;

        return Scaffold(
          body: Row(
            children: [
              if (isWide)
                NavigationRail(
                  selectedIndex: _selectedIndex,
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
                    NavigationRailDestination(icon: Icon(Icons.people), label: Text('Clients')),
                    NavigationRailDestination(icon: Icon(Icons.directions_car), label: Text('Mileage')),
                    NavigationRailDestination(icon: Icon(Icons.calculate), label: Text('Calculator')),
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
                            _getScreenTitle(_selectedIndex, !isWide),
                            style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.black87),
                          ),
                          PopupMenuButton<String>(
                            child: CircleAvatar(
                              backgroundColor: Colors.indigo,
                              child: Text(
                                (FirebaseAuth.instance.currentUser?.displayName ?? 'U')[0].toUpperCase(),
                                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                              ),
                            ),
                            itemBuilder: (context) => <PopupMenuEntry<String>>[
                              PopupMenuItem(
                                child: Text(FirebaseAuth.instance.currentUser?.email ?? ''),
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
                          ),
                        ],
                      ),
                    ),
                    const Divider(height: 1),
                    Expanded(child: screens[_selectedIndex]),
                  ],
                ),
              ),
            ],
          ),
          bottomNavigationBar: isWide
              ? null
              : BottomNavigationBar(
                  currentIndex: _selectedIndex,
                  onTap: (index) => setState(() => _selectedIndex = index),
                  type: BottomNavigationBarType.fixed,
                  selectedItemColor: Colors.indigo,
                  unselectedItemColor: Colors.grey,
                  selectedFontSize: 12,
                  unselectedFontSize: 11,
                  items: const [
                    BottomNavigationBarItem(icon: Icon(Icons.dashboard), label: 'Home'),
                    BottomNavigationBarItem(icon: Icon(Icons.analytics), label: 'Analytics'),
                    BottomNavigationBarItem(icon: Icon(Icons.receipt_long), label: 'Invoices'),
                    BottomNavigationBarItem(icon: Icon(Icons.people), label: 'Clients'),
                    BottomNavigationBarItem(icon: Icon(Icons.directions_car), label: 'Mileage'),
                    BottomNavigationBarItem(icon: Icon(Icons.calculate), label: 'Calc'),
                    BottomNavigationBarItem(icon: Icon(Icons.settings), label: 'Settings'),
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
            if (!invSnapshot.hasData || !tripSnapshot.hasData) {
              return const Center(child: CircularProgressIndicator());
            }

            final invoices = invSnapshot.data!.docs;
            final trips = tripSnapshot.data!.docs;

            double totalIncome = 0;
            double pendingIncome = 0;
            double paidIncome = 0;

            for (var doc in invoices) {
              final amount = (doc['amount'] as num).toDouble();
              totalIncome += amount;
              if (doc['status'] == 'Pending') pendingIncome += amount;
              if (doc['status'] == 'Paid') paidIncome += amount;
            }

            double totalMiles = 0;
            for (var doc in trips) {
              totalMiles += (doc['miles'] as num).toDouble();
            }
            double taxDed = totalMiles * 0.67;

            return SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  Wrap(
                    spacing: 16,
                    runSpacing: 16,
                    children: [
                      _StatCard(title: "Total Revenue", value: "\$${totalIncome.toStringAsFixed(2)}", icon: Icons.attach_money, color: Colors.green),
                      _StatCard(title: "Paid", value: "\$${paidIncome.toStringAsFixed(2)}", icon: Icons.check_circle, color: Colors.blue),
                      _StatCard(title: "Pending", value: "\$${pendingIncome.toStringAsFixed(2)}", icon: Icons.access_time, color: Colors.orange),
                      _StatCard(title: "Tax Deductions", value: "\$${taxDed.toStringAsFixed(2)}", icon: Icons.directions_car, color: Colors.purple),
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
                                  Text("\$${doc['amount']}", style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
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

        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text("Revenue Trend", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              const SizedBox(height: 16),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: SizedBox(
                    height: 250,
                    child: LineChart(
                      LineChartData(
                        gridData: FlGridData(show: true),
                        titlesData: FlTitlesData(
                          bottomTitles: AxisTitles(
                            sideTitles: SideTitles(
                              showTitles: true,
                              getTitlesWidget: (value, meta) {
                                if (value.toInt() >= 0 && value.toInt() < sortedMonths.length) {
                                  return Text(
                                    sortedMonths[value.toInt()].substring(5),
                                    style: const TextStyle(fontSize: 10),
                                  );
                                }
                                return const Text('');
                              },
                              reservedSize: 30,
                            ),
                          ),
                          leftTitles: AxisTitles(
                            sideTitles: SideTitles(
                              showTitles: true,
                              reservedSize: 50,
                              getTitlesWidget: (value, meta) {
                                return Text('\$${value.toInt()}', style: const TextStyle(fontSize: 10));
                              },
                            ),
                          ),
                          topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                          rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                        ),
                        borderData: FlBorderData(show: true, border: Border.all(color: Colors.grey.shade300)),
                        lineBarsData: [
                          LineChartBarData(
                            spots: revenueData.asMap().entries.map((e) => FlSpot(e.key.toDouble(), e.value)).toList(),
                            isCurved: true,
                            color: Colors.indigo,
                            barWidth: 3,
                            dotData: const FlDotData(show: true),
                            belowBarData: BarAreaData(
                              show: true,
                              color: Colors.indigo.withOpacity(0.1),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 32),
              const Text("Invoice Status Distribution", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              const SizedBox(height: 16),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: SizedBox(
                    height: 250,
                    child: PieChart(
                      PieChartData(
                        sections: [
                          PieChartSectionData(
                            value: statusCounts['Paid']!.toDouble(),
                            title: '${statusCounts['Paid']}',
                            color: Colors.green,
                            radius: 100,
                            titleStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
                          ),
                          PieChartSectionData(
                            value: statusCounts['Pending']!.toDouble(),
                            title: '${statusCounts['Pending']}',
                            color: Colors.orange,
                            radius: 100,
                            titleStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
                          ),
                          PieChartSectionData(
                            value: statusCounts['Overdue']!.toDouble(),
                            title: '${statusCounts['Overdue']}',
                            color: Colors.red,
                            radius: 100,
                            titleStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _LegendItem(color: Colors.green, label: 'Paid'),
                  _LegendItem(color: Colors.orange, label: 'Pending'),
                  _LegendItem(color: Colors.red, label: 'Overdue'),
                ],
              ),
            ],
          ),
        );
      },
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

// --- MILEAGE SCREEN WITH GPS ---
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

  void _startTrip() async {
    // For web, we'll use a simpler approach
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Location services are disabled. You can still enter miles manually.'),
              backgroundColor: Colors.orange,
            ),
          );
        }
        setState(() {
          _isTracking = true;
          _startTime = DateTime.now();
        });
        return;
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Location permission denied. Enter miles manually.'),
                backgroundColor: Colors.orange,
              ),
            );
          }
          setState(() {
            _isTracking = true;
            _startTime = DateTime.now();
          });
          return;
        }
      }

      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      ).timeout(const Duration(seconds: 5));
      
      setState(() {
        _isTracking = true;
        _startTime = DateTime.now();
        _startPosition = position;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Trip started! GPS tracking enabled.'), backgroundColor: Colors.green),
        );
      }
    } catch (e) {
      setState(() {
        _isTracking = true;
        _startTime = DateTime.now();
      });
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('GPS unavailable. Please enter miles manually.'),
            backgroundColor: Colors.orange,
          ),
        );
      }
    }
  }

  void _stopTrip() async {
    if (_startPosition != null) {
      try {
        final endPosition = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high,
        ).timeout(const Duration(seconds: 5));

        // Calculate distance in miles
        final distanceInMeters = Geolocator.distanceBetween(
          _startPosition!.latitude,
          _startPosition!.longitude,
          endPosition.latitude,
          endPosition.longitude,
        );
        final distanceInMiles = (distanceInMeters / 1609.344).toStringAsFixed(2);

        _milesCtrl.text = distanceInMiles;
        
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Distance tracked: $distanceInMiles miles'), backgroundColor: Colors.green),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Could not calculate distance. Please enter manually.'),
              backgroundColor: Colors.orange,
            ),
          );
        }
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
              Card(
                color: _isTracking ? Colors.green.shade50 : Colors.white,
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    children: [
                      Icon(_isTracking ? Icons.location_on : Icons.location_off, size: 64, color: _isTracking ? Colors.green : Colors.grey),
                      const SizedBox(height: 16),
                      Text(
                        _isTracking ? "GPS Tracking Active" : "Not Tracking",
                        style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: _isTracking ? Colors.green : Colors.grey),
                      ),
                      if (_isTracking && _startPosition != null) ...[
                        const SizedBox(height: 8),
                        Text(
                          "Started: ${DateFormat('h:mm a').format(_startTime!)}",
                          style: const TextStyle(color: Colors.grey),
                        ),
                      ],
                      const SizedBox(height: 16),
                      ElevatedButton.icon(
                        onPressed: _isTracking ? _stopTrip : _startTrip,
                        icon: Icon(_isTracking ? Icons.stop : Icons.play_arrow),
                        label: Text(_isTracking ? "Stop Trip" : "Start GPS Trip"),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: _isTracking ? Colors.red : Colors.green,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),
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
                              const Text("Log Trip", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
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
                              labelText: "Miles",
                              border: const OutlineInputBorder(),
                              suffixIcon: _startPosition != null 
                                ? const Icon(Icons.gps_fixed, color: Colors.green)
                                : null,
                            ),
                            keyboardType: TextInputType.number,
                            validator: (v) {
                              if (v == null || v.isEmpty) return 'Required';
                              final miles = double.tryParse(v);
                              if (miles == null || miles <= 0) return 'Enter valid miles';
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
                          message: "Start tracking your mileage with GPS",
                        )
                      else
                        ...trips.map((doc) => ListTile(
                          leading: CircleAvatar(
                            backgroundColor: doc['gpsTracked'] == true ? Colors.green.shade100 : Colors.grey.shade100,
                            child: Icon(
                              doc['gpsTracked'] == true ? Icons.gps_fixed : Icons.location_on,
                              color: doc['gpsTracked'] == true ? Colors.green : Colors.grey,
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
                                        Text("\$${doc['amount']}", style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
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
                  pw.Text('\$${invoice['amount']}', style: pw.TextStyle(fontSize: 20, fontWeight: pw.FontWeight.bold)),
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
                  decoration: const InputDecoration(labelText: "Amount", prefixText: "\$", border: OutlineInputBorder()),
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
  double _signatureRate = 15.0;
  double _mileageRate = 0.67;

  final Map<String, Map<String, double>> _countryRates = {
    'USA': {'signature': 15.0, 'mileage': 0.67},
    'Canada': {'signature': 20.0, 'mileage': 0.68},
    'UK': {'signature': 12.0, 'mileage': 0.45},
    'Australia': {'signature': 18.0, 'mileage': 0.78},
    'Custom': {'signature': 0.0, 'mileage': 0.0},
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
      _signatureRate = prefs.getDouble('signature_rate') ?? 15.0;
      _mileageRate = prefs.getDouble('mileage_rate') ?? 0.67;
    });
  }

  Future<void> _saveRates() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('selected_country', _selectedCountry);
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
                      if (value != 'Custom') {
                        _signatureRate = _countryRates[value]!['signature']!;
                        _mileageRate = _countryRates[value]!['mileage']!;
                      }
                    });
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  initialValue: _signatureRate.toStringAsFixed(2),
                  decoration: const InputDecoration(
                    labelText: "Rate per Signature (\$)",
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.number,
                  enabled: _selectedCountry == 'Custom',
                  onChanged: (value) {
                    setDialogState(() {
                      _signatureRate = double.tryParse(value) ?? 15.0;
                    });
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  initialValue: _mileageRate.toStringAsFixed(2),
                  decoration: const InputDecoration(
                    labelText: "Rate per Mile/KM (\$)",
                    border: OutlineInputBorder(),
                    helperText: "IRS standard rate (2025): \$0.67/mile",
                  ),
                  keyboardType: TextInputType.number,
                  enabled: _selectedCountry == 'Custom',
                  onChanged: (value) {
                    setDialogState(() {
                      _mileageRate = double.tryParse(value) ?? 0.67;
                    });
                  },
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
                            "Region: $_selectedCountry | \$${_signatureRate.toStringAsFixed(2)}/signature • \$${_mileageRate.toStringAsFixed(2)}/mile",
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
  bool _isSaving = false;
  bool _isLoading = true;

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
        'updatedAt': FieldValue.serverTimestamp(),
      });

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
                    TextFormField(
                      controller: _businessNameCtrl,
                      decoration: const InputDecoration(labelText: "Business Name", border: OutlineInputBorder()),
                      validator: (v) => v == null || v.trim().isEmpty ? 'Required' : null,
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
