// Configuration des chemins et imports absolus pour l'application

// === CORE ===
export 'package:flashcards_app/core/constants/app_constants.dart';
export 'package:flashcards_app/core/errors/exceptions.dart';
export 'package:flashcards_app/core/errors/failure.dart';

// === DOMAIN ===
// Entities
export 'package:flashcards_app/domain/entities/card.dart';
export 'package:flashcards_app/domain/entities/deck.dart';
export 'package:flashcards_app/domain/entities/deck_stats.dart';

// Repositories
export 'package:flashcards_app/domain/repositories/card_repository.dart';
export 'package:flashcards_app/domain/repositories/deck_repository.dart';

// Use Cases
export 'package:flashcards_app/domain/usecases/card_usecases.dart';
export 'package:flashcards_app/domain/usecases/deck_usecases.dart';
export 'package:flashcards_app/domain/usecases/review_usecases.dart';
export 'package:flashcards_app/domain/usecases/usecase.dart';

// Failures - Using centralized core/errors instead

// === DATA ===
// Database
export 'package:flashcards_app/data/database.dart';

// Models (specific non-conflicting ones)
export 'package:flashcards_app/data/models/daily_aggregated_stats.dart';

// Repositories
export 'package:flashcards_app/data/repositories/card_repository_impl.dart';
export 'package:flashcards_app/data/repositories/deck_repository_impl.dart';

// Mappers
export 'package:flashcards_app/data/mappers/card_mapper.dart';
export 'package:flashcards_app/data/mappers/deck_mapper.dart';

// === SERVICES ===
export 'package:flashcards_app/services/media_service.dart';
export 'package:flashcards_app/services/import_export_service.dart';
export 'package:flashcards_app/services/import_service.dart';
export 'package:flashcards_app/services/performance_service.dart';
export 'package:flashcards_app/services/theme_service.dart';

// === UI ===
// Screens
export 'package:flashcards_app/ui/home_screen.dart';
export 'package:flashcards_app/ui/deck_detail_screen.dart';
export 'package:flashcards_app/ui/edit_card_screen.dart';
export 'package:flashcards_app/ui/review_screen.dart';
export 'package:flashcards_app/ui/stats_screen.dart';
export 'package:flashcards_app/ui/theme_settings_screen.dart';
export 'package:flashcards_app/ui/performance_settings_screen.dart';
export 'package:flashcards_app/ui/study_mode_settings_screen.dart';
export 'package:flashcards_app/ui/study_session_analytics_screen.dart';
export 'package:flashcards_app/ui/onboarding_screen.dart';

// Routes
export 'package:flashcards_app/ui/routes/app_router.dart';

// Theme
export 'package:flashcards_app/ui/theme/app_theme.dart';
export 'package:flashcards_app/ui/theme/design_system.dart';
export 'package:flashcards_app/ui/theme/background_widget.dart';

// Components
export 'package:flashcards_app/ui/components/deck_card.dart';
export 'package:flashcards_app/ui/components/primary_button.dart';
export 'package:flashcards_app/ui/components/input_field.dart';
export 'package:flashcards_app/ui/components/loading_overlay.dart';
export 'package:flashcards_app/ui/components/icon_button_animated.dart';
export 'package:flashcards_app/ui/components/main_layout.dart';
export 'package:flashcards_app/ui/components/card_header.dart';
export 'package:flashcards_app/ui/components/chart_card.dart';

// Widgets
export 'package:flashcards_app/ui/widgets/app_drawer.dart';
export 'package:flashcards_app/ui/widgets/confetti_animation.dart';

// === VIEWMODELS ===
export 'package:flashcards_app/viewmodels/card_viewmodel.dart';
export 'package:flashcards_app/viewmodels/deck_viewmodel.dart';
export 'package:flashcards_app/viewmodels/review_viewmodel.dart';
export 'package:flashcards_app/viewmodels/stats_viewmodel.dart';
