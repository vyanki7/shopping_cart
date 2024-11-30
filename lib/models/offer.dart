class Offer {
  final int offerId;
  final String offerDetails;

  Offer({
    required this.offerId,
    required this.offerDetails,
  });

  factory Offer.fromJson(Map<String, dynamic> json) {
    return Offer(
      offerId: json['offer_id'] as int,
      offerDetails: json['offer_details'] as String,
    );
  }


  Map<String, dynamic> toJson() {
    return {
      'offer_id': offerId,
      'offer_details': offerDetails,
    };
  }
}
