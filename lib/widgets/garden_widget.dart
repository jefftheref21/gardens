import 'package:flutter/material.dart';
import 'package:garden/models/garden.dart';
import 'package:garden/utils/image_network.dart';

Widget buildGardenCard(Garden garden) {
  return Card(
    elevation: 2.0,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(10),
    ),
    child: Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: <Widget>[
          FutureBuilder<String>(
            future: getImageUrl(garden.imageUrl, "garden"), // Fetch the image URL
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const SizedBox(
                  height: 150.0,
                  child: Center(child: CircularProgressIndicator()),
                );
              } else if (snapshot.hasError) {
                return const SizedBox(
                  height: 150.0,
                  child: Center(child: Text('Error loading image')),
                );
              } else {
                return ClipRRect(
                  borderRadius: BorderRadius.circular(10.0),
                  child: Image.network(
                    snapshot.data!, // Use the fetched image URL
                    height: 100.0,
                    width: 100.0,
                    fit: BoxFit.cover,
                  ),
                );
              }
            },
          ),
          
          const SizedBox(
            height: 14.0
          ),
          Text(
            garden.name,
            style: const TextStyle(
              fontSize: 20.0,
              fontWeight: FontWeight.w700,
              fontFamily: 'Palantino',
            )
          ),
          const SizedBox(
            height: 8.0,
          ),
          Text(
            garden.description,
            style: const TextStyle(
              fontSize: 16.0,
              fontWeight: FontWeight.w400,
              fontFamily: 'Palantino',
            )
          ),
        ]
      )
    )
  );
}

