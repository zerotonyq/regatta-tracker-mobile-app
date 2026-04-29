import { createBrowserRouter, Navigate } from 'react-router';
import { RootLayout } from './layouts/RootLayout';
import { RoleSelect } from './pages/RoleSelect';
import { Login } from './pages/Login';
import { Register } from './pages/Register';
import { JudgeDashboard } from './pages/judge/JudgeDashboard';
import { CreateRace } from './pages/judge/CreateRace';
import { RaceDetails } from './pages/judge/RaceDetails';
import { CourseBuilder } from './pages/judge/CourseBuilder';
import { ParticipantDashboard } from './pages/participant/ParticipantDashboard';
import { RaceView } from './pages/participant/RaceView';
import { RacingMode } from './pages/participant/RacingMode';
import { Settings } from './pages/Settings';
import { DesignSystem } from './pages/DesignSystem';

export const router = createBrowserRouter([
  {
    path: '/',
    Component: RootLayout,
    children: [
      { index: true, Component: RoleSelect },
      { path: 'login', Component: Login },
      { path: 'register', Component: Register },
      { path: 'settings', Component: Settings },
      { path: 'design-system', Component: DesignSystem },

      // Judge routes
      { path: 'judge', Component: JudgeDashboard },
      { path: 'judge/race/new', Component: CreateRace },
      { path: 'judge/race/:id', Component: RaceDetails },
      { path: 'judge/course/new', Component: CourseBuilder },
      { path: 'judge/course/:id', Component: CourseBuilder },

      // Participant routes
      { path: 'participant', Component: ParticipantDashboard },
      { path: 'participant/race/:id', Component: RaceView },
      { path: 'participant/racing/:id', Component: RacingMode },

      { path: '*', element: <Navigate to="/" replace /> },
    ],
  },
]);
