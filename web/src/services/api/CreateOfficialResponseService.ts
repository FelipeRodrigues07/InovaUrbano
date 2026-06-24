import { api } from '@/services/api/api';

interface CreateOfficialResponsePayload {
  title: string;
  description: string;
  status: string;
  number: string;
  ibgeId?: number;
  file?: File | null;
}

export const createOfficialResponseService = async (data: CreateOfficialResponsePayload) => {
  const formData = new FormData();

  formData.append('title', data.title);
  formData.append('description', data.description);
  formData.append('status', data.status);
  formData.append('number', data.number);

  if (data.ibgeId != null && data.ibgeId > 0) {
    formData.append('ibgeId', String(data.ibgeId));
  }

  if (data.file) {
    formData.append('File', data.file);
  }

  const response = await api.post('/official-responses', formData);

  return response.data;
};
