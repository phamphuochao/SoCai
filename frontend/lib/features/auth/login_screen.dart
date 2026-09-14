import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../components/buttons/app_buttons.dart';
import '../../components/inputs/app_inputs.dart';
import '../../components/language/language_menu.dart';
import '../../core/constants/app_assets.dart';
import '../../core/constants/app_strings.dart';
import '../../core/design_system/app_colors.dart';
import '../../core/design_system/app_dimensions.dart';
import '../../core/design_system/app_spacing.dart';
import '../../core/routing/route_paths.dart';
import '../../core/utils/validators.dart';
import '../../l10n/l10n.dart';
import '../../providers/auth_provider.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key, this.returnUrl});

  final String? returnUrl;

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _username = TextEditingController(text: 'admin');
  final _password = TextEditingController(text: 'admin123');

  @override
  void dispose() {
    _username.dispose();
    _password.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    final success = await context.read<AuthProvider>().login(
      _username.text.trim(),
      _password.text,
    );
    if (!mounted || !success) return;
    final target =
        widget.returnUrl != null &&
            widget.returnUrl!.startsWith('/') &&
            widget.returnUrl != RoutePaths.login
        ? widget.returnUrl!
        : RoutePaths.dashboard;
    context.go(target);
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    return Scaffold(
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, viewport) {
            final wide = viewport.maxWidth >= 900;
            final pagePadding = wide ? AppSpacing.xxl : AppSpacing.md;
            final availableHeight = viewport.maxHeight - pagePadding * 2;
            final cardHeight = wide && availableHeight >= 620
                ? availableHeight
                      .clamp(620.0, AppDimensions.loginMaxHeight)
                      .toDouble()
                : null;
            final form = _LoginForm(
              formKey: _formKey,
              username: _username,
              password: _password,
              busy: auth.isBusy,
              error: auth.error,
              onSubmit: _submit,
            );
            final cardContent = wide
                ? Row(
                    children: [
                      Expanded(
                        flex: 10,
                        child: Center(
                          child: SingleChildScrollView(
                            padding: const EdgeInsets.all(AppSpacing.xxl),
                            child: ConstrainedBox(
                              constraints: const BoxConstraints(maxWidth: 460),
                              child: form,
                            ),
                          ),
                        ),
                      ),
                      Expanded(
                        flex: 11,
                        child: DecoratedBox(
                          decoration: const BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: [
                                AppColors.paleBlueLight,
                                AppColors.paleBlue,
                              ],
                            ),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(AppSpacing.xxl),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Flexible(
                                  child: ConstrainedBox(
                                    constraints: const BoxConstraints(
                                      maxHeight: 320,
                                    ),
                                    child: Image.asset(
                                      AppAssets.loginStoreIllustration,
                                      fit: BoxFit.contain,
                                      semanticLabel:
                                          context.l10n.storeIllustration,
                                    ),
                                  ),
                                ),
                                const SizedBox(height: AppSpacing.xl),
                                Text(
                                  context.l10n.loginHeroTitle,
                                  style: Theme.of(
                                    context,
                                  ).textTheme.headlineMedium,
                                ),
                                const SizedBox(height: AppSpacing.sm),
                                Text(
                                  context.l10n.loginHeroSubtitle,
                                  textAlign: TextAlign.center,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  )
                : Padding(
                    padding: const EdgeInsets.all(AppSpacing.xl),
                    child: form,
                  );
            return Center(
              child: SingleChildScrollView(
                padding: EdgeInsets.all(pagePadding),
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    maxWidth: wide ? AppDimensions.loginMaxWidth : 560,
                  ),
                  child: SizedBox(
                    height: cardHeight,
                    child: Card(
                      elevation: 4,
                      shadowColor: Colors.black12,
                      clipBehavior: Clip.antiAlias,
                      child: cardContent,
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

class _LoginForm extends StatelessWidget {
  const _LoginForm({
    required this.formKey,
    required this.username,
    required this.password,
    required this.busy,
    required this.error,
    required this.onSubmit,
  });

  final GlobalKey<FormState> formKey;
  final TextEditingController username;
  final TextEditingController password;
  final bool busy;
  final String? error;
  final VoidCallback onSubmit;

  @override
  Widget build(BuildContext context) => Form(
    key: formKey,
    child: Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            Image.asset(
              AppAssets.logo,
              width: 38,
              height: 38,
              fit: BoxFit.contain,
              semanticLabel: AppStrings.appName,
            ),
            const SizedBox(width: AppSpacing.sm),
            const Text(
              AppStrings.appName,
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.w700),
            ),
            const Spacer(),
            const LanguageMenu(),
          ],
        ),
        const SizedBox(height: AppSpacing.xxl),
        Text(
          context.l10n.welcomeBack,
          style: Theme.of(context).textTheme.headlineMedium,
        ),
        const SizedBox(height: AppSpacing.xs),
        Text(
          context.l10n.loginSubtitle,
          style: Theme.of(context).textTheme.bodySmall,
        ),
        const SizedBox(height: AppSpacing.xl),
        AppTextField(
          controller: username,
          label: context.l10n.username,
          prefixIcon: Icons.person_outline,
          validator: (value) => Validators.required(
            value,
            context.l10n.fieldRequired(context.l10n.username),
          ),
        ),
        const SizedBox(height: AppSpacing.md),
        AppTextField(
          controller: password,
          label: context.l10n.password,
          prefixIcon: Icons.lock_outline,
          obscureText: true,
          validator: (value) => Validators.required(
            value,
            context.l10n.fieldRequired(context.l10n.password),
          ),
          onSubmitted: (_) => onSubmit(),
        ),
        if (error != null) ...[
          const SizedBox(height: AppSpacing.sm),
          Text(
            error!,
            style: TextStyle(color: Theme.of(context).colorScheme.error),
          ),
        ],
        const SizedBox(height: AppSpacing.lg),
        PrimaryButton(
          label: context.l10n.login,
          icon: Icons.login,
          loading: busy,
          expand: true,
          onPressed: onSubmit,
        ),
        const SizedBox(height: AppSpacing.md),
        Text(
          context.l10n.demoAccount,
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.bodySmall,
        ),
      ],
    ),
  );
}
