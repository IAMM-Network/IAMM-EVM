import React from 'react'
import Svg from '../Svg'
import { SvgProps } from '../types'

const Icon: React.FC<SvgProps> = props => (
  <Svg viewBox='0 0 36 36' {...props} fill='none'>
    <path
      d='M35.464 7.406c-1.252.555-2.598.93-4.012 1.1a7.005 7.005 0 0 0 3.072-3.868 13.95 13.95 0 0 1-4.437 1.695 6.99 6.99 0 0 0-11.907 6.375A19.844 19.844 0 0 1 3.777 5.406a6.984 6.984 0 0 0-.945 3.513 6.99 6.99 0 0 0 3.108 5.817 6.97 6.97 0 0 1-3.165-.874v.09a6.99 6.99 0 0 0 5.605 6.852 7.038 7.038 0 0 1-3.156.12 6.991 6.991 0 0 0 6.528 4.85 14.022 14.022 0 0 1-8.679 2.993c-.557 0-1.114-.032-1.668-.097a19.763 19.763 0 0 0 10.71 3.14c12.855 0 19.883-10.648 19.883-19.882 0-.3-.008-.603-.021-.903A14.206 14.206 0 0 0 35.46 7.41l.003-.004Z'
      fill={props.fill}
    />
  </Svg>
)

Icon.defaultProps = {
  fill: 'white',
}

export default Icon