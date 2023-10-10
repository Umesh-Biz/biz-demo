class Order {
  const Order({
    required this.number,
    required this.amount,
    required this.createdBy,
    required this.orderId,
  });

  factory Order.fromJSON(Map<String, dynamic> orderData,
      Map<dynamic, dynamic> additionalOrderData) {
    final additionalOrderDetails =
        additionalOrderData[orderData['id'].toString()];
    return Order(
      amount: orderData['value'].toString(),
      number: orderData['number'].toString(),
      createdBy: additionalOrderDetails?['ownerDetails']?['name'],
      orderId: orderData['id'].toString(),
    );
  }

  final String number;
  final String amount;
  final String createdBy;
  final String orderId;
}
