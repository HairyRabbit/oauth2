/**
 * action and types
 *
 * @flow
 */

import type { Data } from './model'


/**
 * action types
 */

export const ICON_ANIMATED: 'ICON_ANIMATED' = 'ICON_ANIMATED'
export const DATA_ANIMATED: 'DATA_ANIMATED' = 'DATA_ANIMATED'
export const SET_DATA: 'SET_DATA' = 'SET_DATA'
export const SET_ERROR: 'SET_ERROR' = 'SET_ERROR'


/**
 * actions
 */

export type Action_IconAnimated = {
  type: typeof ICON_ANIMATED,
  payload: boolean
}

export type Action_DataAnimated = {
  type: typeof DATA_ANIMATED,
  payload: boolean
}

export type Action_SetData = {
  type: typeof SET_DATA,
  payload: Data
}

export type Action_SetError = {
  type: typeof SET_ERROR,
  payload: string
}

export type Action =
  | Action_IconAnimated
  | Action_DataAnimated
  | Action_SetData
  | Action_SetError
