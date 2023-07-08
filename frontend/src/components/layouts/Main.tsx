import { FC, ReactNode } from 'react';
import { Outlet } from 'react-router-dom';

import Header from './Header';
import { Box } from '@chakra-ui/react';

interface MainProps {
  children?: ReactNode;
}

const Main: FC<MainProps> = () => {
  return (
    <div>
        <Header />
        <div>
            <Outlet />
        </div>
    </div>
  );
};

export default Main;