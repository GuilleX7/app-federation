import { useState } from 'react';

const App = () => {
  const [counter, setCounter] = useState(0);

  return (
    <div>
      <h1>Hello from Child 2 + React!</h1>
      <p>Counter: {counter}</p>
      <button onClick={() => setCounter((oldCounter) => oldCounter + 1)}>
        Increment counter
      </button>
    </div>
  );
};

export default App;
