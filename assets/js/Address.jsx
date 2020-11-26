import React, { useState } from "react"
import useBreakpoints from "cozy-ui/transpiled/react/hooks/useBreakpoints"

import Label from "cozy-ui/transpiled/react/Label"
import {
  WizardSelect,
  WizardDualField,
  WizardDualFieldWrapper,
  WizardDualFieldInput,
} from "cozy-ui/transpiled/react/Wizard"

const customDomain = "custom"
const cozyDomain = ".mycozy.cloud"
const inputID = "cozy-url"

const Address = ({ label }) => {
  const { isTiny } = useBreakpoints()
  const [state, setState] = useState({
    value: "",
    domain: cozyDomain,
    hasFocus: true,
  })
  const isCustomDomain = state.domain === customDomain

  return (
    <>
      <Label htmlFor={inputID}>{label}</Label>
      <WizardDualField hasFocus={state.hasFocus}>
        <WizardDualFieldWrapper>
          <WizardDualFieldInput
            type="text"
            id={inputID}
            autoCapitalize="none"
            autoCorrect="off"
            autoComplete="off"
            autoFocus
            placeholder={"claude"}
            size={isTiny ? "medium" : undefined}
            onChange={({ target }) => {
              setState({ value: target.value })
            }}
            onFocus={() => setState({ hasFocus: true })}
            onBlur={() => setState({ hasFocus: false })}
            value={state.value}
          />
        </WizardDualFieldWrapper>
        <WizardSelect
          narrow={isCustomDomain}
          medium={isTiny}
          value={state.domain}
          onChange={({ target }) => {
            setState({ domain: target.value })
          }}
        >
          <option value={cozyDomain}>{cozyDomain}</option>
          <option value={customDomain}>other TODO i18n</option>
        </WizardSelect>
      </WizardDualField>
    </>
  )
}

export default Address
