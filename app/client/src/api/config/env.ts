//src/config/env.ts
// Uses Vite's environment variables (works with Create-React-App too)
export const API_BASE_URL = import.meta.env.VITE_API_BASE_URL || (
  window.location.hostname === 'localhost' 
    ? 'http://localhost:7000' 
    : 'https://task-mngmt-infoempleados.onrender.com'
);

export const API_ENDPOINTS = {
  USERS: '/api/users',
  TASKS: '/api/tasks',
  AUTH: '/api/auth',
  // Add other endpoints
};