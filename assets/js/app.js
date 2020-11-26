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
    const props = { ...warning.dataset, button: warning.innerText }
    const app = <Warning {...props} />
    wrapReact(warning.parentElement, app)
  }

  const address = d.getElementById("react-address")
  if (address) {
    const label = address.querySelector("label").innerText
    const app = <Address label={label} />
    wrapReact(address, app)
  }
})(document)
