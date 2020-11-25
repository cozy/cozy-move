import React, { useState } from 'react'

const Warning = ({button}) => {
  const [count, setCount] = useState(0)

  return <button className="c-btn" onClick={() => setCount(count + 1)}>
    <span>{button} {count}</span>
  </button>
}

export default Warning
