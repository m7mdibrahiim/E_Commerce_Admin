import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:e_commerce_admin/models/order_model.dart';
import 'package:flutter/material.dart';

class OrdersScreenFree extends StatelessWidget {
  static const routeName = '/OrderScreen';
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text(
          'All Orders',
          style: TextStyle(
            fontSize: 20,
          ),
        ),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream:
            FirebaseFirestore.instance.collection('orderAdvanced').snapshots(),
        builder: (context, snapshot) {
          // Check if data is still loading
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          // Check for errors
          if (snapshot.hasError) {
            return const Center(child: Text('Something went wrong!'));
          }

          // Check if there's no data
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text('No orders found.'));
          }

          // Map documents to OrderModelAdvanced
          final orders = snapshot.data!.docs.map((doc) {
            final data = doc.data() as Map<String, dynamic>;
            return OrderModelAdvanced(
              orderId: doc.id,
              userId: data['userId'],
              productId: data['productId'],
              productTitle: data['productTitle'],
              userName: data['userName'],
              price: data['price'].toString(),
              imageUrl: data['imageUrl'],
              quantity: data['quantity'].toString(),
              orderDate: data['orderDate'],
            );
          }).toList();

          // Build the list view
          return ListView.separated(
            itemCount: orders.length,
            separatorBuilder: (context, index) => const Divider(
              height: 1,
            ),
            itemBuilder: (context, index) {
              final order = orders[index];
              return ListTile(
                title: Text(
                  order.productTitle,
                  overflow: TextOverflow.ellipsis,
                  maxLines: 5,
                ),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Text(
                          'User: ',
                          style: TextStyle(
                            fontSize: 15,
                          ),
                        ),
                        Text(
                          order.userName,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    Row(
                      children: [
                        const Text(
                          'Quantity: ',
                          style: TextStyle(
                            fontSize: 15,
                          ),
                        ),
                        Text(
                          order.quantity,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    Row(
                      children: [
                        const Text(
                          'Price: ',
                          style: TextStyle(
                            fontSize: 15,
                          ),
                        ),
                        Text(
                          '\£ ${order.price}',
                          style: const TextStyle(
                              fontSize: 16,
                              color: Colors.blue,
                              fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  ],
                ),
                // trailing: Text(
                //   '\£ ${order.price}',
                //   style: const TextStyle(
                //     fontSize: 14,
                //     color: Colors.blue,
                //   ),
                // ),
                leading: order.imageUrl.isNotEmpty
                    ? Image.network(order.imageUrl)
                    : null,
              );
            },
          );
        },
      ),
    );
  }
}
