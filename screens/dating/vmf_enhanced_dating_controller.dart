import 'package:get/get.dart';
import 'package:flutter_card_swiper/flutter_card_swiper.dart';
import '../../models/user_model.dart';
import '../../services/supabase_service.dart';

class VMFEnhancedDatingController extends GetxController {
  static VMFEnhancedDatingController get to => Get.find();
  

  final CardSwiperController cardController = CardSwiperController();

  // Observable properties
  final RxList<UserModel> _users = <UserModel>[].obs;
  final RxInt _currentIndex = 0.obs;
  final RxBool _isLoading = true.obs;
  final RxList<String> _likedUsers = <String>[].obs;
  final RxList<UserModel> _matchedUsers = <UserModel>[].obs;
  final RxBool _showMatchDialog = false.obs;
  final RxString _currentMatchUserId = ''.obs;

  // Dating preferences
  final RxInt _minAge = 18.obs;
  final RxInt _maxAge = 65.obs;
  final RxDouble _maxDistance = 50.0.obs;
  final RxString _genderPreference = 'both'.obs;
  final RxString _spiritualLevelPreference = 'any'.obs;
  final RxBool _seekingRomance = false.obs;
  final RxBool _seekingFriendship = true.obs;
  final RxBool _seekingFellowship = false.obs;

  // Enhanced features
  final RxBool _showSuperLike = false.obs;
  final RxInt _dailyLikesRemaining = 50.obs;
  final RxInt _superLikesRemaining = 3.obs;
  final RxBool _isBoostActive = false.obs;
  final RxString _selectedFilter = 'all'.obs;

  // Getters
  List<UserModel> get users => _users;
  int get currentIndex => _currentIndex.value;
  bool get isLoading => _isLoading.value;
  List<String> get likedUsers => _likedUsers;
  List<UserModel> get matchedUsers => _matchedUsers;
  bool get showMatchDialog => _showMatchDialog.value;
  String get currentMatchUserId => _currentMatchUserId.value;
  
  int get minAge => _minAge.value;
  int get maxAge => _maxAge.value;
  double get maxDistance => _maxDistance.value;
  String get genderPreference => _genderPreference.value;
  String get spiritualLevelPreference => _spiritualLevelPreference.value;
  bool get seekingRomance => _seekingRomance.value;
  bool get seekingFriendship => _seekingFriendship.value;
  bool get seekingFellowship => _seekingFellowship.value;
  
  bool get showSuperLike => _showSuperLike.value;
  int get dailyLikesRemaining => _dailyLikesRemaining.value;
  int get superLikesRemaining => _superLikesRemaining.value;
  bool get isBoostActive => _isBoostActive.value;
  String get selectedFilter => _selectedFilter.value;

  UserModel? get currentUser => _users.isNotEmpty && _currentIndex.value < _users.length 
      ? _users[_currentIndex.value] 
      : null;

  @override
  void onInit() {
    super.onInit();
    loadUsers();
    loadUserPreferences();
  }

  Future<void> loadUsers() async {
    try {
      _isLoading.value = true;
      final fetchedUsers = await SupabaseService.getUsers();
      _users.value = fetchedUsers.map((userData) => UserModel.fromJson(userData)).toList();
    } catch (e) {
      Get.snackbar('Error', 'Error al cargar usuarios: $e');
    } finally {
      _isLoading.value = false;
    }
  }

  Future<void> loadUserPreferences() async {
    try {
      // Load user preferences from database
      // This would connect to your preferences table
    } catch (e) {
      Get.snackbar('Error', 'Error al cargar preferencias: $e');
    }
  }

  Future<void> swipeRight(UserModel user, {bool isSuperLike = false}) async {
    try {
      if (!isSuperLike && _dailyLikesRemaining.value <= 0) {
        Get.snackbar('Límite alcanzado', 'Has agotado tus likes diarios');
        return;
      }

      if (isSuperLike && _superLikesRemaining.value <= 0) {
        Get.snackbar('Límite alcanzado', 'Has agotado tus super likes');
        return;
      }

      // Create swipe action
      await SupabaseService.createSwipeAction(
        userId: 'current_user_id', // Replace with actual user ID
        targetUserId: user.id,
        action: isSuperLike ? 'super_like' : 'like',
      );

      _likedUsers.add(user.id);
      
      if (!isSuperLike) {
        _dailyLikesRemaining.value--;
      } else {
        _superLikesRemaining.value--;
      }

      // Check for match
      bool isMatch = await SupabaseService.checkMatch('current_user_id', user.id);
      if (isMatch) {
        _matchedUsers.add(user);
        _showMatchDialog.value = true;
        _currentMatchUserId.value = user.id;
      }

      _nextUser();
    } catch (e) {
      Get.snackbar('Error', 'Error al procesar like: $e');
    }
  }

  Future<void> swipeLeft(UserModel user) async {
    try {
      await SupabaseService.createSwipeAction(
        userId: 'current_user_id',
        targetUserId: user.id,
        action: 'pass',
      );
      _nextUser();
    } catch (e) {
      Get.snackbar('Error', 'Error al procesar swipe: $e');
    }
  }

  void superLike(UserModel user) {
    swipeRight(user, isSuperLike: true);
  }

  void _nextUser() {
    if (_currentIndex.value < _users.length - 1) {
      _currentIndex.value++;
    } else {
      loadUsers();
      _currentIndex.value = 0;
    }
  }

  void closeMatchDialog() {
    _showMatchDialog.value = false;
    _currentMatchUserId.value = '';
  }

  void startChat(String userId) {
    closeMatchDialog();
    Get.toNamed('/chat', arguments: {'userId': userId});
  }

  void updatePreferences({
    int? minAge,
    int? maxAge,
    double? maxDistance,
    String? genderPreference,
    String? spiritualLevelPreference,
    bool? seekingRomance,
    bool? seekingFriendship,
    bool? seekingFellowship,
  }) {
    if (minAge != null) _minAge.value = minAge;
    if (maxAge != null) _maxAge.value = maxAge;
    if (maxDistance != null) _maxDistance.value = maxDistance;
    if (genderPreference != null) _genderPreference.value = genderPreference;
    if (spiritualLevelPreference != null) _spiritualLevelPreference.value = spiritualLevelPreference;
    if (seekingRomance != null) _seekingRomance.value = seekingRomance;
    if (seekingFriendship != null) _seekingFriendship.value = seekingFriendship;
    if (seekingFellowship != null) _seekingFellowship.value = seekingFellowship;
    
    // Save preferences and reload users
    savePreferences();
    loadUsers();
  }

  Future<void> savePreferences() async {
    try {
      await SupabaseService.updateUserPreferences({
        'min_age': _minAge.value,
        'max_age': _maxAge.value,
        'max_distance': _maxDistance.value,
        'gender_preference': _genderPreference.value,
        'spiritual_level_preference': _spiritualLevelPreference.value,
        'seeking_romance': _seekingRomance.value,
        'seeking_friendship': _seekingFriendship.value,
        'seeking_fellowship': _seekingFellowship.value,
      });
    } catch (e) {
      Get.snackbar('Error', 'Error al guardar preferencias: $e');
    }
  }

  void activateBoost() async {
    try {
      // Implement boost functionality
      _isBoostActive.value = true;
      Get.snackbar('Boost activado', 'Tu perfil será más visible durante 30 minutos');
      
      // Deactivate boost after 30 minutes
      Future.delayed(const Duration(minutes: 30), () {
        _isBoostActive.value = false;
      });
    } catch (e) {
      Get.snackbar('Error', 'Error al activar boost: $e');
    }
  }

  void changeFilter(String filter) {
    _selectedFilter.value = filter;
    loadUsers();
  }

  void undoLastSwipe() {
    if (_currentIndex.value > 0) {
      _currentIndex.value--;
      // Remove from liked users if it was a like
      if (_likedUsers.isNotEmpty) {
        _likedUsers.removeLast();
      }
    }
  }

  void rewind() {
    undoLastSwipe();
  }

  // Missing methods from the screen
  void openFilters() {
    // TODO: Implement filters modal
    Get.snackbar('Filtros', 'Función de filtros en desarrollo');
  }

  void onSwipe(int previousIndex, CardSwiperDirection direction) {
    if (previousIndex < _users.length) {
      final user = _users[previousIndex];
      if (direction == CardSwiperDirection.right) {
        swipeRight(user);
      } else if (direction == CardSwiperDirection.left) {
        swipeLeft(user);
      }
    }
  }

  void passUser() {
    if (currentUser != null) {
      swipeLeft(currentUser!);
    }
  }

  void superLikeUser() {
    if (currentUser != null) {
      swipeRight(currentUser!, isSuperLike: true);
    }
  }

  void likeUser() {
    if (currentUser != null) {
      swipeRight(currentUser!);
    }
  }

  @override
  void onClose() {
    cardController.dispose();
    super.onClose();
  }
}
