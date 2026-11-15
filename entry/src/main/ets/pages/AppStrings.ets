// AppStrings.ets
export class AppStrings {
  static readonly RATING_HEADER: string = '你本周的评分';
  static readonly TODAY_TASKS_PREFIX: string = '今日任务';
  static readonly BTN_COMPLETE_SELECTED: string = '完成所选任务';


  static readonly PREFERENCES_NAME: string = 'TaskAppPreferences';
  static readonly PREFS_KEY_TASKS: string = 'user_tasks_list';


  static readonly DIALOG_TITLE: string = '确认';
  static readonly DIALOG_MESSAGE: string = '你确定要完成所选任务并获得经验吗？';
  static readonly DIALOG_YES: string = '是';
  static readonly DIALOG_NO: string = '否';

  static readonly TYPE_SIMPLE: string = '简单任务';
  static readonly TYPE_LESSON: string = '课程 / 课';
  static readonly TYPE_TIME_BOUND: string = '限时任务';
  static readonly TYPE_DEADLINE: string = '截止日期';
  static readonly TYPE_UNKNOWN: string = '任务';

  static readonly REPEAT_ONCE: string = '一次性';
  static readonly REPEAT_WEEKLY: string = '每周一次';
  static readonly REPEAT_BIWEEKLY: string = '每两周一次';
  static readonly REPEAT_MONTHLY: string = '每月一次';
  static readonly REPEAT_YEARLY: string = '每年一次';

  static readonly MOTIVATION_EXCELLENT: string = '🚀 你本周的统计数据非常棒！你超过了上周和自己的平均水平！';
  static readonly MOTIVATION_GOOD: string = '📈 节奏不错！你比上周更高效。';
  static readonly MOTIVATION_TRY_HARDER: string = '📉 加把劲！上周更有成效。你可以做得更好！';

  static readonly ADD_PAGE_TITLE: string = '新任务';
  static readonly INPUT_TITLE_PLACEHOLDER: string = '任务名称（例如，讲座）';
  static readonly LABEL_TASK_TYPE: string = '任务类型';
  static readonly LABEL_REPEAT_TYPE: string = '重复';
  static readonly LABEL_IMPORTANCE: string = '重要性';
  static readonly BTN_SAVE_TASK: string = '保存任务';
  static readonly BTN_CANCEL: string = '取消';

  static readonly EMPTY_TASKS_MESSAGE: string = '今天没有活动任务。\n点击“+”来安排事项！';
  static readonly LABEL_CHOOSE_DATE: string = '日期';
  static readonly LABEL_CHOOSE_START_DATE: string = '开始日期';
  static readonly LABEL_CHOOSE_END_DATE: string = '结束日期';
  static readonly LABEL_CHOOSE_DEADLINE: string = '截止到';
  static readonly LABEL_START_TIME: string = '开始时间';
  static readonly LABEL_END_TIME: string = '结束时间';

  static readonly CALENDAR_TITLE: string = '日程与计划';
  static readonly MODE_WEEK: string = '周';
  static readonly MODE_MONTH: string = '月';
  static readonly BTN_BACK: string = '返回';
  static readonly CALENDAR_EMPTY_DAY: string = '这一天没有安排任何事项';
}