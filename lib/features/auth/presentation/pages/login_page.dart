import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../widgets/login_form.dart';

class LoginPage extends StatelessWidget {
  const LoginPage({super.key});

  @override
  Widget build(BuildContext context) {
    // Don't create new BlocProvider here - use the one from AuthWrapper
    return const LoginView();
  }
}

class LoginView extends StatelessWidget {
  const LoginView({super.key});

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final isSmallScreen = screenSize.width < 600;
    final isVerySmallScreen = screenSize.width < 400;
    
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.background,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: EdgeInsets.all(isSmallScreen ? 16.0 : 24.0),
            child: ConstrainedBox(
              constraints: BoxConstraints(
                maxWidth: isSmallScreen ? double.infinity : 400,
                minHeight: screenSize.height - 
                  (MediaQuery.of(context).padding.top + 
                   MediaQuery.of(context).padding.bottom + 
                   (isSmallScreen ? 32 : 48)),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Logo and Title Section
                  _buildHeader(context, isSmallScreen, isVerySmallScreen),
                  
                  SizedBox(height: isSmallScreen ? 32 : 48),
                  
                  // Login Form
                  const LoginForm(),
                  
                  SizedBox(height: isSmallScreen ? 16 : 24),
                  
                  // Footer
                  _buildFooter(context, isSmallScreen),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, bool isSmallScreen, bool isVerySmallScreen) {
    return Column(
      children: [
        Container(
          width: isVerySmallScreen ? 60 : (isSmallScreen ? 70 : 80),
          height: isVerySmallScreen ? 60 : (isSmallScreen ? 70 : 80),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Theme.of(context).primaryColor,
                Theme.of(context).primaryColor.withOpacity(0.8),
              ],
            ),
            borderRadius: BorderRadius.circular(isSmallScreen ? 16 : 20),
            boxShadow: [
              BoxShadow(
                color: Theme.of(context).primaryColor.withOpacity(0.3),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Icon(
            Icons.admin_panel_settings,
            color: Colors.white,
            size: isVerySmallScreen ? 28 : (isSmallScreen ? 32 : 40),
          ),
        ),
        SizedBox(height: isSmallScreen ? 16 : 24),
        Text(
          'MAPIC Manager',
          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
            fontWeight: FontWeight.bold,
            color: Theme.of(context).primaryColor,
            fontSize: isVerySmallScreen ? 20 : (isSmallScreen ? 24 : 28),
          ),
          textAlign: TextAlign.center,
        ),
        SizedBox(height: isSmallScreen ? 4 : 8),
        Text(
          'Bảng điều khiển quản trị',
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
            color: Colors.grey[600],
            fontSize: isSmallScreen ? 14 : 16,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildFooter(BuildContext context, bool isSmallScreen) {
    return Text(
      'Truy cập an toàn vào hệ thống quản lý MAPIC',
      textAlign: TextAlign.center,
      style: Theme.of(context).textTheme.bodySmall?.copyWith(
        color: Colors.grey[500],
        fontSize: isSmallScreen ? 11 : 12,
      ),
    );
  }
}