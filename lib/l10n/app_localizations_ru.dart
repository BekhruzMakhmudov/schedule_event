// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Russian (`ru`).
class AppLocalizationsRu extends AppLocalizations {
  AppLocalizationsRu([String locale = 'ru']) : super(locale);

  @override
  String get appTitle => 'Планировщик событий';

  @override
  String get calendar => 'Календарь';

  @override
  String get eventDetails => 'Детали события';

  @override
  String get addEvent => 'Добавить';

  @override
  String get editEvent => 'Изменить';

  @override
  String get deleteEvent => 'Удалить';

  @override
  String get location => 'Местоположение';

  @override
  String get notification => 'Уведомление';

  @override
  String get save => 'Сохранить';

  @override
  String get cancel => 'Отмена';

  @override
  String get reminder => 'Напоминание';

  @override
  String get selectedLocation => 'Выбранное место';

  @override
  String get currentLocation => 'Текущее местоположение';

  @override
  String get tapToSelectLocation => 'Нажмите, чтобы выбрать место';

  @override
  String locationNotFound(Object query) {
    return 'Местоположение \'$query\' не найдено';
  }

  @override
  String get locationServicesDisabled => 'Службы геолокации отключены';

  @override
  String get openSettings => 'Открыть настройки';

  @override
  String get locationPermissionPermanentlyDenied => 'Доступ к геолокации навсегда запрещён';

  @override
  String get locationPermissionRequired => 'Требуется разрешение на геолокацию';

  @override
  String get selectLocation => 'Выберите место';

  @override
  String get eventReminders => 'Напоминания о событиях';

  @override
  String get notificationsForUpcomingEvents => 'Уведомления о предстоящих событиях';

  @override
  String eventStartsIn(Object description, Object reminder) {
    return 'Событие начнётся через $reminder $description';
  }

  @override
  String get confirm => 'Подтвердить';

  @override
  String get searchLocationHint => 'Поиск местоположения...';

  @override
  String get description => 'Описание';

  @override
  String get noDescription => 'Описание отсутствует';

  @override
  String get deleteEventConfirm => 'Вы уверены, что хотите удалить это событие?';

  @override
  String get eventName => 'Название события';

  @override
  String get enterEventName => 'Введите название события';

  @override
  String get eventDescription => 'Описание события';

  @override
  String get enterEventDescription => 'Введите описание события';

  @override
  String get eventLocation => 'Место проведения';

  @override
  String get enterLocation => 'Введите место проведения';

  @override
  String get priorityColor => 'Цвет приоритета';

  @override
  String get eventTime => 'Время события';

  @override
  String get endTimeAfterStart => 'Время окончания должно быть после времени начала';

  @override
  String get markAllRead => 'Отметить всех';

  @override
  String get markRead => 'Отметить';

  @override
  String get noNotifications => 'Нет уведомлений';

  @override
  String get noEventsForDay => 'Нет событий на этот день';

  @override
  String get minutes => 'минут';

  @override
  String get hour => 'час';

  @override
  String get hours => 'часа';

  @override
  String get day => 'день';

  @override
  String reminderBefore(Object count, Object unit) {
    return '$count $unit до начала';
  }

  @override
  String get schedule => 'Расписание';
}
