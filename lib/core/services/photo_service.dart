import 'dart:io';

import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:projeto_final_m02/core/errors/app_failure.dart';
import 'package:projeto_final_m02/core/result/result.dart';

enum PhotoSource { camera, gallery }

abstract interface class PhotoService {
  Future<Result<String?>> takePhoto(PhotoSource source);

  Future<void> deletePhoto(String path);
}

class ImagePickerPhotoService implements PhotoService {
  static const _maxBytes = 5 * 1024 * 1024;
  static const _allowedExtensions = {'.jpg', '.jpeg', '.png', '.webp'};

  final ImagePicker _picker;

  ImagePickerPhotoService([ImagePicker? picker])
    : _picker = picker ?? ImagePicker();

  @override
  Future<Result<String?>> takePhoto(PhotoSource source) async {
    try {
      final XFile? image = await _picker.pickImage(
        source: source == PhotoSource.camera
            ? ImageSource.camera
            : ImageSource.gallery,
        maxWidth: 1600,
        maxHeight: 1600,
        imageQuality: 70,
      );
      if (image == null) return const Success(null);

      final String fileExtension = p.extension(image.path).toLowerCase();
      if (!_allowedExtensions.contains(fileExtension)) {
        return const Failure(
          PhotoFailure('Formato não suportado. Use JPG, PNG ou WEBP.'),
        );
      }
      if (await image.length() > _maxBytes) {
        return const Failure(
          PhotoFailure('A foto ultrapassa o limite de 5 MB, escolha outra.'),
        );
      }

      final Directory documents = await getApplicationDocumentsDirectory();
      final Directory photos = Directory(p.join(documents.path, 'photos'));
      await photos.create(recursive: true);

      final String target = p.join(
        photos.path,
        'report_${DateTime.now().millisecondsSinceEpoch}$fileExtension',
      );
      await image.saveTo(target);

      return Success(target);
    } catch (_) {
      return const Failure(PhotoFailure());
    }
  }

  @override
  Future<void> deletePhoto(String path) async {
    try {
      final File file = File(path);
      if (await file.exists()) await file.delete();
    } catch (_) {}
  }
}
