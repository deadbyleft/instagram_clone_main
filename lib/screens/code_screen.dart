import 'package:flutter/material.dart';

class CodeScreen extends StatelessWidget {
  const CodeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // 더미 데이터
    final List<Map<String, String>> posts = [
      {
        "title": "Flutter에서 HTTP 요청 처리관련 질문",
        "author": "홍길동",
        "date": "2024-11-18",
        "content": "Flutter에서 Dio를 사용하여 HTTP 요청을 처리하는 방법을 알아봅니다."
      },
      {
        "title": "Dart에서 Future와 async/await 이해하기",
        "author": "김철수",
        "date": "2024-11-17",
        "content": "비동기 프로그래밍의 기본 개념과 Dart에서의 사용법을 다룹니다."
      },
      {
        "title": "상태 관리: Provider vs Riverpod",
        "author": "이영희",
        "date": "2024-11-16",
        "content": "Flutter에서 자주 사용하는 두 상태 관리 패키지를 비교합니다."
      },
      {
        "title": "상태 관리: Provider vs Riverpod",
        "author": "이영희",
        "date": "2024-11-16",
        "content": "Flutter에서 자주 사용하는 두 상태 관리 패키지를 비교합니다."
      },
      {
        "title": "상태 관리: Provider vs Riverpod",
        "author": "이영희",
        "date": "2024-11-16",
        "content": "Flutter에서 자주 사용하는 두 상태 관리 패키지를 비교합니다."
      },
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text("코드 질문/답변 게시판"),
        backgroundColor: Colors.black,
        automaticallyImplyLeading: false, // 뒤로 가기 버튼 제거
      ),
      body: ListView.builder(
        itemCount: posts.length,
        itemBuilder: (context, index) {
          final post = posts[index];
          return Card(
            margin: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
            elevation: 3,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8.0),
            ),
            child: ListTile(
              title: Text(
                post["title"]!,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 4),
                  Text("작성자: ${post["author"]}"),
                  Text("작성일: ${post["date"]}"),
                ],
              ),
              onTap: () {
                // 게시글 상세 화면으로 이동 (추후 구현)
                showDialog(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: Text(post["title"]!),
                    content: Text(post["content"]!),
                    actions: [
                      TextButton(
                        onPressed: () {
                          Navigator.pop(context);
                        },
                        child: const Text("닫기"),
                      ),
                    ],
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}
