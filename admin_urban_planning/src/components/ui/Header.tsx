import { useAuth } from '@/contexts/AuthContext'; 
const Header: React.FC = () => {
  const { userProfile } = useAuth();

  const defaultProfilePicture = 'https://placehold.co/32x32/cccccc/ffffff?text=User';

  const getFirstName = (fullName: string | undefined) => {
    if (!fullName) return '';
    return fullName.split(' ')[0];
  };

  return (
    <header className="h-16 w-full bg-white flex items-center fixed top-0 justify-between px-6 shadow-md rounded-b-lg z-50">
      <div className="flex items-center">
        <span className="text-primary text-xl font-semibold font-sans">InovaUrbano</span>
      </div>

      <div className="flex items-center space-x-2">
        
       <img
          src={userProfile?.profilePictureUrl || defaultProfilePicture}
          alt={userProfile ? `Foto de perfil de ${userProfile.name}` : 'Foto de perfil do usuário'}
          className="h-8 w-8 rounded-full object-cover" 
          onError={(e) => {
            if (e.currentTarget.src !== defaultProfilePicture) {
              e.currentTarget.src = defaultProfilePicture; 
            }
            e.currentTarget.onerror = null; 
          }}
        />
        {userProfile && (
          <>
            <span className="hidden md:inline text-gray-700 text-base font-medium font-sans">
              {userProfile.name}
            </span>
            <span className="md:hidden text-gray-700 text-base font-medium font-sans">
              {getFirstName(userProfile.name)}
            </span>
          </>
        )}
      </div>
    </header>
  );
};

export default Header;