export type UserRole = 'judge' | 'participant';

export interface User {
  id: string;
  email: string;
  name: string;
  role: UserRole;
}

export type RaceType = 'windward-leeward' | 'match-race' | 'coastal' | 'triangle';

export type RaceStatus = 'planned' | 'ready' | 'active' | 'finished' | 'cancelled';

export type CoursePointType = 'start-line' | 'finish-line' | 'mark' | 'gate-left' | 'gate-right' | 'offset-mark';

export interface CoursePoint {
  id: string;
  type: CoursePointType;
  lat: number;
  lng: number;
  order: number;
  name?: string;
}

export interface Course {
  id: string;
  name: string;
  raceType: RaceType;
  points: CoursePoint[];
  windDirection?: number;
  validated: boolean;
  validationErrors?: string[];
}

export interface Race {
  id: string;
  name: string;
  status: RaceStatus;
  courseId?: string;
  course?: Course;
  judgeId: string;
  judgeName: string;
  scheduledStart?: string;
  actualStart?: string;
  actualEnd?: string;
  participants: Participant[];
  trackingInterval: number; // seconds
  createdAt: string;
}

export interface Participant {
  id: string;
  userId: string;
  userName: string;
  boatName?: string;
  sailNumber?: string;
  status: 'invited' | 'confirmed' | 'racing' | 'finished' | 'dnf';
  finishTime?: string;
  position?: number;
}

export interface LocationPoint {
  lat: number;
  lng: number;
  timestamp: string;
  speed?: number;
  heading?: number;
}

export interface RaceTrack {
  participantId: string;
  points: LocationPoint[];
}
