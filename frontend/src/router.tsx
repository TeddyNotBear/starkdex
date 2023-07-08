import { RouteObject } from "react-router-dom";
import Swap from "./views/Swap";
import Tokens from "./views/Tokens";
import Main from "./components/layouts/Main";


const routes: RouteObject[] = [
    {
        path: '/',
        element: <Main />,
        children: [
            {
                path: 'swap',
                element: <Swap />,
            },
            {
                path: 'tokens',
                element: <Tokens />,
            }
        ],
    },
];

export default routes;