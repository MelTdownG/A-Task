// pages/Index.ets
import { router } from '@kit.ArkUI';
import dataPreferences from '@ohos.data.preferences';
import { common } from '@kit.AbilityKit';
import { ThemeColors } from './ThemeColors';
import { AppStrings } from './AppStrings';
import { Task, TaskDto, TaskType, RepeatType, WeeklyProgress } from './TaskModels';
import { TaskScheduler } from './TaskScheduler';

@Entry
@ComponentV2
struct Index {
  @Local tasks: Array<Task> = [];
  @Local selectedTaskIds: Array<string> = [];
  @Local selectedDate: string = '';
  @Local progress: WeeklyProgress = new WeeklyProgress(0, 40, 50);

  private context = getContext(this) as common.UIAbilityContext;

  aboutToAppear(): void {
    this.selectedDate = TaskScheduler.formatDate(new Date());
  }

  onPageShow(): void {
    this.selectedDate = TaskScheduler.formatDate(new Date());
    this.loadTasksFromDisk();
  }

  private loadTasksFromDisk(): void {
    dataPreferences.getPreferences(this.context, AppStrings.PREFERENCES_NAME)
      .then((preferences: dataPreferences.Preferences) => {
        return preferences.get(AppStrings.PREFS_KEY_TASKS, '');
      })
      .then((value: dataPreferences.ValueType) => {
        const jsonStr: string = value as string;
        if (jsonStr !== '') {
          const loadedRaw = JSON.parse(jsonStr) as Array<TaskDto>;
          this.tasks = loadedRaw.map((t: TaskDto) => new Task(
            t.id, t.title, t.type, t.repeatType, t.importance, t.startDateStr, t.endDateStr, t.isCompleted
          ));
          this.recalculateScore(this.tasks);
        } else {
          this.tasks = [];
          this.recalculateScore([]);
        }
      })
      .catch((err: Error) => {
        console.error('Ошибка при чтении: ' + err.message);
      });
  }

  private saveTasksToDisk(tasksToSave: Array<Task>): void {
    dataPreferences.getPreferences(this.context, AppStrings.PREFERENCES_NAME)
      .then((preferences: dataPreferences.Preferences) => {
        const dtoList: Array<TaskDto> = tasksToSave.map((t: Task) => t.toDto());
        const jsonStr: string = JSON.stringify(dtoList);
        return preferences.put(AppStrings.PREFS_KEY_TASKS, jsonStr)
          .then(() => preferences.flush());
      })
      .catch((err: Error) => {
        console.error('Ошибка при сохранении: ' + err.message);
      });
  }

  private recalculateScore(currentTasks: Array<Task>): void {
    let score = 0;
    currentTasks.forEach((task: Task) => {
      if (task.isCompleted) {
        score += task.expPoints;
      }
    });
    this.progress.currentWeekScore = score;
  }

  // Фильтруем только задачи, активные прямо в текущую минуту
  getFilteredTasks(): Array<Task> {
    const now = new Date();
    return this.tasks.filter((task: Task) => TaskScheduler.isTaskActiveNow(task, now));
  }

  toggleSelectTask(taskId: string): void {
    if (this.selectedTaskIds.includes(taskId)) {
      this.selectedTaskIds = this.selectedTaskIds.filter(id => id !== taskId);
    } else {
      this.selectedTaskIds = [...this.selectedTaskIds, taskId];
    }
  }

  showConfirmDialog(): void {
    AlertDialog.show({
      title: AppStrings.DIALOG_TITLE,
      message: AppStrings.DIALOG_MESSAGE,
      autoCancel: false,
      alignment: DialogAlignment.Bottom,
      offset: { dx: 0, dy: -20 },
      primaryButton: {
        value: AppStrings.DIALOG_NO,
        action: () => {
          this.selectedTaskIds = [];
        }
      },
      secondaryButton: {
        value: AppStrings.DIALOG_YES,
        action: () => {
          this.confirmCompleteTasks();
        }
      }
    });
  }

  private confirmCompleteTasks(): void {
    this.tasks.forEach((task: Task) => {
      if (this.selectedTaskIds.includes(task.id)) {
        task.isCompleted = true;
      }
    });

    this.selectedTaskIds = [];
    this.recalculateScore(this.tasks);
    this.saveTasksToDisk(this.tasks);
  }

  getMotivationMessage(): string {
    let current: number = this.progress.currentWeekScore;
    let last: number = this.progress.lastWeekScore;
    let avg: number = this.progress.averageScore;

    if (current > last && current > avg) {
      return AppStrings.MOTIVATION_EXCELLENT;
    } else if (current >= last) {
      return AppStrings.MOTIVATION_GOOD;
    } else {
      return AppStrings.MOTIVATION_TRY_HARDER;
    }
  }

  build() {
    Column() {
      // 1. БЛОК РЕЙТИНГА
      Column() {
        Text(AppStrings.RATING_HEADER)
          .fontSize(14)
          .fontColor(ThemeColors.TEXT_MUTED)

        Text(`${this.progress.currentWeekScore} XP`)
          .fontSize(36)
          .fontWeight(FontWeight.Bold)
          .fontColor(ThemeColors.PRIMARY)
          .margin({ top: 5, bottom: 10 })

        Text(this.getMotivationMessage())
          .fontSize(14)
          .fontColor(this.progress.currentWeekScore >= this.progress.lastWeekScore ? ThemeColors.PROGRESS_UP : ThemeColors.PROGRESS_DOWN)
          .fontWeight(FontWeight.Medium)
          .textAlign(TextAlign.Center)
          .padding({ left: 16, right: 16 })
      }
      .width('100%')
      .padding(20)
      .backgroundColor(ThemeColors.BACKGROUND_HEADER)
      .borderRadius(16)
      .margin({ bottom: 15 })

      // 2. ЗАГОЛОВОК И КНОПКИ НАВИГАЦИИ (КАЛЕНДАРЬ И ДОБАВЛЕНИЕ)
      Row({ space: 8 }) {
        Text(`${AppStrings.TODAY_TASKS_PREFIX} (${this.selectedDate})`)
          .fontSize(17)
          .fontWeight(FontWeight.Bold)
          .fontColor(ThemeColors.TEXT_MAIN)
          .layoutWeight(1)

        Button('📅', { type: ButtonType.Circle })
          .width(38)
          .height(38)
          .fontSize(18)
          .backgroundColor('#E8F1FF')
          .onClick(() => {
            router.pushUrl({ url: 'pages/CalendarPage' });
          })

        Button('+', { type: ButtonType.Circle })
          .width(38)
          .height(38)
          .fontSize(22)
          .backgroundColor(ThemeColors.PRIMARY)
          .fontColor('#FFFFFF')
          .onClick(() => {
            router.pushUrl({ url: 'pages/AddTaskPage' });
          })
      }
      .width('100%')
      .margin({ bottom: 10, top: 10 })

      // 3. СПИСОК АКТИВНЫХ ЗАДАЧ ИЛИ ЗАГЛУШКА
      if (this.getFilteredTasks().length === 0) {
        Column() {
          Text(AppStrings.EMPTY_TASKS_MESSAGE)
            .fontSize(15)
            .fontColor(ThemeColors.TEXT_LIGHT)
            .textAlign(TextAlign.Center)
            .lineHeight(22)
        }
        .width('100%')
        .layoutWeight(1)
        .justifyContent(FlexAlign.Center)
      } else {
        List({ space: 12 }) {
          ForEach(this.getFilteredTasks(), (task: Task) => {
            ListItem() {
              TaskCardView({
                task: task,
                selectedTaskIds: this.selectedTaskIds,
                onSelect: (id: string) => this.toggleSelectTask(id)
              })
            }
          }, (task: Task): string => task.id)
        }
        .width('100%')
        .layoutWeight(1)
      }

      // 4. КНОПКА ПОДТВЕРЖДЕНИЯ ВЫПОЛНЕНИЯ
      Button(AppStrings.BTN_COMPLETE_SELECTED, { type: ButtonType.Capsule })
        .backgroundColor(ThemeColors.PRIMARY)
        .width('80%')
        .margin({ top: 16, bottom: 16 })
        .opacity(this.selectedTaskIds.length > 0 ? 1.0 : 0.4)
        .enabled(this.selectedTaskIds.length > 0)
        .onClick(() => {
          this.showConfirmDialog();
        })
    }
    .width('100%')
    .height('100%')
    .padding(16)
    .backgroundColor(ThemeColors.BACKGROUND_MAIN)
  }
}

@ComponentV2
struct TaskCardView {
  @Param @Require task: Task;
  @Param @Require selectedTaskIds: Array<string>;
  @Event onSelect: (id: string) => void = () => {};

  private getTaskTypeText(): string {
    switch (this.task.type) {
      case TaskType.SIMPLE:
        return AppStrings.TYPE_SIMPLE;
      case TaskType.LESSON:
        return AppStrings.TYPE_LESSON;
      case TaskType.TIME_BOUND:
        return AppStrings.TYPE_TIME_BOUND;
      case TaskType.DEADLINE:
        return AppStrings.TYPE_DEADLINE;
      default:
        return AppStrings.TYPE_UNKNOWN;
    }
  }

  private getRepeatTypeText(): string {
    switch (this.task.repeatType) {
      case RepeatType.ONCE:
        return AppStrings.REPEAT_ONCE;
      case RepeatType.WEEKLY:
        return AppStrings.REPEAT_WEEKLY;
      case RepeatType.BIWEEKLY:
        return AppStrings.REPEAT_BIWEEKLY;
      case RepeatType.MONTHLY:
        return AppStrings.REPEAT_MONTHLY;
      case RepeatType.YEARLY:
        return AppStrings.REPEAT_YEARLY;
      default:
        return AppStrings.REPEAT_ONCE;
    }
  }

  build() {
    Row() {
      if (this.task.isCompleted) {
        Text('✓')
          .fontSize(18)
          .fontWeight(FontWeight.Bold)
          .fontColor(ThemeColors.PROGRESS_UP)
          .margin({ right: 16, left: 5 })
      } else {
        Circle({ width: 20, height: 20 })
          .fill(this.selectedTaskIds.includes(this.task.id) ? ThemeColors.PRIMARY : '#Transparent')
          .stroke(ThemeColors.PRIMARY)
          .strokeWidth(2)
          .margin({ right: 16 })
          .onClick(() => {
            this.onSelect(this.task.id);
          })
      }

      Column() {
        Text(this.task.title)
          .fontSize(16)
          .fontWeight(FontWeight.Medium)
          .decoration({
            type: this.task.isCompleted ? TextDecorationType.Underline : TextDecorationType.None
          })
          .fontColor(this.task.isCompleted ? ThemeColors.TEXT_LIGHT : ThemeColors.TEXT_MAIN)

        Text(`${this.getTaskTypeText()} (${this.getRepeatTypeText()})`)
          .fontSize(12)
          .fontColor(ThemeColors.TEXT_LIGHT)
          .margin({ top: 4 })
      }
      .alignItems(HorizontalAlign.Start)
      .layoutWeight(1)
      Text(`+${this.task.expPoints} XP`)
      .fontSize(14)
        .fontWeight(FontWeight.Bold)
        .fontColor(ThemeColors.XP_BONUS)
    }
    .width('100%')
    .padding(16)
    .backgroundColor((this.task.isCompleted || this.selectedTaskIds.includes(this.task.id)) ? ThemeColors.BACKGROUND_CARD_DONE : ThemeColors.BACKGROUND_CARD)
    .borderRadius(12)
  }
}