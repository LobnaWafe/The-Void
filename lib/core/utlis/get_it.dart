
import 'package:get_it/get_it.dart';

import 'package:the_void/features/game/domain/repos/dialog_repo.dart';
import 'package:the_void/features/game/domain/repos/dialog_repo_imp.dart';
import 'package:the_void/features/game/presentation/view_models/cubit/dialogue_cubit.dart';
import 'package:the_void/features/second_stage/presentation/view_model/second_stage_cubit/second_stage_cubit.dart';


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

  getIt.registerFactory<SecondStageCubit>(
  () => SecondStageCubit(),
);
}
