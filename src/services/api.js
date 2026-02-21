import axios from 'axios';

const API_BASE_URL = 'https://api.raines.africa/api';

export const register = async (userData) => {
  try {
    const response = await axios.post(`${API_BASE_URL}/register`, userData);
    return response.data;
  } catch (error) {
    throw error.response?.data || { error: 'Registration failed' };
  }
};
