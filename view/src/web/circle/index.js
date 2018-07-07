/**
 * <Circle /> view
 *
 * @flow
 */

import * as React from 'react'
import style from './style.css'

type Props = {
  enter: boolean,
  slide?: boolean,
  typ: string,
  children: React.Node
}

export default function Circle(props: Props): React.Node {
  const { enter, slide, typ, children } = props

  const cs = [
    style.main,
    style[typ],
    style.anime,
    style.init,
    enter && style.enter,
    slide && style.slide
  ].filter(Boolean).join(' ')

  return (
    <div className={cs}>
      {children}
    </div>
  )
}
