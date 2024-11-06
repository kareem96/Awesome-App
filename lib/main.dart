import 'dart:developer';
import 'package:awesomapp/src/bloc/photo_bloc.dart';
import 'package:awesomapp/src/presentation/detail_page.dart';
import 'package:awesomapp/src/presentation/list_page.dart';
import 'package:awesomapp/src/repositories/repository_impl.dart';
import 'package:awesomapp/src/service/http_service.dart';
import 'package:awesomapp/src/service/interceptor_client.dart';
import 'package:awesomapp/src/service_locator.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:http/http.dart' as http;

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();


void main() {
  final client = InterceptorClient(http.Client(), onRetry: () {
    log('Retrying the failed network request...');
  });
  setup();
  runApp(MyApp(client));
}

class MyApp extends StatelessWidget {
  final http.Client _client;
  MyApp(this._client);

  @override
  Widget build(BuildContext context) {
    final photoRepository = PhotoRepositoryImpl(HttpService(_client));

    return MaterialApp(
      navigatorKey: navigatorKey,
      title: 'Awesome App',
      theme: ThemeData(primarySwatch: Colors.blue),
      routes: {
        '/': (_) => BlocProvider(
          create: (_) => PhotoBloc(photoRepository),
          child: ListPage(),
        ),
        '/details': (_) => DetailPage(),
      },
    );
  }
}
