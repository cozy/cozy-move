import React, { useState } from 'react'
import { ConfirmDialog } from  'cozy-ui/transpiled/react/CozyDialogs'
import Button from 'cozy-ui/transpiled/react/Button'

const Warning = ({button}) => {
  const [state, setState] = useState({ opened: false })
  const toggle = () => setState(state => ({...state, opened: !state.opened}))

  const ConfirmDialogActions = () => {
    return (
      <>
        <Button theme="secondary" onClick={toggle} label={'Close Modal'} />
        <Button theme="danger" label='Do something destructive' onClick={() => alert('click')} />
      </>
    )
  }

  return <>
    <button className="c-btn" onClick={toggle}>
      <span>{button}</span>
    </button>
      <ConfirmDialog
        size={'medium'}
        open={state.opened}
        onClose={toggle}
        title={"Title"}
        content={"Content"}
        actions=<ConfirmDialogActions />
        actionsLayout={'column'}
      />
  </>
}

export default Warning
