import 'package:flutter_test/flutter_test.dart';
import 'package:lifeflow/main.dart';

void main() {
  test('normalizeSupabaseUrl strips common copy/paste mistakes', () {
    const bare = 'https://abc.supabase.co';
    expect(normalizeSupabaseUrl(bare), bare);
    expect(normalizeSupabaseUrl(' https://abc.supabase.co/rest/v1/ '), bare);
    expect(normalizeSupabaseUrl('https://abc.supabase.co/auth/v1'), bare);
    expect(normalizeSupabaseUrl('"https://abc.supabase.co/"'), bare);
  });
}
