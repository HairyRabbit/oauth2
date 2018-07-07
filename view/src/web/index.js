/**
 * Main
 *
 * @flow
 */

import * as React from 'react'
import { Provider } from 'react-redux'
import store from '../core/store'
import App from './app'
import './global.css'

export type IconProps = {
  className: string
}

export default function Root() {
  return (
    <Provider store={store}>
      <App />
    </Provider>
  )
}
