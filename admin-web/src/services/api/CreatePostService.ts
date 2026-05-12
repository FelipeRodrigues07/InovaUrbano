import { api } from '@/services/api/api';

interface CreatePostPayload {
  title: string;
  description: string;
  status: string;
  number: string;
  file?: File | null;
}

export const createPostService = async (data: CreatePostPayload) => {
  const formData = new FormData();

  formData.append('title', data.title);
  formData.append('description', data.description);
  formData.append('status', data.status);
  formData.append('number', data.number);

  if (data.file) {
    formData.append('File', data.file);
  }

  console.log("2. CONTEÚDO DO FORMDATA SENDO ENVIADO:");
  formData.forEach((value, key) => {
    console.log(`${key}:`, value);
  });


  const response = await api.post('/createPost', formData);

  return response.data;
};