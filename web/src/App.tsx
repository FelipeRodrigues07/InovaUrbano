import './App.css'
import { AuthProvider } from './contexts/AuthContext'
import { CityProvider } from './contexts/CityContext'
import { AppRoutes } from './routes'

function App() {

  return (
    <>
     <AuthProvider>
       <CityProvider>
        <div className="App">
          <AppRoutes />
        </div>
       </CityProvider>
      </AuthProvider>
    </>
  )
}

export default App
