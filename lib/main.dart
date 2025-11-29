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
  
  // Initialize Firebase for Web (and fallback for mobile if config files aren't generated)
  try {
    await Firebase.initializeApp(
      options: firebaseOptions,
    );
  } catch (e) {
    // If already initialized or using google-services.json
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
        scaffoldBackgroundColor: const Color(0xFFF8FAFC), // Slate-50
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
    // Auto-sign in anonymously for MVP
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

// --- MAIN LAYOUT (RESPONSIVE) ---
class MainLayout extends StatefulWidget {
  const MainLayout({super.key});

  @override
  State<MainLayout> createState() => _MainLayoutState();
}

class _MainLayoutState extends State<MainLayout> {
  int _selectedIndex = 0;
  final String _userId = FirebaseAuth.instance.currentUser?.uid ?? '';

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
    // Use LayoutBuilder to switch between Mobile (BottomNav) and Desktop (SideNav)
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
                  backgroundColor: const Color(0xFF0F172A), // Slate-900
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
                    // Header
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
                    // Content
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
                    BottomNavigationBarItem(icon: Icon(Icons.dashboard), label: 'Dash'),
                    BottomNavigationBarItem(icon: Icon(Icons.directions_car), label: 'Miles'),
                    BottomNavigationBarItem(icon: Icon(Icons.attach_money), label: 'Inv'),
                    BottomNavigationBarItem(icon: Icon(Icons.people), label: 'Clients'),
                    BottomNavigationBarItem(icon: Icon(Icons.calculate), label: 'Fee'),
                    BottomNavigationBarItem(icon: Icon(Icons.settings), label: 'Set'),
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
              if (!invSnapshot.hasData || !tripSnapshot.hasData) return const LinearProgressIndicator();

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
                  // Stats Row
                  Wrap(
                    spacing: 16,
                    runSpacing: 16,
                    children: [
                      _StatCard(title: "Revenue", value: "\$${totalIncome.toStringAsFixed(2)}", icon: Icons.attach_money, color: Colors.green),
                      _StatCard(title: "Pending", value: "\$${pendingIncome.toStringAsFixed(2)}", icon: Icons.access_time, color: Colors.orange),
                      _StatCard(title: "Deductions", value: "\$${taxDed.toStringAsFixed(2)}", icon: Icons.directions_car, color: Colors.blue),
                    ],
                  ),
                  const SizedBox(height: 24),
                  // Recent Activity
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text("Recent Invoices", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                          const SizedBox(height: 16),
                          if (invoices.isEmpty) const Text("No invoices found."),
                          ...invoices.take(5).map((doc) => ListTile(
                            leading: const CircleAvatar(child: Icon(Icons.receipt)),
                            title: Text(doc['description'] ?? 'Unknown'),
                            subtitle: Text(doc['date'] ?? ''),
                            trailing: Text("\$${doc['amount']}", style: const TextStyle(fontWeight: FontWeight.bold)),
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
    return Container(
      width: 300,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10)]),
      child: Row(
        children: [
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(title, style: const TextStyle(color: Colors.grey)),
            const SizedBox(height: 8),
            Text(value, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
          ])),
          Container(padding: const EdgeInsets.all(12), decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(12)), child: Icon(icon, color: color, size: 28)),
        ],
      ),
    );
  }
}

// --- 2. MILEAGE SCREEN ---
class MileageScreen extends StatefulWidget {
  const MileageScreen({super.key});

  @override
  State<MileageScreen> createState() => _MileageScreenState();
}

class _MileageScreenState extends State<MileageScreen> {
  bool _isTracking = false;
  int _seconds = 0;
  Timer? _timer;
  final TextEditingController _milesCtrl = TextEditingController();
  final TextEditingController _purposeCtrl = TextEditingController();

  void _toggleTracking() {
    if (_isTracking) {
      _timer?.cancel();
    } else {
      _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
        setState(() => _seconds++);
      });
    }
    setState(() => _isTracking = !_isTracking);
  }

  Future<void> _saveTrip() async {
    final uid = FirebaseAuth.instance.currentUser!.uid;
    await FirebaseFirestore.instance.collection('artifacts/notaryflow-v2/users/$uid/trips').add({
      'miles': double.tryParse(_milesCtrl.text) ?? 0.0,
      'purpose': _purposeCtrl.text,
      'date': DateFormat('yyyy-MM-dd').format(DateTime.now()),
      'duration': _seconds,
      'createdAt': FieldValue.serverTimestamp(),
    });
    _milesCtrl.clear();
    _purposeCtrl.clear();
    setState(() => _seconds = 0);
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Trip Saved!")));
  }

  String _formatTime(int s) {
    final duration = Duration(seconds: s);
    return duration.toString().split('.').first.padLeft(8, "0");
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(32),
            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(24), boxShadow: [BoxShadow(color: Colors.indigo.withOpacity(0.1), blurRadius: 20)]),
            child: Column(
              children: [
                Text(_formatTime(_seconds), style: const TextStyle(fontSize: 48, fontFamily: 'Monospace', fontWeight: FontWeight.bold)),
                const SizedBox(height: 24),
                ElevatedButton.icon(
                  onPressed: _toggleTracking,
                  icon: Icon(_isTracking ? Icons.stop : Icons.play_arrow),
                  label: Text(_isTracking ? "STOP TRIP" : "START TRIP"),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _isTracking ? Colors.red : Colors.indigo,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          if (!_isTracking && _seconds > 0 || !_isTracking) 
             Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    TextField(controller: _milesCtrl, decoration: const InputDecoration(labelText: "Miles Driven", suffixText: "mi"), keyboardType: TextInputType.number),
                    TextField(controller: _purposeCtrl, decoration: const InputDecoration(labelText: "Purpose")),
                    const SizedBox(height: 16),
                    SizedBox(width: double.infinity, child: ElevatedButton(onPressed: _saveTrip, child: const Text("Save Trip Log"))),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}

// --- 3. INVOICE SCREEN ---
class InvoicesScreen extends StatefulWidget {
  const InvoicesScreen({super.key});

  @override
  State<InvoicesScreen> createState() => _InvoicesScreenState();
}

class _InvoicesScreenState extends State<InvoicesScreen> {
  // Simple state for the form dialog
  final _amountCtrl = TextEditingController();
  final _descCtrl = TextEditingController();
  String? _selectedClientId;

  void _showAddDialog(List<QueryDocumentSnapshot> clients) {
    showDialog(context: context, builder: (ctx) => AlertDialog(
      title: const Text("New Invoice"),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          DropdownButtonFormField<String>(
            value: _selectedClientId,
            hint: const Text("Select Client"),
            items: clients.map((c) => DropdownMenuItem(value: c.id, child: Text(c['name']))).toList(),
            onChanged: (v) => setState(() => _selectedClientId = v),
          ),
          TextField(controller: _amountCtrl, decoration: const InputDecoration(labelText: "Amount"), keyboardType: TextInputType.number),
          TextField(controller: _descCtrl, decoration: const InputDecoration(labelText: "Description")),
        ],
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(ctx), child: const Text("Cancel")),
        ElevatedButton(onPressed: () async {
          if (_selectedClientId == null) return;
          final uid = FirebaseAuth.instance.currentUser!.uid;
          await FirebaseFirestore.instance.collection('artifacts/notaryflow-v2/users/$uid/invoices').add({
            'clientId': _selectedClientId,
            'amount': double.tryParse(_amountCtrl.text) ?? 0.0,
            'description': _descCtrl.text,
            'status': 'Pending',
            'date': DateFormat('MM/dd/yyyy').format(DateTime.now()),
            'createdAt': FieldValue.serverTimestamp(),
          });
          _amountCtrl.clear(); _descCtrl.clear();
          if (mounted) Navigator.pop(ctx);
        }, child: const Text("Create")),
      ],
    ));
  }

  @override
  Widget build(BuildContext context) {
    final uid = FirebaseAuth.instance.currentUser!.uid;
    return StreamBuilder(
      stream: FirebaseFirestore.instance.collection('artifacts/notaryflow-v2/users/$uid/clients').snapshots(),
      builder: (context, clientSnap) {
        return StreamBuilder(
          stream: FirebaseFirestore.instance.collection('artifacts/notaryflow-v2/users/$uid/invoices').orderBy('createdAt', descending: true).snapshots(),
          builder: (context, invSnap) {
            if (!clientSnap.hasData || !invSnap.hasData) return const Center(child: CircularProgressIndicator());
            
            final clients = clientSnap.data!.docs;
            final invoices = invSnap.data!.docs;

            return Scaffold(
              backgroundColor: Colors.transparent,
              floatingActionButton: FloatingActionButton(
                onPressed: () => _showAddDialog(clients),
                backgroundColor: Colors.indigo,
                child: const Icon(Icons.add, color: Colors.white),
              ),
              body: ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: invoices.length,
                itemBuilder: (ctx, i) {
                  final inv = invoices[i];
                  // Find client name logic omitted for brevity, would usually do a lookup map
                  return Card(
                    child: ListTile(
                      title: Text(inv['description']),
                      subtitle: Text("Date: ${inv['date']} • Status: ${inv['status']}"),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text("\$${inv['amount']}", style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                          IconButton(
                            icon: const Icon(Icons.print, color: Colors.indigo),
                            onPressed: () {
                              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("PDF Generation would open here.")));
                            },
                          )
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

// --- 4. CLIENTS SCREEN ---
class ClientsScreen extends StatelessWidget {
  const ClientsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final nameCtrl = TextEditingController();
    final uid = FirebaseAuth.instance.currentUser!.uid;

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Card(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                children: [
                  Expanded(child: TextField(controller: nameCtrl, decoration: const InputDecoration(hintText: "New Client Name"))),
                  const SizedBox(width: 16),
                  ElevatedButton(onPressed: () {
                    if (nameCtrl.text.isEmpty) return;
                    FirebaseFirestore.instance.collection('artifacts/notaryflow-v2/users/$uid/clients').add({
                      'name': nameCtrl.text,
                      'createdAt': FieldValue.serverTimestamp(),
                    });
                    nameCtrl.clear();
                  }, child: const Text("Add")),
                ],
              ),
            ),
          ),
        ),
        Expanded(
          child: StreamBuilder(
            stream: FirebaseFirestore.instance.collection('artifacts/notaryflow-v2/users/$uid/clients').snapshots(),
            builder: (ctx, snap) {
              if (!snap.hasData) return const Center(child: CircularProgressIndicator());
              return ListView(
                children: snap.data!.docs.map((doc) => ListTile(
                  leading: const Icon(Icons.business),
                  title: Text(doc['name']),
                  trailing: IconButton(
                    icon: const Icon(Icons.delete, color: Colors.red),
                    onPressed: () => doc.reference.delete(),
                  ),
                )).toList(),
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
                  const Text("Fee Estimator", style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 32),
                  Text("Signatures: ${_sigs.toInt()} (\$${(_sigs*15).toInt()})"),
                  Slider(value: _sigs, min: 1, max: 20, divisions: 19, label: _sigs.toString(), onChanged: (v) => setState(()=>_sigs=v)),
                  const SizedBox(height: 16),
                  Text("Miles: ${_miles.toInt()} (\$${(_miles*2).toInt()})"),
                  Slider(value: _miles, min: 0, max: 100, divisions: 100, label: _miles.toString(), onChanged: (v) => setState(()=>_miles=v)),
                  const Divider(height: 48),
                  const Text("Total Estimate", style: TextStyle(color: Colors.grey)),
                  Text("\$${total.toStringAsFixed(2)}", style: const TextStyle(fontSize: 48, fontWeight: FontWeight.bold, color: Colors.indigo)),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// --- 6. SETTINGS SCREEN ---
class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final _nameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _addressCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    final uid = FirebaseAuth.instance.currentUser!.uid;
    final doc = await FirebaseFirestore.instance.doc('artifacts/notaryflow-v2/users/$uid/profile/business_info').get();
    if (doc.exists) {
      final data = doc.data()!;
      _nameCtrl.text = data['businessName'] ?? '';
      _emailCtrl.text = data['email'] ?? '';
      _addressCtrl.text = data['address'] ?? '';
    }
  }

  Future<void> _save() async {
    final uid = FirebaseAuth.instance.currentUser!.uid;
    await FirebaseFirestore.instance.doc('artifacts/notaryflow-v2/users/$uid/profile/business_info').set({
      'businessName': _nameCtrl.text,
      'email': _emailCtrl.text,
      'address': _addressCtrl.text,
    }, SetOptions(merge: true));
    if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Profile Saved")));
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text("Business Profile", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              const Text("This info will appear on your PDF invoices."),
              const SizedBox(height: 24),
              TextField(controller: _nameCtrl, decoration: const InputDecoration(labelText: "Business Name", border: OutlineInputBorder())),
              const SizedBox(height: 16),
              TextField(controller: _emailCtrl, decoration: const InputDecoration(labelText: "Business Email", border: OutlineInputBorder())),
              const SizedBox(height: 16),
              TextField(controller: _addressCtrl, decoration: const InputDecoration(labelText: "Address", border: OutlineInputBorder()), maxLines: 3),
              const SizedBox(height: 24),
              SizedBox(width: double.infinity, child: ElevatedButton.icon(onPressed: _save, icon: const Icon(Icons.save), label: const Text("Save Profile"))),
            ],
          ),
        ),
      ),
    );
  }
}
