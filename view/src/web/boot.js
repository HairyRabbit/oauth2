/**
 * bootstrapper
 *
 * @flow
 */

import * as React from 'react'
import { render } from 'react-dom'
import initial from './initial'
import Root from './'

/**
 * assert mount node
 */
const mount = 'app'
const node = document.getElementById(mount)

if(!node) {
  throw new Error(
    `Mount node named ${mount} can't find`
  )
}

/**
 * render app
 */
initial().then(() => render(<Root />, node))
