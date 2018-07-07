/**
 * model
 *
 * @flow
 */

export type Data = {
  id: string,
  name: string,
  avatar: string
}

export type Model = {
  padding: boolean,
  data: ?Data,
  error: ?string,
  icon_anime: boolean,
  data_anime: boolean
}

const init: Model = {
  padding: true,
  data: null,
  error: null,
  icon_anime: false,
  data_anime: false
}

export default init
