import { useState } from 'react';
import { useNavigate } from 'react-router';
import { Anchor, ArrowLeft } from 'lucide-react';
import { Button } from '../components/Button';
import { Input } from '../components/Input';
import { Card } from '../components/Card';

export function Register() {
  const navigate = useNavigate();
  const [formData, setFormData] = useState({
    name: '',
    email: '',
    password: '',
    confirmPassword: '',
    role: 'participant' as 'judge' | 'participant',
  });
  const [loading, setLoading] = useState(false);

  const handleRegister = async (e: React.FormEvent) => {
    e.preventDefault();
    setLoading(true);

    // Simulate API call
    await new Promise(resolve => setTimeout(resolve, 1000));

    setLoading(false);
    navigate('/');
  };

  return (
    <div className="flex min-h-screen flex-col bg-gradient-to-br from-blue-50 to-blue-100 p-4">
      <button
        onClick={() => navigate(-1)}
        className="mb-4 flex items-center gap-2 text-muted-foreground"
      >
        <ArrowLeft className="h-5 w-5" />
        Назад
      </button>

      <div className="flex flex-1 flex-col items-center justify-center pb-8">
        <div className="mb-8 text-center">
          <div className="mx-auto mb-4 flex h-16 w-16 items-center justify-center rounded-full bg-primary shadow-lg">
            <Anchor className="h-8 w-8 text-primary-foreground" />
          </div>
          <h1 className="mb-2 text-2xl font-bold">Регистрация</h1>
          <p className="text-muted-foreground">Создайте новый аккаунт</p>
        </div>

        <Card className="w-full max-w-md p-6">
          <form onSubmit={handleRegister} className="space-y-4">
            <Input
              label="Имя"
              placeholder="Иван Петров"
              value={formData.name}
              onChange={(e) => setFormData({ ...formData, name: e.target.value })}
              fullWidth
              required
            />

            <Input
              type="email"
              label="Email"
              placeholder="ваш@email.ru"
              value={formData.email}
              onChange={(e) => setFormData({ ...formData, email: e.target.value })}
              fullWidth
              required
            />

            <Input
              type="password"
              label="Пароль"
              placeholder="••••••••"
              value={formData.password}
              onChange={(e) => setFormData({ ...formData, password: e.target.value })}
              fullWidth
              required
            />

            <Input
              type="password"
              label="Подтвердите пароль"
              placeholder="••••••••"
              value={formData.confirmPassword}
              onChange={(e) => setFormData({ ...formData, confirmPassword: e.target.value })}
              fullWidth
              required
            />

            <div>
              <label className="mb-2 block text-sm font-medium">Роль</label>
              <div className="grid grid-cols-2 gap-3">
                <button
                  type="button"
                  onClick={() => setFormData({ ...formData, role: 'participant' })}
                  className={`rounded-lg border-2 p-3 text-sm transition-all ${
                    formData.role === 'participant'
                      ? 'border-primary bg-primary/5 text-primary'
                      : 'border-border bg-transparent'
                  }`}
                >
                  Участник
                </button>
                <button
                  type="button"
                  onClick={() => setFormData({ ...formData, role: 'judge' })}
                  className={`rounded-lg border-2 p-3 text-sm transition-all ${
                    formData.role === 'judge'
                      ? 'border-primary bg-primary/5 text-primary'
                      : 'border-border bg-transparent'
                  }`}
                >
                  Судья
                </button>
              </div>
            </div>

            <Button type="submit" fullWidth loading={loading}>
              Зарегистрироваться
            </Button>

            <div className="text-center">
              <button
                type="button"
                onClick={() => navigate('/login')}
                className="text-sm text-primary"
              >
                Уже есть аккаунт? Войти
              </button>
            </div>
          </form>
        </Card>
      </div>
    </div>
  );
}
