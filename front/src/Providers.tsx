import { PopupContext } from './contexts'
import UserProfileContext from './contexts/UserProfile'

const Providers: React.FC = ({ children }) => {
  return (
    <>
      <UserProfileContext>
        <PopupContext>{children}</PopupContext>
      </UserProfileContext>
    </>
  )
}

export default Providers
