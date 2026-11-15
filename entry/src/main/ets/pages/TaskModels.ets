export enum TaskType {
  SIMPLE = 'SIMPLE',
  LESSON = 'LESSON',
  TIME_BOUND = 'TIME_BOUND',
  DEADLINE = 'DEADLINE'
}

export enum RepeatType {
  ONCE = 'ONCE',
  WEEKLY = 'WEEKLY',
  BIWEEKLY = 'BIWEEKLY',
  MONTHLY = 'MONTHLY',
  YEARLY = 'YEARLY'
}

// Чистый интерфейс без декораторов V2 для надежного сохранения в JSON
export interface TaskDto {
  id: string;
  title: string;
  type: TaskType;
  repeatType: RepeatType;
  importance: number;
  startDateStr: string;
  endDateStr: string;
  isCompleted: boolean;
}

@ObservedV2
export class Task {
  public id: string;
  public title: string;
  public type: TaskType;
  public repeatType: RepeatType;
  public importance: number;
  public startDateStr: string;
  public endDateStr: string;
  @Trace public isCompleted: boolean;
  public expPoints: number;

  constructor(
    id: string,
    title: string,
    type: TaskType,
    repeatType: RepeatType,
    importance: number,
    startDateStr: string,
    endDateStr: string,
    isCompleted: boolean
  ) {
    this.id = id;
    this.title = title;
    this.type = type;
    this.repeatType = repeatType;
    this.importance = importance;
    this.startDateStr = startDateStr;
    this.endDateStr = endDateStr;
    this.isCompleted = isCompleted;
    this.expPoints = importance * 5;
  }

  // Метод конвертации в чистый объект перед записью на диск
  public toDto(): TaskDto {
    return {
      id: this.id,
      title: this.title,
      type: this.type,
      repeatType: this.repeatType,
      importance: this.importance,
      startDateStr: this.startDateStr,
      endDateStr: this.endDateStr,
      isCompleted: this.isCompleted
    };
  }
}

@ObservedV2
export class WeeklyProgress {
  @Trace public currentWeekScore: number;
  @Trace public lastWeekScore: number;
  @Trace public averageScore: number;

  constructor(current: number, last: number, avg: number) {
    this.currentWeekScore = current;
    this.lastWeekScore = last;
    this.averageScore = avg;
  }
}