import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:path/path.dart' as path;
import 'package:flutter/foundation.dart';

const String SUPABASE_STORAGE_BUCKET = 'atelier-manager';

class ImageService {
  final SupabaseClient _supabase = Supabase.instance.client;
  final ImagePicker _picker = ImagePicker();

  Future<File?> pickImageFromGallery() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      return File(pickedFile.path);
    }
    return null;
  }

  Future<String?> uploadImageToSupabaseStorage(File imageFile) async {
    if (SUPABASE_STORAGE_BUCKET.isEmpty) {
      print('Nome do bucket Supabase Storage não configurado para upload.');
      if (kDebugMode) {
        print('DEBUG: Verifique se SUPABASE_STORAGE_BUCKET está definido via --dart-define.');
      }
      return null;
    }

    final String fileName = '${DateTime.now().millisecondsSinceEpoch}${path.extension(imageFile.path)}';
    final String filePathInStorage = fileName;

    try {
      await _supabase.storage
          .from(SUPABASE_STORAGE_BUCKET)
          .upload(filePathInStorage, imageFile,
          fileOptions: const FileOptions(
              cacheControl: '3600',
              upsert: false
          ));

      final publicUrl = _supabase.storage
          .from(SUPABASE_STORAGE_BUCKET)
          .getPublicUrl(filePathInStorage);

      print('Upload para Supabase Storage bem-sucedido. Path: $filePathInStorage, URL: $publicUrl');
      return publicUrl;

    } catch (e) {
      print('Erro ao fazer upload para Supabase Storage: $e');
      if (kDebugMode) {
        print('DEBUG UPLOAD EXCEPTION: $e');
      }
      return null;
    }
  }


  Future<bool> deleteImageFromSupabaseStorage(String filePathInStorage) async {
    if (SUPABASE_STORAGE_BUCKET.isEmpty || filePathInStorage.isEmpty) {
      print('Nome do bucket ou path do arquivo para exclusão não configurados.');
      if (kDebugMode) {
        print('DEBUG DELETE: Bucket ou path vazio.');
      }
      return false;
    }

    try {
      final List<FileObject> response = await _supabase.storage
          .from(SUPABASE_STORAGE_BUCKET)
          .remove([filePathInStorage]);

      if (response.isEmpty) {
        print('Arquivo $filePathInStorage deletado do Supabase Storage com sucesso (ou não encontrado).');
      } else {
        print('Resposta de exclusão não vazia para $filePathInStorage. Resultado: $response');
      }

      return true;

    } catch (e) {
      print('Erro na requisição de exclusão para Supabase Storage para path $filePathInStorage: $e');
      if (kDebugMode) {
        print('DEBUG DELETE EXCEPTION: $e');
      }
      return false;
    }
  }
}