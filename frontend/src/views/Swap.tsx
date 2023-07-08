import { Box, Input } from "@chakra-ui/react";
import { FiSettings } from 'react-icons/fi';

const Swap = () => {
    return (
      <div className="flex justify-center items-center">
        <Box className="w-[36rem] flex flex-col justify-start items-start px-8 bg-[#0E111B] border-[#21273a] border-2 border-solid rounded-2xl">
          <div className="container flex justify-between items-center pt-6 pb-6">
            <div className="text-white font-semibold text-xl">Swap</div>
            <div></div>
            <div><FiSettings size={22} className="cursor-pointer"/></div>
          </div>
          <div>
            <Input placeholder='0' size='lg'/>
            <Input placeholder='0' size='lg' />
          </div>
        </Box>
      </div>
    );
  };
  
  export default Swap;