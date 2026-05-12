const USER_PROFILE_KEY = 'userProfile';

export const storageUser = {
  
  getUserProfile: (): any | null => { 
    const profile = localStorage.getItem(USER_PROFILE_KEY);
    return profile ? JSON.parse(profile) : null;
  },
  setUserProfile: (profile: any): void => { 
    localStorage.setItem(USER_PROFILE_KEY, JSON.stringify(profile));
  },
  removeUserProfile: (): void => {
    localStorage.removeItem(USER_PROFILE_KEY);
  },
};