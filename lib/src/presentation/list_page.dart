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

  @override
  void initState() {
    super.initState();
    context.read<PhotoBloc>().add(LoadPhotos(page: page));

    _scrollController.addListener(() {
      if (_scrollController.position.pixels ==
          _scrollController.position.maxScrollExtent &&
          !(context.read<PhotoBloc>().isLoadingMore)) {
        page++;
        context.read<PhotoBloc>().add(LoadPhotos(page: page));
      }
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
            // Toggle between GridView and ListView based on isGridView
            return isGridView
                ? GridView.builder(
              controller: _scrollController,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
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
    );
  }
}