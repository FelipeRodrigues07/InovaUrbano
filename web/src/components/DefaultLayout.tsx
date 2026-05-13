import React from 'react';
import { Outlet } from 'react-router-dom';
import Sidebar from './ui/Sidebar';
import Header from './ui/Header';


const DefaultLayout: React.FC = () => {
    return (
        <div className="flex">
            <Header />
            <Sidebar />
            <main className="ml-48 max-md:ml-12 mt-16 w-full">
                <Outlet />
            </main>
        </div>
    );
};

export default DefaultLayout;