import 'package:flutter/material.dart';
import 'package:jimjaew_app/home_screen/seller_order_screen.dart';
import 'package:jimjaew_app/home_screen/income_screen.dart';
import 'package:jimjaew_app/products/order_manager.dart';

class TradeSystemScreen extends StatefulWidget {
  const TradeSystemScreen({super.key});

  @override
  State<TradeSystemScreen> createState() => _TradeSystemScreenState();
}

class _TradeSystemScreenState extends State<TradeSystemScreen> {
  final OrderManager _orderManager = OrderManager();

  void _approveTrade(TradeModel item) {
    double finalPrice = item.originalPrice - item.discount;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Confirm Trade Approval"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Product: ${item.name}"),
            const SizedBox(height: 8),
            Text(
              "Original Price: ฿${item.originalPrice}",
              style: const TextStyle(
                decoration: TextDecoration.lineThrough,
                color: Colors.grey,
              ),
            ),
            Text(
              "Trade Discount: - ฿${item.discount}",
              style: const TextStyle(
                color: Colors.red,
              ),
            ),
            const Divider(),
            Text(
              "Final Price: ฿$finalPrice",
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
                color: Colors.green,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: const Text("Cancel"),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);

              await _orderManager.updateTradeStatus(
                item.id,
                'Approved',
              );

              await _orderManager.addOrder(
                "Trade Sale: ${item.name}",
                finalPrice,
              );

              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text(
                      'Trade approved successfully!',
                    ),
                    backgroundColor: Colors.green,
                  ),
                );
              }
            },
            child: const Text(
              "Approve & Receive Payment",
              style: TextStyle(
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _getDisplayStatus(String status) {
    if (status == 'อนุมัติแล้ว') {
      return 'Approved';
    } else if (status == 'รอตรวจสอบ') {
      return 'Pending';
    } else if (status == 'ปฏิเสธ') {
      return 'Rejected';
    } else {
      return status;
    }
  }

  Color _getStatusColor(String status) {
    final displayStatus = _getDisplayStatus(status);

    if (displayStatus == 'Approved') {
      return Colors.green;
    } else if (displayStatus == 'Pending') {
      return Colors.orange;
    } else {
      return Colors.red;
    }
  }

  bool _isPendingStatus(String status) {
    return status == 'Pending' || status == 'รอตรวจสอบ';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        title: const Text('Trade System'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
      ),
      body: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            color: Colors.white,
            child: Row(
              children: [
                Expanded(
                  child: _buildShortcutButton(
                    context,
                    'Customer Orders',
                    Icons.shopping_basket,
                    Colors.orange,
                    SellerOrderScreen(),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildShortcutButton(
                    context,
                    'Store Income',
                    Icons.account_balance_wallet,
                    Colors.green,
                    IncomeScreen(),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          const Padding(
            padding: EdgeInsets.symmetric(
              horizontal: 16.0,
              vertical: 8.0,
            ),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                "Trade Requests",
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),

          Expanded(
            child: StreamBuilder<List<TradeModel>>(
              stream: _orderManager.getTradesStream(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(
                    child: CircularProgressIndicator(),
                  );
                }

                if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return const Center(
                    child: Text(
                      "No trade requests yet",
                      style: TextStyle(
                        color: Colors.grey,
                      ),
                    ),
                  );
                }

                final trades = snapshot.data!;

                return ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: trades.length,
                  itemBuilder: (context, index) {
                    final item = trades[index];

                    final displayStatus = _getDisplayStatus(item.status);
                    final statusColor = _getStatusColor(item.status);

                    return Card(
                      elevation: 0,
                      margin: const EdgeInsets.only(bottom: 10),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                        side: BorderSide(
                          color: Colors.grey.shade200,
                        ),
                      ),
                      child: ListTile(
                        onTap: _isPendingStatus(item.status)
                            ? () {
                          _approveTrade(item);
                        }
                            : null,
                        leading: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.blue.shade50,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.swap_horiz,
                            color: Colors.blue,
                          ),
                        ),
                        title: Text(
                          item.name,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        subtitle: Text(
                          "Condition: ${item.grade} | Discount ฿${item.discount}",
                        ),
                        trailing: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: statusColor.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            displayStatus,
                            style: TextStyle(
                              color: statusColor,
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
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

      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          await _orderManager.addTradeRequest(
            'Smart Watch',
            'Grade A',
            1500.0,
            400.0,
          );

          if (context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text(
                  'Trade request added successfully!',
                ),
              ),
            );
          }
        },
        label: const Text(
          "Add Demo Trade",
          style: TextStyle(
            color: Colors.white,
          ),
        ),
        icon: const Icon(
          Icons.add_shopping_cart,
          color: Colors.white,
        ),
        backgroundColor: Colors.blue,
      ),
    );
  }

  Widget _buildShortcutButton(
      BuildContext context,
      String title,
      IconData icon,
      Color color,
      Widget targetPage,
      ) {
    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => targetPage,
          ),
        );
      },
      child: Container(
        padding: const EdgeInsets.symmetric(
          vertical: 16,
        ),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: color.withValues(alpha: 0.3),
          ),
        ),
        child: Column(
          children: [
            Icon(
              icon,
              color: color,
              size: 30,
            ),
            const SizedBox(height: 8),
            Text(
              title,
              style: TextStyle(
                color: color,
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }
}