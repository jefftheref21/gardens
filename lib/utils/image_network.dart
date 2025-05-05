import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';

Future<XFile> pickImage() async {
  final ImagePicker picker = ImagePicker();
  final XFile? image = await picker.pickImage(source: ImageSource.gallery);
  return image!;
}

Future<String> uploadImage(XFile imageFile, String _id, String type) async {
  final storageRef = FirebaseStorage.instance.ref();
  
  String imageUrl = "$_id/${DateTime.now().millisecondsSinceEpoch}.jpg";
  final imagesRef = storageRef.child("${type}_uploads/$imageUrl");

  await imagesRef.putFile(File(imageFile.path));
  return imageUrl;
  // String downloadURL = await imagesRef.getDownloadURL();
  // return downloadURL;
}

Future<String> getImageUrl(String imagePath, String type) async {
  final storageRef = FirebaseStorage.instance.ref().child('${type}_uploads/$imagePath');
  return await storageRef.getDownloadURL();
}

Future<String> getCachedImageUrl(Map<String, String> imageCache, String plantID, String imageUrl) async {
  if (imageCache.containsKey(plantID)) {
    // Return the cached URL
    return imageCache[plantID]!;
  } else {
    // Fetch the image URL from Firebase and cache it
    final fetchedUrl = await getImageUrl(imageUrl, "plant");
    imageCache[plantID] = fetchedUrl;
    return fetchedUrl;
  }
}