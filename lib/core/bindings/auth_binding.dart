import 'package:get/get.dart';
import '../../data/repositories/auth_repository_impl.dart';
import '../../data/repositories/user_repository_impl.dart';
import '../../domain/repositories/auth_repository.dart';
import '../../domain/repositories/user_repository.dart';
import '../../domain/usecases/login_user.dart';
import '../../domain/usecases/register_user.dart';
import '../../domain/usecases/logout_user.dart';
import '../../presentation/controllers/auth_controller.dart';

class AuthBinding extends Bindings {
  @override
  void dependencies() {
    // Repositories 
    Get.put<AuthRepository>(AuthRepositoryImpl());
    Get.put<UserRepository>(UserRepositoryImpl());
    
    // Use Cases
    Get.put<LoginUser>(LoginUser(Get.find<AuthRepository>()));
    Get.put<RegisterUser>(RegisterUser(Get.find<AuthRepository>(), Get.find<UserRepository>()));
    Get.put<LogoutUser>(LogoutUser(Get.find<AuthRepository>()));
    
    // Controller 
    Get.put<AuthController>(
      AuthController(
        loginUser: Get.find<LoginUser>(),
        registerUser: Get.find<RegisterUser>(),
        logoutUser: Get.find<LogoutUser>(),
      ),
    );
  }
}