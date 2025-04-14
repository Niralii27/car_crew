import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class CheckoutPage extends StatefulWidget {
  final List<CartItem> cartItems;
  final double totalAmount;

  const CheckoutPage({
    Key? key,
    required this.cartItems,
    required this.totalAmount,
  }) : super(key: key);

  @override
  _CheckoutPageState createState() => _CheckoutPageState();
}

class _CheckoutPageState extends State<CheckoutPage> {
  // Selected date and time slot
  DateTime selectedDate = DateTime.now().add(const Duration(days: 1));
  String selectedTimeSlot = '10:00 AM - 12:00 PM';
  
  // Available time slots
  final List<String> timeSlots = [
    '08:00 AM - 10:00 AM',
    '10:00 AM - 12:00 PM',
    '01:00 PM - 03:00 PM',
    '03:00 PM - 05:00 PM',
    '05:00 PM - 07:00 PM',
  ];

  // Payment method
  String selectedPaymentMethod = 'Online Payment';
  final List<String> paymentMethods = [
    'Online Payment',
    'Credit/Debit Card',
    'UPI',
    'Pay at Service',
  ];

  // Form key
  final _formKey = GlobalKey<FormState>();
  
  // User details
  final TextEditingController nameController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController addressController = TextEditingController();
  final TextEditingController vehicleController = TextEditingController();

  // Handle date selection
  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: selectedDate,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 30)),
      selectableDayPredicate: (DateTime date) {
        // Disable past dates
        return date.isAfter(DateTime.now().subtract(const Duration(days: 1)));
      },
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: Colors.blue[800]!,
              onPrimary: Colors.white,
              onSurface: Colors.black,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null && picked != selectedDate) {
      setState(() {
        selectedDate = picked;
      });
    }
  }

  // Book service
  void _bookService() {
    if (_formKey.currentState!.validate()) {
      // Show loading indicator
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const Center(
          child: CircularProgressIndicator(),
        ),
      );

      // Simulate processing
      Future.delayed(const Duration(seconds: 2), () {
        Navigator.pop(context); // Close loading dialog
        
        // Show success dialog
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return _buildSuccessDialog(context);
          },
        );
      });
    }
  }

  Widget _buildSuccessDialog(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.0)),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.check_circle,
              color: Colors.green,
              size: 80,
            ),
            const SizedBox(height: 20),
            const Text(
              'Booking Successful!',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 15),
            Text(
              'Your service has been booked for ${DateFormat('EEEE, dd MMM yyyy').format(selectedDate)} at $selectedTimeSlot',
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 10),
            Text(
              'Total Amount: ₹${widget.totalAmount.toStringAsFixed(2)}',
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.blue,
              ),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue[800],
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 15),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                onPressed: () {
                  // Navigate back to home/dashboard
                  Navigator.of(context).popUntil((route) => route.isFirst);
                },
                child: const Text(
                  'Back to Home',
                  style: TextStyle(fontSize: 16),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Get screen size for responsive design
    final Size screenSize = MediaQuery.of(context).size;
    final bool isSmallScreen = screenSize.width < 600;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Checkout'),
        backgroundColor: Colors.blue[800],
        elevation: 0,
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.blue[50]!, Colors.white],
          ),
        ),
        child: SafeArea(
          child: Form(
            key: _formKey,
            child: ListView(
              padding: EdgeInsets.all(isSmallScreen ? 16 : 24),
              children: [
                // Service summary section
                _buildSectionTitle('Service Summary', Icons.car_repair),
                _buildServiceSummary(isSmallScreen),
                
                // Date and time selection
                _buildSectionTitle('Select Date & Time', Icons.calendar_today),
                _buildDateTimeSelection(isSmallScreen),
                
                // User details
                _buildSectionTitle('Your Details', Icons.person),
                _buildUserDetailsForm(isSmallScreen),
                
                // Payment method
                _buildSectionTitle('Payment Method', Icons.payment),
                _buildPaymentMethodSelection(isSmallScreen),
                
                // Proceed to pay button
                const SizedBox(height: 30),
                _buildProceedButton(isSmallScreen),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title, IconData icon) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Row(
        children: [
          Icon(icon, color: Colors.blue[800], size: 24),
          const SizedBox(width: 10),
          Text(
            title,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.blue[800],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildServiceSummary(bool isSmallScreen) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Services list
            ...widget.cartItems.map((item) => Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    item.serviceName,
                    style: TextStyle(fontSize: isSmallScreen ? 14 : 16),
                  ),
                  Text(
                    '₹${item.price.toStringAsFixed(2)}',
                    style: TextStyle(
                      fontSize: isSmallScreen ? 14 : 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            )).toList(),
            
            // Divider
            const Divider(height: 20, thickness: 1),
            
            // Total
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Total Amount',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                Text(
                  '₹${widget.totalAmount.toStringAsFixed(2)}',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.blue[800],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDateTimeSelection(bool isSmallScreen) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Date picker
            InkWell(
              onTap: () => _selectDate(context),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey[300]!),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Date: ${DateFormat('dd MMM yyyy (EEEE)').format(selectedDate)}',
                      style: TextStyle(fontSize: isSmallScreen ? 14 : 16),
                    ),
                    const Icon(Icons.calendar_month),
                  ],
                ),
              ),
            ),
            
            const SizedBox(height: 16),
            
            // Time slot selection
            const Text(
              'Select Time Slot:',
              style: TextStyle(fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: 10),
            
            // Time slot chips
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: timeSlots.map((slot) {
                final isSelected = selectedTimeSlot == slot;
                return ChoiceChip(
                  label: Text(slot),
                  selected: isSelected,
                  labelStyle: TextStyle(
                    color: isSelected ? Colors.white : Colors.black,
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                  ),
                  backgroundColor: Colors.grey[200],
                  selectedColor: Colors.blue[700],
                  onSelected: (selected) {
                    if (selected) {
                      setState(() {
                        selectedTimeSlot = slot;
                      });
                    }
                  },
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildUserDetailsForm(bool isSmallScreen) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Name field
            TextFormField(
              controller: nameController,
              decoration: InputDecoration(
                labelText: 'Full Name',
                prefixIcon: const Icon(Icons.person_outline),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter your name';
                }
                return null;
              },
            ),
            
            const SizedBox(height: 16),
            
            // Phone field
            TextFormField(
              controller: phoneController,
              decoration: InputDecoration(
                labelText: 'Phone Number',
                prefixIcon: const Icon(Icons.phone_android),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              keyboardType: TextInputType.phone,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter your phone number';
                } else if (value.length < 10) {
                  return 'Please enter a valid phone number';
                }
                return null;
              },
            ),
            
            const SizedBox(height: 16),
            
            // Address field
            TextFormField(
              controller: addressController,
              decoration: InputDecoration(
                labelText: 'Service Address',
                prefixIcon: const Icon(Icons.location_on_outlined),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              maxLines: 2,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter your address';
                }
                return null;
              },
            ),
            
            const SizedBox(height: 16),
            
            // Vehicle details
            TextFormField(
              controller: vehicleController,
              decoration: InputDecoration(
                labelText: 'Vehicle Model',
                hintText: 'e.g. Maruti Swift, Honda City',
                prefixIcon: const Icon(Icons.directions_car_outlined),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter your vehicle model';
                }
                return null;
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPaymentMethodSelection(bool isSmallScreen) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Payment methods
            ...paymentMethods.map((method) => RadioListTile<String>(
              title: Text(method),
              value: method,
              groupValue: selectedPaymentMethod,
              activeColor: Colors.blue[800],
              onChanged: (value) {
                setState(() {
                  selectedPaymentMethod = value!;
                });
              },
              dense: isSmallScreen,
            )).toList(),
            
            // Payment icons
            Padding(
              padding: const EdgeInsets.only(top: 8, left: 8),
              child: Wrap(
                spacing: 10,
                children: [
                  _buildPaymentIcon(Icons.credit_card, Colors.blue),
                  _buildPaymentIcon(Icons.account_balance, Colors.green),
                  _buildPaymentIcon(Icons.payment, Colors.orange),
                  _buildPaymentIcon(Icons.attach_money, Colors.purple),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPaymentIcon(IconData icon, MaterialColor color) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: color[50],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color[100]!),
      ),
      child: Icon(icon, color: color[700], size: 20),
    );
  }

  Widget _buildProceedButton(bool isSmallScreen) {
  final Size screenSize = MediaQuery.of(context).size;
    
    return Center(
      child: SizedBox(
        width: isSmallScreen ? double.infinity : screenSize.width * 0.6,
      height: isSmallScreen ? 50 : 55,
        child: ElevatedButton(
          onPressed: _bookService,
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.blue[800],
            foregroundColor: Colors.white,
            elevation: 3,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(15),
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.lock, size: 20),
              const SizedBox(width: 10),
              Text(
                'Proceed to Pay ₹${widget.totalAmount.toStringAsFixed(2)}',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// Create a helper function to navigate from the CartPage to CheckoutPage
void navigateToCheckout(BuildContext context, List<CartItem> cartItems, double totalAmount) {
  Navigator.push(
    context,
    MaterialPageRoute(
      builder: (context) => CheckoutPage(
        cartItems: cartItems,
        totalAmount: totalAmount,
      ),
    ),
  );
}

class CartItem {
  final String id;
  final String serviceName;
  final double price;
  final String imageUrl;

  CartItem({
    required this.id,
    required this.serviceName,
    required this.price,
    required this.imageUrl,
  });
}