import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:image_picker/image_picker.dart';

class ProfileImageService {
  final ImagePicker _picker = ImagePicker();

  // 1. image_picker Integration: Grabs a local image reference file from gallery
  Future<String?> pickAndConvertImage() async {
    try {
      final XFile? pickedFile = await _picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 400,
        maxHeight: 400,
        imageQuality:
            50, // Compresses the asset to ensure it easily fits within Firestore document sizes
      );
      if (pickedFile == null) return null; // User backed out of selection View

      // Read file binary array directly from XFile (works cross-platform including Web)
      final List<int> imageBytes = await pickedFile.readAsBytes();

      // Guard check: Firestore documents have a 1MB limit.
      // Base64 encoding increases size by ~33%. 750,000 bytes translates to ~1,000,000 characters.
      if (imageBytes.length > 750000) {
        throw Exception(
          "Selected image is too large (exceeds Firestore 1MB document limit). Please choose a smaller image.",
        );
      }

      // Translate raw binary into a clean, portable Base64 text string passport
      String base64String = base64Encode(imageBytes);
      return base64String;
    } catch (e) {
      debugPrint('Image Selection Fault: $e');
      rethrow;
    }
  }
}
