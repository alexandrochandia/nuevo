
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/dating/vmf_dating_controller.dart';

class VmfMatchesList extends StatelessWidget {
  final VmfDatingController controller = Get.find<VmfDatingController>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          'Matches',
          style: TextStyle(color: Colors.white),
        ),
        iconTheme: IconThemeData(color: Colors.white),
      ),
      body: Obx(() {
        if (controller.matchedUsers.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.favorite_border,
                  size: 100,
                  color: Colors.grey,
                ),
                SizedBox(height: 20),
                Text(
                  'No tienes matches aún',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                  ),
                ),
                SizedBox(height: 10),
                Text(
                  'Sigue deslizando para encontrar a alguien especial',
                  style: TextStyle(
                    color: Colors.grey,
                    fontSize: 14,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          );
        }

        return ListView.builder(
          padding: EdgeInsets.all(16),
          itemCount: controller.matchedUsers.length,
          itemBuilder: (context, index) {
            final user = controller.matchedUsers[index];
            return Container(
              margin: EdgeInsets.only(bottom: 16),
              padding: EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.grey[900],
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: Colors.deepPurple.withOpacity(0.3),
                ),
              ),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 30,
                    backgroundImage: NetworkImage(
                      user.profilePicture ?? 'https://via.placeholder.com/100',
                    ),
                  ),
                  SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text(
                              user.name ?? 'Usuario',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            if (user.isVerified == true) ...[
                              SizedBox(width: 8),
                              Icon(
                                Icons.verified,
                                color: Colors.blue,
                                size: 20,
                              ),
                            ],
                          ],
                        ),
                        SizedBox(height: 4),
                        Text(
                          user.bio ?? 'Sin descripción',
                          style: TextStyle(
                            color: Colors.grey,
                            fontSize: 14,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    onPressed: () {
                      // Navegar al chat
                      Get.snackbar(
                        'Chat',
                        'Abriendo chat con ${user.name}',
                        backgroundColor: Colors.deepPurple,
                        colorText: Colors.white,
                      );
                    },
                    icon: Icon(
                      Icons.chat_bubble,
                      color: Colors.deepPurple,
                    ),
                  ),
                ],
              ),
            );
          },
        );
      }),
    );
  }
}
