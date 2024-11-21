import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart' hide CarouselController;
import 'package:instagram_clone/exceptions/custom_exception.dart';
import 'package:instagram_clone/providers/user/user_provider.dart';
import 'package:instagram_clone/screens/feed_screen.dart';
import 'package:instagram_clone/screens/feed_upload_screen.dart';
import 'package:instagram_clone/screens/like_screen.dart';
import 'package:instagram_clone/screens/profile_screen.dart';
import 'package:instagram_clone/screens/search_screen.dart';
import 'package:instagram_clone/widgets/error_dialog_widget.dart';
import 'package:provider/provider.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen>
    with SingleTickerProviderStateMixin {
  late TabController tabController;

  // 현재 화면 상태를 관리하는 변수
  bool showCodeScreen = false;

  // 태그 상태 관리
  String? selectedTag;
  final List<String> tags = ["Python", "C언어", "Flutter", "Dart", "라즈베리파이"];

  @override
  void initState() {
    super.initState();
    tabController = TabController(length: 5, vsync: this);
    _getProfile();
  }

  void bottomNavigationItemOnTab(int index) {
    setState(() {
      tabController.index = index;
      showCodeScreen = false; // 네비게이션 클릭 시 코드 질문 화면 숨김
    });
  }

  @override
  void dispose() {
    tabController.dispose();
    super.dispose();
  }

  Future<void> _getProfile() async {
    try {
      await context.read<UserProvider>().getUserInfo();
    } on CustomException catch (e) {
      errorDialogWidget(context, e);
    }
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async => false,
      child: Scaffold(
        appBar: tabController.index == 0
            ? AppBar(
          backgroundColor: Colors.black,
          automaticallyImplyLeading: false,
          title: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              IconButton(
                icon: Icon(Icons.search, color: Colors.white),
                onPressed: () {
                  showDialog(
                    context: context,
                    builder: (context) => AlertDialog(
                      title: const Text("검색"),
                      content: const Text("검색 기능을 구현하세요."),
                      actions: [
                        TextButton(
                          onPressed: () {
                            Navigator.of(context).pop();
                          },
                          child: const Text("닫기"),
                        ),
                      ],
                    ),
                  );
                },
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  TextButton(
                    onPressed: () {
                      setState(() {
                        showCodeScreen = false;
                        tabController.index = 0;
                      });
                    },
                    child: Text(
                      "코드 공유",
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                  TextButton(
                    onPressed: () {
                      setState(() {
                        showCodeScreen = true;
                      });
                    },
                    child: Text(
                      "코드 질문",
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ],
              ),
            ],
          ),
        )
            : null, // 다른 화면에서는 AppBar를 숨김
        body: Column(
          children: [
            // 태그 UI 추가
            if (tabController.index == 0 && !showCodeScreen)
              Container(
                margin: const EdgeInsets.all(8.0),
                child: Wrap(
                  spacing: 8.0,
                  children: tags.map((tag) {
                    final isSelected = selectedTag == tag;
                    return ChoiceChip(
                      label: Text(tag),
                      selected: isSelected,
                      onSelected: (selected) {
                        setState(() {
                          selectedTag = selected ? tag : null;
                        });
                      },
                      selectedColor: Colors.purple,
                      backgroundColor: Colors.grey[200],
                      labelStyle: TextStyle(
                        color: isSelected ? Colors.white : Colors.black,
                      ),
                    );
                  }).toList(),
                ),
              ),
            // 피드 화면 또는 코드 질문 화면
            Expanded(
              child: showCodeScreen
                  ? const CodeScreen() // 코드 질문 화면
                  : TabBarView(
                controller: tabController,
                physics: const NeverScrollableScrollPhysics(),
                children: [
                  FeedScreen(), // FeedScreen에서만 AppBar 표시
                  SearchScreen(),
                  FeedUploadScreen(
                    onFeedUploaded: () {},
                  ),
                  LikeScreen(),
                  ProfileScreen(
                    uid: context.read<User>().uid,
                  ),
                ],
              ),
            ),
          ],
        ),
        bottomNavigationBar: BottomNavigationBar(
          type: BottomNavigationBarType.fixed,
          currentIndex: tabController.index,
          onTap: bottomNavigationItemOnTab,
          showSelectedLabels: false,
          showUnselectedLabels: false,
          items: [
            BottomNavigationBarItem(
              icon: Icon(Icons.home),
              label: 'feed',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.search),
              label: 'search',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.add_circle),
              label: 'upload',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.favorite),
              label: 'favorite',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.person),
              label: 'profile',
            ),
          ],
        ),
      ),
    );
  }
}

