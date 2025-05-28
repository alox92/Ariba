import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';
import 'package:image_picker/image_picker.dart';
import 'package:just_audio/just_audio.dart' as just_audio;
import 'package:audioplayers/audioplayers.dart' as audio_players;
import 'package:path/path.dart' as path;
import 'package:uuid/uuid.dart';
import 'package:file_picker/file_picker.dart';

/// Service pour gérer les opérations liées aux médias (images, audio) pour les cartes
class MediaService {
  final ImagePicker _imagePicker = ImagePicker();
  final _uuid = const Uuid();

  // Lecteur audio avec just_audio (correctement préfixé)
  final just_audio.AudioPlayer _justAudioPlayer = just_audio.AudioPlayer();

  // Lecteur audio avec audioplayers (correctement préfixé)
  final audio_players.AudioPlayer _audioPlayer = audio_players.AudioPlayer();

  // Singleton pattern
  static final MediaService _instance = MediaService._internal();

  factory MediaService() {
    return _instance;
  }

  MediaService._internal();

  /// Sélectionne une image à partir de la galerie
  Future<String?> pickImage() async {
    try {
      final XFile? image = await _imagePicker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 80, // Optimisation de la qualité
      );

      if (image == null) {
        return null;
      }

      // Copier l'image dans notre dossier d'application
      final savedPath = await _saveMedia(File(image.path), 'images');
      return savedPath;
    } catch (e) {
      debugPrint('Error picking image: $e');
      return null;
    }
  }

  /// Prendre une photo avec la caméra
  Future<String?> takePhoto() async {
    try {
      final XFile? photo = await _imagePicker.pickImage(
        source: ImageSource.camera,
        imageQuality: 80,
      );

      if (photo == null) {
        return null;
      }

      // Copier la photo dans notre dossier d'application
      final savedPath = await _saveMedia(File(photo.path), 'images');
      return savedPath;
    } catch (e) {
      debugPrint('Error taking photo: $e');
      return null;
    }
  }

  /// Enregistrer un audio (à compléter avec un plugin d'enregistrement)
  Future<String?> recordAudio() async {
    // À implémenter avec un plugin d'enregistrement audio
    return null;
  }

  /// Sélectionner un fichier audio existant
  Future<String?> pickAudio() async {
    try {
      // Utiliser file_picker pour sélectionner un fichier audio
      final FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.audio,
      );

      if (result == null || result.files.isEmpty) {
        return null;
      }

      // Obtenir le chemin du fichier
      final file = result.files.first;

      // Pour les plateformes web, le path est null et nous devrions utiliser les bytes
      if (kIsWeb) {
        // Implémentation web non incluse pour l'instant
        return null;
      }

      // Pour les plateformes mobiles et desktop
      if (file.path == null) {
        return null;
      }

      // Copier l'audio dans notre dossier d'application
      final savedPath = await _saveMedia(File(file.path!), 'audio');
      return savedPath;
    } catch (e) {
      debugPrint('Error picking audio: $e');
      return null;
    }
  }

  /// Jouer un fichier audio
  Future<void> playAudio(String? audioPath) async {
    if (audioPath == null || audioPath.isEmpty) {
      return;
    }

    try {
      // Essayer d'abord avec just_audio
      await _justAudioPlayer.setFilePath(audioPath);
      await _justAudioPlayer.play();
    } catch (e) {
      debugPrint('Error playing with just_audio: $e');

      try {
        // Fallback à audioplayers si just_audio échoue
        await _audioPlayer.play(audio_players.DeviceFileSource(audioPath));
      } catch (e) {
        debugPrint('Error playing with audioplayers too: $e');
      }
    }
  }

  /// Arrêter la lecture audio en cours
  Future<void> stopAudio() async {
    try {
      await _justAudioPlayer.stop();
    } catch (e) {
      debugPrint('Error stopping just_audio: $e');
    }

    try {
      await _audioPlayer.stop();
    } catch (e) {
      debugPrint('Error stopping audioplayers: $e');
    }
  }

  /// Sauvegarder un fichier média dans le stockage de l'application
  Future<String> saveMedia(File file, String subFolder) async {
    final appDir = await getApplicationDocumentsDirectory();
    final mediaDir = Directory('${appDir.path}/media/$subFolder');

    // Créer le dossier s'il n'existe pas
    if (!await mediaDir.exists()) {
      await mediaDir.create(recursive: true);
    }

    // Générer un nom de fichier unique
    final fileExt = path.extension(file.path);
    final fileName = '${_uuid.v4()}$fileExt';
    final destPath = '${mediaDir.path}/$fileName';

    // Copier le fichier
    await file.copy(destPath);

    return destPath;
  }

  // Garde l'ancienne méthode privée pour la compatibilité
  Future<String> _saveMedia(File file, String subFolder) =>
      saveMedia(file, subFolder);

  /// Supprimer un fichier média
  Future<void> deleteMedia(String? filePath) async {
    if (filePath == null || filePath.isEmpty) {
      return;
    }

    try {
      final file = File(filePath);
      if (await file.exists()) {
        await file.delete();
      }
    } catch (e) {
      debugPrint('Error deleting media: $e');
    }
  }

  /// Traite une image (copie dans le dossier d'app, retourne le chemin)
  Future<String?> processImage(String imagePath) async {
    try {
      final file = File(imagePath);
      if (!await file.exists()) {
        return null;
      }
      return await saveMedia(file, 'images');
    } catch (e) {
      debugPrint('Error processing image: $e');
      return null;
    }
  }

  /// Traite un audio (copie dans le dossier d'app, retourne le chemin)
  Future<String?> processAudio(String audioPath) async {
    try {
      final file = File(audioPath);
      if (!await file.exists()) {
        return null;
      }
      return await saveMedia(file, 'audio');
    } catch (e) {
      debugPrint('Error processing audio: $e');
      return null;
    }
  }

  /// Nettoyer le cache des médias (supprime tous les fichiers dans le dossier media)
  Future<void> clearMediaCache() async {
    try {
      final appDir = await getApplicationDocumentsDirectory();
      final mediaDir = Directory('${appDir.path}/media');

      if (await mediaDir.exists()) {
        await mediaDir.delete(recursive: true);
        debugPrint('Media cache cleared.');
      } else {
        debugPrint('Media cache directory does not exist, nothing to clear.');
      }
    } catch (e) {
      debugPrint('Error clearing media cache: $e');
      // Optionally rethrow or handle more gracefully
    }
  }

  /// Libérer les ressources
  void dispose() {
    _justAudioPlayer.dispose();
    _audioPlayer.dispose();
  }
}
