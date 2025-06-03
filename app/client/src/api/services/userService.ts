//apr/services/userService.ts
import { API_ENDPOINTS } from '../config/env';
import http from '../http';

interface User {
  _id: string;
  name: string;
  role?: string;
}

export const UserService = {
  /**
   * Fetch all employees
   */
  getEmployees: async (): Promise<User[]> => {
    try {
      const { data } = await http.get<User[]>(
        `${API_ENDPOINTS.USERS}/employees`
      );
      return data.map((user) => ({
        _id: user._id,
        name: user.name || 'Unnamed Employee',
      }));
    } catch (error) {
      console.error('Error fetching employees:', error);
      throw error;
    }
  },

  /**
   * Fetch all users
   */
  getUsers: async (): Promise<User[]> => {
    try {
      const { data } = await http.get<User[]>(API_ENDPOINTS.USERS);
      return data.map((user) => ({
        _id: user._id,
        name: user.name || 'Unnamed User',
      }));
    } catch (error) {
      console.error('Error fetching users:', error);
      throw error;
    }
  },

  /**
   * Fetch user by ID
   */
  getUserById: async (userId: string): Promise<User> => {
    try {
      const { data } = await http.get<User>(`${API_ENDPOINTS.USERS}/${userId}`);
      return {
        _id: data._id,
        name: data.name || 'Unknown User',
      };
    } catch (error) {
      console.error(`Error fetching user ${userId}:`, error);
      throw error;
    }
  },
};
