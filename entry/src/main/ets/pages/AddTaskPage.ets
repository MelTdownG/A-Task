import { router } from '@kit.ArkUI';
import dataPreferences from '@ohos.data.preferences';
import { common } from '@kit.AbilityKit';
import { ThemeColors } from './ThemeColors';
import { AppStrings } from './AppStrings';
import { Task, TaskDto, TaskType, RepeatType } from './TaskModels';

@Entry
@ComponentV2
struct AddTaskPage {
  @Local title: string = '';
  @Local selectedType: TaskType = TaskType.SIMPLE;
  @Local selectedRepeat: RepeatType = RepeatType.ONCE;
  @Local importance: number = 5;

  // Объекты Date для хранения выбранных дат и времени
  @Local startDate: Date = new Date();
  @Local endDate: Date = new Date();
  @Local startTime: Date = new Date();
  @Local endTime: Date = new Date();

  private context = getContext(this) as common.UIAbilityContext;

  aboutToAppear(): void {
    const now = new Date();
    this.startDate = now;
    this.endDate = now;

    // По умолчанию ставим время начала на текущий час, а окончания — на +1 час
    const startT = new Date();
    startT.setMinutes(0);
    this.startTime = startT;

    const endT = new Date();
    endT.setHours(now.getHours() + 1);
    endT.setMinutes(0);
    this.endTime = endT;
  }

  // Форматирование Date в "YYYY-MM-DD"
  private formatDate(d: Date): string {
    const year = d.getFullYear();
    const month = (d.getMonth() + 1).toString().padStart(2, '0');
    const day = d.getDate().toString().padStart(2, '0');
    return `${year}-${month}-${day}`;
  }

  // Форматирование Date в "HH:mm"
  private formatTime(d: Date): string {
    const hours = d.getHours().toString().padStart(2, '0');
    const minutes = d.getMinutes().toString().padStart(2, '0');
    return `${hours}:${minutes}`;
  }

  // Открытие системного барабана выбора даты
  private openDatePicker(isStart: boolean): void {
    DatePickerDialog.show({
      start: new Date('2024-01-01'),
      end: new Date('2035-12-31'),
      selected: isStart ? this.startDate : this.endDate,
      onDateAccept: (value: Date) => {
        if (isStart) {
          this.startDate = value;
          // Если дата окончания оказалась раньше даты начала, подтягиваем её
          if (this.endDate.getTime() < value.getTime()) {
            this.endDate = value;
          }
        } else {
          this.endDate = value;
        }
      }
    });
  }

  // Открытие системного барабана выбора времени (24-часовой формат)
  private openTimePicker(isStart: boolean): void {
    TimePickerDialog.show({
      selected: isStart ? this.startTime : this.endTime,
      useMilitaryTime: true,
      onAccept: (value: TimePickerResult) => {
        const updatedTime = new Date();
        updatedTime.setHours(value.hour ?? 0);
        updatedTime.setMinutes(value.minute ?? 0);
        if (isStart) {
          this.startTime = updatedTime;
        } else {
          this.endTime = updatedTime;
        }
      }
    });
  }

  private saveNewTaskAndReturn(): void {
    if (this.title.trim() === '') {
      return;
    }

    let finalStartStr = '';
    let finalEndStr = '';

    // Формируем итоговые строки дат в зависимости от типа задачи
    switch (this.selectedType) {
      case TaskType.SIMPLE:
        finalStartStr = this.formatDate(this.startDate);
        finalEndStr = finalStartStr;
        break;
      case TaskType.LESSON:
        const lessonDate = this.formatDate(this.startDate);
        finalStartStr = `${lessonDate} ${this.formatTime(this.startTime)}`;
        finalEndStr = `${lessonDate} ${this.formatTime(this.endTime)}`;
        break;
      case TaskType.TIME_BOUND:
        finalStartStr = `${this.formatDate(this.startDate)} ${this.formatTime(this.startTime)}`;
        finalEndStr = `${this.formatDate(this.endDate)} ${this.formatTime(this.endTime)}`;
        break;
      case TaskType.DEADLINE:
        finalStartStr = `${this.formatDate(new Date())} 00:00`;
        finalEndStr = `${this.formatDate(this.endDate)} ${this.formatTime(this.endTime)}`;
        break;
    }

    const newTask = new Task(
      Date.now().toString(),
      this.title.trim(),
      this.selectedType,
      this.selectedRepeat,
      this.importance,
      finalStartStr,
      finalEndStr,
      false
    );

    dataPreferences.getPreferences(this.context, AppStrings.PREFERENCES_NAME)
      .then((preferences: dataPreferences.Preferences) => {
        return preferences.get(AppStrings.PREFS_KEY_TASKS, '').then((value: dataPreferences.ValueType) => {
          const jsonStr: string = value as string;
          let existingTasks: Array<TaskDto> = [];
          if (jsonStr !== '') {
            existingTasks = JSON.parse(jsonStr) as Array<TaskDto>;
          }
          existingTasks.push(newTask.toDto());
          return preferences.put(AppStrings.PREFS_KEY_TASKS, JSON.stringify(existingTasks))
            .then(() => preferences.flush());
        });
      })
      .then(() => {
        router.back();
      })
      .catch((err: Error) => {
        console.error('Ошибка сохранения задачи: ' + err.message);
      });
  }

  build() {
    Column() {
      // Верхняя панель навигации
      Row() {
        Button(AppStrings.BTN_CANCEL, { type: ButtonType.Normal })
          .backgroundColor('#Transparent')
          .fontColor(ThemeColors.PRIMARY)
          .onClick(() => {
            router.back();
          })

        Text(AppStrings.ADD_PAGE_TITLE)
          .fontSize(20)
          .fontWeight(FontWeight.Bold)
          .fontColor(ThemeColors.TEXT_MAIN)
          .layoutWeight(1)
          .textAlign(TextAlign.Center)
          .margin({ right: 60 })
      }
      .width('100%')
      .margin({ bottom: 16 })

      Scroll() {
        Column() {
          // Поле названия задачи
          TextInput({ placeholder: AppStrings.INPUT_TITLE_PLACEHOLDER, text: this.title })
            .backgroundColor(ThemeColors.BACKGROUND_CARD)
            .borderRadius(12)
            .padding(14)
            .margin({ bottom: 16 })
            .onChange((value: string) => {
              this.title = value;
            })

          // Выбор типа задачи
          Text(AppStrings.LABEL_TASK_TYPE)
            .fontSize(14)
            .fontWeight(FontWeight.Medium)
            .fontColor(ThemeColors.TEXT_MUTED)
            .width('100%')
            .margin({ bottom: 8 })

          Row({ space: 8 }) {
            this.TypeChip(AppStrings.TYPE_SIMPLE, TaskType.SIMPLE)
            this.TypeChip(AppStrings.TYPE_LESSON, TaskType.LESSON)
          }
          .width('100%')
          .margin({ bottom: 8 })

          Row({ space: 8 }) {
            this.TypeChip(AppStrings.TYPE_TIME_BOUND, TaskType.TIME_BOUND)
            this.TypeChip(AppStrings.TYPE_DEADLINE, TaskType.DEADLINE)
          }
          .width('100%')
          .margin({ bottom: 16 })

          // Выбор повторения
          Text(AppStrings.LABEL_REPEAT_TYPE)
            .fontSize(14)
            .fontWeight(FontWeight.Medium)
            .fontColor(ThemeColors.TEXT_MUTED)
            .width('100%')
            .margin({ bottom: 8 })

          Flex({ wrap: FlexWrap.Wrap }) {
            this.RepeatChip(AppStrings.REPEAT_ONCE, RepeatType.ONCE)
            this.RepeatChip(AppStrings.REPEAT_WEEKLY, RepeatType.WEEKLY)
            this.RepeatChip(AppStrings.REPEAT_BIWEEKLY, RepeatType.BIWEEKLY)
            this.RepeatChip(AppStrings.REPEAT_MONTHLY, RepeatType.MONTHLY)
            this.RepeatChip(AppStrings.REPEAT_YEARLY, RepeatType.YEARLY)
          }
          .width('100%')
          .margin({ bottom: 16 })

          // Слайдер важности (0 - 10)
          Row() {
            Text(`${AppStrings.LABEL_IMPORTANCE}: ${this.importance} (+${this.importance * 5} XP)`)
              .fontSize(14)
              .fontWeight(FontWeight.Medium)
              .fontColor(ThemeColors.TEXT_MAIN)
          }
          .width('100%')
          .margin({ bottom: 4 })

          Slider({ value: this.importance, min: 0, max: 10, step: 1 })
            .selectedColor(ThemeColors.PRIMARY)
            .margin({ bottom: 16 })
            .onChange((value: number) => {
              this.importance = Math.round(value);
            })

          // АДАПТИВНЫЙ БЛОК ВЫБОРА ДАТ И ВРЕМЕНИ
          if (this.selectedType === TaskType.SIMPLE) {
            this.PickerRow(AppStrings.LABEL_CHOOSE_DATE, this.formatDate(this.startDate), () => {
              this.openDatePicker(true);
            })
          } else if (this.selectedType === TaskType.LESSON) {
            this.PickerRow(AppStrings.LABEL_CHOOSE_DATE, this.formatDate(this.startDate), () => {
              this.openDatePicker(true);
            })
            this.PickerRow(AppStrings.LABEL_START_TIME, this.formatTime(this.startTime), () => {
              this.openTimePicker(true);
            })
            this.PickerRow(AppStrings.LABEL_END_TIME, this.formatTime(this.endTime), () => {
              this.openTimePicker(false);
            })
          } else if (this.selectedType === TaskType.TIME_BOUND) {
            this.PickerRow(AppStrings.LABEL_CHOOSE_START_DATE, this.formatDate(this.startDate), () => {
              this.openDatePicker(true);
            })
            this.PickerRow(AppStrings.LABEL_START_TIME, this.formatTime(this.startTime), () => {
              this.openTimePicker(true);
            })
            this.PickerRow(AppStrings.LABEL_CHOOSE_END_DATE, this.formatDate(this.endDate), () => {
              this.openDatePicker(false);
            })
            this.PickerRow(AppStrings.LABEL_END_TIME, this.formatTime(this.endTime), () => {
              this.openTimePicker(false);
            })
          } else if (this.selectedType === TaskType.DEADLINE) {
            this.PickerRow(AppStrings.LABEL_CHOOSE_DEADLINE, this.formatDate(this.endDate), () => {
              this.openDatePicker(false);
            })
            this.PickerRow(AppStrings.LABEL_END_TIME, this.formatTime(this.endTime), () => {
              this.openTimePicker(false);
            })
          }
        }
      }
      .layoutWeight(1)
      .align(Alignment.Top)
      // Кнопка сохранения
      Button(AppStrings.BTN_SAVE_TASK, { type: ButtonType.Capsule })
        .backgroundColor(ThemeColors.PRIMARY)
        .width('85%')
        .margin({ top: 12, bottom: 8 })
        .opacity(this.title.trim() !== '' ? 1.0 : 0.4)
        .enabled(this.title.trim() !== '')
        .onClick(() => {
          this.saveNewTaskAndReturn();
        })
    }
    .width('100%')
    .height('100%')
    .padding(16)
    .backgroundColor(ThemeColors.BACKGROUND_MAIN)
  }
  @Builder
  PickerRow(label: string, valueText: string, onClickAction: () => void) {
    Row() {
      Text(label)
        .fontSize(14)
        .fontColor(ThemeColors.TEXT_MAIN)
        .layoutWeight(1)
      Button(valueText, { type: ButtonType.Normal })
        .backgroundColor('#E8F1FF')
        .fontColor(ThemeColors.PRIMARY)
        .fontWeight(FontWeight.Medium)
        .borderRadius(8)
        .padding({ left: 14, right: 14, top: 8, bottom: 8 })
        .onClick(onClickAction)
    }
    .width('100%')
    .padding(12)
    .backgroundColor(ThemeColors.BACKGROUND_CARD)
    .borderRadius(12)
    .margin({ bottom: 10 })
  }
  @Builder
  TypeChip(label: string, typeValue: TaskType) {
    Button(label, { type: ButtonType.Capsule })
      .fontSize(13)
      .height(34)
      .layoutWeight(1)
      .backgroundColor(this.selectedType === typeValue ? ThemeColors.PRIMARY : ThemeColors.BACKGROUND_CARD)
      .fontColor(this.selectedType === typeValue ? '#FFFFFF' : ThemeColors.TEXT_MAIN)
      .onClick(() => {
        this.selectedType = typeValue;
      })
  }
  @Builder
  RepeatChip(label: string, repeatValue: RepeatType) {
    Button(label, { type: ButtonType.Capsule })
      .fontSize(12)
      .height(32)
      .margin({ right: 6, bottom: 6 })
      .backgroundColor(this.selectedRepeat === repeatValue ? ThemeColors.PRIMARY : ThemeColors.BACKGROUND_CARD)
      .fontColor(this.selectedRepeat === repeatValue ? '#FFFFFF' : ThemeColors.TEXT_MAIN)
      .onClick(() => {
        this.selectedRepeat = repeatValue;
      })
  }
}