/**
 * <Msg /> view
 *
 * @flow
 */

import * as React from 'react'
import style from './style.css'

type Props = {
  children: React.Node
}

export default function Msg(props: Props): React.Node {
  const { children } = props
  return (
    <div className={style.main}>
      {children}
    </div>
  )
}
