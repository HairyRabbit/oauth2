/**
 * <Ring /> view
 *
 * @flow
 */

import * as React from 'react'
import style from './style.css'

type Props = {
  enter: boolean,
  dir: 'left' | 'right',
  typ: string
}

export default function Ring(props: Props): React.Node {
  const { enter, dir, typ } = props

  const cs = [
    style.main,
    style[dir],
    style[typ],
    style.anime,
    style.init,
    enter && style.enter
  ].filter(Boolean).join(' ')

  return (
    <div className={cs}></div>
  )
}
