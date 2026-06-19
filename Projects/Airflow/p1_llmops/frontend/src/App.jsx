import { useEffect, useState } from 'react'
import './App.css'

function App() {
  const [health, setHealth] = useState(null)
  const [error, setError] = useState(null)

  useEffect(() => {
    fetch('/api/health/')
      .then((res) => {
        if (!res.ok) throw new Error(`HTTP ${res.status}`)
        return res.json()
      })
      .then(setHealth)
      .catch((err) => setError(err.message))
  }, [])

  return (
    <main className="app">
      <h1>LLMOps</h1>
      <p>Django + React starter project</p>

      <section className="card">
        <h2>API health</h2>
        {health && (
          <pre>{JSON.stringify(health, null, 2)}</pre>
        )}
        {error && <p className="error">Backend not reachable: {error}</p>}
        {!health && !error && <p>Checking backend...</p>}
      </section>
    </main>
  )
}

export default App
