import React, { useState } from "react"
import useBreakpoints from "cozy-ui/transpiled/react/hooks/useBreakpoints"

import Label from "cozy-ui/transpiled/react/Label"
import {
  WizardSelect,
  WizardDualField,
  WizardDualFieldWrapper,
  WizardDualFieldInput,
} from "cozy-ui/transpiled/react/Wizard"

const cozyDomain = ".mycozy.cloud"
const inputID = "cozy-url"

const Address = ({ label, other }) => {
  const { isTiny } = useBreakpoints()
  const [state, setState] = useState({
    isCustomDomain: false,
    hasFocus: true,
  })

  return (
    <>
      <Label htmlFor={inputID}>{label}</Label>
      <WizardDualField hasFocus={state.hasFocus}>
        <WizardDualFieldWrapper>
          <WizardDualFieldInput
            type="text"
            id={inputID}
            name="url"
            autoCapitalize="none"
            autoCorrect="off"
            autoComplete="off"
            autoFocus
            placeholder={"claude"}
            size={isTiny ? "medium" : undefined}
            onFocus={() => setState({ hasFocus: true })}
            onBlur={() => setState({ hasFocus: false })}
          />
        </WizardDualFieldWrapper>
        <WizardSelect
          name="domain"
          narrow={state.isCustomDomain}
          medium={isTiny}
          onChange={({ target }) => {
            setState({ isCustomDomain: target.value === "" })
          }}
        >
          <option value={cozyDomain}>{cozyDomain}</option>
          <option value="">{other}</option>
        </WizardSelect>
      </WizardDualField>
    </>
  )
}

export default Address
