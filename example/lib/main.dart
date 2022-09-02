import 'package:example/demo/custom_segment.dart';
import 'package:example/demo/foreground_background.dart';
import 'package:example/demo/page_segment.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Easy Segment Demo',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        appBarTheme: const AppBarTheme(
          elevation: 0,
          foregroundColor: Colors.black,
          backgroundColor: Colors.white,
          centerTitle: true,
          titleTextStyle: TextStyle(
            fontSize: 16,
            color: Colors.black,
          ),
          toolbarHeight: 44,
          systemOverlayStyle: SystemUiOverlayStyle.dark,
        ),
      ),
      home: const HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Easy Segment Demo'),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            _listItem(
                'PageView + EasySegment', (context) => const PageSegment()),
            _listItem('Custom Segment', (context) => const CustomSegment()),
            _listItem('Foreground Indicator',
                (context) => const ForegroundBackground()),
          ],
        ),
      ),
    );
  }

  Widget _listItem(String title, WidgetBuilder builder) {
    return ListTile(
      title: Text(title),
      onTap: () {
        Navigator.push(context, CupertinoPageRoute(builder: (context) {
          return Scaffold(
            appBar: AppBar(title: Text(title)),
            body: builder(context),
          );
        }));
      },
    );
  }
}
