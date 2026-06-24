import { z } from 'zod';

export const UserRoleSchema = z.enum(['child', 'parent', 'teacher', 'admin']);
export type UserRole = z.infer<typeof UserRoleSchema>;

export const AgeBandSchema = z.enum(['5-8', '9-12', '13-17']);
export type AgeBand = z.infer<typeof AgeBandSchema>;

export const GuideSchema = z.enum(['penny', 'finBot', 'atlas']);
export type Guide = z.infer<typeof GuideSchema>;

export const RegionSchema = z.enum(['AE']);
export type Region = z.infer<typeof RegionSchema>;

export const LocaleSchema = z.enum(['en', 'ar']);
export type Locale = z.infer<typeof LocaleSchema>;

export const BusinessIQSchema = z.object({
  profit: z.number().min(0).max(100),
  decision: z.number().min(0).max(100),
  resilience: z.number().min(0).max(100),
});

export const StreakSchema = z.object({
  count: z.number().int().min(0),
  lastActive: z.string().datetime().nullable(),
});

export const UserProfileSchema = z.object({
  role: UserRoleSchema,
  displayName: z.string().min(1).max(64),
  ageBand: AgeBandSchema.optional(),
  guide: GuideSchema.optional(),
  proficiencyLevel: z.number().int().min(1).max(6).default(1),
  locale: LocaleSchema.default('en'),
  region: RegionSchema.default('AE'),
  parentUid: z.string().optional(),
  classIds: z.array(z.string()).optional(),
  createdAt: z.string().datetime(),
});

export const UserStatsSchema = z.object({
  xp: z.number().int().min(0),
  level: z.number().int().min(1),
  coins: z.number().int().min(0),
  lqScore: z.number().int().min(0).max(900),
  businessIQ: BusinessIQSchema,
  streak: StreakSchema,
  conceptSkills: z.record(z.string(), z.number().min(0).max(100)).optional(),
  updatedAt: z.string().datetime(),
});

export const GamePlaySchema = z.object({
  profit: z.number(),
  revenue: z.number(),
  cost: z.number(),
  won: z.boolean(),
  difficulty: z.number().min(1).max(10),
  playedAt: z.string().datetime(),
});

export const LessonProgressSchema = z.object({
  status: z.enum(['locked', 'available', 'in_progress', 'completed']),
  quizScore: z.number().min(0).max(5).optional(),
  gamePlays: z.array(GamePlaySchema).optional(),
  stars: z.number().int().min(0).max(6).optional(),
  completedAt: z.string().datetime().optional(),
});

export const TowerSchema = z.object({
  id: z.string(),
  type: z.string(),
  name: z.string(),
  builtAt: z.string().datetime(),
});

export const CitySchema = z.object({
  towers: z.array(TowerSchema),
});

export const BadgeSchema = z.object({
  earnedAt: z.string().datetime(),
});

export const CoachNoteSchema = z.object({
  text: z.string(),
  activity: z.string(),
  createdAt: z.string().datetime(),
});

export const ClassSchema = z.object({
  teacherUid: z.string(),
  code: z.string().length(6),
  name: z.string(),
  roster: z.array(z.string()),
  assignments: z.array(
    z.object({
      lessonId: z.string(),
      assignedAt: z.string().datetime(),
      dueAt: z.string().datetime().optional(),
    }),
  ),
  createdAt: z.string().datetime(),
});

// Callable payloads
export const SubmitQuizPayloadSchema = z.object({
  lessonId: z.string(),
  answers: z.array(z.number().int().min(0).max(3)).length(5),
  correctAnswers: z.array(z.number().int().min(0).max(3)).length(5),
});

export const SubmitGamePlayPayloadSchema = z.object({
  lessonId: z.string(),
  profit: z.number(),
  revenue: z.number(),
  cost: z.number(),
  won: z.boolean(),
  difficulty: z.number().min(1).max(10),
});

export const CompleteLessonPayloadSchema = z.object({
  lessonId: z.string(),
  idempotencyKey: z.string().min(8).max(128),
  quizScore: z.number().int().min(0).max(5),
  gameWon: z.boolean(),
  gameProfit: z.number(),
});

export const RunScreeningPayloadSchema = z.object({
  answers: z.array(
    z.object({
      questionId: z.string(),
      selectedIndex: z.number().int().min(0).max(3),
      correctIndex: z.number().int().min(0).max(3),
    }),
  ).min(3).max(6),
});

export const LinkChildPayloadSchema = z.object({
  childUid: z.string(),
});

export const CreateClassPayloadSchema = z.object({
  name: z.string().min(1).max(64),
});

export const JoinClassPayloadSchema = z.object({
  code: z.string().length(6),
});

export const GeneratedQuizQuestionSchema = z.object({
  id: z.string(),
  prompt: z.string().min(1).max(500),
  options: z.array(z.string().min(1).max(200)).length(4),
  correctIndex: z.number().int().min(0).max(3),
  explanation: z.string().min(1).max(500),
});

export const GeneratedContentSchema = z.object({
  concept: z.string(),
  ageBand: AgeBandSchema,
  region: RegionSchema,
  guide: GuideSchema,
  locale: LocaleSchema,
  readParagraphs: z.array(z.string().min(1).max(800)).min(2).max(8),
  quizQuestions: z.array(GeneratedQuizQuestionSchema).length(5),
  gameConfig: z.object({
    unitCost: z.number().positive(),
    daySeconds: z.number().int().min(30).max(180),
    customerCount: z.number().int().min(3).max(20),
    minPrice: z.number().positive(),
    maxPrice: z.number().positive(),
    defaultPrice: z.number().positive(),
  }),
  reviewed: z.boolean().default(false),
});

export const CoachNoteOutputSchema = z.object({
  text: z.string().min(20).max(600),
  activity: z.string().min(10).max(300),
});

export type UserProfile = z.infer<typeof UserProfileSchema>;
export type UserStats = z.infer<typeof UserStatsSchema>;
export type LessonProgress = z.infer<typeof LessonProgressSchema>;
export type CompleteLessonPayload = z.infer<typeof CompleteLessonPayloadSchema>;
export type SubmitQuizPayload = z.infer<typeof SubmitQuizPayloadSchema>;
export type SubmitGamePlayPayload = z.infer<typeof SubmitGamePlayPayloadSchema>;
