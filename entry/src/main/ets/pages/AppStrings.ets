// AppStrings.ets
export class AppStrings {
  // Основные заголовки и кнопки
  static readonly RATING_HEADER: string = 'Твой рейтинг на этой неделе';
  static readonly TODAY_TASKS_PREFIX: string = 'Задачи на сегодня';
  static readonly BTN_COMPLETE_SELECTED: string = 'Завершить выбранные задачи';

  // Ключи и имена для базы данных Preferences
  static readonly PREFERENCES_NAME: string = 'TaskAppPreferences';
  static readonly PREFS_KEY_TASKS: string = 'user_tasks_list';

  // Диалоговое окно подтверждения
  static readonly DIALOG_TITLE: string = 'Подтверждение';
  static readonly DIALOG_MESSAGE: string = 'Вы точно уверены, что хотите завершить выбранные задачи и получить опыт?';
  static readonly DIALOG_YES: string = 'Да';
  static readonly DIALOG_NO: string = 'Нет';

  // Локализация типов задач (TaskType)
  static readonly TYPE_SIMPLE: string = 'Простая задача';
  static readonly TYPE_LESSON: string = 'Урок / Пара';
  static readonly TYPE_TIME_BOUND: string = 'Задача на время';
  static readonly TYPE_DEADLINE: string = 'Дедлайн';
  static readonly TYPE_UNKNOWN: string = 'Задача';

  // Локализация типов повторения (RepeatType)
  static readonly REPEAT_ONCE: string = 'Однократно';
  static readonly REPEAT_WEEKLY: string = 'Раз в неделю';
  static readonly REPEAT_BIWEEKLY: string = 'Раз в 2 недели';
  static readonly REPEAT_MONTHLY: string = 'Раз в месяц';
  static readonly REPEAT_YEARLY: string = 'Раз в год';

  // Строки мотивации рейтинга
  static readonly MOTIVATION_EXCELLENT: string = '🚀 Твоя статистика на этой неделе великолепна! Ты обгоняешь прошлую неделю и свой средний результат!';
  static readonly MOTIVATION_GOOD: string = '📈 Хороший темп! Ты продуктивнее, чем на прошлой неделе.';
  static readonly MOTIVATION_TRY_HARDER: string = '📉 Поднажми! Прошлая неделя была более продуктивной. Ты можешь лучше!';

  // Строки для страницы добавления задачи
  static readonly ADD_PAGE_TITLE: string = 'Новая задача';
  static readonly INPUT_TITLE_PLACEHOLDER: string = 'Название задачи (например, Лекция)';
  static readonly LABEL_TASK_TYPE: string = 'Тип задачи';
  static readonly LABEL_REPEAT_TYPE: string = 'Повторение';
  static readonly LABEL_IMPORTANCE: string = 'Важность';
  static readonly BTN_SAVE_TASK: string = 'Сохранить задачу';
  static readonly BTN_CANCEL: string = 'Отмена';

  // Заглушка пустого списка и выбор дат/времени
  static readonly EMPTY_TASKS_MESSAGE: string = 'На сегодня активных задач нет.\nНажмите «+», чтобы запланировать дела!';
  static readonly LABEL_CHOOSE_DATE: string = 'Дата';
  static readonly LABEL_CHOOSE_START_DATE: string = 'Дата начала';
  static readonly LABEL_CHOOSE_END_DATE: string = 'Дата окончания';
  static readonly LABEL_CHOOSE_DEADLINE: string = 'Сдать до';
  static readonly LABEL_START_TIME: string = 'Время начала';
  static readonly LABEL_END_TIME: string = 'Время окончания';

  // Строки для страницы Календаря
  static readonly CALENDAR_TITLE: string = 'Расписание и планы';
  static readonly MODE_WEEK: string = 'Неделя';
  static readonly MODE_MONTH: string = 'Месяц';
  static readonly BTN_BACK: string = 'Назад';
  static readonly CALENDAR_EMPTY_DAY: string = 'На этот день ничего не запланировано';
}