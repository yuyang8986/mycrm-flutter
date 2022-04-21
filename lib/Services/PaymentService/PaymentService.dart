import 'package:stripe_payment/stripe_payment.dart';

class PaymentService {
  Token _paymentToken;
  PaymentMethod _paymentMethod;
  String _error;
  PaymentIntentResult _paymentIntent;
  Source _source;

  final CreditCard testCard = CreditCard(
    number: '4000002760003184',
    expMonth: 12,
    expYear: 21,
  );
}
