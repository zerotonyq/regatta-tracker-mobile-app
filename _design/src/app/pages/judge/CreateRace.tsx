import { useState } from 'react';
import { useNavigate } from 'react-router';
import { ArrowLeft, Calendar, Users, Map, Clock } from 'lucide-react';
import { Button } from '../../components/Button';
import { Input } from '../../components/Input';
import { Card } from '../../components/Card';
import { mockCourses } from '../../mockData';

export function CreateRace() {
  const navigate = useNavigate();
  const [formData, setFormData] = useState({
    name: '',
    courseId: '',
    scheduledStart: '',
    trackingInterval: '5',
  });
  const [loading, setLoading] = useState(false);

  const handleSubmit = async (e: React.FormEvent) => {
    e.preventDefault();
    setLoading(true);

    // Simulate API call
    await new Promise(resolve => setTimeout(resolve, 1000));

    setLoading(false);
    navigate('/judge');
  };

  return (
    <div className="min-h-screen bg-background">
      {/* Header */}
      <div className="bg-primary px-4 py-4 text-primary-foreground">
        <div className="mx-auto max-w-2xl">
          <button
            onClick={() => navigate(-1)}
            className="mb-3 flex items-center gap-2 text-primary-foreground/80"
          >
            <ArrowLeft className="h-5 w-5" />
            Назад
          </button>
          <h1 className="text-2xl font-bold">Создать гонку</h1>
        </div>
      </div>

      <div className="mx-auto max-w-2xl px-4 py-6">
        <form onSubmit={handleSubmit} className="space-y-4">
          {/* Race Name */}
          <Card className="p-4">
            <Input
              label="Название гонки"
              placeholder="Весенний Кубок 2026 - Гонка 1"
              value={formData.name}
              onChange={(e) => setFormData({ ...formData, name: e.target.value })}
              fullWidth
              required
            />
          </Card>

          {/* Course Selection */}
          <Card className="p-4">
            <label className="mb-3 block text-sm font-medium">
              <div className="mb-2 flex items-center gap-2">
                <Map className="h-4 w-4" />
                Выберите трассу
              </div>
            </label>
            <div className="space-y-2">
              {mockCourses.map(course => (
                <button
                  key={course.id}
                  type="button"
                  onClick={() => setFormData({ ...formData, courseId: course.id })}
                  className={`w-full rounded-lg border-2 p-4 text-left transition-all ${
                    formData.courseId === course.id
                      ? 'border-primary bg-primary/5'
                      : 'border-border bg-background'
                  }`}
                >
                  <div className="font-medium">{course.name}</div>
                  <div className="mt-1 text-sm text-muted-foreground">
                    {course.raceType} • {course.points.length} точек
                  </div>
                </button>
              ))}
              <Button
                type="button"
                variant="outline"
                fullWidth
                onClick={() => navigate('/judge/course/new')}
              >
                <Plus className="mr-2 h-4 w-4" />
                Создать новую трассу
              </Button>
            </div>
          </Card>

          {/* Schedule */}
          <Card className="p-4">
            <Input
              type="datetime-local"
              label={
                <div className="flex items-center gap-2">
                  <Calendar className="h-4 w-4" />
                  Запланированное время старта
                </div>
              }
              value={formData.scheduledStart}
              onChange={(e) => setFormData({ ...formData, scheduledStart: e.target.value })}
              fullWidth
              required
            />
          </Card>

          {/* Tracking Settings */}
          <Card className="p-4">
            <label className="mb-3 block text-sm font-medium">
              <div className="flex items-center gap-2">
                <Clock className="h-4 w-4" />
                Интервал отправки GPS (секунды)
              </div>
            </label>
            <div className="grid grid-cols-4 gap-2">
              {['3', '5', '10', '15'].map(interval => (
                <button
                  key={interval}
                  type="button"
                  onClick={() => setFormData({ ...formData, trackingInterval: interval })}
                  className={`rounded-lg border-2 p-3 text-center font-medium transition-all ${
                    formData.trackingInterval === interval
                      ? 'border-primary bg-primary text-primary-foreground'
                      : 'border-border bg-background'
                  }`}
                >
                  {interval}с
                </button>
              ))}
            </div>
            <p className="mt-2 text-xs text-muted-foreground">
              Меньший интервал = точнее трек, но больше расход батареи
            </p>
          </Card>

          {/* Submit */}
          <div className="pt-4">
            <Button type="submit" fullWidth size="lg" loading={loading}>
              Создать гонку
            </Button>
          </div>
        </form>
      </div>
    </div>
  );
}

function Plus({ className }: { className?: string }) {
  return (
    <svg className={className} fill="none" viewBox="0 0 24 24" stroke="currentColor">
      <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M12 4v16m8-8H4" />
    </svg>
  );
}
