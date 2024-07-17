// ignore_for_file: use_build_context_synchronously

import 'dart:convert';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:http/http.dart' as http;

class StripePaymentScreen extends StatefulWidget {
  const StripePaymentScreen({super.key});

  @override
  State<StripePaymentScreen> createState() => _StripePaymentScreenState();
}

class _StripePaymentScreenState extends State<StripePaymentScreen> {
  Map<String, dynamic>? paymentIntent;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Stripe Payment'),
      ),
      body: Center(
        child: ElevatedButton(
          child: const Text('Make Payment'),
          onPressed: () async {
            await makePayment();
          },
        ),
      ),
    );
  }

  Future<void> makePayment() async {
    try {
      // Create payment intent data
      paymentIntent =
          await createPaymentIntent('1000', 'KES') as Map<String, dynamic>?;
      // initialise the payment sheet setup
      await Stripe.instance.initPaymentSheet(
        paymentSheetParameters: SetupPaymentSheetParameters(
          // Client secret key from payment data
          paymentIntentClientSecret: paymentIntent!['client_secret'].toString(),
          googlePay: const PaymentSheetGooglePay(
            // Currency and country code is accourding to KENYA
            testEnv: true,
            currencyCode: 'KES',
            merchantCountryCode: 'KE',
          ),
          // Merchant Name
          merchantDisplayName: 'Erick Ogaro',
          // return URl if you want to add
          // returnURL: 'flutterstripe://redirect',
        ),
      );
      // Display payment sheet
      await displayPaymentSheet();
    } catch (e) {
      log('exception $e');

      if (e is StripeConfigException) {
        log('Stripe exception ${e.message}');
      } else {
        log('exception $e');
      }
    }
  }

  Future<void> displayPaymentSheet() async {
    try {
      // "Display payment sheet";
      await Stripe.instance.presentPaymentSheet();
      // Show when payment is done
      // Displaying snackbar for it
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Paid successfully')),
      );
      paymentIntent = null;
    } on StripeException catch (e) {
      // If any error comes during payment
      // so payment will be cancelled
      log('Error: $e');

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text(' Payment Cancelled')),
      );
    } catch (e) {
      log('Error in displaying');
      log('$e');
    }
  }

  Future<void> createPaymentIntent(String amount, String currency) async {
    try {
      final body = <String, dynamic>{
        'amount': ((int.parse(amount)) * 100).toString(),
        'currency': currency,
        'payment_method_types[]': 'card',
      };
      final secretKey = dotenv.env['STRIPE_SECRET_KEY'] ?? '';

      final response = await http.post(
        Uri.parse('https://api.stripe.com/v1/payment_intents'),
        headers: {
          'Authorization': 'Bearer $secretKey',
          'Content-Type': 'application/x-www-form-urlencoded',
        },
        body: body,
      );
      log('Payment Intent Body: ${response.body}');
      return jsonDecode(response.body);
    } catch (err) {
      log('Error charging user: $err');
    }
  }
}
