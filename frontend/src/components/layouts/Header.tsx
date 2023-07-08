import { Button } from '@chakra-ui/react';
import { Link as RouterLink } from 'react-router-dom';
// import Logo from '../../assets/logo/logo.png';

const Header = () => {
  return (
    <header>
      <div className="container mx-auto pt-8">
        <div className="flex justify-between items-center">
          <div className='flex items-center'>
            {/* <img src={Logo} alt="logo" className="w-12 h-12" /> */}
            <RouterLink className='no-underline font-semibold text-white pl-20 text-xl' to={"/swap"}>Swap</RouterLink>
            <RouterLink className='no-underline font-semibold text-white pl-20 text-xl' to={"/tokens"}>Tokens</RouterLink>
          </div>
          <div>
            <button className='rounded-full px-5 p-2.5 font-semibold text-[#5981F3] bg-[#243056] text-lg'>Connect</button>
          </div>
        </div>
      </div>
    </header>
  );
};

export default Header;