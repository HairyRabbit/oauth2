/**
 * update state
 *
 * @flow
 */

import init, { type Model } from './model'
import * as ActionType from './type'
import type { Action } from './type'

export default function update(model: Model = init, action: Action): Model {
  switch(action.type) {
    case ActionType.ICON_ANIMATED:
      return {
        ...model,
        icon_anime: action.payload
      }

    case ActionType.DATA_ANIMATED:
      return {
        ...model,
        data_anime: action.payload
      }

    case ActionType.SET_DATA:
      return {
        ...model,
        padding: false,
        data: action.payload
      }

    case ActionType.SET_ERROR:
      return {
        ...model,
        padding: false,
        error: action.payload
      }

    default:
      return model
  }
}
