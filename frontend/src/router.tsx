import { RouteObject } from "react-router-dom";
import Swap from "./views/Swap";
import Token from "./views/Token";
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
                path: 'token',
                element: <Token />,
            }
        ],
    },
];

export default routes;