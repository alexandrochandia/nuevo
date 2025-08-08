import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/vmf_post_model.dart';
import '../screens/vmf_create_content_screen.dart';

class VMFConnectController extends GetxController {
  // Observable variables
  final RxList<VMFPostModel> posts = <VMFPostModel>[].obs;
  final RxBool isLoading = false.obs;
  final RxBool isRefreshing = false.obs;
  final RxInt currentIndex = 0.obs;
  
  // Controllers
  final PageController pageController = PageController();
  final ScrollController scrollController = ScrollController();
  
  // Firebase instances
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  
  @override
  void onInit() {
    super.onInit();
    loadPosts();
    setupScrollListener();
  }
  
  @override
  void onClose() {
    pageController.dispose();
    scrollController.dispose();
    super.onClose();
  }
  
  // Cargar posts del feed
  Future<void> loadPosts() async {
    try {
      isLoading.value = true;
      
      final QuerySnapshot snapshot = await _firestore
          .collection('vmf_posts')
          .orderBy('createdAt', descending: true)
          .limit(20)
          .get();
      
      final List<VMFPostModel> loadedPosts = snapshot.docs
          .map((doc) => VMFPostModel.fromFirestore(doc))
          .toList();
      
      posts.assignAll(loadedPosts);
    } catch (e) {
      Get.snackbar(
        'Error',
        'No se pudieron cargar los posts: $e',
        backgroundColor: Colors.red.withOpacity(0.8),
        colorText: Colors.white,
      );
    } finally {
      isLoading.value = false;
    }
  }
  
  // Refrescar feed
  Future<void> refreshPosts() async {
    isRefreshing.value = true;
    await loadPosts();
    isRefreshing.value = false;
  }
  
  // Configurar listener para scroll infinito
  void setupScrollListener() {
    scrollController.addListener(() {
      if (scrollController.position.pixels >= 
          scrollController.position.maxScrollExtent - 200) {
        loadMorePosts();
      }
    });
  }
  
  // Cargar más posts
  Future<void> loadMorePosts() async {
    if (isLoading.value || posts.isEmpty) return;
    
    try {
      final QuerySnapshot snapshot = await _firestore
          .collection('vmf_posts')
          .orderBy('createdAt', descending: true)
          .startAfter([posts.last.createdAt])
          .limit(10)
          .get();
      
      final List<VMFPostModel> morePosts = snapshot.docs
          .map((doc) => VMFPostModel.fromFirestore(doc))
          .toList();
      
      posts.addAll(morePosts);
    } catch (e) {
      print('Error loading more posts: $e');
    }
  }
  
  // Abrir pantalla de crear contenido
  void openCreateContent() {
    Get.to(() => const VMFCreateContentScreen());
  }
  
  // Dar like a un post
  Future<void> toggleLike(String postId) async {
    try {
      final String userId = _auth.currentUser?.uid ?? '';
      if (userId.isEmpty) return;
      
      final DocumentReference postRef = _firestore.collection('vmf_posts').doc(postId);
      final DocumentReference likeRef = postRef.collection('likes').doc(userId);
      
      final DocumentSnapshot likeDoc = await likeRef.get();
      
      if (likeDoc.exists) {
        // Quitar like
        await likeRef.delete();
        await postRef.update({
          'likesCount': FieldValue.increment(-1),
        });
      } else {
        // Dar like
        await likeRef.set({
          'userId': userId,
          'createdAt': FieldValue.serverTimestamp(),
        });
        await postRef.update({
          'likesCount': FieldValue.increment(1),
        });
      }
      
      // Actualizar post local
      final int postIndex = posts.indexWhere((post) => post.id == postId);
      if (postIndex != -1) {
        final VMFPostModel post = posts[postIndex];
        posts[postIndex] = post.copyWith(
          likesCount: likeDoc.exists ? post.likesCount - 1 : post.likesCount + 1,
          isLiked: !likeDoc.exists,
        );
      }
    } catch (e) {
      Get.snackbar(
        'Error',
        'No se pudo procesar el like: $e',
        backgroundColor: Colors.red.withOpacity(0.8),
        colorText: Colors.white,
      );
    }
  }
  
  // Compartir post
  void sharePost(VMFPostModel post) {
    // Implementar funcionalidad de compartir
    Get.snackbar(
      'Compartir',
      'Compartiendo: ${post.description}',
      backgroundColor: const Color(0xFFD4AF37).withOpacity(0.8),
      colorText: Colors.white,
    );
  }
  
  // Abrir comentarios
  void openComments(VMFPostModel post) {
    // Implementar modal de comentarios
    Get.bottomSheet(
      Container(
        height: Get.height * 0.7,
        decoration: const BoxDecoration(
          color: Colors.black87,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          children: [
            Container(
              width: 40,
              height: 4,
              margin: const EdgeInsets.symmetric(vertical: 10),
              decoration: BoxDecoration(
                color: Colors.grey,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Text(
                'Comentarios (${post.commentsCount})',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const Expanded(
              child: Center(
                child: Text(
                  'Comentarios próximamente...',
                  style: TextStyle(color: Colors.grey),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
