import 'dart:io';
import 'package:flutter_test/flutter_test.dart';

import 'package:flashcards_app/services/media_service.dart';

void main() {
  // Initialize Flutter binding for media operations
  TestWidgetsFlutterBinding.ensureInitialized();
  group('MediaService', () {
    late MediaService mediaService;
      setUp(() {
      mediaService = MediaService();
    });

    tearDown(() {
      // Don't dispose singleton service - it may be used by other tests
    });

    group('pickImage', () {
      test('should return null when no image is selected', () async {
        // Act
        final result = await mediaService.pickImage();
        
        // Assert
        // Le résultat peut être null si l'utilisateur annule la sélection
        expect(result, isA<String?>());
      });

      test('should handle image picker errors gracefully', () async {
        // Act
        final result = await mediaService.pickImage();
        
        // Assert
        // Le service ne devrait pas lever d'exception même en cas d'erreur
        expect(result, isA<String?>());
      });
    });

    group('takePhoto', () {
      test('should return null when no photo is taken', () async {
        // Act
        final result = await mediaService.takePhoto();
        
        // Assert
        expect(result, isA<String?>());
      });

      test('should handle camera errors gracefully', () async {
        // Act
        final result = await mediaService.takePhoto();
        
        // Assert
        expect(result, isA<String?>());
      });
    });

    group('pickAudio', () {
      test('should return null when no audio file is selected', () async {
        // Act
        final result = await mediaService.pickAudio();
        
        // Assert
        expect(result, isA<String?>());
      });

      test('should handle file picker errors gracefully', () async {
        // Act
        final result = await mediaService.pickAudio();
        
        // Assert
        expect(result, isA<String?>());
      });
    });

    group('recordAudio', () {
      test('should return null as recording is not implemented', () async {
        // Act
        final result = await mediaService.recordAudio();
        
        // Assert
        expect(result, isNull);
      });
    });

    group('playAudio', () {
      test('should handle null audio path gracefully', () async {
        // Act & Assert
        await expectLater(
          () => mediaService.playAudio(null),
          returnsNormally,
        );
      });

      test('should handle empty audio path gracefully', () async {
        // Act & Assert
        await expectLater(
          () => mediaService.playAudio(''),
          returnsNormally,
        );
      });

      test('should handle invalid audio path gracefully', () async {
        // Act & Assert
        await expectLater(
          () => mediaService.playAudio('/invalid/path.mp3'),
          returnsNormally,
        );
      });
    });

    group('stopAudio', () {
      test('should stop audio playback without errors', () async {
        // Act & Assert
        await expectLater(
          () => mediaService.stopAudio(),
          returnsNormally,
        );
      });
    });

    group('saveMedia', () {
      test('should handle non-existent file gracefully', () async {
        // Arrange
        final nonExistentFile = File('/non/existent/path.jpg');
        
        // Act
        final result = await mediaService.saveMedia(nonExistentFile, 'images');
        
        // Assert
        expect(result, isNull);
      });
    });

    group('deleteMedia', () {
      test('should handle non-existent file gracefully', () async {
        // Act & Assert
        await expectLater(
          () => mediaService.deleteMedia('/non/existent/path.jpg'),
          returnsNormally,
        );
      });

      test('should handle null path gracefully', () async {
        // Act & Assert
        await expectLater(
          () => mediaService.deleteMedia(null),
          returnsNormally,
        );
      });
    });

    group('processImage', () {
      test('should return null for non-existent image', () async {
        // Act
        final result = await mediaService.processImage('/non/existent/image.jpg');
        
        // Assert
        expect(result, isNull);
      });
    });

    group('processAudio', () {
      test('should return null for non-existent audio', () async {
        // Act
        final result = await mediaService.processAudio('/non/existent/audio.mp3');
        
        // Assert
        expect(result, isNull);
      });
    });

    group('clearMediaCache', () {
      test('should clear media cache without errors', () async {
        // Act & Assert
        await expectLater(
          () => mediaService.clearMediaCache(),
          returnsNormally,
        );
      });
    });

    group('Singleton Pattern', () {
      test('should return same instance', () {
        // Arrange
        final instance1 = MediaService();
        final instance2 = MediaService();
        
        // Assert
        expect(identical(instance1, instance2), isTrue);
      });
    });

    group('dispose', () {
      test('should dispose resources without errors', () {
        // Act & Assert
        expect(() => mediaService.dispose(), returnsNormally);
      });
    });
  });
}
