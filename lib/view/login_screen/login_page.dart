import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:pokedex/services/auth_services.dart';
import 'package:pokedex/utils/responsive_helper.dart';

class LoginPage extends StatelessWidget {
  const LoginPage({super.key});

  void _showError(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.all(8),
        duration: const Duration(seconds: 4),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final auth = Provider.of<AuthServices>(context);
    
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: SingleChildScrollView(
          child: Container(
            constraints: BoxConstraints(
              maxWidth: ResponsiveHelper.getMaxContentWidth(context),
            ),
            padding: ResponsiveHelper.getScreenPadding(context),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ConstrainedBox(
                  constraints: BoxConstraints(
                    maxHeight: ResponsiveHelper.isMobile(context) 
                        ? size.height * 0.4 
                        : size.height * 0.5,
                    maxWidth: ResponsiveHelper.isMobile(context) 
                        ? size.width * 0.8 
                        : size.width * 0.6,
                  ),
                  child: Image.asset(
                    'assets/pokemons.png',
                    fit: BoxFit.contain,
                  ),
                ),
                const SizedBox(height: 32),
                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 200),
                  child: auth.isLoading
                      ? const CircularProgressIndicator()
                      : SizedBox(
                          width: ResponsiveHelper.isMobile(context) 
                              ? size.width * 0.8 
                              : 300,
                          child: ElevatedButton.icon(
                            style: ElevatedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 24, 
                                vertical: 12,
                              ),
                              backgroundColor: Colors.grey.shade200,
                              foregroundColor: Colors.black,
                              elevation: 8,
                              side: BorderSide(
                                color: Colors.grey.shade500,
                                width: 1,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                            onPressed: auth.isLoading
                                ? null
                                : () async {
                                    try {
                                      final user = await auth.signInWithGoogle();
                                      if (user == null && context.mounted) {
                                        _showError(
                                          context, 
                                          'Sign in was cancelled',
                                        );
                                      }
                                    } on AuthException catch (e) {
                                      if (context.mounted) {
                                        _showError(context, e.message);
                                      }
                                    } catch (e) {
                                      if (context.mounted) {
                                        _showError(
                                          context,
                                          'An unexpected error occurred',
                                        );
                                      }
                                    }
                                  },
                            icon: const Icon(
                              Icons.g_mobiledata,
                              size: 32,
                            ),
                            label: const Text(
                              "Sign in with Google",
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ),
                ),
                const SizedBox(height: 16),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
