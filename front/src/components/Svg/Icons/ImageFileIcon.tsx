import React from 'react'
import Svg from '../Svg'
import { SvgProps } from '../types'

const Icon: React.FC<SvgProps> = props => (
  <Svg viewBox='0 0 83 71' {...props} fill='none'>
    <path
      d='M41.498 70.92c-11.678 0-23.36.005-35.039 0-4.279 0-6.288-2-6.292-6.262 0-19.443 0-38.886.004-58.33C.17 2.071 2.184.07 6.459.07 29.816.066 53.177.066 76.538.07c4.275 0 6.292 2.005 6.292 6.259.004 19.443.004 38.886 0 58.329 0 4.257-2.013 6.263-6.288 6.263-11.683.004-23.36 0-35.044 0ZM76.92 56.244c0-16.192.016-31.843-.021-47.494-.005-2.148-1.007-2.819-3.73-2.819-21.108-.004-42.22-.004-63.329 0-3.079 0-3.792.726-3.792 3.83-.004 14.678 0 29.36 0 44.037v2.245c.776-.819 1.258-1.276 1.678-1.783 7.047-8.499 14.086-16.998 21.12-25.505 2.22-2.68 4.716-2.836 7.09-.34a532.195 532.195 0 0 1 7.84 8.453c4.094 4.484 4.392 4.51 9.061.495 3.146-2.706 4.111-2.618 6.917.424 5.592 6.04 11.209 12.056 17.166 18.457Z'
      fill={props.fill}
    />
    <path
      d='M62.137 29.492c-5.084-.012-8.767-3.78-8.738-8.926.03-4.85 4.01-8.734 8.876-8.667 4.8.067 8.78 4.128 8.73 8.91-.042 4.858-3.964 8.692-8.868 8.683Z'
      fill={props.fill}
    />
  </Svg>
)

export default Icon

Icon.defaultProps = {
  fill: 'white',
}