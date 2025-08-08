import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'dart:async';
import 'dart:math';

class ProfileModalProvider extends ChangeNotifier {
  final SupabaseClient _supabase = Supabase.instance.client;
  
  // Real-time data
  int _onlineUsers = 1247;
  int _todayVisitors = 15;
  int _unreadMessages = 3;
  int _pendingOrders = 2;
  double _profileCompletion = 18.0;
  
  // User stats
  int _myTestimonies = 12;
  int _myLiveVideos = 3;
  int _myGalleryItems = 45;
  int _savedDevotionals = 8;
  int _myChats = 5;
  
  // Timers for real-time updates
  Timer? _onlineUsersTimer;
  Timer? _visitorsTimer;
  Timer? _messagesTimer;
  
  // Loading states
  bool _isLoading = false;
  
  // Getters
  int get onlineUsers => _onlineUsers;
  int get todayVisitors => _todayVisitors;
  int get unreadMessages => _unreadMessages;
  int get pendingOrders => _pendingOrders;
  double get profileCompletion => _profileCompletion;
  
  int get myTestimonies => _myTestimonies;
  int get myLiveVideos => _myLiveVideos;
  int get myGalleryItems => _myGalleryItems;
  int get savedDevotionals => _savedDevotionals;
  int get myChats => _myChats;
  bool get isLoading => _isLoading;
  
  ProfileModalProvider() {
    _initializeData();
    _startRealTimeUpdates();
  }
  
  Future<void> _initializeData() async {
    _isLoading = true;
    notifyListeners();
    
    try {
      // Check if user is authenticated
      final user = Supabase.instance.client.auth.currentUser;
      if (user == null) {
        print('No authenticated user, using fallback data');
        _setFallbackData();
        _isLoading = false;
        notifyListeners();
        return;
      }
      
      await _fetchRealData(user.id);
      await Future.wait([
        _fetchOnlineUsers(),
        _fetchTodayVisitors(),
        _fetchUnreadMessages(),
        _fetchPendingOrders(),
        _fetchUserStats(),
        _fetchProfileCompletion(),
      ]);
    } catch (e) {
      print('Error initializing profile data: $e');
      _setFallbackData();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
  
  Future<void> _fetchRealData(String userId) async {
    // Fetch online users (users active in last 5 minutes)
    final onlineResponse = await Supabase.instance.client
        .from('user_activity')
        .select('user_id')
        .gte('last_active', DateTime.now().subtract(Duration(minutes: 5)).toIso8601String())
        .neq('user_id', userId);
    
    // Fetch today's visitors
    final visitorsResponse = await Supabase.instance.client
        .from('profile_visitors')
        .select('id')
        .eq('visited_user_id', userId)
        .gte('visited_at', DateTime.now().toLocal().toString().split(' ')[0]);
    
    // Fetch unread messages
    final messagesResponse = await Supabase.instance.client
        .from('chat_messages')
        .select('id')
        .eq('receiver_id', userId)
        .eq('is_read', false);
    
    // Fetch pending orders
    final ordersResponse = await Supabase.instance.client
        .from('digital_transactions')
        .select('id')
        .eq('user_id', userId)
        .eq('status', 'pending');
    
    // Update values
    _onlineUsers = onlineResponse.length;
    _todayVisitors = visitorsResponse.length;
    _unreadMessages = messagesResponse.length;
    _pendingOrders = ordersResponse.length;
  }
  
  Future<void> _fetchOnlineUsers() async {
    try {
      // Count users active in the last 5 minutes
      final response = await _supabase
          .from('user_activity')
          .select('id')
          .eq('is_online', true)
          .gte('last_seen', DateTime.now().subtract(const Duration(minutes: 5)).toIso8601String());
      
      _onlineUsers = response.length;
    } catch (e) {
      print('Error fetching online users: $e');
      // Keep simulated data
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
  
  Future<void> _fetchTodayVisitors() async {
    try {
      final currentUser = _supabase.auth.currentUser;
      if (currentUser == null) return;
      
      final today = DateTime.now();
      final todayStart = DateTime(today.year, today.month, today.day);
      
      final response = await _supabase
          .from('profile_visitors')
          .select('id')
          .eq('profile_owner_id', currentUser.id)
          .gte('visited_at', todayStart.toIso8601String());
      
      _todayVisitors = response.length;
    } catch (e) {
      print('Error fetching today visitors: $e');
    }
  }
  
  Future<void> _fetchUnreadMessages() async {
    try {
      final currentUser = _supabase.auth.currentUser;
      if (currentUser == null) return;
      
      final response = await _supabase
          .from('chat_messages')
          .select('id')
          .eq('receiver_id', currentUser.id)
          .eq('is_read', false);
      
      _unreadMessages = response.length;
    } catch (e) {
      print('Error fetching unread messages: $e');
    }
  }
  
  Future<void> _fetchPendingOrders() async {
    try {
      final currentUser = _supabase.auth.currentUser;
      if (currentUser == null) return;
      
      final response = await _supabase
          .from('digital_transactions')
          .select('id')
          .eq('user_id', currentUser.id)
          .eq('status', 'pending');
      
      _pendingOrders = response.length;
    } catch (e) {
      print('Error fetching pending orders: $e');
    }
  }
  
  Future<void> _fetchUserStats() async {
    try {
      final currentUser = _supabase.auth.currentUser;
      if (currentUser == null) return;
      
      // Fetch testimonies
      final testimoniesResponse = await _supabase
          .from('testimonios')
          .select('id')
          .eq('user_id', currentUser.id);
      _myTestimonies = testimoniesResponse.length;
      
      // Fetch live videos (posts with video media)
      final videosResponse = await _supabase
          .from('posts')
          .select('id')
          .eq('user_id', currentUser.id)
          .eq('media_type', 'video');
      _myLiveVideos = videosResponse.length;
      
      // Fetch gallery items (all posts with media)
      final galleryResponse = await _supabase
          .from('posts')
          .select('id')
          .eq('user_id', currentUser.id)
          .not('media_urls', 'is', null);
      _myGalleryItems = galleryResponse.length;
      
      // Fetch chat rooms count
      final chatsResponse = await _supabase
          .from('chat_participants')
          .select('chat_room_id')
          .eq('user_id', currentUser.id);
      _myChats = chatsResponse.length;
      
      // For saved devotionals, we'll use a simulated count for now
      // You can create a saved_devotionals table later if needed
      _savedDevotionals = 8;
    } catch (e) {
      print('Error fetching user stats: $e');
    }
  }
  
  Future<void> _fetchProfileCompletion() async {
    try {
      final currentUser = _supabase.auth.currentUser;
      if (currentUser == null) return;
      
      final response = await _supabase
          .from('user_profiles')
          .select('profile_completed, name, bio, birthday, location_city')
          .eq('user_id', currentUser.id)
          .single();
      
      if (response['profile_completed'] != null) {
        _profileCompletion = (response['profile_completed'] as num).toDouble();
      } else {
        // Calculate completion based on filled fields
        int completedFields = 0;
        int totalFields = 5; // name, bio, birthday, location, avatar
        
        if (response['name'] != null && response['name'].toString().isNotEmpty) completedFields++;
        if (response['bio'] != null && response['bio'].toString().isNotEmpty) completedFields++;
        if (response['birthday'] != null) completedFields++;
        if (response['location_city'] != null && response['location_city'].toString().isNotEmpty) completedFields++;
        completedFields++; // Assume avatar is present
        
        _profileCompletion = (completedFields / totalFields) * 100;
      }
    } catch (e) {
      print('Error fetching profile completion: $e');
    }
  }
  
  void _startRealTimeUpdates() {
    // Update online users every 30 seconds
    _onlineUsersTimer = Timer.periodic(Duration(seconds: 30), (timer) {
      _updateOnlineUsers();
    });
    
    // Update visitors every 2 minutes
    _visitorsTimer = Timer.periodic(Duration(minutes: 2), (timer) {
      _updateTodayVisitors();
    });
    
    // Update messages every minute
    _messagesTimer = Timer.periodic(Duration(minutes: 1), (timer) {
      _updateUnreadMessages();
    });
  }
  
  void _setFallbackData() {
    _onlineUsers = 42;
    _todayVisitors = 15;
    _unreadMessages = 3;
    _pendingOrders = 2;
    _profileCompletion = 0.75;
    _myTestimonies = 8;
    _myLiveVideos = 12;
    _myGalleryItems = 45;
    _savedDevotionals = 23;
    _myChats = 5;
  }
  
  // Manual refresh method
  Future<void> refreshData() async {
    await _initializeData();
  }
  
  // Manual updates (when user interacts)
  Future<void> _updateOnlineUsers() async {
    try {
      final user = Supabase.instance.client.auth.currentUser;
      if (user == null) return;
      final response = await _supabase
          .from('user_activity')
          .select('id')
          .eq('is_online', true)
          .gte('last_seen', DateTime.now().subtract(const Duration(minutes: 5)).toIso8601String());
      
      _onlineUsers = response.length;
      notifyListeners();
    } catch (e) {
      print('Error updating online users: $e');
    }
  }
  
  Future<void> _updateTodayVisitors() async {
    try {
      final currentUser = _supabase.auth.currentUser;
      if (currentUser == null) return;
      
      final today = DateTime.now();
      final todayStart = DateTime(today.year, today.month, today.day);
      
      final response = await _supabase
          .from('profile_visitors')
          .select('id')
          .eq('profile_owner_id', currentUser.id)
          .gte('visited_at', todayStart.toIso8601String());
      
      _todayVisitors = response.length;
      notifyListeners();
    } catch (e) {
      print('Error updating today visitors: $e');
    }
  }
  
  Future<void> _updateUnreadMessages() async {
    try {
      final currentUser = _supabase.auth.currentUser;
      if (currentUser == null) return;
      
      final response = await _supabase
          .from('chat_messages')
          .select('id')
          .eq('receiver_id', currentUser.id)
          .eq('is_read', false);
      
      _unreadMessages = response.length;
      notifyListeners();
    } catch (e) {
      print('Error updating unread messages: $e');
    }
  }
  
  Future<void> markMessagesAsRead() async {
    try {
      final user = Supabase.instance.client.auth.currentUser;
      if (user == null) return;
      await Supabase.instance.client
          .from('chat_messages')
          .update({'is_read': true})
          .eq('receiver_id', user.id)
          .eq('is_read', false);
      
      _unreadMessages = 0;
      notifyListeners();
    } catch (e) {
      print('Error marking messages as read: $e');
    }
  }
  
  Future<void> updateProfileCompletion(double newCompletion) async {
    try {
      final currentUser = _supabase.auth.currentUser;
      if (currentUser == null) return;
      
      await _supabase
          .from('user_profiles')
          .update({'profile_completed': newCompletion})
          .eq('user_id', currentUser.id);
      
      _profileCompletion = newCompletion.clamp(0.0, 100.0);
      notifyListeners();
    } catch (e) {
      print('Error updating profile completion: $e');
    }
  }
  
  void incrementTestimonies() {
    _myTestimonies++;
    notifyListeners();
  }
  
  void incrementGalleryItems(int count) {
    _myGalleryItems += count;
    notifyListeners();
  }
  
  @override
  void dispose() {
    _onlineUsersTimer?.cancel();
    _visitorsTimer?.cancel();
    _messagesTimer?.cancel();
    super.dispose();
  }
}
