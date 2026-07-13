import React from 'react';

const LAST_UPDATED = '13 de julho de 2026';

const PrivacyPolicyPage: React.FC = () => {
  return (
    <div className="min-h-screen bg-slate-50 px-4 py-10">
      <div className="bg-white p-8 rounded-lg shadow-md w-full max-w-3xl mx-auto">
        <h1 className="text-center text-3xl font-semibold mb-2 text-primary">
          Inova Urbano
        </h1>
        <h2 className="text-center text-xl font-medium mb-6 text-slate-800">
          Política de Privacidade
        </h2>

        <div className="space-y-6 text-sm text-slate-700 leading-relaxed">
          <p className="text-slate-500">Última atualização: {LAST_UPDATED}</p>

          <p>
            Esta Política de Privacidade descreve como o <strong>Inova Urbano</strong>{' '}
            ("nós", "aplicativo") coleta, usa e protege as informações dos
            usuários do aplicativo móvel e do painel web administrativo.
          </p>

          <section>
            <h3 className="font-semibold text-slate-900 mb-2">1. Dados que coletamos</h3>
            <ul className="list-disc pl-5 space-y-1">
              <li>
                <strong>Dados de cadastro:</strong> nome, e-mail e senha
                (armazenada de forma criptografada).
              </li>
              <li>
                <strong>Foto de perfil:</strong> imagem enviada opcionalmente pelo
                usuário, armazenada em serviço de nuvem (Cloudinary).
              </li>
              <li>
                <strong>Localização (GPS):</strong> coordenadas de latitude e
                longitude usadas para registrar onde um problema urbano foi
                relatado. Só é coletada quando o usuário cria um relato.
              </li>
              <li>
                <strong>Fotos dos relatos:</strong> imagens anexadas às sugestões
                enviadas pelo usuário, usadas como evidência do problema
                relatado.
              </li>
              <li>
                <strong>Conteúdo enviado:</strong> descrições, comentários e
                respostas publicadas no aplicativo ou no painel.
              </li>
            </ul>
          </section>

          <section>
            <h3 className="font-semibold text-slate-900 mb-2">2. Como usamos os dados</h3>
            <ul className="list-disc pl-5 space-y-1">
              <li>Autenticar o usuário e manter sua conta segura.</li>
              <li>
                Exibir relatos no mapa público de ocorrências, permitindo que
                a prefeitura e outros cidadãos acompanhem o status de
                resolução.
              </li>
              <li>
                Permitir que gestores municipais analisem dados agregados para
                tomada de decisão (sem exposição de dados pessoais sensíveis).
              </li>
              <li>Notificar o usuário sobre respostas oficiais aos seus relatos.</li>
            </ul>
          </section>

          <section>
            <h3 className="font-semibold text-slate-900 mb-2">3. Compartilhamento de dados</h3>
            <p>
              Não vendemos dados pessoais. Utilizamos os seguintes serviços de
              terceiros para operar o aplicativo:
            </p>
            <ul className="list-disc pl-5 space-y-1 mt-1">
              <li>
                <strong>Cloudinary:</strong> armazenamento das imagens
                enviadas (foto de perfil e fotos dos relatos).
              </li>
              <li>
                <strong>Render:</strong> hospedagem da API e do banco de
                dados.
              </li>
            </ul>
            <p className="mt-1">
              Relatos exibidos publicamente no mapa não identificam o autor:
              nome e demais dados pessoais não são exibidos junto ao relato.
            </p>
          </section>

          <section>
            <h3 className="font-semibold text-slate-900 mb-2">4. Exclusão de conta e dados</h3>
            <p>
              O usuário pode excluir sua conta a qualquer momento pelo
              aplicativo (Perfil &gt; Excluir conta) ou pela página{' '}
              <a href="/excluir-conta" className="text-primary underline">
                /excluir-conta
              </a>
              . Ao excluir a conta, removemos nome, e-mail, senha e foto de
              perfil. Relatos já publicados permanecem visíveis no mapa
              público de forma anônima, sem qualquer identificação do autor.
            </p>
          </section>

          <section>
            <h3 className="font-semibold text-slate-900 mb-2">5. Permissões do aplicativo</h3>
            <ul className="list-disc pl-5 space-y-1">
              <li>
                <strong>Câmera e galeria:</strong> usadas apenas para anexar
                fotos aos relatos ou à foto de perfil, por escolha do
                usuário.
              </li>
              <li>
                <strong>Localização:</strong> usada apenas para preencher a
                coordenada de um relato no momento em que ele é criado. Não
                monitoramos a localização em segundo plano.
              </li>
            </ul>
          </section>

          <section>
            <h3 className="font-semibold text-slate-900 mb-2">6. Segurança</h3>
            <p>
              Senhas são armazenadas com hash e nunca em texto puro. O acesso
              à API é protegido por autenticação baseada em token (JWT).
            </p>
          </section>

          <section>
            <h3 className="font-semibold text-slate-900 mb-2">7. Contato</h3>
            <p>
              Dúvidas sobre esta política ou solicitações relacionadas aos
              seus dados podem ser enviadas para{' '}
              <a href="mailto:feliperodrigues07rs@gmail.com" className="text-primary underline">
                feliperodrigues07rs@gmail.com
              </a>
              .
            </p>
          </section>
        </div>
      </div>
    </div>
  );
};

export default PrivacyPolicyPage;
