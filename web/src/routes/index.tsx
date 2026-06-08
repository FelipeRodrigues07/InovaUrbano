import React from 'react';
import { BrowserRouter, Routes, Route } from 'react-router-dom';
import { Navigate } from 'react-router-dom';
import { NotFoundPage } from '@/pages/NotFoundPage';
import DefaultLayout from '@/components/DefaultLayout';
import SignIn from '@/pages/Auth/SignIn';

import ProtectedRoute from '@/routes/ProtectedRoutes';
import ViewSuggestions from '@/pages/App/ViewSuggestions';
import ViewPostings from '@/pages/App/ViewPosting';
import PostingArea from '@/pages/App/PostingArea';
import SuggestionsMapPage from '@/pages/App/Dashboard';
import Analytics from '@/pages/App/Analytics';
import Profile from '@/pages/App/Profile';


export const AppRoutes: React.FC = () => {

  return (
    <BrowserRouter>
      <Routes>
        <Route path="/login" element={<SignIn />} />
        <Route path="*" element={<NotFoundPage />} />
        <Route element={<ProtectedRoute/>}>
          <Route element={<DefaultLayout />}>
            <Route path="/" element={<Navigate to="/dashboard" replace />} />
            <Route path="/dashboard" element={<SuggestionsMapPage />} />
            <Route path="/analytics" element={<Analytics />} />
            <Route path="/view-suggestions" element={<ViewSuggestions />} />
            <Route path="/view-postings" element={<ViewPostings />} />
            <Route path="/profile" element={<Profile />} />
            <Route path="/posting-area" element={<PostingArea />} />
          </Route>
        </Route>
      </Routes>
    </BrowserRouter>
  );
};
