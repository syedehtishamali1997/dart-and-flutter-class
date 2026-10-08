import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class Dashboard extends StatefulWidget {
  const Dashboard({super.key});

  @override
  State<Dashboard> createState() => _DashboardState();
}

class _DashboardState extends State<Dashboard> {
  // ================= Firestore Collections =================

  final CollectionReference cust = FirebaseFirestore.instance.collection(
    'customer',
  );

  final CollectionReference prod = FirebaseFirestore.instance.collection(
    'product',
  );

  int selectIndex = 0;

  // ================= Logout =================

  void logout() {
    Navigator.pushNamedAndRemoveUntil(context, '/login', (route) => false);
  }

  // ================= Add Product =================

  void showProductDialog() {
    final TextEditingController pName = TextEditingController();
    final TextEditingController pPrice = TextEditingController();
    final TextEditingController pDes = TextEditingController();

    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text("Add Product"),

          content: SingleChildScrollView(
            child: Column(
              children: [
                TextField(
                  controller: pName,
                  decoration: const InputDecoration(
                    labelText: "P_Name",
                    border: OutlineInputBorder(),
                  ),
                ),

                const SizedBox(height: 10),

                TextField(
                  controller: pPrice,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: "P_Price",
                    border: OutlineInputBorder(),
                  ),
                ),

                const SizedBox(height: 10),

                TextField(
                  controller: pDes,
                  decoration: const InputDecoration(
                    labelText: "P_Description",
                    border: OutlineInputBorder(),
                  ),
                ),
              ],
            ),
          ),

          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(dialogContext);
              },
              child: const Text("Cancel"),
            ),

            ElevatedButton(
              onPressed: () async {
                final String name = pName.text.trim();
                final String price = pPrice.text.trim();
                final String des = pDes.text.trim();

                final double? pri = double.tryParse(price);

                if (name.isEmpty || pri == null) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text("Please enter valid name and price"),
                    ),
                  );
                  return;
                }

                try {
                  await prod.add({'name': name, 'price': pri, 'des': des});

                  if (dialogContext.mounted) {
                    Navigator.pop(dialogContext);
                  }

                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text("Product Added Successfully"),
                      ),
                    );
                  }
                } catch (e) {
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text("Unable to add product")),
                    );
                  }
                }
              },
              child: const Text("Add Product"),
            ),
          ],
        );
      },
    );
  }

  // ================= Edit Product =================

  void editproduct(String docID, Map<String, dynamic> data) {
    final TextEditingController name = TextEditingController(
      text: data['name']?.toString() ?? '',
    );

    final TextEditingController price = TextEditingController(
      text: data['price']?.toString() ?? '',
    );

    final TextEditingController des = TextEditingController(
      text: data['des']?.toString() ?? '',
    );

    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text("Edit Product"),

          content: SingleChildScrollView(
            child: Column(
              children: [
                TextField(
                  controller: name,
                  decoration: const InputDecoration(
                    labelText: "P_Name",
                    border: OutlineInputBorder(),
                  ),
                ),

                const SizedBox(height: 10),

                TextField(
                  controller: price,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: "P_Price",
                    border: OutlineInputBorder(),
                  ),
                ),

                const SizedBox(height: 10),

                TextField(
                  controller: des,
                  decoration: const InputDecoration(
                    labelText: "P_Description",
                    border: OutlineInputBorder(),
                  ),
                ),
              ],
            ),
          ),

          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(dialogContext);
              },
              child: const Text("Cancel"),
            ),

            ElevatedButton(
              onPressed: () async {
                final String proName = name.text.trim();
                final String proPri = price.text.trim();
                final String proDese = des.text.trim();

                final double? proPrice = double.tryParse(proPri);

                if (proName.isEmpty || proPrice == null || proDese.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text(
                        "Please enter valid name, price and description",
                      ),
                    ),
                  );
                  return;
                }

                try {
                  await prod.doc(docID).update({
                    'name': proName,
                    'price': proPrice,
                    'des': proDese,
                  });

                  if (dialogContext.mounted) {
                    Navigator.pop(dialogContext);
                  }

                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text("Product Updated Successfully"),
                      ),
                    );
                  }
                } catch (e) {
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text("Unable to update product")),
                    );
                  }
                }
              },
              child: const Text("Update"),
            ),
          ],
        );
      },
    );
  }

  // ================= Delete Product =================

  Future<void> deleteproduct(String docID) async {
    final bool? confirm = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text("Delete Product"),

          content: const Text("Are you sure you want to delete this product?"),

          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(dialogContext, false);
              },
              child: const Text("Cancel"),
            ),

            ElevatedButton(
              onPressed: () {
                Navigator.pop(dialogContext, true);
              },
              child: const Text("Delete"),
            ),
          ],
        );
      },
    );

    if (confirm != true) {
      return;
    }

    try {
      await prod.doc(docID).delete();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Product Deleted Successfully")),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Unable to delete product")),
        );
      }
    }
  }

  // ================= Approve User =================

  Future<void> approveUser(String docID) async {
    try {
      await cust.doc(docID).update({'status': 'approved'});

      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(const SnackBar(content: Text("User Approved")));
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text("Unable to approve user")));
      }
    }
  }

  // ================= Reject User =================

  Future<void> rejectUser(String docID) async {
    try {
      await cust.doc(docID).update({'status': 'rejected'});

      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(const SnackBar(content: Text("User Rejected")));
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text("Unable to reject user")));
      }
    }
  }

  // ================= Delete User =================

  Future<void> deleteUser(String documentId) async {
    final bool? confirm = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text("Delete User"),

          content: const Text("Are you sure you want to delete this user?"),

          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(dialogContext, false);
              },
              child: const Text("Cancel"),
            ),

            ElevatedButton(
              onPressed: () {
                Navigator.pop(dialogContext, true);
              },
              child: const Text("Delete"),
            ),
          ],
        );
      },
    );

    if (confirm != true) {
      return;
    }

    try {
      await cust.doc(documentId).delete();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("User Deleted Successfully")),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text("Unable to delete user")));
      }
    }
  }

  // ================= Edit User =================

  void editUser(String documentId, Map<String, dynamic> data) {
    final TextEditingController nameController = TextEditingController(
      text: data['name']?.toString() ?? '',
    );

    final TextEditingController ageController = TextEditingController(
      text: data['age']?.toString() ?? '',
    );

    final TextEditingController emailController = TextEditingController(
      text: data['email']?.toString() ?? '',
    );

    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text("Edit User"),

          content: SingleChildScrollView(
            child: Column(
              children: [
                TextField(
                  controller: nameController,
                  decoration: const InputDecoration(
                    labelText: "Name",
                    border: OutlineInputBorder(),
                  ),
                ),

                const SizedBox(height: 10),

                TextField(
                  controller: ageController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: "Age",
                    border: OutlineInputBorder(),
                  ),
                ),

                const SizedBox(height: 10),

                TextField(
                  controller: emailController,
                  keyboardType: TextInputType.emailAddress,
                  decoration: const InputDecoration(
                    labelText: "Email",
                    border: OutlineInputBorder(),
                  ),
                ),
              ],
            ),
          ),

          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(dialogContext);
              },
              child: const Text("Cancel"),
            ),

            ElevatedButton(
              onPressed: () async {
                final String name = nameController.text.trim();

                final String ageText = ageController.text.trim();

                final String email = emailController.text.trim();

                final int? age = int.tryParse(ageText);

                if (name.isEmpty || email.isEmpty || age == null) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text("Please enter valid user information"),
                    ),
                  );
                  return;
                }

                try {
                  await cust.doc(documentId).update({
                    'name': name,
                    'age': age,
                    'email': email,
                  });

                  if (dialogContext.mounted) {
                    Navigator.pop(dialogContext);
                  }

                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text("User Updated Successfully"),
                      ),
                    );
                  }
                } catch (e) {
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text("Unable to update user")),
                    );
                  }
                }
              },
              child: const Text("Update"),
            ),
          ],
        );
      },
    );
  }

  // ================= Dashboard Home =================

  Widget dashboardHome() {
    return StreamBuilder<QuerySnapshot>(
      stream: cust.snapshots(),

      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return const Center(child: Text("Unable to load users"));
        }

        final int totalUsers = snapshot.data?.docs.length ?? 0;

        int approvedUsers = 0;
        int pendingUsers = 0;
        int rejectedUsers = 0;

        if (snapshot.hasData) {
          for (final doc in snapshot.data!.docs) {
            final data = doc.data() as Map<String, dynamic>;

            final String status = data['status']?.toString() ?? 'pending';

            if (status == 'approved') {
              approvedUsers++;
            } else if (status == 'rejected') {
              rejectedUsers++;
            } else {
              pendingUsers++;
            }
          }
        }

        return SingleChildScrollView(
          padding: const EdgeInsets.all(20),

          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,

            children: [
              const Text(
                "Dashboard",
                style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
              ),

              const SizedBox(height: 20),

              Row(
                children: [
                  dashboardCard(
                    "Total Users",
                    totalUsers.toString(),
                    Icons.people,
                  ),

                  const SizedBox(width: 15),

                  dashboardCard(
                    "Approved",
                    approvedUsers.toString(),
                    Icons.check_circle,
                  ),

                  const SizedBox(width: 15),

                  dashboardCard(
                    "Pending",
                    pendingUsers.toString(),
                    Icons.pending,
                  ),

                  const SizedBox(width: 15),

                  dashboardCard(
                    "Rejected",
                    rejectedUsers.toString(),
                    Icons.cancel,
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  // ================= Dashboard Card =================

  Widget dashboardCard(String title, String value, IconData icon) {
    return Expanded(
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(20),

          child: Column(
            children: [
              Icon(icon, size: 40),

              const SizedBox(height: 10),

              Text(
                value,
                style: const TextStyle(
                  fontSize: 25,
                  fontWeight: FontWeight.bold,
                ),
              ),

              Text(title),
            ],
          ),
        ),
      ),
    );
  }

  // ================= Products =================

  Widget productsPage() {
    return Padding(
      padding: const EdgeInsets.all(20),

      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,

        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,

            children: [
              const Text(
                "Products Page",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),

              ElevatedButton.icon(
                onPressed: showProductDialog,
                icon: const Icon(Icons.add),
                label: const Text("Add Product"),
              ),
            ],
          ),

          const SizedBox(height: 20),

          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: prod.snapshots(),

              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (snapshot.hasError) {
                  return const Center(child: Text("Unable to load products"));
                }

                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return const Center(child: Text("No Products Found"));
                }

                return ListView.builder(
                  itemCount: snapshot.data!.docs.length,

                  itemBuilder: (context, index) {
                    final doc = snapshot.data!.docs[index];

                    final data = doc.data() as Map<String, dynamic>;

                    return Card(
                      child: ListTile(
                        leading: const CircleAvatar(
                          child: Icon(Icons.shopping_bag),
                        ),

                        title: Text(data['name']?.toString() ?? ''),

                        subtitle: Text(
                          "Price: \$${data['price'] ?? 0}\n"
                          "${data['des']?.toString() ?? ''}",
                        ),

                        isThreeLine: true,

                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,

                          children: [
                            IconButton(
                              onPressed: () {
                                editproduct(doc.id, data);
                              },
                              icon: const Icon(Icons.edit),
                            ),

                            IconButton(
                              onPressed: () {
                                deleteproduct(doc.id);
                              },
                              icon: const Icon(Icons.delete),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  // ================= Users =================

  Widget usersPage() {
    return Padding(
      padding: const EdgeInsets.all(20),

      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,

        children: [
          const Text(
            "Manage Users",
            style: TextStyle(fontSize: 25, fontWeight: FontWeight.bold),
          ),

          const SizedBox(height: 20),

          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: cust.snapshots(),

              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (snapshot.hasError) {
                  return const Center(child: Text("Unable to load users"));
                }

                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return const Center(child: Text("No Users Found"));
                }

                return ListView.builder(
                  itemCount: snapshot.data!.docs.length,

                  itemBuilder: (context, index) {
                    final doc = snapshot.data!.docs[index];

                    final data = doc.data() as Map<String, dynamic>;

                    final String role = data['role']?.toString() ?? 'user';

                    final String status =
                        data['status']?.toString() ?? 'pending';

                    return Card(
                      child: ListTile(
                        leading: CircleAvatar(
                          child: role == 'admin'
                              ? const Icon(Icons.admin_panel_settings)
                              : const Icon(Icons.person),
                        ),

                        title: Text(data['name']?.toString() ?? ''),

                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,

                          children: [
                            Text("Email: ${data['email']?.toString() ?? ''}"),

                            Text("Age: ${data['age']?.toString() ?? ''}"),

                            Text("Role: $role"),

                            Text("Status: $status"),
                          ],
                        ),

                        isThreeLine: true,

                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,

                          children: [
                            if (role != 'admin' && status != 'approved')
                              IconButton(
                                onPressed: () {
                                  approveUser(doc.id);
                                },
                                icon: const Icon(Icons.check),
                              ),

                            if (role != 'admin' && status != 'rejected')
                              IconButton(
                                onPressed: () {
                                  rejectUser(doc.id);
                                },
                                icon: const Icon(Icons.close),
                              ),

                            IconButton(
                              onPressed: () {
                                editUser(doc.id, data);
                              },
                              icon: const Icon(Icons.edit),
                            ),

                            IconButton(
                              onPressed: () {
                                deleteUser(doc.id);
                              },
                              icon: const Icon(Icons.delete),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  // ================= Main Build =================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Admin Dashboard"),

        actions: [
          IconButton(onPressed: logout, icon: const Icon(Icons.logout)),
        ],
      ),

      body: Row(
        children: [
          // ================= Sidebar =================

          NavigationRail(
            selectedIndex: selectIndex,

            onDestinationSelected: (int index) {
              setState(() {
                selectIndex = index;
              });
            },

            destinations: const [
              NavigationRailDestination(
                icon: Icon(Icons.dashboard),
                label: Text("Dashboard"),
              ),

              NavigationRailDestination(
                icon: Icon(Icons.shopping_bag),
                label: Text("Products"),
              ),

              NavigationRailDestination(
                icon: Icon(Icons.people),
                label: Text("Users"),
              ),
            ],
          ),

          const VerticalDivider(width: 1),

          // ================= Main Content =================
          Expanded(
            child: IndexedStack(
              index: selectIndex,

              children: [dashboardHome(), productsPage(), usersPage()],
            ),
          ),
        ],
      ),
    );
  }
}
