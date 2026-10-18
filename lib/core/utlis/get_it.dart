
import 'package:get_it/get_it.dart';

import 'package:the_void/features/game/domain/repos/dialog_repo.dart';
import 'package:the_void/features/game/domain/repos/dialog_repo_imp.dart';
import 'package:the_void/features/game/presentation/view_models/cubit/dialogue_cubit.dart';


final getIt = GetIt.instance;

void setupServiceLocator() {
  // Repositories
  getIt.registerLazySingleton<DialogueRepo>(
    () => DialogueRepoImpl(),
  );

  // Cubits
  getIt.registerFactory<DialogueCubit>(
    () => DialogueCubit(getIt<DialogueRepo>()),
  );
}
