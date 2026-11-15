import { router } from '@kit.ArkUI';
import dataPreferences from '@ohos.data.preferences';
import { common } from '@kit.AbilityKit';
import { ThemeColors } from './ThemeColors';
import { AppStrings } from './AppStrings';
import { Task, TaskDto, TaskType, RepeatType } from './TaskModels';
import { TaskScheduler } from './TaskScheduler';

@Entry
@ComponentV2
struct CalendarPage {
  @Local allTasks: Array<Task> = [];
  @Local isMonthMode: boolean = false; // false = Неделя, true = Месяц
  @Local selectedDate: Date = new Date();

  // Смещения относительно текущей даты (0 = текущая неделя/месяц, > 0 = будущее)
  @Local weekOffset: number = 0;
  @Local monthOffset: number = 0;

  private readonly weekDayNames: Array<string> = ['Пн', 'Вт', 'Ср', 'Чт', 'Пт', 'Сб', 'Вс'];
  private readonly monthNames: Array<string> = [
    'Январь', 'Февраль', 'Март', 'Апрель', 'Май', 'Июнь',
    'Июль', 'Август', 'Сентябрь', 'Октябрь', 'Ноябрь', 'Декабрь'
  ];

  private context = getContext(this) as common.UIAbilityContext;

  onPageShow(): void {
    this.loadTasks();
  }

  private loadTasks(): void {
    dataPreferences.getPreferences(this.context, AppStrings.PREFERENCES_NAME)
      .then((preferences: dataPreferences.Preferences) => {
        return preferences.get(AppStrings.PREFS_KEY_TASKS, '');
      })
      .then((value: dataPreferences.ValueType) => {
        const jsonStr: string = value as string;
        if (jsonStr !== '') {
          const loadedRaw = JSON.parse(jsonStr) as Array<TaskDto>;
          this.allTasks = loadedRaw.map((t: TaskDto) => new Task(
            t.id, t.title, t.type, t.repeatType, t.importance, t.startDateStr, t.endDateStr, t.isCompleted
          ));
        }
      });
  }

  // Генерация 7 дней для режима "Неделя"
  private getWeekDays(): Array<Date> {
    const today = new Date();
    const dayOfWeek = today.getDay(); // 0 (Вс) - 6 (Сб)
    const diffToMonday = dayOfWeek === 0 ? -6 : 1 - dayOfWeek;

    const baseMonday = new Date(today.getFullYear(), today.getMonth(), today.getDate() + diffToMonday + this.weekOffset * 7);
    const days: Array<Date> = [];
    for (let i = 0; i < 7; i++) {
      days.push(new Date(baseMonday.getFullYear(), baseMonday.getMonth(), baseMonday.getDate() + i));
    }
    return days;
  }

  // Генерация сетки дней для режима "Месяц" (null = пустая ячейка до 1-го числа)
  private getMonthCells(): Array<Date | null> {
    const today = new Date();
    const targetMonthDate = new Date(today.getFullYear(), today.getMonth() + this.monthOffset, 1);
    const year = targetMonthDate.getFullYear();
    const month = targetMonthDate.getMonth();

    const firstDayOfWeek = targetMonthDate.getDay();
    const leadingEmpty = firstDayOfWeek === 0 ? 6 : firstDayOfWeek - 1;
    const daysInMonth = new Date(year, month + 1, 0).getDate();

    const cells: Array<Date | null> = [];
    for (let i = 0; i < leadingEmpty; i++) {
      cells.push(null);
    }
    for (let d = 1; d <= daysInMonth; d++) {
      cells.push(new Date(year, month, d));
    }
    return cells;
  }

  private getHeaderTitle(): string {
    if (this.isMonthMode) {
      const today = new Date();
      const d = new Date(today.getFullYear(), today.getMonth() + this.monthOffset, 1);
      return `${this.monthNames[d.getMonth()]} ${d.getFullYear()}`;
    } else {
      const days = this.getWeekDays();
      const start = days[0];
      const end = days[6];
      const sStr = `${start.getDate().toString().padStart(2, '0')}.${(start.getMonth() + 1).toString().padStart(2, '0')}`;
      const eStr = `${end.getDate().toString().padStart(2, '0')}.${(end.getMonth() + 1).toString().padStart(2, '0')}`;
      return `${sStr} — ${eStr}`;
    }
  }

  private isSameDay(d1: Date, d2: Date): boolean {
    return d1.getFullYear() === d2.getFullYear() &&
      d1.getMonth() === d2.getMonth() &&
      d1.getDate() === d2.getDate();
  }

  private isPastDay(d: Date): boolean {
    const today = new Date();
    const todayMidnight = new Date(today.getFullYear(), today.getMonth(), today.getDate());
    const dMidnight = new Date(d.getFullYear(), d.getMonth(), d.getDate());
    return dMidnight.getTime() < todayMidnight.getTime();
  }

  private hasTasksOnDay(d: Date): boolean {
    return this.allTasks.some((t: Task) => TaskScheduler.isTaskScheduledForDate(t, d));
  }

  private getTasksForSelectedDay(): Array<Task> {
    return this.allTasks.filter((t: Task) => TaskScheduler.isTaskScheduledForDate(t, this.selectedDate));
  }

  private getTimeInfoText(task: Task): string {
    switch (task.type) {
      case TaskType.SIMPLE:
        return `${AppStrings.TYPE_SIMPLE} • Весь день`;
      case TaskType.LESSON:
        const sTime = task.startDateStr.split(' ')[1] ?? '';
        const eTime = task.endDateStr.split(' ')[1] ?? '';
        return `${AppStrings.TYPE_LESSON} • ${sTime} – ${eTime}`;
      case TaskType.TIME_BOUND:
        return `${AppStrings.TYPE_TIME_BOUND} • ${task.startDateStr} — ${task.endDateStr}`;
      case TaskType.DEADLINE:
        return `${AppStrings.TYPE_DEADLINE} • До ${task.endDateStr}`;
      default:
        return AppStrings.TYPE_UNKNOWN;
    }
  }

  build() {
    Column() {
      // Верхняя панель с кнопкой возврата
      Row() {
        Button(`← ${AppStrings.BTN_BACK}`, { type: ButtonType.Normal })
          .backgroundColor('#Transparent')
          .fontColor(ThemeColors.PRIMARY)
          .onClick(() => {
            router.back();
          })

        Text(AppStrings.CALENDAR_TITLE)
          .fontSize(20)
          .fontWeight(FontWeight.Bold)
          .fontColor(ThemeColors.TEXT_MAIN)
          .layoutWeight(1)
          .textAlign(TextAlign.Center)
          .margin({ right: 65 })
      }
      .width('100%')
      .margin({ bottom: 12 })

      // Переключатель режима: Неделя / Месяц
      Row({ space: 8 }) {
        Button(AppStrings.MODE_WEEK, { type: ButtonType.Capsule })
          .layoutWeight(1)
          .height(36)
          .backgroundColor(!this.isMonthMode ? ThemeColors.PRIMARY : ThemeColors.BACKGROUND_CARD)
          .fontColor(!this.isMonthMode ? '#FFFFFF' : ThemeColors.TEXT_MAIN)
          .onClick(() => {
            this.isMonthMode = false;
          })

        Button(AppStrings.MODE_MONTH, { type: ButtonType.Capsule })
          .layoutWeight(1)
          .height(36)
          .backgroundColor(this.isMonthMode ? ThemeColors.PRIMARY : ThemeColors.BACKGROUND_CARD)
          .fontColor(this.isMonthMode ? '#FFFFFF' : ThemeColors.TEXT_MAIN)
          .onClick(() => {
            this.isMonthMode = true;
          })
      }
      .width('100%')
      .margin({ bottom: 12 })

      // Карточка календаря
      Column() {
        // Навигация периодов (кнопка "Назад" заблокирована на текущем периоде)
        Row() {
          Button('<', { type: ButtonType.Circle })
            .width(34)
            .height(34)
            .backgroundColor(ThemeColors.BACKGROUND_HEADER)
            .fontColor(ThemeColors.TEXT_MAIN)
            .enabled(this.isMonthMode ? this.monthOffset > 0 : this.weekOffset > 0)
            .opacity((this.isMonthMode ? this.monthOffset > 0 : this.weekOffset > 0) ? 1.0 : 0.3)
            .onClick(() => {
              if (this.isMonthMode && this.monthOffset > 0) {
                this.monthOffset -= 1;
              } else if (!this.isMonthMode && this.weekOffset > 0) {
                this.weekOffset -= 1;
              }
            })

          Text(this.getHeaderTitle())
            .fontSize(16)
            .fontWeight(FontWeight.Bold)
            .fontColor(ThemeColors.TEXT_MAIN)
            .layoutWeight(1)
            .textAlign(TextAlign.Center)

          Button('>', { type: ButtonType.Circle })
            .width(34)
            .height(34)
            .backgroundColor(ThemeColors.BACKGROUND_HEADER)
            .fontColor(ThemeColors.TEXT_MAIN)
            .onClick(() => {
              if (this.isMonthMode) {
                this.monthOffset += 1;
              } else {
                this.weekOffset += 1;
              }
            })
        }
        .width('100%')
        .margin({ bottom: 12 })

        // Заголовки дней недели (Пн - Вс)
        Row() {
          ForEach(this.weekDayNames, (dayName: string) => {
            Text(dayName)
              .fontSize(12)
              .fontColor(ThemeColors.TEXT_MUTED)
              .textAlign(TextAlign.Center)
              .layoutWeight(1)
          }, (dayName: string): string => dayName)
        }
        .width('100%')
        .margin({ bottom: 8 })

        // Сетка чисел (Неделя или Месяц)
        if (!this.isMonthMode) {
          Row() {
            ForEach(this.getWeekDays(), (dayDate: Date) => {
              this.DayCell(dayDate)
            }, (dayDate: Date): string => TaskScheduler.formatDate(dayDate))
          }
          .width('100%')
        } else {
          Grid() {
            ForEach(this.getMonthCells(), (cellDate: Date | null, idx: number) => {
              GridItem() {
                if (cellDate !== null) {
                  this.DayCell(cellDate)
                } else {
                  Column().height(42)
                }
              }
            }, (cellDate: Date | null, idx: number): string => cellDate ? TaskScheduler.formatDate(cellDate) : `empty_${idx}`)
          }
          .columnsTemplate('1fr 1fr 1fr 1fr 1fr 1fr 1fr')
          .rowsGap(6)
          .height(260)
        }
      }
      .width('100%')
      .padding(14)
      .backgroundColor(ThemeColors.BACKGROUND_CARD)
      .borderRadius(16)
      .margin({ bottom: 14 })

      // Заголовок выбранного дня
      Row() {
        Text(`План на ${TaskScheduler.formatDate(this.selectedDate)}`)
          .fontSize(16)
          .fontWeight(FontWeight.Bold)
          .fontColor(ThemeColors.TEXT_MAIN)
      }
      .width('100%')
      .margin({ bottom: 8 })

      // Список задач выбранного дня
      if (this.getTasksForSelectedDay().length === 0) {
        Column() {
          Text(AppStrings.CALENDAR_EMPTY_DAY)
            .fontSize(14)
            .fontColor(ThemeColors.TEXT_LIGHT)
        }
        .width('100%')
        .layoutWeight(1)
        .justifyContent(FlexAlign.Center)
      } else {
        List({ space: 10 }) {
          ForEach(this.getTasksForSelectedDay(), (task: Task) => {
            ListItem() {
              Row() {
                Column() {
                  Text(task.title)
                    .fontSize(15)
                    .fontWeight(FontWeight.Medium)
                    .fontColor(ThemeColors.TEXT_MAIN)
                  Text(this.getTimeInfoText(task))
                    .fontSize(12)
                    .fontColor(ThemeColors.TEXT_MUTED)
                    .margin({ top: 4 })
                }
                .alignItems(HorizontalAlign.Start)
                .layoutWeight(1)
                Text(`+${task.expPoints} XP`)
                .fontSize(13)
                  .fontWeight(FontWeight.Bold)
                  .fontColor(ThemeColors.XP_BONUS)
              }
              .width('100%')
              .padding(14)
              .backgroundColor(ThemeColors.BACKGROUND_CARD)
              .borderRadius(12)
            }
          }, (task: Task): string => task.id)
        }
        .width('100%')
        .layoutWeight(1)
      }
    }
    .width('100%')
    .height('100%')
    .padding(16)
    .backgroundColor(ThemeColors.BACKGROUND_MAIN)
  }
  @Builder
  DayCell(dayDate: Date) {
    Column() {
      Text(`${dayDate.getDate()}`)
      .fontSize(14)
        .fontWeight(this.isSameDay(dayDate, this.selectedDate) ? FontWeight.Bold : FontWeight.Normal)
        .fontColor(
          this.isSameDay(dayDate, this.selectedDate)
            ? '#FFFFFF'
            : (this.isPastDay(dayDate) ? ThemeColors.TEXT_LIGHT : ThemeColors.TEXT_MAIN)
        )
      // Синяя точка, если на этот день есть запланированные задачи
      Circle({ width: 5, height: 5 })
        .fill(
          this.hasTasksOnDay(dayDate)
            ? (this.isSameDay(dayDate, this.selectedDate) ? '#FFFFFF' : ThemeColors.PRIMARY)
            : '#Transparent'
        )
        .margin({ top: 2 })
    }
    .width(38)
    .height(42)
    .layoutWeight(this.isMonthMode ? 0 : 1)
    .justifyContent(FlexAlign.Center)
    .backgroundColor(this.isSameDay(dayDate, this.selectedDate) ? ThemeColors.PRIMARY : '#Transparent')
    .borderRadius(10)
    .onClick(() => {
      // Разрешаем выбирать только сегодняшний день и будущее
      if (!this.isPastDay(dayDate)) {
        this.selectedDate = dayDate;
      }
    })
  }
}
