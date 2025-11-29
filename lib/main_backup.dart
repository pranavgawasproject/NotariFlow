import 'dart:async';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

// --- CONFIGURATION ---
// Firebase Configuration for NotariFlow
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
class AuthWrapper extends StatefulWidget {
  const AuthWrapper({super.key});

  @override
  State<AuthWrapper> createState() => _AuthWrapperState();
}

class _AuthWrapperState extends State<AuthWrapper> {
  @override
  void initState() {
    super.initState();
    _signIn();
  }

  Future<void> _signIn() async {
    if (FirebaseAuth.instance.currentUser == null) {
      await FirebaseAuth.instance.signInAnonymously();
    }
  }

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
        return const Scaffold(
          body: Center(child: Text("Authenticating secure session...")),
        );
      },
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
    const MileageScreen(),
    const InvoicesScreen(),
    const ClientsScreen(),
    const CalculatorScreen(),
    const SettingsScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        bool isWide = constraints.maxWidth > 800;

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
                  leading: const Padding(
                    padding: EdgeInsets.symmetric(vertical: 24.0),
                    child: Row(
                      children: [
                        Icon(Icons.work, color: Colors.white),
                        SizedBox(width: 8),
                        Text("NotaryFlow", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18)),
                      ],
                    ),
                  ),
                  destinations: const [
                    NavigationRailDestination(icon: Icon(Icons.dashboard), label: Text('Dashboard')),
                    NavigationRailDestination(icon: Icon(Icons.directions_car), label: Text('Mileage')),
                    NavigationRailDestination(icon: Icon(Icons.attach_money), label: Text('Invoices')),
                    NavigationRailDestination(icon: Icon(Icons.people), label: Text('Clients')),
                    NavigationRailDestination(icon: Icon(Icons.calculate), label: Text('Estimator')),
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
                            _getScreenTitle(_selectedIndex),
                            style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.black87),
                          ),
                          const CircleAvatar(
                            backgroundColor: Colors.indigo,
                            child: Icon(Icons.person, color: Colors.white),
                          ),
                        ],
                      ),
                    ),
                    const Divider(height: 1),
                    Expanded(child: _screens[_selectedIndex]),
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
                  items: const [
                    BottomNavigationBarItem(icon: Icon(Icons.dashboard), label: 'Dashboard'),
                    BottomNavigationBarItem(icon: Icon(Icons.directions_car), label: 'Mileage'),
                    BottomNavigationBarItem(icon: Icon(Icons.attach_money), label: 'Invoices'),
                    BottomNavigationBarItem(icon: Icon(Icons.people), label: 'Clients'),
                    BottomNavigationBarItem(icon: Icon(Icons.calculate), label: 'Estimator'),
                    BottomNavigationBarItem(icon: Icon(Icons.settings), label: 'Settings'),
                  ],
                ),
        );
      },
    );
  }

  String _getScreenTitle(int index) {
    switch (index) {
      case 0: return 'Dashboard';
      case 1: return 'Mileage Tracker';
      case 2: return 'Invoices';
      case 3: return 'Client Rolodex';
      case 4: return 'Fee Estimator';
      case 5: return 'Settings';
      default: return 'NotaryFlow';
    }
  }
}

// --- 1. DASHBOARD SCREEN ---
class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final uid = FirebaseAuth.instance.currentUser!.uid;
    final Stream<QuerySnapshot> invoiceStream = FirebaseFirestore.instance
        .collection('artifacts/notaryflow-v2/users/$uid/invoices')
        .snapshots();
    final Stream<QuerySnapshot> tripStream = FirebaseFirestore.instance
        .collection('artifacts/notaryflow-v2/users/$uid/trips')
        .snapshots();

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: StreamBuilder(
        stream: invoiceStream,
        builder: (context, invSnapshot) {
          return StreamBuilder(
            stream: tripStream,
            builder: (context, tripSnapshot) {
              if (!invSnapshot.hasData || !tripSnapshot.hasData) {
                return const Center(child: CircularProgressIndicator());
              }

              final invoices = invSnapshot.data!.docs;
              final trips = tripSnapshot.data!.docs;

              double totalIncome = 0;
              double pendingIncome = 0;
              for (var doc in invoices) {
                totalIncome += (doc['amount'] as num).toDouble();
                if (doc['status'] == 'Pending') pendingIncome += (doc['amount'] as num).toDouble();
              }

              double totalMiles = 0;
              for (var doc in trips) {
                totalMiles += (doc['miles'] as num).toDouble();
              }
              double taxDed = totalMiles * 0.67;

              return Column(
                children: [
                  Wrap(
                    spacing: 16,
                    runSpacing: 16,
                    children: [
                      _StatCard(title: "Revenue", value: "\$${totalIncome.toStringAsFixed(2)}", icon: Icons.attach_money, color: Colors.green),
                      _StatCard(title: "Pending", value: "\$${pendingIncome.toStringAsFixed(2)}", icon: Icons.access_time, color: Colors.orange),
                      _StatCard(title: "Tax Deductions", value: "\$${taxDed.toStringAsFixed(2)}", icon: Icons.directions_car, color: Colors.blue),
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
                                child: Icon(Icons.receipt, color: Colors.indigo),
                              ),
                              title: Text(doc['description'] ?? 'Unknown', style: const TextStyle(fontWeight: FontWeight.w600)),
                              subtitle: Text(doc['date'] ?? ''),
                              trailing: Text("\$${doc['amount']}", style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                            )),
                        ],
                      ),
                    ),
                  ),
                ],
              );
            },
          );
        },
      ),
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

// --- 2. MILEAGE SCREEN (IMPROVED) ---
class MileageScreen extends StatefulWidget {
  const MileageScreen({super.key});

  @override
  State<MileageScreen> createState() => _MileageScreenState();
}

class _MileageScreenState extends State<MileageScreen> {
  bool _isTracking = false;
  bool _showForm = false;
  int _seconds = 0;
  Timer? _timer;
  bool _isSaving = false;
  
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _milesCtrl = TextEditingController();
  final TextEditingController _purposeCtrl = TextEditingController();

  void _toggleTracking() {
    if (_isTracking) {
      _timer?.cancel();
      setState(() {
        _isTracking = false;
        _showForm = true; // Show form after stopping
      });
    } else {
      setState(() {
        _isTracking = true;
        _showForm = false;
        _seconds = 0;
      });
      _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
        setState(() => _seconds++);
      });
    }
  }

  Future<void> _saveTrip() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSaving = true);

    try {
      final uid = FirebaseAuth.instance.currentUser!.uid;
      await FirebaseFirestore.instance.collection('artifacts/notaryflow-v2/users/$uid/trips').add({
        'miles': double.parse(_milesCtrl.text),
        'purpose': _purposeCtrl.text,
        'date': DateFormat('yyyy-MM-dd').format(DateTime.now()),
        'duration': _seconds,
        'createdAt': FieldValue.serverTimestamp(),
      });

      _milesCtrl.clear();
      _purposeCtrl.clear();
      setState(() {
        _seconds = 0;
        _showForm = false;
        _isSaving = false;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Row(
              children: [
                Icon(Icons.check_circle, color: Colors.white),
                SizedBox(width: 12),
                Text("Trip saved successfully!"),
              ],
            ),
            backgroundColor: Colors.green,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (e) {
      setState(() => _isSaving = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.error, color: Colors.white),
                const SizedBox(width: 12),
                Expanded(child: Text("Error saving trip: ${e.toString()}")),
              ],
            ),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  String _formatTime(int s) {
    final duration = Duration(seconds: s);
    return duration.toString().split('.').first.padLeft(8, "0");
  }

  @override
  void dispose() {
    _timer?.cancel();
    _milesCtrl.dispose();
    _purposeCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(32),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(24),
              boxShadow: [BoxShadow(color: Colors.indigo.withOpacity(0.1), blurRadius: 20)],
            ),
            child: Column(
              children: [
                const Text(
                  "Trip Timer",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.grey),
                ),
                const SizedBox(height: 16),
                Text(
                  _formatTime(_seconds),
                  style: const TextStyle(fontSize: 52, fontFamily: 'Monospace', fontWeight: FontWeight.bold, color: Colors.indigo),
                ),
                const SizedBox(height: 24),
                ElevatedButton.icon(
                  onPressed: _toggleTracking,
                  icon: Icon(_isTracking ? Icons.stop : Icons.play_arrow),
                  label: Text(_isTracking ? "STOP TRIP" : "START TRIP"),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _isTracking ? Colors.red : Colors.indigo,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 18),
                    textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          if (_showForm)
            Card(
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        "Trip Details",
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _milesCtrl,
                        decoration: const InputDecoration(
                          labelText: "Miles Driven *",
                          suffixText: "mi",
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.straighten),
                        ),
                        keyboardType: const TextInputType.numberWithOptions(decimal: true),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter miles driven';
                          }
                          final miles = double.tryParse(value);
                          if (miles == null) {
                            return 'Please enter a valid number';
                          }
                          if (miles <= 0) {
                            return 'Miles must be greater than 0';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _purposeCtrl,
                        decoration: const InputDecoration(
                          labelText: "Purpose *",
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.description),
                          hintText: "e.g., Client meeting, Document signing",
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter trip purpose';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 20),
                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton(
                              onPressed: _isSaving ? null : () {
                                setState(() {
                                  _showForm = false;
                                  _milesCtrl.clear();
                                  _purposeCtrl.clear();
                                });
                              },
                              child: const Text("Cancel"),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            flex: 2,
                            child: ElevatedButton.icon(
                              onPressed: _isSaving ? null : _saveTrip,
                              icon: _isSaving
                                  ? const SizedBox(
                                      width: 20,
                                      height: 20,
                                      child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                                    )
                                  : const Icon(Icons.save),
                              label: Text(_isSaving ? "Saving..." : "Save Trip Log"),
                            ),
                          ),
                        ],
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

// --- 3. INVOICE SCREEN (IMPROVED) ---
class InvoicesScreen extends StatefulWidget {
  const InvoicesScreen({super.key});

  @override
  State<InvoicesScreen> createState() => _InvoicesScreenState();
}

class _InvoicesScreenState extends State<InvoicesScreen> {
  final _formKey = GlobalKey<FormState>();
  final _amountCtrl = TextEditingController();
  final _descCtrl = TextEditingController();
  String? _selectedClientId;
  bool _isSaving = false;

  void _showAddDialog(List<QueryDocumentSnapshot> clients, Map<String, String> clientMap) {
    _selectedClientId = null;
    _amountCtrl.clear();
    _descCtrl.clear();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("New Invoice"),
        content: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (clients.isEmpty)
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.orange.shade50,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Row(
                      children: [
                        Icon(Icons.warning, color: Colors.orange),
                        SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            "Please add clients first in the Clients tab",
                            style: TextStyle(color: Colors.orange),
                          ),
                        ),
                      ],
                    ),
                  )
                else
                  DropdownButtonFormField<String>(
                    value: _selectedClientId,
                    decoration: const InputDecoration(
                      labelText: "Client *",
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.person),
                    ),
                    hint: const Text("Select Client"),
                    items: clients.map((c) => DropdownMenuItem(
                      value: c.id,
                      child: Text(c['name']),
                    )).toList(),
                    onChanged: (v) => setState(() => _selectedClientId = v),
                    validator: (value) {
                      if (value == null) return 'Please select a client';
                      return null;
                    },
                  ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _amountCtrl,
                  decoration: const InputDecoration(
                    labelText: "Amount *",
                    prefixText: "\$ ",
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.attach_money),
                  ),
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter an amount';
                    }
                    final amount = double.tryParse(value);
                    if (amount == null) {
                      return 'Please enter a valid number';
                    }
                    if (amount <= 0) {
                      return 'Amount must be greater than 0';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _descCtrl,
                  decoration: const InputDecoration(
                    labelText: "Description *",
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.description),
                    hintText: "e.g., Notary services for loan docs",
                  ),
                  maxLines: 2,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter a description';
                    }
                    return null;
                  },
                ),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: _isSaving ? null : () => Navigator.pop(ctx),
            child: const Text("Cancel"),
          ),
          ElevatedButton.icon(
            onPressed: (_isSaving || clients.isEmpty) ? null : () async {
              if (!_formKey.currentState!.validate()) return;

              setState(() => _isSaving = true);

              try {
                final uid = FirebaseAuth.instance.currentUser!.uid;
                await FirebaseFirestore.instance.collection('artifacts/notaryflow-v2/users/$uid/invoices').add({
                  'clientId': _selectedClientId,
                  'amount': double.parse(_amountCtrl.text),
                  'description': _descCtrl.text,
                  'status': 'Pending',
                  'date': DateFormat('MM/dd/yyyy').format(DateTime.now()),
                  'createdAt': FieldValue.serverTimestamp(),
                });

                if (ctx.mounted) Navigator.pop(ctx);
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Row(
                        children: [
                          Icon(Icons.check_circle, color: Colors.white),
                          SizedBox(width: 12),
                          Text("Invoice created successfully!"),
                        ],
                      ),
                      backgroundColor: Colors.green,
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
                }
              } catch (e) {
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text("Error: ${e.toString()}"),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              } finally {
                setState(() => _isSaving = false);
              }
            },
            icon: _isSaving
                ? const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                  )
                : const Icon(Icons.add),
            label: Text(_isSaving ? "Creating..." : "Create"),
          ),
        ],
      ),
    );
  }

  void _showEditDialog(DocumentSnapshot invoice, Map<String, String> clientMap) {
    _amountCtrl.text = invoice['amount'].toString();
    _descCtrl.text = invoice['description'];
    _selectedClientId = invoice['clientId'];

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Edit Invoice"),
        content: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: _amountCtrl,
                decoration: const InputDecoration(
                  labelText: "Amount *",
                  prefixText: "\$ ",
                  border: OutlineInputBorder(),
                ),
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                validator: (value) {
                  if (value == null || value.isEmpty) return 'Required';
                  if (double.tryParse(value) == null || double.parse(value) <= 0) {
                    return 'Enter valid amount';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _descCtrl,
                decoration: const InputDecoration(
                  labelText: "Description *",
                  border: OutlineInputBorder(),
                ),
                maxLines: 2,
                validator: (value) => (value == null || value.isEmpty) ? 'Required' : null,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text("Cancel"),
          ),
          ElevatedButton.icon(
            onPressed: () async {
              if (!_formKey.currentState!.validate()) return;

              try {
                await invoice.reference.update({
                  'amount': double.parse(_amountCtrl.text),
                  'description': _descCtrl.text,
                });

                if (ctx.mounted) Navigator.pop(ctx);
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text("Invoice updated successfully!"),
                      backgroundColor: Colors.green,
                    ),
                  );
                }
              } catch (e) {
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text("Error: ${e.toString()}"),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              }
            },
            icon: const Icon(Icons.save),
            label: const Text("Update"),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final uid = FirebaseAuth.instance.currentUser!.uid;
    return StreamBuilder(
      stream: FirebaseFirestore.instance.collection('artifacts/notaryflow-v2/users/$uid/clients').snapshots(),
      builder: (context, clientSnap) {
        return StreamBuilder(
          stream: FirebaseFirestore.instance
              .collection('artifacts/notaryflow-v2/users/$uid/invoices')
              .orderBy('createdAt', descending: true)
              .snapshots(),
          builder: (context, invSnap) {
            if (!clientSnap.hasData || !invSnap.hasData) {
              return const Center(child: CircularProgressIndicator());
            }

            final clients = clientSnap.data!.docs;
            final invoices = invSnap.data!.docs;

            // Create client lookup map
            final Map<String, String> clientMap = {
              for (var client in clients) client.id: client['name']
            };

            return Scaffold(
              backgroundColor: Colors.transparent,
              floatingActionButton: FloatingActionButton.extended(
                onPressed: () => _showAddDialog(clients, clientMap),
                backgroundColor: Colors.indigo,
                icon: const Icon(Icons.add, color: Colors.white),
                label: const Text("New Invoice", style: TextStyle(color: Colors.white)),
              ),
              body: invoices.isEmpty
                  ? Center(
                      child: _EmptyState(
                        icon: Icons.receipt_long,
                        title: "No invoices yet",
                        message: "Tap the button below to create your first invoice",
                      ),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: invoices.length,
                      itemBuilder: (ctx, i) {
                        final inv = invoices[i];
                        final clientName = clientMap[inv['clientId']] ?? 'Unknown Client';

                        return Card(
                          margin: const EdgeInsets.only(bottom: 12),
                          child: ListTile(
                            leading: CircleAvatar(
                              backgroundColor: Colors.indigo.shade50,
                              child: const Icon(Icons.receipt, color: Colors.indigo),
                            ),
                            title: Text(
                              inv['description'],
                              style: const TextStyle(fontWeight: FontWeight.w600),
                            ),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const SizedBox(height: 4),
                                Row(
                                  children: [
                                    Icon(Icons.person, size: 14, color: Colors.grey.shade600),
                                    const SizedBox(width: 4),
                                    Text(clientName),
                                  ],
                                ),
                                const SizedBox(height: 2),
                                Row(
                                  children: [
                                    Icon(Icons.calendar_today, size: 14, color: Colors.grey.shade600),
                                    const SizedBox(width: 4),
                                    Text(inv['date'] ?? ''),
                                    const SizedBox(width: 16),
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                      decoration: BoxDecoration(
                                        color: inv['status'] == 'Pending' 
                                            ? Colors.orange.shade50 
                                            : Colors.green.shade50,
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: Text(
                                        inv['status'],
                                        style: TextStyle(
                                          fontSize: 11,
                                          color: inv['status'] == 'Pending' 
                                              ? Colors.orange.shade700 
                                              : Colors.green.shade700,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  "\$${inv['amount']}",
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 18,
                                    color: Colors.indigo,
                                  ),
                                ),
                                PopupMenuButton(
                                  itemBuilder: (context) => [
                                    const PopupMenuItem(
                                      value: 'edit',
                                      child: Row(
                                        children: [
                                          Icon(Icons.edit, size: 20),
                                          SizedBox(width: 12),
                                          Text('Edit'),
                                        ],
                                      ),
                                    ),
                                    const PopupMenuItem(
                                      value: 'delete',
                                      child: Row(
                                        children: [
                                          Icon(Icons.delete, size: 20, color: Colors.red),
                                          SizedBox(width: 12),
                                          Text('Delete', style: TextStyle(color: Colors.red)),
                                        ],
                                      ),
                                    ),
                                  ],
                                  onSelected: (value) async {
                                    if (value == 'edit') {
                                      _showEditDialog(inv, clientMap);
                                    } else if (value == 'delete') {
                                      final confirm = await showDialog<bool>(
                                        context: context,
                                        builder: (ctx) => AlertDialog(
                                          title: const Text('Delete Invoice'),
                                          content: const Text('Are you sure you want to delete this invoice?'),
                                          actions: [
                                            TextButton(
                                              onPressed: () => Navigator.pop(ctx, false),
                                              child: const Text('Cancel'),
                                            ),
                                            ElevatedButton(
                                              onPressed: () => Navigator.pop(ctx, true),
                                              style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                                              child: const Text('Delete'),
                                            ),
                                          ],
                                        ),
                                      );

                                      if (confirm == true) {
                                        try {
                                          await inv.reference.delete();
                                          if (mounted) {
                                            ScaffoldMessenger.of(context).showSnackBar(
                                              const SnackBar(
                                                content: Text("Invoice deleted"),
                                                backgroundColor: Colors.green,
                                              ),
                                            );
                                          }
                                        } catch (e) {
                                          if (mounted) {
                                            ScaffoldMessenger.of(context).showSnackBar(
                                              SnackBar(
                                                content: Text("Error: ${e.toString()}"),
                                                backgroundColor: Colors.red,
                                              ),
                                            );
                                          }
                                        }
                                      }
                                    }
                                  },
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
            );
          },
        );
      },
    );
  }
}

// --- 4. CLIENTS SCREEN (IMPROVED) ---
class ClientsScreen extends StatefulWidget {
  const ClientsScreen({super.key});

  @override
  State<ClientsScreen> createState() => _ClientsScreenState();
}

class _ClientsScreenState extends State<ClientsScreen> {
  final _formKey = GlobalKey<FormState>();
  final nameCtrl = TextEditingController();
  bool _isSaving = false;

  Future<void> _addClient() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSaving = true);

    try {
      final uid = FirebaseAuth.instance.currentUser!.uid;
      await FirebaseFirestore.instance.collection('artifacts/notaryflow-v2/users/$uid/clients').add({
        'name': nameCtrl.text.trim(),
        'createdAt': FieldValue.serverTimestamp(),
      });

      nameCtrl.clear();
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Row(
              children: [
                Icon(Icons.check_circle, color: Colors.white),
                SizedBox(width: 12),
                Text("Client added successfully!"),
              ],
            ),
            backgroundColor: Colors.green,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Error: ${e.toString()}"),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final uid = FirebaseAuth.instance.currentUser!.uid;

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Card(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Form(
                key: _formKey,
                child: Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: nameCtrl,
                        decoration: const InputDecoration(
                          hintText: "Client Name *",
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.person_add),
                        ),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Please enter client name';
                          }
                          return null;
                        },
                      ),
                    ),
                    const SizedBox(width: 16),
                    ElevatedButton.icon(
                      onPressed: _isSaving ? null : _addClient,
                      icon: _isSaving
                          ? const SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                            )
                          : const Icon(Icons.add),
                      label: Text(_isSaving ? "Adding..." : "Add Client"),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
        Expanded(
          child: StreamBuilder(
            stream: FirebaseFirestore.instance
                .collection('artifacts/notaryflow-v2/users/$uid/clients')
                .orderBy('createdAt', descending: true)
                .snapshots(),
            builder: (ctx, snap) {
              if (!snap.hasData) {
                return const Center(child: CircularProgressIndicator());
              }

              final clients = snap.data!.docs;

              if (clients.isEmpty) {
                return Center(
                  child: _EmptyState(
                    icon: Icons.people,
                    title: "No clients yet",
                    message: "Add your first client above to get started!",
                  ),
                );
              }

              return ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: clients.length,
                itemBuilder: (context, index) {
                  final doc = clients[index];
                  return Card(
                    margin: const EdgeInsets.only(bottom: 8),
                    child: ListTile(
                      leading: CircleAvatar(
                        backgroundColor: Colors.indigo.shade50,
                        child: Text(
                          doc['name'][0].toUpperCase(),
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.indigo,
                          ),
                        ),
                      ),
                      title: Text(
                        doc['name'],
                        style: const TextStyle(fontWeight: FontWeight.w600),
                      ),
                      trailing: IconButton(
                        icon: const Icon(Icons.delete, color: Colors.red),
                        onPressed: () async {
                          final confirm = await showDialog<bool>(
                            context: context,
                            builder: (ctx) => AlertDialog(
                              title: const Text('Delete Client'),
                              content: Text('Are you sure you want to delete "${doc['name']}"?'),
                              actions: [
                                TextButton(
                                  onPressed: () => Navigator.pop(ctx, false),
                                  child: const Text('Cancel'),
                                ),
                                ElevatedButton(
                                  onPressed: () => Navigator.pop(ctx, true),
                                  style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                                  child: const Text('Delete'),
                                ),
                              ],
                            ),
                          );

                          if (confirm == true) {
                            try {
                              await doc.reference.delete();
                              if (mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text("Client deleted successfully"),
                                    backgroundColor: Colors.green,
                                  ),
                                );
                              }
                            } catch (e) {
                              if (mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text("Error: ${e.toString()}"),
                                    backgroundColor: Colors.red,
                                  ),
                                );
                              }
                            }
                          }
                        },
                      ),
                    ),
                  );
                },
              );
            },
          ),
        )
      ],
    );
  }
}

// --- 5. CALCULATOR SCREEN ---
class CalculatorScreen extends StatefulWidget {
  const CalculatorScreen({super.key});

  @override
  State<CalculatorScreen> createState() => _CalculatorScreenState();
}

class _CalculatorScreenState extends State<CalculatorScreen> {
  double _sigs = 1;
  double _miles = 0;

  @override
  Widget build(BuildContext context) {
    double total = (_sigs * 15) + (_miles * 2);

    return Padding(
      padding: const EdgeInsets.all(32.0),
      child: Center(
        child: Card(
          child: Padding(
            padding: const EdgeInsets.all(32.0),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 500),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text("Fee Estimator", style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  Text(
                    "Calculate your notary service fees",
                    style: TextStyle(color: Colors.grey.shade600),
                  ),
                  const SizedBox(height: 32),
                  Text(
                    "Signatures: ${_sigs.toInt()} (\$${(_sigs * 15).toInt()})",
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                  ),
                  Slider(
                    value: _sigs,
                    min: 1,
                    max: 20,
                    divisions: 19,
                    label: _sigs.toInt().toString(),
                    onChanged: (v) => setState(() => _sigs = v),
                  ),
                  const SizedBox(height: 24),
                  Text(
                    "Miles: ${_miles.toInt()} (\$${(_miles * 2).toInt()})",
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                  ),
                  Slider(
                    value: _miles,
                    min: 0,
                    max: 100,
                    divisions: 100,
                    label: _miles.toInt().toString(),
                    onChanged: (v) => setState(() => _miles = v),
                  ),
                  const Divider(height: 48),
                  const Text("Total Estimate", style: TextStyle(color: Colors.grey, fontSize: 16)),
                  const SizedBox(height: 8),
                  Text(
                    "\$${total.toStringAsFixed(2)}",
                    style: const TextStyle(fontSize: 56, fontWeight: FontWeight.bold, color: Colors.indigo),
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

// --- 6. SETTINGS SCREEN (IMPROVED) ---
class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _addressCtrl = TextEditingController();
  bool _isLoading = true;
  bool _isSaving = false;

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
      
      if (doc.exists) {
        final data = doc.data()!;
        _nameCtrl.text = data['businessName'] ?? '';
        _emailCtrl.text = data['email'] ?? '';
        _addressCtrl.text = data['address'] ?? '';
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Error loading profile: ${e.toString()}"),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSaving = true);

    try {
      final uid = FirebaseAuth.instance.currentUser!.uid;
      await FirebaseFirestore.instance
          .doc('artifacts/notaryflow-v2/users/$uid/profile/business_info')
          .set({
        'businessName': _nameCtrl.text.trim(),
        'email': _emailCtrl.text.trim(),
        'address': _addressCtrl.text.trim(),
        'updatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Row(
              children: [
                Icon(Icons.check_circle, color: Colors.white),
                SizedBox(width: 12),
                Text("Profile saved successfully!"),
              ],
            ),
            backgroundColor: Colors.green,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Error: ${e.toString()}"),
            backgroundColor: Colors.red,
          ),
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
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "Business Profile",
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Text(
                  "This information will appear on your invoices and documents.",
                  style: TextStyle(color: Colors.grey.shade600),
                ),
                const SizedBox(height: 32),
                TextFormField(
                  controller: _nameCtrl,
                  decoration: const InputDecoration(
                    labelText: "Business Name *",
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.business),
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Please enter your business name';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _emailCtrl,
                  decoration: const InputDecoration(
                    labelText: "Business Email *",
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.email),
                  ),
                  keyboardType: TextInputType.emailAddress,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Please enter your email';
                    }
                    if (!value.contains('@')) {
                      return 'Please enter a valid email';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _addressCtrl,
                  decoration: const InputDecoration(
                    labelText: "Business Address",
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.location_on),
                    alignLabelWithHint: true,
                  ),
                  maxLines: 3,
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: _isSaving ? null : _save,
                    icon: _isSaving
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                          )
                        : const Icon(Icons.save),
                    label: Text(_isSaving ? "Saving..." : "Save Profile"),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      textStyle: const TextStyle(fontSize: 16),
                    ),
                  ),
                ),
              ],
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

  const _EmptyState({
    required this.icon,
    required this.title,
    required this.message,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(48.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            icon,
            size: 80,
            color: Colors.grey.shade300,
          ),
          const SizedBox(height: 24),
          Text(
            title,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.grey.shade700,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            message,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey.shade500,
            ),
          ),
        ],
      ),
    );
  }
}
