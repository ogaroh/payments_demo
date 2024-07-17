part of 'payment_cubit.dart';

@immutable
sealed class PaymentState {}

final class PaymentInitial extends PaymentState {}

final class PaymentLoading extends PaymentState {}

final class PaymentError extends PaymentState {
  PaymentError(this.message);

  final String message;
}

final class PaymentSuccess extends PaymentState {
  PaymentSuccess(this.message, this.data);

  final String message;
  final dynamic data;
}
