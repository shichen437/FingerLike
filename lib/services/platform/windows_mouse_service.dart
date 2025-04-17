import 'package:win32/win32.dart';
import 'dart:ffi';
import 'package:ffi/ffi.dart';
import '../../l10n/app_localizations.dart';
import '../mouse_service.dart';
import 'dart:math' as math;

class WindowsMouseService implements MousePlatformInterface {
  final AppLocalizations? _l10n;

  WindowsMouseService(this._l10n);

  @override
  Future<Point> getCurrentPosition() async {
    final point = malloc<POINT>();
    try {
      GetCursorPos(point);
      return Point(point.ref.x.toDouble(), point.ref.y.toDouble());
    } finally {
      malloc.free(point);
    }
  }

  @override
  Future<void> clickAt(Point position) async {
    final input = calloc<INPUT>();
    try {
      SetCursorPos(position.x.toInt(), position.y.toInt());

      input.ref.type = INPUT_MOUSE;
      input.ref.mi.dx = 0;
      input.ref.mi.dy = 0;
      input.ref.mi.mouseData = 0;
      input.ref.mi.dwFlags = MOUSEEVENTF_LEFTDOWN;
      input.ref.mi.time = 0;
      input.ref.mi.dwExtraInfo = 0;
      SendInput(1, input, sizeOf<INPUT>());

      await Future.delayed(
        Duration(milliseconds: 2 + math.Random().nextInt(9)),
      );

      input.ref.mi.dwFlags = MOUSEEVENTF_LEFTUP;
      SendInput(1, input, sizeOf<INPUT>());
    } finally {
      calloc.free(input);
    }
  }
}
