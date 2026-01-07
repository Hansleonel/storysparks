import 'package:memorysparks/features/subscription/domain/entities/customer_info_entity.dart';
import 'package:memorysparks/features/subscription/domain/repositories/subscription_repository.dart';

class SetCustomerInfoListenerUseCase {
  final SubscriptionRepository repository;

  SetCustomerInfoListenerUseCase(this.repository);

  void call(Function(CustomerInfoEntity) onUpdate) {
    repository.setCustomerInfoUpdateListener(onUpdate);
  }
}
