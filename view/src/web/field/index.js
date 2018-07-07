/**
 * <Field /> view
 *
 * @flow
 */

import * as React from 'react'
import style from './style.css'

type Props = {
  enter: boolean,
  children: React.Node
}

export default function Field(props: Props): React.Node {
  const { enter, children } = props

  const cs = [
    style.main,
    style.anime,
    style.init,
    enter && style.enter
  ].filter(Boolean).join(' ')

  return (
    <div className={cs}>
      {children}
    </div>
  )
}
