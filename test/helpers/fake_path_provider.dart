import 'package:mocktail/mocktail.dart';
import 'package:path_provider_platform_interface/path_provider_platform_interface.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

/// Provides a temporary documents directory for unit tests.
class FakePathProviderPlatform extends Fake
    with MockPlatformInterfaceMixin
    implements PathProviderPlatform {
  FakePathProviderPlatform(this.rootPath);

  final String rootPath;

  @override
  Future<String?> getApplicationDocumentsPath() async => rootPath;

  @override
  Future<String?> getTemporaryPath() async => rootPath;

  @override
  Future<String?> getApplicationSupportPath() async => rootPath;

  @override
  Future<String?> getLibraryPath() async => rootPath;

  @override
  Future<String?> getApplicationCachePath() async => rootPath;

  @override
  Future<String?> getExternalStoragePath() async => rootPath;

  @override
  Future<List<String>?> getExternalCachePaths() async => <String>[rootPath];

  @override
  Future<List<String>?> getExternalStoragePaths({
    StorageDirectory? type,
  }) async =>
      <String>[rootPath];

  @override
  Future<String?> getDownloadsPath() async => rootPath;
}

void configureFakePathProvider(String rootPath) {
  PathProviderPlatform.instance = FakePathProviderPlatform(rootPath);
}
