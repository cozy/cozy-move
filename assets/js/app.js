// We need to import the CSS so that webpack will load it.
// The MiniCssExtractPlugin is used to separate it out into
// its own CSS file.
import "../css/app.css"

import React from 'react'
import { render } from 'react-dom'
import Warning from './Warning.jsx'

(function(w, d) {
  const warning = d.getElementById("react-warning")
  if (warning) {
    const app = <Warning button={warning.innerText} />
    render(app, warning.parentElement)
  }
})(window, document)
