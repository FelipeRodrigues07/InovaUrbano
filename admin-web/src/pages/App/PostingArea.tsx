import React, { useState, useEffect } from 'react';
import { Select, SelectContent, SelectItem, SelectTrigger, SelectValue } from '@/components/ui/select';
import { createPostService } from '@/services/api/CreatePostService';
import { useLocation } from 'react-router-dom';

const PostingArea: React.FC = () => {
  const [selectedStatus, setSelectedStatus] = useState<string>('');
  const [numero, setNumero] = useState<string>('');
  const [titulo, setTitulo] = useState<string>('');
  const [descricao, setDescricao] = useState<string>('');
  const [imageFile, setImageFile] = useState<File | null>(null);
  const [isLoading, setIsLoading] = useState<boolean>(false);

  const location = useLocation();

  useEffect(() => {
    if (location.state && location.state.suggestionNumber) {
      setNumero(location.state.suggestionNumber.toString());
    }
  }, [location.state]);

  const statusOptions = [
    'Pendente',
    'Em análise',
    'Aprovada',
    'Em andamento',
    'Concluídas',
    'Rejeitada',
    'Todas'
  ];

  const handleSubmit = async () => {
    setIsLoading(true);

    try {
      await createPostService({
        title: titulo,
        description: descricao,
        status: selectedStatus,
        number: numero,
        file: imageFile,
      });

      alert('Sugestão enviada com sucesso!');

      setNumero('');
      setTitulo('');
      setDescricao('');
      setSelectedStatus('');
      setImageFile(null);
    } catch (error: any) {
      console.error("ERRO COMPLETO:", error);

      if (error.response) {
        console.error("STATUS:", error.response.status);
        console.error("DATA (BACKEND):", error.response.data);
        alert(`Erro do Servidor: ${JSON.stringify(error.response.data)}`);
      } else if (error.request) {
        console.error("REQUEST ERROR (SEM RESPOSTA):", error.request);
        alert("O servidor não respondeu. Verifique se o backend está rodando.");
      } else {
        console.error("ERRO DE CONFIGURAÇÃO:", error.message);
      }
    } finally {
      setIsLoading(false);
    }
  };

  return (
    <div className="flex items-center justify-center min-h-screen bg-gray-50 p-8">
      <div className="w-full max-w-2xl">
        <h1 className="text-2xl font-bold text-center mb-8 text-gray-800">
          Área de Postagem
        </h1>

        <div className="bg-white rounded-lg shadow-md p-8">
          <div className="flex flex-col items-center space-y-5">

            <div className="w-full max-w-xs">
              <input
                type="text"
                value={numero}
                onChange={(e) => setNumero(e.target.value)}
                placeholder="Número da Sugestão"
                className="w-full px-4 py-2 border border-gray-300 rounded-md"
              />
            </div>

            <div className="w-full max-w-sm">
              <Select value={selectedStatus} onValueChange={setSelectedStatus}>
                <SelectTrigger className="w-full !bg-white !text-gray-500">
                  <SelectValue placeholder="Status" />
                </SelectTrigger>
                <SelectContent className="bg-white">
                  {statusOptions.map((status) => (
                    <SelectItem key={status} value={status}>
                      {status}
                    </SelectItem>
                  ))}
                </SelectContent>
              </Select>
            </div>

            <div className="w-full max-w-sm">
              <input
                type="text"
                value={titulo}
                onChange={(e) => setTitulo(e.target.value)}
                placeholder="Título"
                className="w-full px-4 py-2 border border-gray-300 rounded-md"
              />
            </div>

            <div className="w-full max-w-sm">
              <textarea
                value={descricao}
                onChange={(e) => setDescricao(e.target.value)}
                placeholder="Descrição"
                rows={3}
                className="w-full px-4 py-2 border border-gray-300 rounded-md resize-none"
              />
            </div>

            <input
              type="file"
              accept="image/*"
              id="imageInput"
              hidden
              onChange={(e) => {
                if (e.target.files && e.target.files[0]) {
                  setImageFile(e.target.files[0]);
                }
              }}
            />

            <div className="w-full max-w-sm">
              <button
                onClick={() => document.getElementById('imageInput')?.click()}
                className="w-full px-4 py-2 border border-gray-400 text-gray-500 rounded-md hover:bg-gray-50"
              >
                Selecionar Imagem (opcional)
              </button>
            </div>

            {imageFile && (
              <div className="w-full max-w-sm flex justify-between items-center px-4 py-2 bg-gray-100 border rounded-md">
                <span className="text-sm text-gray-700">
                  {imageFile.name}
                </span>
                <button
                  onClick={() => setImageFile(null)}
                  className="text-red-500 text-sm"
                >
                  Remover
                </button>
              </div>
            )}

            <div className="w-full max-w-sm pt-2">
              <button
                onClick={handleSubmit}
                disabled={isLoading}
                className="w-full px-6 py-2 bg-blue-500 text-white rounded-md hover:bg-blue-600 disabled:opacity-50"
              >
                {isLoading ? 'Enviando...' : 'Enviar'}
              </button>
            </div>

          </div>
        </div>
      </div>
    </div>
  );
};

export default PostingArea;
