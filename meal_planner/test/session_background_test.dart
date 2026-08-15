import 'package:flutter_test/flutter_test.dart';
import 'package:meal_planner/core/auth/session_background.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  test('timeout is seven days (aligned with refresh token)', () {
    expect(SessionBackground.timeout, const Duration(days: 7));
  });

  test('is not expired when never backgrounded', () async {
    expect(await SessionBackground.isExpiredAfterBackground(), isFalse);
  });

  test('is not expired shortly after backgrounding', () async {
    await SessionBackground.markBackgrounded();
    expect(await SessionBackground.isExpiredAfterBackground(), isFalse);
  });

  test('is expired after the background timeout', () async {
    await SessionBackground.markBackgroundedAt(
      DateTime.now().subtract(
        SessionBackground.timeout + const Duration(minutes: 1),
      ),
    );

    expect(await SessionBackground.isExpiredAfterBackground(), isTrue);
  });

  test('is not expired just under the timeout', () async {
    await SessionBackground.markBackgroundedAt(
      DateTime.now().subtract(
        SessionBackground.timeout - const Duration(minutes: 1),
      ),
    );

    expect(await SessionBackground.isExpiredAfterBackground(), isFalse);
  });

  test('clearMarker removes the background timestamp', () async {
    await SessionBackground.markBackgrounded();
    await SessionBackground.clearMarker();
    expect(await SessionBackground.isExpiredAfterBackground(), isFalse);
  });
}
