import '../../../infra/supabase/supabase_client_provider.dart';

class AccountRepositoryImpl {
  Future<void> deleteMyAccount() async {
    final client = SupabaseClientProvider.client;
    await client.functions.invoke('delete-account');
  }
}
