class Delivery {
  const Delivery(this.deliveryId);

  final String deliveryId;

  factory Delivery.fromJSON(Map<String, dynamic> deliveryData) {
    return Delivery(deliveryData['deliveryId'].toString());
  }
}
