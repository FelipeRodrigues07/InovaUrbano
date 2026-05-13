import './App.css'
import { AuthProvider } from './contexts/AuthContext'
import { AppRoutes } from './routes'

function App() {

  return (
    <>
     <AuthProvider>
        <div className="App">
          <AppRoutes />
        </div>
      </AuthProvider>
    </>
  )
}

export default App
