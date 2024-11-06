import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/photo_bloc.dart';
import '../bloc/photo_event.dart';
import '../bloc/photo_state.dart';
import '../widget/photo_item.dart';

class ListPage extends StatefulWidget {
  @override
  _ListPageState createState() => _ListPageState();
}

class _ListPageState extends State<ListPage> {
  bool isGridView = true;
  int page = 1;
  final ScrollController _scrollController = ScrollController();
  late Connectivity _connectivity;
  late Stream<ConnectivityResult> _connectivityStream;

  @override
  void initState() {
    super.initState();
    // Initial load of photos
    BlocProvider.of<PhotoBloc>(context).add(LoadPhotos(page: page));

    _scrollController.addListener(() {
      if (_scrollController.position.pixels ==
              _scrollController.position.maxScrollExtent &&
          !(context.read<PhotoBloc>().isLoadingMore)) {
        page++;
        context.read<PhotoBloc>().add(LoadPhotos(page: page));
      }
    });

    // Initialize connectivity and listen to changes
    _connectivity = Connectivity();
    _connectivityStream = _connectivity.onConnectivityChanged;

    // Listen for connectivity changes and try to reload data if connected
    _connectivityStream.listen((ConnectivityResult result) {
      if (result != ConnectivityResult.none) {
        // If connected, trigger a data reload
        BlocProvider.of<PhotoBloc>(context).add(LoadPhotos(page: page));
      }
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _onRefresh() async {
    setState(() {
      page = 1;
    });
    BlocProvider.of<PhotoBloc>(context).add(LoadPhotos(page: page));
  }

  // Show confirmation dialog before going back
  Future<bool> _onWillPop() async {
    bool? exit = await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Exit App'),
          content: const Text('Are you sure you want to exit the app?'),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop(false);
              },
            ),
            TextButton(
              child: const Text('Exit'),
              onPressed: () {
                Navigator.of(context).pop(true);
              },
            ),
          ],
        );
      },
    );

    return exit ?? false;
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: _onWillPop, // Intercept back button
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Awesome App'),
          actions: [
            IconButton(
              icon: Icon(isGridView ? Icons.list : Icons.grid_on),
              onPressed: () {
                setState(() {
                  isGridView = !isGridView;
                });
              },
            ),
          ],
        ),
        body: BlocBuilder<PhotoBloc, PhotoState>(
          builder: (context, state) {
            if (state is PhotoLoading && page == 1) {
              return const Center(child: CircularProgressIndicator());
            } else if (state is PhotoLoaded) {
              // Wrap the list/grid view with a RefreshIndicator
              return RefreshIndicator(
                onRefresh: _onRefresh,
                child: isGridView
                    ? GridView.builder(
                        controller: _scrollController,
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          childAspectRatio: 0.75,
                        ),
                        itemCount: state.photos.length,
                        itemBuilder: (context, index) {
                          return PhotoItem(photo: state.photos[index]);
                        },
                      )
                    : ListView.builder(
                        controller: _scrollController,
                        itemCount: state.photos.length,
                        itemBuilder: (context, index) {
                          return PhotoItem(photo: state.photos[index]);
                        },
                      ),
              );
            } else if (state is PhotoError) {
              return Center(child: Text('Error: ${state.message}'));
            }
            return Container();
          },
        ),
        bottomNavigationBar: BlocBuilder<PhotoBloc, PhotoState>(
          builder: (context, state) {
            if (state is PhotoLoading && page > 1) {
              return const Padding(
                padding: EdgeInsets.all(8.0),
                child: Center(child: CircularProgressIndicator()),
              );
            }
            return const SizedBox.shrink();
          },
        ),
      ),
    );
  }
}
