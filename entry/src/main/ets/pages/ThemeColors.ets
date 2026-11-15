// ThemeColors.ets
export class ThemeColors {
  static readonly PRIMARY: string = '#007DFF';          // Основной синий цвет кнопок и акцентов
  static readonly BACKGROUND_MAIN: string = '#F5F7FA';    // Серый фон всего экрана
  static readonly BACKGROUND_CARD: string = '#FFFFFF';    // Белый фон карточки задачи
  static readonly BACKGROUND_CARD_DONE: string = '#F8F9FA';// Фон выполненной задачи
  static readonly BACKGROUND_HEADER: string = '#F1F3F5';  // Фон верхнего виджета рейтинга

  static readonly TEXT_MAIN: string = '#000000';         // Основной черный текст
  static readonly TEXT_MUTED: string = '#666666';        // Серый текст для подзаголовков
  static readonly TEXT_LIGHT: string = '#999999';        // Светло-серый текст (выполненные задачи)

  static readonly PROGRESS_UP: string = '#2E7D32';       // Зеленый цвет для хорошей мотивации
  static readonly PROGRESS_DOWN: string = '#D32F2F';     // Красный цвет для отставания
  static readonly XP_BONUS: string = '#66BB6A';          // Цвет начисления очков
}