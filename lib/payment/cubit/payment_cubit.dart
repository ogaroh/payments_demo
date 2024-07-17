import 'dart:convert';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;

part 'payment_state.dart';

class PaymentCubit extends Cubit<PaymentState> {
  PaymentCubit() : super(PaymentInitial());

  // create payment
  Future<void> createPaymentIntent(String amount, String currency) async {
    emit(PaymentLoading());
    try {
      final body = <String, dynamic>{
        // Amount must be in smaller unit of currency
        // so we have multiply it by 100
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
      final result = jsonDecode(response.body);
      emit(
        PaymentSuccess(
          'Intent started',
          result,
        ),
      );
    } catch (err) {
      log('Error charging user: $err');

      emit(
        PaymentError('Error charging user: $err'),
      );
    }
  }
}
