import 'dart:collection';
import 'dart:io';
import 'dart:math' as math;

import 'package:image/image.dart' as img;

/// Builds splash art from [assets/app_icon.png]:
/// keeps the full branded icon, removes only the outer white letterbox.
void main() {
  final source = img.decodePng(File('assets/app_icon.png').readAsBytesSync());
  if (source == null) {
    throw StateError('Could not decode assets/app_icon.png');
  }

  final cutout = _removeOuterWhiteBackground(source);
  final trimmed = _trimTransparent(cutout);

  const canvasSize = 1024;
  const targetLogo = 520;
  final canvas = img.Image(
    width: canvasSize,
    height: canvasSize,
    numChannels: 4,
  );
  img.fill(canvas, color: img.ColorRgba8(0, 0, 0, 0));

  final scale = targetLogo / math.max(trimmed.width, trimmed.height);
  final logoW = math.max(1, (trimmed.width * scale).round());
  final logoH = math.max(1, (trimmed.height * scale).round());
  final logo = img.copyResize(
    trimmed,
    width: logoW,
    height: logoH,
    interpolation: img.Interpolation.cubic,
  );

  img.compositeImage(
    canvas,
    logo,
    dstX: (canvasSize - logoW) ~/ 2,
    dstY: (canvasSize - logoH) ~/ 2,
  );

  Directory('assets/branding').createSync(recursive: true);
  final out = File('assets/branding/splash_icon.png');
  out.writeAsBytesSync(img.encodePng(canvas));

  final corner = canvas.getPixel(0, 0);
  final mid = canvas.getPixel(canvasSize ~/ 2, canvasSize ~/ 2);
  stdout.writeln(
    'Wrote ${out.path} cornerA=${corner.a.toInt()} '
    'midRGB=${mid.r.toInt()},${mid.g.toInt()},${mid.b.toInt()},${mid.a.toInt()} '
    'logo=${logoW}x$logoH',
  );
}

bool _isOuterWhite(int r, int g, int b, int a) {
  if (a < 16) return true;
  final maxC = math.max(r, math.max(g, b));
  final minC = math.min(r, math.min(g, b));
  final sat = maxC == 0 ? 0.0 : (maxC - minC) / maxC;
  final luma = (r + g + b) / (3 * 255);
  // Outer canvas is near-white / light grey, not saturated purple.
  return luma > 0.90 && sat < 0.08;
}

img.Image _removeOuterWhiteBackground(img.Image source) {
  final out = img.Image(
    width: source.width,
    height: source.height,
    numChannels: 4,
  );

  // Copy source first.
  for (var y = 0; y < source.height; y++) {
    for (var x = 0; x < source.width; x++) {
      final p = source.getPixel(x, y);
      out.setPixelRgba(x, y, p.r.toInt(), p.g.toInt(), p.b.toInt(), p.a.toInt());
    }
  }

  // Flood-fill from image edges: only white connected to the border
  // becomes transparent. White logo ink inside the purple icon is kept.
  final visited = List<bool>.filled(source.width * source.height, false);
  final queue = Queue<math.Point<int>>();

  void tryEnqueue(int x, int y) {
    if (x < 0 || y < 0 || x >= source.width || y >= source.height) return;
    final i = y * source.width + x;
    if (visited[i]) return;
    final p = out.getPixel(x, y);
    if (!_isOuterWhite(p.r.toInt(), p.g.toInt(), p.b.toInt(), p.a.toInt())) {
      return;
    }
    visited[i] = true;
    queue.add(math.Point<int>(x, y));
  }

  for (var x = 0; x < source.width; x++) {
    tryEnqueue(x, 0);
    tryEnqueue(x, source.height - 1);
  }
  for (var y = 0; y < source.height; y++) {
    tryEnqueue(0, y);
    tryEnqueue(source.width - 1, y);
  }

  while (queue.isNotEmpty) {
    final pt = queue.removeFirst();
    out.setPixelRgba(pt.x, pt.y, 0, 0, 0, 0);
    tryEnqueue(pt.x + 1, pt.y);
    tryEnqueue(pt.x - 1, pt.y);
    tryEnqueue(pt.x, pt.y + 1);
    tryEnqueue(pt.x, pt.y - 1);
  }

  return out;
}

img.Image _trimTransparent(img.Image src) {
  var minX = src.width;
  var minY = src.height;
  var maxX = 0;
  var maxY = 0;

  for (var y = 0; y < src.height; y++) {
    for (var x = 0; x < src.width; x++) {
      if (src.getPixel(x, y).a.toInt() > 8) {
        minX = math.min(minX, x);
        minY = math.min(minY, y);
        maxX = math.max(maxX, x);
        maxY = math.max(maxY, y);
      }
    }
  }

  if (maxX < minX || maxY < minY) {
    return src;
  }

  const pad = 8;
  minX = math.max(0, minX - pad);
  minY = math.max(0, minY - pad);
  maxX = math.min(src.width - 1, maxX + pad);
  maxY = math.min(src.height - 1, maxY + pad);

  return img.copyCrop(
    src,
    x: minX,
    y: minY,
    width: maxX - minX + 1,
    height: maxY - minY + 1,
  );
}
