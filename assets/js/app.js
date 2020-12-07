// We need to import the CSS so that webpack will load it.
// The MiniCssExtractPlugin is used to separate it out into
// its own CSS file.
import "../css/app.css"

import React from "react"
import { render } from "react-dom"
import { BreakpointsProvider } from "cozy-ui/transpiled/react/hooks/useBreakpoints"
import MuiCozyTheme from "cozy-ui/transpiled/react/MuiCozyTheme"
import Address from "./Address.jsx"
import Warning from "./Warning.jsx"
;(function (d) {
  const wrapReact = (element, app) => {
    render(
      <BreakpointsProvider>
        <MuiCozyTheme>{app}</MuiCozyTheme>
      </BreakpointsProvider>,
      element
    )
  }

  const warning = d.getElementById("react-warning")
  if (warning) {
    const footer = warning.parentElement
    const props = { ...warning.dataset, button: warning.name }
    const app = <Warning form={footer.parentElement} {...props} />
    wrapReact(footer, app)
  }

  const address = d.getElementById("react-address")
  if (address) {
    const label = address.querySelector("label").innerText
    const other = address.dataset.other
    const app = <Address label={label} other={other} />
    wrapReact(address, app)
  }
})(document)
