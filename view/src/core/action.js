/**
 * actions
 *
 * @flow
 */

import * as ActionType from './type'
import type { Data } from './model'
import type {
  Action_IconAnimated,
  Action_DataAnimated,
  Action_SetData,
  Action_SetError
} from './type'

export function animated(tg: string, stat: boolean): Action_IconAnimated | Action_DataAnimated {
  const str = `${tg.toUpperCase()}_ANIMATED`

  switch(str) {
    case ActionType.ICON_ANIMATED:
      return {
        type: ActionType.ICON_ANIMATED,
        payload: stat
      }

    case ActionType.DATA_ANIMATED:
      return {
        type: ActionType.DATA_ANIMATED,
        payload: stat
      }

    default:
      throw new Error(`Unknow action type target, ${tg}`)
  }
}

export function set_data(data: Data): Action_SetData {
  return {
    type: ActionType.SET_DATA,
    payload: data
  }
}

export function set_error(err: string): Action_SetError {
  return {
    type: ActionType.SET_ERROR,
    payload: err
  }
}
