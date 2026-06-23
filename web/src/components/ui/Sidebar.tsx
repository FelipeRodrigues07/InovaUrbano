import {
  BsHouse,
  BsPerson,
  BsPencilSquare,
  BsFiles,
  BsBoxArrowRight,
  BsChatText,
  BsBarChartLine,
} from 'react-icons/bs';
import { useAuth } from '@/contexts/AuthContext';
import { useNavigate } from 'react-router-dom';
import { Link } from 'react-router-dom';



const Sidebar: React.FC = () => {

  const { signOut } = useAuth();
  const navigate = useNavigate();

  const handleLogout = async (e: React.MouseEvent) => {
    e.preventDefault();
    try {
      await signOut();
      console.log('Logout bem-sucedido!');
      navigate('/login');
    } catch (error) {
      console.error('Erro ao fazer logout:', error);
    }
  };

  return (
    <aside className="bg-primary fixed top-0 flex flex-col items-start w-48 h-full pt-0 pr-0 transition-all delay-400 max-md:w-12 z-40">
      <nav className="flex flex-1 w-full flex-col text-db-300 mt-16">
        <div className="flex-grow">
          <Link to="/dashboard">
            <span className="inline-flex items-center gap-4 mt-2 h-12 pl-4 py-0 text-white rounded-r-full w-full hover:bg-indigo-50 hover:text-black transition-all ease-in-out delay-100 duration-200">
              <BsHouse className="relative text-lg" />
              <span className="max-md:opacity-0 max-md:hidden"> Dashboard </span>
            </span>
          </Link>

          <Link to="/view-suggestions">
            <span className="inline-flex items-center gap-4 pl-4 h-12 py-0 rounded-r-full text-white w-full hover:bg-indigo-50 hover:text-black transition-all ease-in-out delay-100 duration-200">
              <BsChatText className="relative text-lg" />
              <span className="max-md:opacity-0 max-md:hidden">Ver solicitações</span>
            </span>
          </Link>

          <Link to="/official-responses/publish">
            <span className="inline-flex items-center gap-4 pl-4 h-12 py-0 rounded-r-full text-white w-full hover:bg-indigo-50 hover:text-black  transition-all ease-in-out delay-100 duration-200">
              <BsPencilSquare className="relative text-lg" />
              <span className="max-md:opacity-0 max-md:hidden">Publicar resposta</span>
            </span>
          </Link>

          <Link to="/official-responses">
            <span className="inline-flex items-center gap-4 pl-4 h-12 py-0 rounded-r-full w-full text-white hover:bg-indigo-50 hover:text-black  transition-all ease-in-out delay-100 duration-200">
              <BsFiles className="relative text-lg" />
              <span className="max-md:opacity-0 max-md:hidden">Ver respostas oficiais</span>
            </span>
          </Link>

          <Link to="/analytics">
            <span className="inline-flex items-center gap-4 pl-4 h-12 py-0 rounded-r-full text-white w-full hover:bg-indigo-50 hover:text-black transition-all ease-in-out delay-100 duration-200">
              <BsBarChartLine className="relative text-lg" />
              <span className="max-md:opacity-0 max-md:hidden">Análise</span>
            </span>
          </Link>

          <Link to="/profile">
            <span className="inline-flex items-center gap-4 pl-4 h-12 py-0 rounded-r-full w-full text-white hover:bg-indigo-50 hover:text-black  transition-all ease-in-out delay-100 duration-200">
              <BsPerson className="relative text-lg" />
              <span className="max-md:opacity-0 max-md:hidden">Perfil </span>
            </span>
          </Link>
        </div>

        <a onClick={handleLogout} className="mt-auto mb-2">
          <span className="inline-flex items-center gap-4 pl-4 h-12 py-0 rounded-r-full w-full text-white hover:bg-indigo-50 hover:text-black  transition-all ease-in-out delay-100 duration-200">
            <BsBoxArrowRight className="relative text-lg" />
            <span className="max-md:opacity-0 max-md:hidden">Sair</span>
          </span>
        </a>
      </nav>
    </aside>
  );
};

export default Sidebar;