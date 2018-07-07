/**
 * <App /> view
 *
 * @flow
 */

import * as React from 'react'
import { connect } from 'react-redux'
import style from './style.css'
import Avatar from '../../avatar.png'
import * as action from '../../core/action'
import type { Data } from '../../core/model'
import delay from '../../util/delay'
import Msg from '../msg'
import Ring from '../ring'
import Circle from '../circle'
import Field from '../field'
import lang from '../../lang'

type Props = {
  padding: boolean,
  data: ?Data,
  error: ?string,
  typ: string,
  icon_anime: boolean,
  data_anime: boolean,
  icon_animed: boolean => void,
  data_animed: boolean => void,
  set_data: Data => void,
  set_error: string => void
}

export class App extends React.PureComponent<Props> {
  componentDidMount() {
    const {
      icon_animed,
      data_animed,
      set_data,
      set_error
    } = this.props

    const animate = this.animate.bind(this)

    Promise.resolve()
      .then(() => delay(() => icon_animed(true)))
      .then(() => {
        return fetch(window.env.OAUTH2_URL)
          .then(res => {
            /**
             * handle 4XX or 5XX
             */
            const { ok, status } = res

            if(!ok) {
              return res.text().then(animate(
                set_error,
                () => lang.runtime_error
              ))
            }

            return res.json().then(animate(set_data))
              .then(data => {
                /**
                 * show details 1.5s, then close window or redirect
                 */
                return delay(() => {

                  /**
                   * write data to LocalStorage
                   */
                  const dataify = JSON.stringify(data)
                  const key = window.env.OAUTH2_STOREKEY

                  localStorage.setItem(
                    window.env.OAUTH2_STOREKEY,
                    dataify
                  )

                  /**
                   * handle mode
                   */
                  const mode = window.env.OAUTH2_MODE

                  /**
                   * if mode was 'popup', send message to origin
                   */
                  if('popup' === mode) {
                    const opener = window.opener
                    if(!opener) {
                      throw new Error(
                        `The window.opener was lost when mode was 'popup'`
                      )
                    }

                    opener.postMessage(
                      dataify,
                      window.origin
                    )

                    return data
                  }

                  /**
                   * if mode was 'redirect', redirect to 'from' argument,
                   * the origin need read data from LocalStorage
                   */
                  if('redirect' === mode) {
                    const from = window.env.OAUTH2_FROM

                    if(!from) {
                      throw new Error(`'from' was required, when mode was 'redirect'`)
                    }

                    location.href = from

                    return data
                  }

                }, 1500)
              })
              .catch(console.error)
          })
          .catch(animate(
            set_error,
            () => lang.client_error
          ))
      })
  }

  animate(func: Function, proc?: Function = a => a) {
    const { icon_animed, data_animed } = this.props

    return function animate(data: *): Promise<*> {

      icon_animed(false)

      return delay(() => {
        const da = proc(data)

        func(da)
        icon_animed(true)

        return da
      }, 300).then(data => {

        return delay(() => {
          data_animed(true)

          return data
        }, 1000)
      })
    }
  }

  render_load(): React.Node {
    const { typ, icon_anime } = this.props
    const Icon = require('../../icon/' + typ).default

    return (
      <>
        <Circle typ={typ} enter={icon_anime}>
          <Icon className={style.icon} />
        </Circle>
        <Ring typ={typ} enter={icon_anime} dir={'left'} />
        <Ring typ={typ} enter={icon_anime} dir={'right'} />
      </>
    )
  }

  render_data(): React.Node {
    const { data, typ, icon_anime, data_anime } = this.props

    if(!data) {
      throw new Error('data was undefined')
    }

    return (
      <>
        <Circle typ={typ} enter={icon_anime} slide={data_anime}>
          <img src={Avatar} className={style.avatar} />
        </Circle>

        <Field enter={data_anime}>
          <div className={style.id}>ID: {data.id}</div>
          <div className={style.name}>{data.name}</div>
        </Field>
      </>
    )
  }

  render_error(): React.Node {
    const { typ, error, icon_anime, data_anime } = this.props
    const Icon = require('../../icon/error').default

    return (
      <>
        <Circle typ={'error'} enter={icon_anime} slide={data_anime}>
          <Icon className={style.icon} />
        </Circle>

        <Field enter={data_anime}>
          <div className={style.id}>{error}</div>
        </Field>
      </>
    )
  }

  render() {
    const { padding, data, error } = this.props

    const [ child_view, desc ] = padding
          ? [ this.render_load(), lang.request + ' . . .' ]
          : error
            ? [ this.render_error(), lang.failure ]
            : [ this.render_data(), lang.success ]

    return (
      <div className={style.main}>
        <div className={style.top}>
          {child_view}
        </div>

        <Msg>
          {desc}
        </Msg>
      </div>
    )
  }
}

function mapto_prop(state) {
  return {
    padding: state.padding,
    data: state.data,
    error: state.error,
    typ: window.env.OAUTH2_TYPE,
    icon_anime: state.icon_anime,
    data_anime: state.data_anime
  }
}

function mapto_dispatch(dispatch: Function) {
  return {
    icon_animed: stat => dispatch(action.animated('icon', stat)),
    data_animed: stat => dispatch(action.animated('data', stat)),
    set_data: data => dispatch(action.set_data(data)),
    set_error: error => dispatch(action.set_error(error))
  }
}


export default connect(mapto_prop, mapto_dispatch)(App)
