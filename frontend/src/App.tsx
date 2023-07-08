import React from 'react';
import './App.css';
import { Box, ChakraProvider } from '@chakra-ui/react'
import { Suspense } from 'react';
import { useRoutes } from 'react-router-dom';
import routes from './router';

function App() {
  const elements = useRoutes(routes);

  return (
    <ChakraProvider>
      <Box className="App" h='100vh' bgGradient={"linear-gradient(180deg, rgba(25, 33, 52, 1) 28%,rgba(7, 8, 21, 1) 75%)"}>
        <Suspense>{elements}</Suspense>
      </Box>
    </ChakraProvider>
  );
}

export default App;
