import os

files = [
    "lib/app/app.dart",
    "lib/app/bootstrap.dart",
    "lib/app/routes/app_router.dart",
    "lib/app/routes/route_names.dart",
    "lib/app/routes/route_guards.dart",

    "lib/core/theme/app_theme.dart",
    "lib/core/theme/app_spacing.dart",
    "lib/core/theme/app_radius.dart",
    "lib/core/theme/app_text_styles.dart",

    "lib/shared/widgets/layout/app_scaffold.dart",
    "lib/shared/widgets/layout/app_page_padding.dart",
    "lib/shared/widgets/buttons/app_primary_button.dart",
    "lib/shared/widgets/buttons/app_secondary_button.dart",
    "lib/shared/widgets/buttons/app_text_button.dart",
    "lib/shared/widgets/inputs/app_text_field.dart",
    "lib/shared/widgets/feedback/app_loader.dart",
    "lib/shared/widgets/feedback/app_empty_state.dart",
    "lib/shared/widgets/feedback/app_error_view.dart",
    "lib/shared/widgets/cards/app_card.dart",

    "lib/infra/supabase/supabase_client_provider.dart",
    "lib/infra/supabase/supabase_tables.dart",

    "lib/features/splash/presentation/screens/splash_screen.dart",
    "lib/features/auth/presentation/screens/login_screen.dart",
    "lib/features/gym_context/presentation/screens/select_gym_screen.dart",
    "lib/features/owner/presentation/screens/owner_home_screen.dart",
    "lib/features/booking/presentation/screens/booking_screen.dart",
    "lib/features/workouts/presentation/screens/workouts_screen.dart",
    "lib/features/profile/presentation/screens/profile_screen.dart",
]

for f in files:
    os.makedirs(os.path.dirname(f), exist_ok=True)
    if not os.path.exists(f):
        with open(f, "w") as file:
            file.write("// TODO: implement\n")

print("✅ Archivos creados correctamente")
