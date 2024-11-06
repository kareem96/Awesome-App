import 'package:flutter/material.dart';
import '../models/photo_model.dart';

class DetailPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final Photo photo = ModalRoute.of(context)!.settings.arguments as Photo;

    return Scaffold(
      appBar: AppBar(title: Text(photo.photographer)),
      body: Column(
        children: [
          Expanded(
            child: Image.network(photo.photoUrl),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Photographer: ${photo.photographer}'),
                const SizedBox(height: 8),
                Text('URL: ${photo.photoUrl}'),
              ],
            ),
          ),
        ],
      ),
    );
  }
}