import 'package:flutter/material.dart' hide CarouselController;
import 'package:instagram_clone/models/user_model.dart';
import 'package:instagram_clone/providers/search/search_provider.dart';
import 'package:instagram_clone/providers/search/search_state.dart';
import 'package:instagram_clone/utils/debounce.dart';
import 'package:instagram_clone/widgets/avatar_widget.dart';
import 'package:provider/provider.dart';

class ManagerScreen extends StatefulWidget {
  const ManagerScreen({super.key});

  @override
  State<ManagerScreen> createState() => _ManagerScreenState();
}

class _ManagerScreenState extends State<ManagerScreen> {
  final Debounce debounce = Debounce(milliseconds: 500);

  @override
  void initState() {
    super.initState();
    _clearSearchState();
  }

  void _clearSearchState() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<SearchProvider>().clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    List<UserModel> userModelList = context.watch<SearchState>().userModelList;

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            children: [
              TextField(
                decoration: InputDecoration(
                  border: OutlineInputBorder(),
                  labelText: '이름을 입력해주세요',
                ),
                onChanged: (value) {
                  debounce.run(() async {
                    if (value.trim().isNotEmpty) {
                      await context
                          .read<SearchProvider>()
                          .searchUser(keyword: value);
                    } else {
                      _clearSearchState();
                    }
                  });
                },
              ),
              SizedBox(height: 10),
              Expanded(
                child: GestureDetector(
                  onTap: () => FocusScope.of(context).unfocus(),
                  child: ListView.builder(
                    itemCount: userModelList.length,
                    itemBuilder: (context, index) {
                      UserModel userModel = userModelList[index];
                      return Container(
                        padding: const EdgeInsets.symmetric(
                          vertical: 8,
                          horizontal: 5,
                        ),
                        child: Row(
                          children: [
                            AvatarWidget(userModel: userModel),
                            SizedBox(width: 10),
                            Expanded(
                              child: Text(userModel.name),
                            ),
                            // 버튼 4개 추가
                            IconButton(
                              icon: Text('차단'),
                              onPressed: () {
                                // 버튼 a의 기능 구현
                              },
                            ),
                            IconButton(
                              icon: Text('차단해제'),
                              onPressed: () {
                                // 버튼 b의 기능 구현
                              },
                            ),
                            IconButton(
                              icon: Text('권한 부여'),
                              onPressed: () {
                                // 버튼 c의 기능 구현
                              },
                            ),
                            IconButton(
                              icon: Text('권한 해제'),
                              onPressed: () {
                                // 버튼 d의 기능 구현
                              },
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}