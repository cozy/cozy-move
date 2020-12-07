import React, { useState } from "react"
import ReactMarkdown from "react-markdown"
import snarkdown from "snarkdown"
import useBreakpoints from "cozy-ui/transpiled/react/hooks/useBreakpoints"
import { ConfirmDialog } from "cozy-ui/transpiled/react/CozyDialogs"
import Button from "cozy-ui/transpiled/react/Button"

const Markdown = ({ content }) => (
  <div dangerouslySetInnerHTML={{ __html: snarkdown(content) }}></div>
)

const Warning = ({ button, title, content, cancel, confirm, form }) => {
  const { isMobile } = useBreakpoints()
  const [state, setState] = useState({ opened: false })
  const submit = () => {
    form.submit()
  }
  const toggle = () =>
    setState((state) => ({ ...state, opened: !state.opened }))

  const Buttons = () => (
    <>
      <Button theme="secondary" onClick={toggle} label={cancel} />
      <Button theme="danger" label={confirm} onClick={submit} />
    </>
  )

  return (
    <>
      <button className="c-btn" onClick={toggle} type="button">
        <span>{button}</span>
      </button>
      <ConfirmDialog
        open={state.opened}
        opened={state.opened} // XXX required to a fix a React warning
        onClose={toggle}
        title={title}
        content=<Markdown content={content} />
        actions=<Buttons />
        actionsLayout={isMobile ? "column" : "row"}
      />
    </>
  )
}

export default Warning
