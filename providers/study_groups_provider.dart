
import 'package:flutter/material.dart';
import '../models/study_group_model.dart';
import '../services/supabase_service.dart';

class StudyGroupsProvider with ChangeNotifier {
  final SupabaseService _supabaseService = SupabaseService();
  
  List<StudyGroup> _groups = [];
  List<StudyGroup> _myGroups = [];
  List<StudyGroup> _joinedGroups = [];
  bool _isLoading = false;
  String? _error;
  String _selectedCategory = 'all';

  List<StudyGroup> get groups => _groups;
  List<StudyGroup> get myGroups => _myGroups;
  List<StudyGroup> get joinedGroups => _joinedGroups;
  bool get isLoading => _isLoading;
  String? get error => _error;
  String get selectedCategory => _selectedCategory;

  void setSelectedCategory(String category) {
    _selectedCategory = category;
    notifyListeners();
  }

  List<StudyGroup> get filteredGroups {
    if (_selectedCategory == 'all') return _groups;
    return _groups.where((group) => group.category == _selectedCategory).toList();
  }

  Future<void> loadGroups() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final response = await _supabaseService.client
          .from('study_groups')
          .select('''
            *,
            leader_profile:user_profiles!study_groups_leader_id_fkey(
              display_name,
              avatar_url,
              is_verified
            ),
            members_count:study_group_members(count)
          ''')
          .eq('is_active', true)
          .order('created_at', ascending: false);

      _groups = (response as List).map((groupData) {
        return StudyGroup.fromJson({
          ...groupData,
          'leader_name': groupData['leader_profile']['display_name'],
          'leader_avatar': groupData['leader_profile']['avatar_url'],
          'members_count': groupData['members_count']?.length ?? 0,
        });
      }).toList();

      // Load user's groups
      await _loadUserGroups();
    } catch (e) {
      _error = 'Error loading groups: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> _loadUserGroups() async {
    try {
      final userId = _supabaseService.client.auth.currentUser?.id;
      if (userId == null) return;

      // Load groups where user is leader
      final leaderResponse = await _supabaseService.client
          .from('study_groups')
          .select('*')
          .eq('leader_id', userId)
          .eq('is_active', true);

      _myGroups = (leaderResponse as List)
          .map((data) => StudyGroup.fromJson(data))
          .toList();

      // Load groups where user is member
      final memberResponse = await _supabaseService.client
          .from('study_group_members')
          .select('''
            study_groups!inner(*)
          ''')
          .eq('user_id', userId)
          .eq('is_active', true);

      _joinedGroups = (memberResponse as List)
          .map((data) => StudyGroup.fromJson(data['study_groups']))
          .toList();
    } catch (e) {
      print('Error loading user groups: $e');
    }
  }

  Future<void> createGroup({
    required String name,
    required String description,
    required String category,
    required List<String> tags,
    String? coverImage,
    int maxMembers = 50,
    bool isPrivate = false,
    bool requiresApproval = false,
    DateTime? nextMeeting,
    String? meetingLocation,
    String? meetingLink,
    String? currentStudy,
    int totalLessons = 1,
  }) async {
    try {
      final userId = _supabaseService.client.auth.currentUser?.id;
      if (userId == null) throw Exception('User not authenticated');

      final groupData = {
        'name': name,
        'description': description,
        'category': category,
        'tags': tags,
        'cover_image': coverImage,
        'leader_id': userId,
        'max_members': maxMembers,
        'is_private': isPrivate,
        'requires_approval': requiresApproval,
        'next_meeting': nextMeeting?.toIso8601String(),
        'meeting_location': meetingLocation,
        'meeting_link': meetingLink,
        'current_study': currentStudy,
        'total_lessons': totalLessons,
        'created_at': DateTime.now().toIso8601String(),
      };

      await _supabaseService.client
          .from('study_groups')
          .insert(groupData);

      // Reload groups
      await loadGroups();
    } catch (e) {
      _error = 'Error creating group: $e';
      notifyListeners();
      rethrow;
    }
  }

  Future<void> joinGroup(String groupId) async {
    try {
      final userId = _supabaseService.client.auth.currentUser?.id;
      if (userId == null) throw Exception('User not authenticated');

      await _supabaseService.client
          .from('study_group_members')
          .insert({
            'group_id': groupId,
            'user_id': userId,
            'role': 'member',
            'joined_at': DateTime.now().toIso8601String(),
          });

      // Reload groups
      await loadGroups();
    } catch (e) {
      _error = 'Error joining group: $e';
      notifyListeners();
      rethrow;
    }
  }

  Future<void> leaveGroup(String groupId) async {
    try {
      final userId = _supabaseService.client.auth.currentUser?.id;
      if (userId == null) throw Exception('User not authenticated');

      await _supabaseService.client
          .from('study_group_members')
          .delete()
          .eq('group_id', groupId)
          .eq('user_id', userId);

      // Reload groups
      await loadGroups();
    } catch (e) {
      _error = 'Error leaving group: $e';
      notifyListeners();
      rethrow;
    }
  }

  Future<void> updateGroupProgress(String groupId, int lessonsCompleted) async {
    try {
      await _supabaseService.client
          .from('study_groups')
          .update({
            'lessons_completed': lessonsCompleted,
            'updated_at': DateTime.now().toIso8601String(),
          })
          .eq('id', groupId);

      // Update local state
      final groupIndex = _groups.indexWhere((g) => g.id == groupId);
      if (groupIndex != -1) {
        _groups[groupIndex] = StudyGroup.fromJson({
          ..._groups[groupIndex].toJson(),
          'lessons_completed': lessonsCompleted,
        });
        notifyListeners();
      }
    } catch (e) {
      _error = 'Error updating progress: $e';
      notifyListeners();
    }
  }

  Future<List<StudyGroupMember>> getGroupMembers(String groupId) async {
    try {
      final response = await _supabaseService.client
          .from('study_group_members')
          .select('''
            *,
            user_profiles!study_group_members_user_id_fkey(
              display_name,
              avatar_url,
              is_verified
            )
          ''')
          .eq('group_id', groupId)
          .eq('is_active', true)
          .order('joined_at');

      return (response as List).map((memberData) {
        return StudyGroupMember.fromJson({
          ...memberData,
          'user_name': memberData['user_profiles']['display_name'],
          'user_avatar': memberData['user_profiles']['avatar_url'],
          'is_verified': memberData['user_profiles']['is_verified'],
        });
      }).toList();
    } catch (e) {
      throw Exception('Error loading members: $e');
    }
  }

  Future<void> scheduleNextMeeting(String groupId, DateTime meetingDate, {
    String? location,
    String? meetingLink,
    String? agenda,
  }) async {
    try {
      await _supabaseService.client
          .from('study_groups')
          .update({
            'next_meeting': meetingDate.toIso8601String(),
            'meeting_location': location,
            'meeting_link': meetingLink,
            'updated_at': DateTime.now().toIso8601String(),
          })
          .eq('id', groupId);

      // Create meeting record
      if (agenda != null) {
        await _supabaseService.client
            .from('group_meetings')
            .insert({
              'group_id': groupId,
              'scheduled_date': meetingDate.toIso8601String(),
              'location': location,
              'meeting_link': meetingLink,
              'agenda': agenda,
              'created_at': DateTime.now().toIso8601String(),
            });
      }

      await loadGroups();
    } catch (e) {
      _error = 'Error scheduling meeting: $e';
      notifyListeners();
    }
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }
}
