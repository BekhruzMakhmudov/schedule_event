import 'package:get_it/get_it.dart';

import 'features/events/data/repositories/event_repository_impl.dart';
import 'features/events/domain/repositories/event_repository.dart';
import 'features/events/domain/usecases/usecases.dart';
import 'features/events/presentation/bloc/bloc.dart';

final getIt = GetIt.instance;

Future<void> setupServiceLocator() async {
  // Repositories
  getIt.registerLazySingleton<EventRepository>(() => EventRepositoryImpl());

  // Use cases
  getIt.registerLazySingleton<GetEvents>(() => GetEvents(getIt()));
  getIt.registerLazySingleton<AddEvent>(() => AddEvent(getIt()));
  getIt.registerLazySingleton<UpdateEvent>(() => UpdateEvent(getIt()));
  getIt.registerLazySingleton<DeleteEvent>(() => DeleteEvent(getIt()));

  // Blocs
  getIt.registerFactory<EventBloc>(() => EventBloc(
        getEvents: getIt(),
        addEvent: getIt(),
        updateEvent: getIt(),
        deleteEvent: getIt(),
      ));
}
