
import 'package:flutter/material.dart';

class HelpCenterScreen extends StatelessWidget {
  const HelpCenterScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),

      appBar: AppBar(
        title: const Text('Help Center'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
      ),

      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [

          const Padding(
            padding: EdgeInsets.only(bottom: 12.0),
            child: Text(
              "Contact Channels",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
          ),

          _buildContactCard(
            Icons.headset_mic,
            'Live Chat Support',
            'Available from 09:00 AM - 06:00 PM',
            Colors.blue,
          ),

          _buildContactCard(
            Icons.phone,
            'Call Center',
            '02-XXX-XXXX',
            Colors.green,
          ),

          _buildContactCard(
            Icons.email,
            'Email Support',
            'support@jimjaew.com',
            Colors.orange,
          ),

          const SizedBox(height: 24),

          const Padding(
            padding: EdgeInsets.only(bottom: 12.0),
            child: Text(
              "Frequently Asked Questions",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
          ),

          _buildFAQTile(
            'How can I place an order?',
            'You can select the product you want, tap the "Buy Now" button, and the system will process your purchase.',
          ),

          _buildFAQTile(
            'Can I cancel my order?',
            'Yes. If your order is still in the "In Delivery" status, you can go to "My Orders" and tap the cancel button.',
          ),

          _buildFAQTile(
            'How long does delivery take?',
            'Delivery usually takes around 2-3 business days, depending on the customer location.',
          ),

          _buildFAQTile(
            'When will I receive my sales income?',
            'Your income will appear in "Store Income" after the customer confirms that they have received the product.',
          ),

          _buildFAQTile(
            'How can I change my profile picture?',
            'The profile editing feature is currently under development. Please wait for the next app update.',
          ),
        ],
      ),
    );
  }

  Widget _buildContactCard(
      IconData icon,
      String title,
      String subtitle,
      Color iconColor,
      ) {
    return Card(
      elevation: 1,
      margin: const EdgeInsets.only(bottom: 8),
      color: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),

      child: ListTile(

        leading: CircleAvatar(
          backgroundColor: iconColor.withOpacity(0.1),
          child: Icon(
            icon,
            color: iconColor,
          ),
        ),

        title: Text(
          title,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 14,
          ),
        ),

        subtitle: Text(
          subtitle,
          style: const TextStyle(
            fontSize: 12,
            color: Colors.grey,
          ),
        ),

        trailing: const Icon(
          Icons.chevron_right,
          color: Colors.grey,
        ),

        onTap: () {

        },
      ),
    );
  }

  Widget _buildFAQTile(
      String question,
      String answer,
      ) {
    return Card(
      elevation: 1,
      margin: const EdgeInsets.only(bottom: 8),
      color: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),

      child: ExpansionTile(
        title: Text(
          question,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 14,
          ),
        ),
        iconColor: Colors.blue,

        children: [
          Padding(
            padding: const EdgeInsets.only(
              left: 16.0,
              right: 16.0,
              bottom: 16.0,
            ),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    answer,
                    style: TextStyle(
                      color: Colors.grey.shade700,
                      height: 1.5,
                      fontSize: 13,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}