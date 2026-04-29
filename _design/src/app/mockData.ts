import type { User, Race, Course, Participant } from './types';

// Mock users
export const mockJudge: User = {
  id: 'judge-1',
  email: 'судья@regatta.ru',
  name: 'Иван Петров',
  role: 'judge',
};

export const mockParticipant: User = {
  id: 'participant-1',
  email: 'участник@regatta.ru',
  name: 'Алексей Морской',
  role: 'participant',
};

// Mock courses
export const mockCourses: Course[] = [
  {
    id: 'course-1',
    name: 'Windward-Leeward Стандарт',
    raceType: 'windward-leeward',
    validated: true,
    windDirection: 45,
    points: [
      { id: 'p1', type: 'start-line', lat: 59.9311, lng: 30.3609, order: 0, name: 'Старт (левый)' },
      { id: 'p2', type: 'start-line', lat: 59.9315, lng: 30.3615, order: 1, name: 'Старт (правый)' },
      { id: 'p3', type: 'mark', lat: 59.9350, lng: 30.3650, order: 2, name: 'Верхняя метка' },
      { id: 'p4', type: 'offset-mark', lat: 59.9348, lng: 30.3655, order: 3, name: 'Offset метка' },
      { id: 'p5', type: 'gate-left', lat: 59.9310, lng: 30.3605, order: 4, name: 'Ворота (левые)' },
      { id: 'p6', type: 'gate-right', lat: 59.9308, lng: 30.3610, order: 5, name: 'Ворота (правые)' },
      { id: 'p7', type: 'finish-line', lat: 59.9312, lng: 30.3608, order: 6, name: 'Финиш (левый)' },
      { id: 'p8', type: 'finish-line', lat: 59.9316, lng: 30.3614, order: 7, name: 'Финиш (правый)' },
    ],
  },
  {
    id: 'course-2',
    name: 'Match Race Трасса',
    raceType: 'match-race',
    validated: true,
    windDirection: 90,
    points: [
      { id: 'p1', type: 'start-line', lat: 59.9320, lng: 30.3620, order: 0, name: 'Старт' },
      { id: 'p2', type: 'mark', lat: 59.9360, lng: 30.3680, order: 1, name: 'Метка 1' },
      { id: 'p3', type: 'mark', lat: 59.9340, lng: 30.3700, order: 2, name: 'Метка 2' },
      { id: 'p4', type: 'finish-line', lat: 59.9325, lng: 30.3625, order: 3, name: 'Финиш' },
    ],
  },
];

// Mock participants
const mockParticipants: Participant[] = [
  {
    id: 'part-1',
    userId: 'user-1',
    userName: 'Алексей Морской',
    boatName: 'Буря',
    sailNumber: 'RUS-101',
    status: 'confirmed',
  },
  {
    id: 'part-2',
    userId: 'user-2',
    userName: 'Мария Ветрова',
    boatName: 'Волна',
    sailNumber: 'RUS-102',
    status: 'confirmed',
  },
  {
    id: 'part-3',
    userId: 'user-3',
    userName: 'Дмитрий Компасов',
    boatName: 'Парус',
    sailNumber: 'RUS-103',
    status: 'racing',
    position: 1,
  },
  {
    id: 'part-4',
    userId: 'user-4',
    userName: 'Ольга Моряк',
    boatName: 'Регата',
    sailNumber: 'RUS-104',
    status: 'finished',
    finishTime: '2026-04-13T14:35:22Z',
    position: 2,
  },
];

// Mock races
export const mockRaces: Race[] = [
  {
    id: 'race-1',
    name: 'Весенний Кубок 2026 - Гонка 1',
    status: 'active',
    courseId: 'course-1',
    course: mockCourses[0],
    judgeId: 'judge-1',
    judgeName: 'Иван Петров',
    scheduledStart: '2026-04-13T14:00:00Z',
    actualStart: '2026-04-13T14:05:12Z',
    participants: mockParticipants.slice(2, 4),
    trackingInterval: 5,
    createdAt: '2026-04-10T10:00:00Z',
  },
  {
    id: 'race-2',
    name: 'Весенний Кубок 2026 - Гонка 2',
    status: 'planned',
    courseId: 'course-1',
    course: mockCourses[0],
    judgeId: 'judge-1',
    judgeName: 'Иван Петров',
    scheduledStart: '2026-04-13T16:00:00Z',
    participants: mockParticipants.slice(0, 2),
    trackingInterval: 5,
    createdAt: '2026-04-10T10:15:00Z',
  },
  {
    id: 'race-3',
    name: 'Открытый Чемпионат - Квалификация',
    status: 'finished',
    courseId: 'course-2',
    course: mockCourses[1],
    judgeId: 'judge-1',
    judgeName: 'Иван Петров',
    scheduledStart: '2026-04-12T12:00:00Z',
    actualStart: '2026-04-12T12:03:45Z',
    actualEnd: '2026-04-12T13:15:30Z',
    participants: [
      { ...mockParticipants[0], status: 'finished', position: 1, finishTime: '2026-04-12T13:15:30Z' },
      { ...mockParticipants[1], status: 'finished', position: 2, finishTime: '2026-04-12T13:18:45Z' },
    ],
    trackingInterval: 5,
    createdAt: '2026-04-11T09:00:00Z',
  },
  {
    id: 'race-4',
    name: 'Тренировочная Гонка',
    status: 'ready',
    courseId: 'course-1',
    course: mockCourses[0],
    judgeId: 'judge-1',
    judgeName: 'Иван Петров',
    scheduledStart: '2026-04-14T10:00:00Z',
    participants: mockParticipants,
    trackingInterval: 10,
    createdAt: '2026-04-13T08:00:00Z',
  },
];

// Current user (можно переключать для демо)
export let currentUser: User = mockJudge;

export const setCurrentUser = (user: User) => {
  currentUser = user;
};

export const getCurrentUser = () => currentUser;
