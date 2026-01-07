import 'package:memorysparks/features/subscription/domain/repositories/subscription_repository.dart';

class RemoveCustomerInfoListenerUseCase {
  final SubscriptionRepository repository;

  RemoveCustomerInfoListenerUseCase(this.repository);

  void call() {
    repository.removeCustomerInfoUpdateListener();
  }
}
