interface User {
  email: string;
  isAdmin: boolean;
}

let currentUser: User | null = null;

export async function signIn(email: string, password: string): Promise<User> {
  const adminEmail = import.meta.env.VITE_ADMIN_EMAIL;
  const adminPassword = import.meta.env.VITE_ADMIN_PASSWORD;

  if (email === adminEmail && password === adminPassword) {
    currentUser = { email, isAdmin: true };
    return currentUser;
  }

  throw new Error('Invalid credentials');
}

export async function getCurrentUser(): Promise<User | null> {
  return currentUser;
}

export async function signOut(): Promise<void> {
  currentUser = null;
}