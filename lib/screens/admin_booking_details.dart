import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
//import 'package:url_launcher/url_launcher.dart';

class BookingDetailsPage extends StatefulWidget {
  final String bookingId;

  const BookingDetailsPage({Key? key, required this.bookingId})
      : super(key: key);

  @override
  _BookingDetailsPageState createState() => _BookingDetailsPageState();
}

class _BookingDetailsPageState extends State<BookingDetailsPage> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  bool _isLoading = true;
  BookingModel? _booking;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _fetchBookingDetails();
  }

  Future<void> _fetchBookingDetails() async {
    try {
      setState(() {
        _isLoading = true;
        _errorMessage = null;
      });

      final DocumentSnapshot doc =
          await _firestore.collection('Booking').doc(widget.bookingId).get();

      if (doc.exists) {
        setState(() {
          _booking = BookingModel.fromFirestore(doc);
          _isLoading = false;
        });
      } else {
        setState(() {
          _isLoading = false;
          _errorMessage = 'Booking not found';
        });
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
        _errorMessage = 'Error loading booking details: ${e.toString()}';
      });
      print('Error fetching booking details: $e');
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
        title: Text(
          "Booking Details",
          style: TextStyle(color: Colors.black, fontSize: 18),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.refresh, color: Colors.black),
            onPressed: _fetchBookingDetails,
          ),
        ],
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : _errorMessage != null
              ? Center(
                  child:
                      Text(_errorMessage!, style: TextStyle(color: Colors.red)),
                )
              : _booking == null
                  ? Center(child: Text("No booking found"))
                  : _buildBookingDetails(),
    );
  }

  Widget _buildBookingDetails() {
    return SingleChildScrollView(
      padding: EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildBookingHeader(),
          SizedBox(height: 24),
          _buildSection(
            title: "Customer Information",
            child: _buildCustomerInfo(),
          ),
          SizedBox(height: 16),
          _buildSection(
            title: "Booking Information",
            child: _buildBookingInfo(),
          ),
          SizedBox(height: 16),
          _buildSection(
            title: "Service Details",
            child: _buildServicesInfo(),
          ),
          SizedBox(height: 16),
          _buildSection(
            title: "Payment Details",
            child: _buildPaymentInfo(),
          ),
          SizedBox(height: 24),
          _buildActionButtons(),
        ],
      ),
    );
  }

  Widget _buildBookingHeader() {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Container(
        padding: EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.blue.shade700, Colors.blue.shade500],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "Booking #${_booking!.id.substring(0, 8)}",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                _buildStatusBadge(_booking!.status),
              ],
            ),
            SizedBox(height: 12),
            Text(
              "Customer: ${_booking!.customerName}",
              style: TextStyle(color: Colors.white, fontSize: 16),
            ),
            SizedBox(height: 6),
            Text(
              "Vehicle: ${_booking!.vehicleModel}",
              style:
                  TextStyle(color: Colors.white.withOpacity(0.9), fontSize: 15),
            ),
            SizedBox(height: 12),
            Row(
              children: [
                Icon(Icons.calendar_today, color: Colors.white, size: 16),
                SizedBox(width: 6),
                Text(
                  DateFormat('dd MMM yyyy').format(_booking!.bookingDate),
                  style: TextStyle(color: Colors.white, fontSize: 14),
                ),
                SizedBox(width: 12),
                Icon(Icons.access_time, color: Colors.white, size: 16),
                SizedBox(width: 6),
                Text(
                  _booking!.timeSlot,
                  style: TextStyle(color: Colors.white, fontSize: 14),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusBadge(String status) {
    Color badgeColor;
    switch (status) {
      case 'Confirmed':
        badgeColor = Colors.green.shade600;
        break;
      case 'Pending':
        badgeColor = Colors.orange.shade600;
        break;
      case 'Cancelled':
        badgeColor = Colors.red.shade600;
        break;
      default:
        badgeColor = Colors.blue.shade600;
    }

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        status,
        style: TextStyle(
          color: badgeColor,
          fontWeight: FontWeight.bold,
          fontSize: 14,
        ),
      ),
    );
  }

  Widget _buildSection({required String title, required Widget child}) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 2,
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.blue.shade800,
              ),
            ),
            SizedBox(height: 12),
            child,
          ],
        ),
      ),
    );
  }

  Widget _buildCustomerInfo() {
    return Column(
      children: [
        _buildInfoRow(
          icon: Icons.person,
          title: "Name",
          value: _booking!.customerName,
        ),
        Divider(height: 24),
        _buildInfoRow(
          icon: Icons.phone,
          title: "Phone",
          value: _booking!.phoneNumber,
          action: IconButton(
              icon: Icon(Icons.call, color: Colors.green, size: 22),
              onPressed: () {} //_launchPhone(_booking!.phoneNumber),

              ),
        ),
        Divider(height: 24),
        _buildInfoRow(
          icon: Icons.location_on,
          title: "Address",
          value: _booking!.address,
          action: IconButton(
              icon: Icon(Icons.map, color: Colors.blue, size: 22),
              onPressed: () {} //=> // _launchMaps(_booking!.address),
              ),
        ),
      ],
    );
  }

  Widget _buildBookingInfo() {
    return Column(
      children: [
        _buildInfoRow(
          icon: Icons.calendar_today,
          title: "Date",
          value: DateFormat('dd MMMM yyyy').format(_booking!.bookingDate),
        ),
        Divider(height: 24),
        _buildInfoRow(
          icon: Icons.access_time,
          title: "Time Slot",
          value: _booking!.timeSlot,
        ),
        Divider(height: 24),
        _buildInfoRow(
          icon: Icons.car_repair,
          title: "Vehicle",
          value: _booking!.vehicleModel,
        ),
        Divider(height: 24),
        _buildInfoRow(
          icon: Icons.pin,
          title: "Booking ID",
          value: _booking!.id,
        ),
      ],
    );
  }

  Widget _buildServicesInfo() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ..._booking!.services
            .map((service) => Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: service.imageUrl.isNotEmpty
                            ? Image.network(
                                service.imageUrl,
                                width: 80,
                                height: 60,
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) =>
                                    Container(
                                  width: 80,
                                  height: 60,
                                  color: Colors.grey.shade200,
                                  child: Icon(Icons.image_not_supported,
                                      color: Colors.grey),
                                ),
                              )
                            : Container(
                                width: 80,
                                height: 60,
                                color: Colors.grey.shade200,
                                child: Icon(Icons.cleaning_services,
                                    color: Colors.blue),
                              ),
                      ),
                      SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              service.serviceName,
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 15,
                              ),
                            ),
                            SizedBox(height: 4),
                            Text(
                              "Service ID: ${service.serviceId.substring(0, 8)}...",
                              style: TextStyle(
                                color: Colors.grey.shade600,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Text(
                        "₹${service.price.toStringAsFixed(0)}",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          color: Colors.blue.shade800,
                        ),
                      ),
                    ],
                  ),
                ))
            .toList(),
        Divider(height: 24),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              "Total Amount",
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
            Text(
              "₹${_booking!.totalAmount.toStringAsFixed(0)}",
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 18,
                color: Colors.blue.shade800,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildPaymentInfo() {
    return Column(
      children: [
        _buildInfoRow(
          icon: Icons.payment,
          title: "Status",
          value: _booking!.paymentDetails.paymentStatus,
          valueColor:
              _getPaymentStatusColor(_booking!.paymentDetails.paymentStatus),
          valueBold: true,
        ),
        Divider(height: 24),
        _buildInfoRow(
          icon: Icons.credit_card,
          title: "Method",
          value: _booking!.paymentDetails.paymentMethod,
        ),
        if (_booking!.paymentDetails.paymentId != null) ...[
          Divider(height: 24),
          _buildInfoRow(
            icon: Icons.confirmation_number,
            title: "Payment ID",
            value: _booking!.paymentDetails.paymentId!,
          ),
        ],
        if (_booking!.paymentDetails.timestamp != null) ...[
          Divider(height: 24),
          _buildInfoRow(
            icon: Icons.access_time,
            title: "Payment Date",
            value: DateFormat('dd MMM yyyy, hh:mm a')
                .format(_booking!.paymentDetails.timestamp!),
          ),
        ],
        Divider(height: 24),
        _buildInfoRow(
          icon: Icons.monetization_on,
          title: "Amount",
          value: "₹${_booking!.paymentDetails.amount.toStringAsFixed(0)}",
          valueBold: true,
          valueColor: Colors.blue.shade800,
        ),
      ],
    );
  }

  Widget _buildInfoRow({
    required IconData icon,
    required String title,
    required String value,
    Widget? action,
    Color? valueColor,
    bool valueBold = false,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 20, color: Colors.blue.shade600),
        SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey.shade600,
                ),
              ),
              SizedBox(height: 4),
              Text(
                value,
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: valueBold ? FontWeight.bold : FontWeight.normal,
                  color: valueColor,
                ),
              ),
            ],
          ),
        ),
        if (action != null) action,
      ],
    );
  }

  Widget _buildActionButtons() {
    return Row(
      children: [
        Expanded(
          child: ElevatedButton.icon(
            onPressed: () {
              // Update booking status functionality
              // This would typically show a dialog with status options
              _showUpdateStatusDialog();
            },
            icon: Icon(Icons.edit),
            label: Text("Update Status"),
            style: ElevatedButton.styleFrom(
              padding: EdgeInsets.symmetric(vertical: 12),
              backgroundColor: Colors.blue,
            ),
          ),
        ),
        SizedBox(width: 12),
        Expanded(
          child: OutlinedButton.icon(
            onPressed: () {
              // Contact customer functionality
              // _launchPhone(_booking!.phoneNumber);
            },
            icon: Icon(Icons.call),
            label: Text("Contact"),
            style: OutlinedButton.styleFrom(
              padding: EdgeInsets.symmetric(vertical: 12),
              side: BorderSide(color: Colors.blue),
            ),
          ),
        ),
      ],
    );
  }

  void _showUpdateStatusDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("Update Booking Status"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildStatusOption("Pending"),
            _buildStatusOption("Confirmed"),
            _buildStatusOption("In Progress"),
            _buildStatusOption("Completed"),
            _buildStatusOption("Cancelled"),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text("Cancel"),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusOption(String status) {
    bool isSelected = _booking!.status == status;
    return ListTile(
      contentPadding: EdgeInsets.symmetric(horizontal: 8),
      title: Text(status),
      leading: Radio<String>(
        value: status,
        groupValue: _booking!.status,
        onChanged: (value) {
          Navigator.pop(context);
          // Implement status update functionality
          _updateBookingStatus(value!);
        },
      ),
      onTap: () {
        Navigator.pop(context);
        _updateBookingStatus(status);
      },
      dense: true,
    );
  }

  Future<void> _updateBookingStatus(String newStatus) async {
    try {
      setState(() => _isLoading = true);

      await _firestore.collection('Booking').doc(_booking!.id).update({
        'status': newStatus,
        'updatedAt': FieldValue.serverTimestamp(),
      });

      // Refresh booking details
      _fetchBookingDetails();

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Booking status updated to $newStatus'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to update status: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  // Future<void> _launchPhone(String phoneNumber) async {
  //   final Uri phoneUri = Uri(scheme: 'tel', path: phoneNumber);
  //   if (await canLaunchUrl(phoneUri)) {
  //     await launchUrl(phoneUri);
  //   } else {
  //     ScaffoldMessenger.of(context).showSnackBar(
  //       SnackBar(content: Text('Could not launch phone dialer')),
  //     );
  //   }
  // }

  // Future<void> _launchMaps(String address) async {
  //   final Uri mapsUri = Uri(
  //     scheme: 'https',
  //     host: 'www.google.com',
  //     path: '/maps/search/',
  //     queryParameters: {'query': address},
  //   );
  //   if (await canLaunchUrl(mapsUri)) {
  //     await launchUrl(mapsUri, mode: LaunchMode.externalApplication);
  //   } else {
  //     ScaffoldMessenger.of(context).showSnackBar(
  //       SnackBar(content: Text('Could not launch maps')),
  //     );
  //   }
  // }

  Color _getPaymentStatusColor(String status) {
    switch (status) {
      case 'Completed':
        return Colors.green.shade600;
      case 'Failed':
        return Colors.red.shade600;
      case 'Pending':
        return Colors.orange.shade600;
      default:
        return Colors.blue.shade600;
    }
  }
}

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
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final String? userId;

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
    this.createdAt,
    this.updatedAt,
    this.userId,
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
      createdAt: data['createdAt'] != null
          ? (data['createdAt'] as Timestamp).toDate()
          : null,
      updatedAt: data['updatedAt'] != null
          ? (data['updatedAt'] as Timestamp).toDate()
          : null,
      userId: data['userId'],
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
      paymentMethod: map['paymentMethod'] ?? 'UPI', // Default value added
      paymentStatus: map['paymentStatus'] ?? 'Completed', // Default value added
    );
  }
}
