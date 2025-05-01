import 'package:car_crew/screens/admin_booking_details.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

// Import the BookingDetailsPage

class BookingModel {
  final String id;
  final String customerName;
  final String phoneNumber;
  final String address;
  final DateTime bookingDate;
  final String timeSlot;
  final String status;
  final List<ServiceModel> services;
  final double totalAmount;
  final PaymentDetails paymentDetails;
  final String vehicleModel;

  BookingModel({
    required this.id,
    required this.customerName,
    required this.phoneNumber,
    required this.address,
    required this.bookingDate,
    required this.timeSlot,
    required this.status,
    required this.services,
    required this.totalAmount,
    required this.paymentDetails,
    required this.vehicleModel,
  });

  factory BookingModel.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;

    // Parse services list
    List<ServiceModel> servicesList = [];
    if (data['services'] != null) {
      for (var service in data['services']) {
        servicesList.add(ServiceModel.fromMap(service));
      }
    }

    // Parse payment details
    PaymentDetails payment =
        PaymentDetails.fromMap(data['paymentDetails'] ?? {});

    return BookingModel(
      id: doc.id,
      customerName: data['customerName'] ?? '',
      phoneNumber: data['phoneNumber'] ?? '',
      address: data['address'] ?? '',
      bookingDate: (data['bookingDate'] as Timestamp).toDate(),
      timeSlot: data['timeSlot'] ?? '',
      status: data['status'] ?? '',
      services: servicesList,
      totalAmount: (data['totalAmount'] ?? 0).toDouble(),
      paymentDetails: payment,
      vehicleModel: data['vehicleModel'] ?? '',
    );
  }
}

class ServiceModel {
  final String serviceId;
  final String serviceName;
  final double price;
  final String imageUrl;

  ServiceModel({
    required this.serviceId,
    required this.serviceName,
    required this.price,
    required this.imageUrl,
  });

  factory ServiceModel.fromMap(Map<String, dynamic> map) {
    return ServiceModel(
      serviceId: map['serviceId'] ?? '',
      serviceName: map['serviceName'] ?? '',
      price: (map['price'] ?? 0).toDouble(),
      imageUrl: map['imageUrl'] ?? '',
    );
  }
}

class PaymentDetails {
  final double amount;
  final String? orderId;
  final String? paymentId;
  final String? signature;
  final DateTime? timestamp;
  final String paymentMethod;
  final String paymentStatus;

  PaymentDetails({
    required this.amount,
    this.orderId,
    this.paymentId,
    this.signature,
    this.timestamp,
    required this.paymentMethod,
    required this.paymentStatus,
  });

  factory PaymentDetails.fromMap(Map<String, dynamic> map) {
    return PaymentDetails(
      amount: (map['amount'] ?? 0).toDouble(),
      orderId: map['orderId'],
      paymentId: map['paymentId'],
      signature: map['signature'],
      timestamp: map['timestamp'] != null
          ? (map['timestamp'] as Timestamp).toDate()
          : null,
      paymentMethod: map['paymentMethod'] ?? '',
      paymentStatus: map['paymentStatus'] ?? '',
    );
  }
}

class AdminShowBooking extends StatefulWidget {
  @override
  _AdminShowBookingState createState() => _AdminShowBookingState();
}

class _AdminShowBookingState extends State<AdminShowBooking> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  bool _isLoading = true;
  List<BookingModel> _bookings = [];
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _fetchBookings();
  }

  Future<void> _fetchBookings() async {
    try {
      setState(() {
        _isLoading = true;
        _errorMessage = null;
      });

      final QuerySnapshot snapshot = await _firestore
          .collection('Booking')
          .orderBy('bookingDate', descending: true)
          .get();

      List<BookingModel> loadedBookings = [];
      for (var doc in snapshot.docs) {
        loadedBookings.add(BookingModel.fromFirestore(doc));
      }

      setState(() {
        _bookings = loadedBookings;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _errorMessage = 'Error loading bookings: ${e.toString()}';
      });
      print('Error fetching bookings: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text("Show Bookings",
            style: TextStyle(color: Colors.black, fontSize: 18)),
        actions: [
          IconButton(
            icon: Icon(Icons.refresh, color: Colors.black),
            onPressed: _fetchBookings,
          ),
        ],
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : _errorMessage != null
              ? Center(
                  child:
                      Text(_errorMessage!, style: TextStyle(color: Colors.red)))
              : _bookings.isEmpty
                  ? Center(child: Text("No bookings found"))
                  : SingleChildScrollView(
                      padding:
                          EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                      child: Column(
                        children: _bookings
                            .map((booking) => _buildBookingCard(booking))
                            .toList(),
                      ),
                    ),
    );
  }

  Widget _buildBookingCard(BookingModel booking) {
    // Format booking date
    final DateFormat dateFormatter = DateFormat('dd MMM yyyy');
    final String formattedDate = dateFormatter.format(booking.bookingDate);

    // Get primary service for display
    final String serviceName = booking.services.isNotEmpty
        ? booking.services[0].serviceName
        : 'No service';
    final String serviceImage =
        booking.services.isNotEmpty ? booking.services[0].imageUrl : '';

    return GestureDetector(
      onTap: () {
        // Navigate to booking details page when card is tapped
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => BookingDetailsPage(bookingId: booking.id),
          ),
        ).then((_) {
          // Refresh the list when returning from details page
          _fetchBookings();
        });
      },
      child: Card(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        elevation: 2,
        margin: EdgeInsets.only(bottom: 16),
        child: Padding(
          padding: EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildCustomerInfo(booking),
              SizedBox(height: 12),
              _buildTripDetail(
                icon: Icons.calendar_today_outlined,
                text: "$formattedDate • ${booking.timeSlot}",
                actionText: booking.status,
                isStatus: true,
                status: booking.status,
              ),
              SizedBox(height: 10),
              _buildTripDetail(
                icon: Icons.location_on_outlined,
                text: booking.address,
                actionText: "View Details",
              ),
              SizedBox(height: 10),
              _buildTripDetail(
                icon: Icons.car_repair,
                text: "Vehicle: ${booking.vehicleModel}",
                actionText: "",
              ),
              if (booking.services.isNotEmpty) ...[
                SizedBox(height: 10),
                _buildServicesList(booking.services),
              ],
              SizedBox(height: 10),
              _buildPaymentInfo(booking.paymentDetails, booking.totalAmount),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCustomerInfo(BookingModel booking) {
    return Row(
      children: [
        CircleAvatar(
          radius: 25,
          backgroundColor: Colors.blue.shade100,
          child: Icon(Icons.person, color: Colors.blue, size: 30),
        ),
        SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(booking.customerName,
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              Text("Phone: ${booking.phoneNumber}",
                  style: TextStyle(fontSize: 14, color: Colors.grey[700])),
              Text("Booking ID: ${booking.id.substring(0, 8)}...",
                  style: TextStyle(fontSize: 12, color: Colors.grey[600])),
            ],
          ),
        ),
        IconButton(
          icon: Icon(Icons.call, color: Colors.blue, size: 24),
          onPressed: () {
            // Implement call functionality
            // _makePhoneCall(booking.phoneNumber);
          },
        ),
      ],
    );
  }

  Widget _buildTripDetail({
    required IconData icon,
    required String text,
    required String actionText,
    bool isStatus = false,
    String status = '',
  }) {
    Color statusColor = Colors.blue;
    if (isStatus) {
      if (status == 'Confirmed')
        statusColor = Colors.green;
      else if (status == 'Cancelled')
        statusColor = Colors.red;
      else if (status == 'Pending') statusColor = Colors.orange;
    }

    return Container(
      padding: EdgeInsets.symmetric(vertical: 12, horizontal: 16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Row(
              children: [
                Icon(icon, color: Colors.blue, size: 20),
                SizedBox(width: 8),
                Expanded(
                  child: Text(text, style: TextStyle(fontSize: 14)),
                ),
              ],
            ),
          ),
          if (actionText.isNotEmpty)
            Text(
              actionText,
              style: TextStyle(
                  fontSize: 14,
                  color: isStatus ? statusColor : Colors.blue,
                  fontWeight: FontWeight.bold),
            ),
        ],
      ),
    );
  }

  Widget _buildServicesList(List<ServiceModel> services) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 12, horizontal: 16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.cleaning_services, color: Colors.blue, size: 20),
              SizedBox(width: 8),
              Text("Services", style: TextStyle(fontWeight: FontWeight.bold)),
            ],
          ),
          SizedBox(height: 8),
          ...services
              .map((service) => Padding(
                    padding: const EdgeInsets.only(left: 28, bottom: 4),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(service.serviceName),
                        Text("₹${service.price.toStringAsFixed(0)}",
                            style: TextStyle(fontWeight: FontWeight.bold)),
                      ],
                    ),
                  ))
              .toList(),
        ],
      ),
    );
  }

  Widget _buildPaymentInfo(PaymentDetails payment, double totalAmount) {
    Color statusColor = Colors.blue;
    if (payment.paymentStatus == 'Completed')
      statusColor = Colors.green;
    else if (payment.paymentStatus == 'Failed')
      statusColor = Colors.red;
    else if (payment.paymentStatus == 'Pending') statusColor = Colors.orange;

    return Container(
      padding: EdgeInsets.symmetric(vertical: 12, horizontal: 16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.grey.shade300),
        color: Colors.grey.shade50,
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(Icons.payment, color: Colors.blue, size: 20),
                  SizedBox(width: 8),
                  Text("Payment",
                      style: TextStyle(fontWeight: FontWeight.bold)),
                ],
              ),
              Text(
                payment.paymentStatus,
                style: TextStyle(
                  color: statusColor,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text("Method:"),
              Text(payment.paymentMethod),
            ],
          ),
          if (payment.paymentId != null) ...[
            SizedBox(height: 4),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text("Payment ID:"),
                Text(payment.paymentId!
                        .substring(0, min(10, payment.paymentId!.length)) +
                    "..."),
              ],
            ),
          ],
          Divider(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text("Total Amount:",
                  style: TextStyle(fontWeight: FontWeight.bold)),
              Text(
                "₹${totalAmount.toStringAsFixed(0)}",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  color: Colors.blue.shade800,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // Helper function to make phone calls
  // void _makePhoneCall(String phoneNumber) async {
  //   final Uri phoneUri = Uri(scheme: 'tel', path: phoneNumber);
  //   try {
  //     if (await canLaunchUrl(phoneUri)) {
  //       await launchUrl(phoneUri);
  //     } else {
  //       ScaffoldMessenger.of(context).showSnackBar(
  //         SnackBar(content: Text('Could not launch phone dialer')),
  //       );
  //     }
  //   } catch (e) {
  //     ScaffoldMessenger.of(context).showSnackBar(
  //       SnackBar(content: Text('Error making phone call: $e')),
  //     );
  //   }
  // }
}

// Helper function for string length comparison
int min(int a, int b) => a < b ? a : b;

void main() {
  runApp(MaterialApp(
    debugShowCheckedModeBanner: false,
    theme: ThemeData(
      primarySwatch: Colors.blue,
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.white,
        iconTheme: IconThemeData(color: Colors.black),
        titleTextStyle: TextStyle(color: Colors.black, fontSize: 18),
      ),
    ),
    home: AdminShowBooking(),
  ));
}
