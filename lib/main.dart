import 'package:flutter/material.dart';
import 'dart:io'; //파일 사용을 위해 추가
import 'package:image_picker/image_picker.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

import 'calender_screen.dart';

void main() {
  runApp(const MangaLogApp());
}

class MangaLogApp extends StatelessWidget {
  const MangaLogApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '만화책 기록장',
      theme: ThemeData(
        primarySwatch: Colors.orange,
        scaffoldBackgroundColor: Colors.grey[100],
      ),
      initialRoute: '/',
      routes: {
        '/': (context) => const IntroScreen(),
        '/main': (context) => const MainShelfScreen(),
        '/record': (context) => const RecordPage(),
      },
    );
  }
}

// 1. 인트로 화면
class IntroScreen extends StatelessWidget {
  const IntroScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.auto_stories, size: 100, color: Colors.orange),
            const SizedBox(height: 20),
            const Text("나만의 만화 서재", style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
            const SizedBox(height: 40),
            ElevatedButton(
              onPressed: () => Navigator.pushReplacementNamed(context, '/main'),
              child: const Text("입장하기"),
            ),
          ],
        ),
      ),
    );
  }
}

// 2. 메인 화면 (상태 변화가 필요하므로 StatefulWidget 사용)
class MainShelfScreen extends StatefulWidget {
  const MainShelfScreen({super.key});

  @override
  State<MainShelfScreen> createState() => _MainShelfScreenState();
}

class _MainShelfScreenState extends State<MainShelfScreen> {
  int _gridCount = 3;
  String _sortType = '최신순';

  // 임시 데이터 리스트 (초기 데이터에는 imagePath가 없으므로 null로 시작)
  List<Map<String, dynamic>> books = [
    {'title': '슬램덩크', 'date': DateTime(2024, 1, 1), 'isPurchased': true, 'imagePath': null},
    {'title': '원피스', 'date': DateTime(2024, 5, 10), 'isPurchased': false, 'imagePath': null},
    {'title': '나루토', 'date': DateTime(2023, 10, 5), 'isPurchased': true, 'imagePath': null},
  ];

  void _sortBooks() {
    setState(() {
      if (_sortType == '제목순') {
        books.sort((a, b) => a['title'].compareTo(b['title']));
      } else if (_sortType == '최신순') {
        books.sort((a, b) => b['date'].compareTo(a['date']));
      } else if (_sortType == '오래된순') {
        books.sort((a, b) => a['date'].compareTo(b['date']));
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("내 책장"),
        actions: [
          IconButton(
            icon: const Icon(Icons.calendar_month),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => CalendarScreen(books: books),
                ),
              );
            },
          ),
          IconButton(
            icon: Icon(_gridCount == 3 ? Icons.grid_view : Icons.view_module),
            onPressed: () {
              setState(() {
                if(_gridCount < 5) _gridCount++;
                else _gridCount = 2;
              });
            },
          ),
          PopupMenuButton<String>(
            onSelected: (value) {
              _sortType = value;
              _sortBooks();
            },
            itemBuilder: (context) => [
              const PopupMenuItem(value: '제목순', child: Text('제목순')),
              const PopupMenuItem(value: '최신순', child: Text('최신순')),
              const PopupMenuItem(value: '오래된순', child: Text('오래된순')),
            ],
          ),
        ],
      ),
      body: GridView.builder(
        padding: const EdgeInsets.all(12),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: _gridCount,
          childAspectRatio: 0.7,
          crossAxisSpacing: 10,
          mainAxisSpacing: 10,
        ),
        itemCount: books.length,
        itemBuilder: (context, index) {
          final book = books[index];
          return InkWell(
            onTap: () async {
              final updatedBook = await Navigator.pushNamed(
                context,
                '/record',
                arguments: book,
              );

              if (updatedBook != null && updatedBook is Map<String, dynamic>) {
                setState(() {
                  books[index] = updatedBook;
                  _sortBooks();
                });
              }
            },
            borderRadius: BorderRadius.circular(8),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
                boxShadow: [const BoxShadow(color: Colors.black12, blurRadius: 4)],
                border: book['isPurchased'] ? Border.all(color: Colors.orange, width: 2) : null,
              ),
              child: Stack(
                children: [
                  // --- 이미지 표시 부분 수정 ---
                  book['imagePath'] != null
                      ? ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: kIsWeb
                        ? Image.network(
                      book['imagePath'],
                      width: double.infinity,
                      height: double.infinity,
                      fit: BoxFit.cover,
                    )
                        : Image.file(
                      File(book['imagePath']),
                      width: double.infinity,
                      height: double.infinity,
                      fit: BoxFit.cover,
                    ),
                  )
                      : Center(child: Text(book['title'], textAlign: TextAlign.center)),

                  // 이미지가 있을 때 제목을 하단에 살짝 겹쳐서 보여주고 싶다면 추가 (선택 사항)
                  if (book['imagePath'] != null)
                    Positioned(
                      bottom: 0, left: 0, right: 0,
                      child: Container(
                        color: Colors.black54,
                        padding: const EdgeInsets.symmetric(vertical: 2),
                        child: Text(
                          book['title'],
                          style: const TextStyle(color: Colors.white, fontSize: 15),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                  // --------------------------

                  if (book['isPurchased'])
                    const Positioned(
                      top: 5, right: 5,
                      child: Icon(Icons.check_circle, color: Colors.orange, size: 20),
                    ),
                ],
              ),
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          // 새 책 추가 시에도 데이터를 받아올 수 있도록 수정
          final newBook = await Navigator.pushNamed(context, '/record');
          if (newBook != null && newBook is Map<String, dynamic>) {
            setState(() {
              books.add(newBook);
              _sortBooks();
            });
          }
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}

// 3. 기록 페이지
class RecordPage extends StatefulWidget {
  const RecordPage({super.key});

  @override
  State<RecordPage> createState() => _RecordPageState();
}
class _RecordPageState extends State<RecordPage> {
  // 1. 상태 관리 변수 (기존 유지 + 이미지 경로 추가)
  String _title = "";
  DateTime _buyDate = DateTime.now();
  DateTime _readDate = DateTime.now();
  double _rating = 3.0;
  String _selectedGenre = '액션';
  int _totalVolumes = 1;
  int _myVolumes = 1;
  String? _imagePath; // [추가] 선택된 이미지 경로 저장

  final List<String> _genres = ['드라마', '스릴러', '스포츠', '액션', '코믹', '로맨스', '판타지'];
  bool _isInitialized = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_isInitialized) {
      final args = ModalRoute.of(context)!.settings.arguments;
      if (args != null && args is Map<String, dynamic>) {
        setState(() {
          _title = args['title'] ?? "";
          _buyDate = args['date'] ?? DateTime.now();
          _selectedGenre = args['genre'] ?? '액션';
          _rating = args['rating'] ?? 3.0;
          _myVolumes = args['myVolumes'] ?? 1;
          _totalVolumes = args['totalVolumes'] ?? 1;
          _readDate = args['readDate'] ?? DateTime.now();
          _imagePath = args['imagePath']; // [추가] 이미지 경로 불러오기
        });
      }
      _isInitialized = true;
    }
  }

  // [추가] 갤러리에서 이미지를 가져오는 함수
  Future<void> _pickImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);

    if (image != null) {
      setState(() {
        _imagePath = image.path;
      });
    }
  }

  //날짜선택함수
  Future<void> _selectDate(BuildContext context, bool isBuyDate) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: isBuyDate ? _buyDate : _readDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );
    if (picked != null) {
      setState(() {
        if (isBuyDate) _buyDate = picked;
        else _readDate = picked;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(_title.isEmpty ? "만화책 상세 기록" : "$_title 수정하기")),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // --- [추가] 이미지 선택 영역 ---
            Center(
              child: GestureDetector(
                onTap: _pickImage,
                child: Container(
                  width: 140,
                  height: 200,
                  decoration: BoxDecoration(
                    color: Colors.grey[200],
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: Colors.grey[400]!),
                  ),
                  child: _imagePath != null
                      ? ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: kIsWeb
                      ? Image.network(_imagePath!, fit: BoxFit.cover) //[웹용] 가상 주소로 읽기
                        : Image.file(File(_imagePath!), fit:BoxFit.cover), //[앱용] 실제 파일로 읽기
                  )
                      : const Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.add_a_photo, size: 40, color: Colors.grey),
                      SizedBox(height: 8),
                      Text("표지 등록", style: TextStyle(color: Colors.grey)),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),
            // --------------------------

            TextFormField(
              initialValue: _title,
              decoration: const InputDecoration(labelText: "만화책 제목", border: OutlineInputBorder()),
              onChanged: (val) => _title = val,
            ),
            const SizedBox(height: 20),

            Row(
              children: [
                const Text("주제(장르): ", style: TextStyle(fontSize: 16)),
                const SizedBox(width: 20),
                DropdownButton<String>(
                  value: _selectedGenre,
                  items: _genres.map((String value) => DropdownMenuItem(value: value, child: Text(value))).toList(),
                  onChanged: (newValue) => setState(() => _selectedGenre = newValue!),
                ),
              ],
            ),
            const Divider(),

            ListTile(
              title: Text("구매 날짜: ${_buyDate.toString().split(' ')[0]}"),
              trailing: const Icon(Icons.calendar_today),
              onTap: () => _selectDate(context, true),
            ),
            ListTile(
              title: Text("완독 날짜: ${_readDate.toString().split(' ')[0]}"),
              trailing: const Icon(Icons.calendar_today),
              onTap: () => _selectDate(context, false),
            ),
            const Divider(),

            Text("나의 평점: ${_rating.toStringAsFixed(1)} / 5.0", style: const TextStyle(fontSize: 16)),
            Slider(
              value: _rating,
              min: 0, max: 5, divisions: 10,
              label: _rating.toString(),
              onChanged: (val) => setState(() => _rating = val),
            ),
            const Divider(),

            const Text("시리즈 정보 (보유/완독)", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    keyboardType: TextInputType.number,
                    initialValue: _myVolumes.toString(),
                    decoration: const InputDecoration(labelText: "내 보유 권수"),
                    onChanged: (val) => _myVolumes = int.tryParse(val) ?? 1,
                  ),
                ),
                const SizedBox(width: 20),
                const Text("/", style: TextStyle(fontSize: 24)),
                const SizedBox(width: 20),
                Expanded(
                  child: TextFormField(
                    keyboardType: TextInputType.number,
                    initialValue: _totalVolumes.toString(),
                    decoration: const InputDecoration(labelText: "전체 총 권수"),
                    onChanged: (val) => _totalVolumes = int.tryParse(val) ?? 1,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 30),

            ElevatedButton(
              style: ElevatedButton.styleFrom(minimumSize: const Size(double.infinity, 50)),
              onPressed: () {
                final updatedData = {
                  'title': _title,
                  'date': _buyDate,
                  'readDate': _readDate,
                  'genre': _selectedGenre,
                  'rating': _rating,
                  'myVolumes': _myVolumes,
                  'totalVolumes': _totalVolumes,
                  'imagePath': _imagePath, // [추가] 이미지 경로 저장
                  'isPurchased': _myVolumes >= _totalVolumes,
                };
                Navigator.pop(context, updatedData);
              },
              child: const Text("기록 저장하기"),
            ),
          ],
        ),
      ),
    );
  }
}