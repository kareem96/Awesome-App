import 'package:awesomapp/src/bloc/photo_bloc.dart';
import 'package:awesomapp/src/presentation/detail_page.dart';
import 'package:awesomapp/src/presentation/list_page.dart';
import 'package:awesomapp/src/service/http_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Pexels App',
      theme: ThemeData(primarySwatch: Colors.blue),
      routes: {
        '/': (_) => BlocProvider(
          create: (_) => PhotoBloc(PhotoService()),
          child: ListPage(),
        ),
        '/details': (_) => DetailPage(),
      },
    );
  }
}
