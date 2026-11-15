import { Task, TaskType, RepeatType } from './TaskModels';

export class TaskScheduler {
  // Форматирование Date в "YYYY-MM-DD"
  public static formatDate(d: Date): string {
    const year = d.getFullYear();
    const month = (d.getMonth() + 1).toString().padStart(2, '0');
    const day = d.getDate().toString().padStart(2, '0');
    return `${year}-${month}-${day}`;
  }

  // Парсинг строки "YYYY-MM-DD" или "YYYY-MM-DD HH:mm" в объект Date
  public static parseDateTime(str: string): Date {
    const parts = str.trim().split(' ');
    const dateParts = parts[0].split('-');
    const year = parseInt(dateParts[0], 10);
    const month = parseInt(dateParts[1], 10) - 1;
    const day = parseInt(dateParts[2], 10);

    if (parts.length > 1) {
      const timeParts = parts[1].split(':');
      const hours = parseInt(timeParts[0], 10);
      const minutes = parseInt(timeParts[1], 10);
      return new Date(year, month, day, hours, minutes, 0, 0);
    }
    return new Date(year, month, day, 0, 0, 0, 0);
  }

  // Проверка совпадения дня с учетом типа повторения
  public static matchesRepeatRule(taskStart: Date, targetDay: Date, repeat: RepeatType): boolean {
    const startMidnight = new Date(taskStart.getFullYear(), taskStart.getMonth(), taskStart.getDate());
    const targetMidnight = new Date(targetDay.getFullYear(), targetDay.getMonth(), targetDay.getDate());

    if (targetMidnight.getTime() < startMidnight.getTime()) {
      return false;
    }

    const diffDays = Math.round((targetMidnight.getTime() - startMidnight.getTime()) / 86400000);

    switch (repeat) {
      case RepeatType.ONCE:
        return diffDays === 0;
      case RepeatType.WEEKLY:
        return diffDays % 7 === 0;
      case RepeatType.BIWEEKLY:
        return diffDays % 14 === 0;
      case RepeatType.MONTHLY:
        return taskStart.getDate() === targetDay.getDate();
      case RepeatType.YEARLY:
        return taskStart.getDate() === targetDay.getDate() && taskStart.getMonth() === targetDay.getMonth();
      default:
        return diffDays === 0;
    }
  }

  // 1. Проверка для ГЛАВНОГО ЭКРАНА (Активна ли задача в текущую секунду)
  public static isTaskActiveNow(task: Task, now: Date): boolean {
    const startDt = TaskScheduler.parseDateTime(task.startDateStr);
    const endDt = TaskScheduler.parseDateTime(task.endDateStr);
    const nowMs = now.getTime();

    if (task.type === TaskType.SIMPLE) {
      return TaskScheduler.matchesRepeatRule(startDt, now, task.repeatType);
    }

    if (task.type === TaskType.LESSON) {
      if (!TaskScheduler.matchesRepeatRule(startDt, now, task.repeatType)) {
        return false;
      }
      const todayStart = new Date(now.getFullYear(), now.getMonth(), now.getDate(), startDt.getHours(), startDt.getMinutes());
      const todayEnd = new Date(now.getFullYear(), now.getMonth(), now.getDate(), endDt.getHours(), endDt.getMinutes());
      // Активна за 10 минут до начала и 10 минут после окончания
      return nowMs >= (todayStart.getTime() - 600000) && nowMs <= (todayEnd.getTime() + 600000);
    }

    if (task.type === TaskType.TIME_BOUND) {
      const durationMs = endDt.getTime() - startDt.getTime();
      // Проверяем, попадает ли текущий момент в один из повторяющихся интервалов
      const dayMidnight = new Date(now.getFullYear(), now.getMonth(), now.getDate());
      const maxDaysLookback = Math.ceil(durationMs / 86400000) + 1;

      for (let i = 0; i <= maxDaysLookback; i++) {
        const candidateDay = new Date(dayMidnight.getTime() - i * 86400000);
        if (TaskScheduler.matchesRepeatRule(startDt, candidateDay, task.repeatType)) {
          const cycleStart = new Date(candidateDay.getFullYear(), candidateDay.getMonth(), candidateDay.getDate(), startDt.getHours(), startDt.getMinutes());
          const cycleEnd = new Date(cycleStart.getTime() + durationMs);
          if (nowMs >= cycleStart.getTime() && nowMs <= cycleEnd.getTime()) {
            return true;
          }
        }
      }
      return false;
    }

    if (task.type === TaskType.DEADLINE) {
      // Активна с момента создания и сгорает через 1 минуту после конца
      return nowMs <= (endDt.getTime() + 60000);
    }

    return false;
  }

  // 2. Проверка для КАЛЕНДАРЯ (Есть ли задача в конкретный день)
  public static isTaskScheduledForDate(task: Task, targetDate: Date): boolean {
    const startDt = TaskScheduler.parseDateTime(task.startDateStr);
    const endDt = TaskScheduler.parseDateTime(task.endDateStr);
    const targetMidnight = new Date(targetDate.getFullYear(), targetDate.getMonth(), targetDate.getDate());

    if (task.type === TaskType.SIMPLE || task.type === TaskType.LESSON) {
      return TaskScheduler.matchesRepeatRule(startDt, targetMidnight, task.repeatType);
    }

    if (task.type === TaskType.TIME_BOUND) {
      const startMidnight = new Date(startDt.getFullYear(), startDt.getMonth(), startDt.getDate());
      const endMidnight = new Date(endDt.getFullYear(), endDt.getMonth(), endDt.getDate());
      const spanDays = Math.round((endMidnight.getTime() - startMidnight.getTime()) / 86400000);

      for (let i = 0; i <= spanDays; i++) {
        const candidateStart = new Date(targetMidnight.getTime() - i * 86400000);
        if (TaskScheduler.matchesRepeatRule(startMidnight, candidateStart, task.repeatType)) {
          return true;
        }
      }
      return false;
    }

    if (task.type === TaskType.DEADLINE) {
      const endMidnight = new Date(endDt.getFullYear(), endDt.getMonth(), endDt.getDate());
      return TaskScheduler.matchesRepeatRule(endMidnight, targetMidnight, task.repeatType);
    }

    return false;
  }
}