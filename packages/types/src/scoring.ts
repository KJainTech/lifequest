/**
 * Server-authoritative scoring logic — single source of truth for economy math.
 */

export interface QuizResult {
  score: number;
  maxScore: number;
  xpEarned: number;
  coinsEarned: number;
  allCorrect: boolean;
}

export interface GameResult {
  xpEarned: number;
  coinsEarned: number;
  profitBonus: boolean;
}

export interface LessonCompletionAwards {
  xp: number;
  coins: number;
  lqDelta: number;
  stars: number;
  newLevel: number;
  newLqScore: number;
  badgeUnlocked: string | null;
  tower: { id: string; type: string; name: string } | null;
  streakCount: number;
}

export function scoreQuiz(
  answers: number[],
  correctAnswers: number[],
): QuizResult {
  const maxScore = correctAnswers.length;
  let score = 0;
  for (let i = 0; i < maxScore; i++) {
    if (answers[i] === correctAnswers[i]) score++;
  }
  const allCorrect = score === maxScore;
  const xpEarned = score * 10 + (allCorrect ? 20 : 0);
  const coinsEarned = allCorrect ? 15 : score * 2;
  return { score, maxScore, xpEarned, coinsEarned, allCorrect };
}

export function scoreGamePlay(
  profit: number,
  won: boolean,
): GameResult {
  const xpEarned = won ? 30 : 10;
  const coinsEarned = won ? Math.max(0, Math.min(50, Math.floor(profit))) : 5;
  return { xpEarned, coinsEarned, profitBonus: won && profit > 0 };
}

export function computeStars(quizScore: number, gameWon: boolean): number {
  const quizStars = quizScore >= 5 ? 3 : quizScore >= 3 ? 2 : quizScore >= 1 ? 1 : 0;
  const gameStars = gameWon ? 3 : 1;
  return Math.min(6, quizStars + gameStars);
}

export function computeLqDelta(stars: number, gameWon: boolean): number {
  return stars * 8 + (gameWon ? 12 : 4);
}

export function levelFromXp(xp: number): number {
  // Level N requires N * 100 XP cumulative threshold (simplified)
  return Math.max(1, Math.floor(Math.sqrt(xp / 50)) + 1);
}

export function computeBusinessIQDelta(
  gameWon: boolean,
  profit: number,
): { profit: number; decision: number; resilience: number } {
  return {
    profit: gameWon && profit > 0 ? 3 : profit >= 0 ? 1 : 0,
    decision: gameWon ? 2 : 1,
    resilience: profit < 0 ? 2 : 1,
  };
}

export function clampBusinessIQ(value: number): number {
  return Math.min(100, Math.max(0, value));
}

export function computeLessonAwards(params: {
  currentStats: {
    xp: number;
    level: number;
    coins: number;
    lqScore: number;
    streak: { count: number; lastActive: string | null };
  };
  quizScore: number;
  gameWon: boolean;
  gameProfit: number;
  lessonId: string;
  isFirstProfit: boolean;
  alreadyCompleted: boolean;
}): LessonCompletionAwards {
  if (params.alreadyCompleted) {
    return {
      xp: 0,
      coins: 0,
      lqDelta: 0,
      stars: computeStars(params.quizScore, params.gameWon),
      newLevel: params.currentStats.level,
      newLqScore: params.currentStats.lqScore,
      badgeUnlocked: null,
      tower: null,
      streakCount: params.currentStats.streak.count,
    };
  }

  const quiz = scoreQuiz(
    Array(params.quizScore).fill(0),
    Array(params.quizScore).fill(0),
  );
  const game = scoreGamePlay(params.gameProfit, params.gameWon);
  const xp = quiz.xpEarned + game.xpEarned;
  const coins = quiz.coinsEarned + game.coinsEarned;
  const stars = computeStars(params.quizScore, params.gameWon);
  const lqDelta = computeLqDelta(stars, params.gameWon);
  const newXp = params.currentStats.xp + xp;
  const newLevel = levelFromXp(newXp);
  const newLqScore = Math.min(900, params.currentStats.lqScore + lqDelta);

  const today = new Date().toISOString().slice(0, 10);
  const lastActive = params.currentStats.streak.lastActive?.slice(0, 10) ?? null;
  let streakCount = params.currentStats.streak.count;
  if (lastActive !== today) {
    const yesterday = new Date();
    yesterday.setDate(yesterday.getDate() - 1);
    const yesterdayStr = yesterday.toISOString().slice(0, 10);
    streakCount = lastActive === yesterdayStr ? streakCount + 1 : 1;
  }

  let badgeUnlocked: string | null = null;
  if (params.isFirstProfit && params.gameWon && params.gameProfit > 0) {
    badgeUnlocked = 'first_profit';
  } else if (streakCount >= 5) {
    badgeUnlocked = 'five_day_streak';
  }

  const towerNames: Record<string, string> = {
    lesson_6: 'Earning Tower',
    lesson_1: 'Foundation Tower',
  };
  const towerName = towerNames[params.lessonId] ?? 'Skill Tower';

  return {
    xp,
    coins,
    lqDelta,
    stars,
    newLevel,
    newLqScore,
    badgeUnlocked,
    tower: {
      id: `tower_${params.lessonId}_${Date.now()}`,
      type: params.lessonId,
      name: towerName,
    },
    streakCount,
  };
}
