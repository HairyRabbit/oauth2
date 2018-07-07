/**
 * configure store
 *
 * @flow
 */

import { createStore, applyMiddleware } from 'redux'
import thunkMiddleware from 'redux-thunk'
import { createLogger } from 'redux-logger'
import reducer from './update'
import init from './model'

const enhancer = applyMiddleware(
  thunkMiddleware,
  createLogger()
)

export default createStore(reducer, init, enhancer)
