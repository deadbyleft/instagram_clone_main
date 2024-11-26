import 'package:extended_image/extended_image.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart' hide CarouselController;
import 'package:instagram_clone/exceptions/custom_exception.dart';
import 'package:instagram_clone/models/feed_model.dart';
import 'package:instagram_clone/models/user_model.dart';
import 'package:instagram_clone/providers/auth/auth_provider.dart';
import 'package:instagram_clone/providers/profile/profile_provider.dart';
import 'package:instagram_clone/providers/profile/profile_state.dart';
import 'package:instagram_clone/providers/user/user_state.dart';
import 'package:instagram_clone/screens/manager_screen.dart';
import 'package:instagram_clone/screens/profile_feed_screen.dart';
import 'package:instagram_clone/widgets/error_dialog_widget.dart';
import 'package:provider/provider.dart';



class ProfileScreen extends StatefulWidget {
  final String uid;

  const ProfileScreen({
    super.key,
    required this.uid,
  });

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final ScrollController _scrollController = ScrollController();
  late final ProfileProvider profileProvider;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(scrollListener);
    profileProvider = context.read<ProfileProvider>();
    _getProfile();
  }

  @override
  void dispose() {
    _scrollController.removeListener(scrollListener);
    _scrollController.dispose();
    super.dispose();
  }

  void scrollListener() {
    ProfileState profileState = context.read<ProfileState>();

    if (profileState.profileStatus == ProfileStatus.reFetching) {
      return;
    }

    bool hasNext = profileState.hasNext;

    if (_scrollController.offset >=
            _scrollController.position.maxScrollExtent &&
        hasNext) {
      FeedModel lastFeedModel = profileState.feedList.last;
      profileProvider.getProfile(
        uid: widget.uid,
        feedId: lastFeedModel.feedId,
      );
    }
  }

  void _getProfile() {
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      try {
        await profileProvider.getProfile(uid: widget.uid);
      } on CustomException catch (e) {
        errorDialogWidget(context, e);
      }
    });
  }

  Widget _profileInfoWidget({
    required int num,
    required String label,
  }) {
    return Column(
      children: [
        Text(
          num.toString(),
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w400,
            color: Colors.grey,
          ),
        )
      ],
    );
  }

  Widget _customButtonWidget({
    required AsyncCallback asyncCallback,
    required String text,
  }) {
    return TextButton(
      onPressed: () async {
        try {
          await asyncCallback();
        } on CustomException catch (e) {
          errorDialogWidget(context, e);
        }
      },
      child: Text(text),
      style: TextButton.styleFrom(
          foregroundColor: Colors.white,
          side: const BorderSide(color: Colors.grey),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(5),
          )),
    );
  }

  @override
  Widget build(BuildContext context) {
    ProfileState profileState = context.watch<ProfileState>();
    // 프로필을 확인하려는 유저의 정보
    UserModel userModel = profileState.userModel;
    List<FeedModel> feedList = profileState.feedList;

    // 현재 접속중인 유저의 정보
    UserModel currentUserModel = context.read<UserState>().userModel;

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  Column(
                    children: [
                      CircleAvatar(
                        backgroundImage: userModel.profileImage == null
                            ? ExtendedAssetImageProvider(
                                'assets/images/profile.png') as ImageProvider
                            : ExtendedNetworkImageProvider(
                                userModel.profileImage!),
                        radius: 40,
                      ),
                      SizedBox(height: 5),
                      Text(userModel.name),
                    ],
                  ),

                  SizedBox(width: 20), // 사진과 버튼 간 간격 추가
                  Expanded(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        ElevatedButton(
                          onPressed: () async {
                            try {
                              await context.read<AuthProvider>().signOut();
                            } on CustomException catch (e) {
                              errorDialogWidget(context, e);
                            }
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.grey[800],
                          ),
                          child: Text(
                            '로그아웃',
                            style: TextStyle(color: Colors.white),
                          ),
                        ),
                        ElevatedButton(
                          onPressed: () {
                            // Navigate to ManagerScreen when the button is pressed
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => ManagerScreen()),
                            );
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blue,
                          ),
                          child: Text(
                            '관리자 설정',
                            style: TextStyle(color: Colors.white),
                          ),
                        ),
                      ],
                    ),
                  ),



                  // Expanded(
//   child: Row(
//     mainAxisAlignment: MainAxisAlignment.spaceEvenly,
//     children: [
//       _profileInfoWidget(
//           num: userModel.feedCount, label: 'feeds'),
//       _profileInfoWidget(
//           num: userModel.followers.length, label: 'follower'),
//       _profileInfoWidget(
//           num: userModel.following.length, label: 'following'),
//     ],
//   ),
// )
                ],
              ),
              currentUserModel.uid == userModel.uid
                  ? _customButtonWidget(
                      asyncCallback: context.read<AuthProvider>().signOut,
                      text: 'Sign Out',
                    )
                  : _customButtonWidget(
                      asyncCallback: () async {
                        await context.read<ProfileProvider>().followUser(
                              currentUserId: currentUserModel.uid,
                              followId: userModel.uid,
                            );
                      },
                      text: userModel.followers.contains(currentUserModel.uid)
                          ? 'Unfollow'
                          : 'Follow',
                    ),
              Expanded(
                child: GridView.builder(
                  controller: _scrollController,
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 3,
                    mainAxisSpacing: 3,
                  ),
                  itemCount: feedList.length + 1,
                  itemBuilder: (context, index) {
                    if (feedList.length == index)
                      return profileState.hasNext
                          ? Center(
                              child: Padding(
                                padding: const EdgeInsets.only(bottom: 10),
                                child: CircularProgressIndicator(),
                              ),
                            )
                          : Container();

                    return GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                ProfileFeedScreen(index: index),
                          ),
                        );
                      },
                      child: ExtendedImage.network(
                        feedList[index].imageUrls[0],
                        fit: BoxFit.cover,
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
