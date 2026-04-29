import { useState } from 'react';
import { useNavigate } from 'react-router';
import { Anchor, ArrowLeft } from 'lucide-react';
import { Button } from '../components/Button';
import { Input } from '../components/Input';
import { Card } from '../components/Card';

export function Login() {
  const navigate = useNavigate();
  const [email, setEmail] = useState('');
  const [password, setPassword] = useState('');
  const [loading, setLoading] = useState(false);

  const handleLogin = async (e: React.FormEvent) => {
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

      <div className="flex flex-1 flex-col items-center justify-center">
        <div className="mb-8 text-center">
          <div className="mx-auto mb-4 flex h-16 w-16 items-center justify-center rounded-full bg-primary shadow-lg">
            <Anchor className="h-8 w-8 text-primary-foreground" />
          </div>
          <h1 className="mb-2 text-2xl font-bold">Вход в систему</h1>
          <p className="text-muted-foreground">Введите email и пароль</p>
        </div>

        <Card className="w-full max-w-md p-6">
          <form onSubmit={handleLogin} className="space-y-4">
            <Input
              type="email"
              label="Email"
              placeholder="ваш@email.ru"
              value={email}
              onChange={(e) => setEmail(e.target.value)}
              fullWidth
              required
            />

            <Input
              type="password"
              label="Пароль"
              placeholder="••••••••"
              value={password}
              onChange={(e) => setPassword(e.target.value)}
              fullWidth
              required
            />

            <Button type="submit" fullWidth loading={loading}>
              Войти
            </Button>

            <div className="text-center">
              <button
                type="button"
                onClick={() => navigate('/register')}
                className="text-sm text-primary"
              >
                Нет аккаунта? Зарегистрироваться
              </button>
            </div>
          </form>
        </Card>
      </div>
    </div>
  );
}
