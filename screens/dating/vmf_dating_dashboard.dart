
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/dating/vmf_dating_controller.dart';
import 'vmf_dating_card.dart';
import 'vmf_matches_list.dart';
import 'vmf_likes_list.dart';

class VmfDatingDashboard extends StatelessWidget {
  final VmfDatingController controller = Get.put(VmfDatingController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(),
            _buildStatsRow(),
            Expanded(
              child: VmfDatingCard(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: EdgeInsets.all(20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            'VMF Connect',
            style: TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          Row(
            children: [
              IconButton(
                onPressed: () => Get.to(() => VmfMatchesList()),
                icon: Icon(
                  Icons.chat_bubble,
                  color: Colors.deepPurple,
                  size: 28,
                ),
              ),
              IconButton(
                onPressed: () => Get.to(() => VmfLikesList()),
                icon: Icon(
                  Icons.favorite,
                  color: Colors.red,
                  size: 28,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatsRow() {
    return Obx(() => Container(
      padding: EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildStatItem(
            'Likes',
            controller.likedUsers.length.toString(),
            Colors.red,
          ),
          _buildStatItem(
            'Matches',
            controller.matchedUsers.length.toString(),
            Colors.green,
          ),
          _buildStatItem(
            'Usuarios',
            controller.users.length.toString(),
            Colors.blue,
          ),
        ],
      ),
    ));
  }

  Widget _buildStatItem(String label, String value, Color color) {
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(
            color: color,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            color: Colors.white.withOpacity(0.7),
            fontSize: 12,
          ),
        ),
      ],
    );
  }
}
