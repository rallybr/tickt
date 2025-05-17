-- Tabela de Estados
CREATE TABLE estados (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    nome VARCHAR(100) NOT NULL,
    sigla CHAR(2) NOT NULL,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT TIMEZONE('utc'::text, NOW()) NOT NULL
);

-- Inserir estados brasileiros
INSERT INTO estados (id, nome, sigla) VALUES
    (gen_random_uuid(), 'Acre', 'AC'),
    (gen_random_uuid(), 'Alagoas', 'AL'),
    (gen_random_uuid(), 'Amapá', 'AP'),
    (gen_random_uuid(), 'Amazonas', 'AM'),
    (gen_random_uuid(), 'Bahia', 'BA'),
    (gen_random_uuid(), 'Ceará', 'CE'),
    (gen_random_uuid(), 'Distrito Federal', 'DF'),
    (gen_random_uuid(), 'Espírito Santo', 'ES'),
    (gen_random_uuid(), 'Goiás', 'GO'),
    (gen_random_uuid(), 'Maranhão', 'MA'),
    (gen_random_uuid(), 'Mato Grosso', 'MT'),
    (gen_random_uuid(), 'Mato Grosso do Sul', 'MS'),
    (gen_random_uuid(), 'Minas Gerais', 'MG'),
    (gen_random_uuid(), 'Pará', 'PA'),
    (gen_random_uuid(), 'Paraíba', 'PB'),
    (gen_random_uuid(), 'Paraná', 'PR'),
    (gen_random_uuid(), 'Pernambuco', 'PE'),
    (gen_random_uuid(), 'Piauí', 'PI'),
    (gen_random_uuid(), 'Rio de Janeiro', 'RJ'),
    (gen_random_uuid(), 'Rio Grande do Norte', 'RN'),
    (gen_random_uuid(), 'Rio Grande do Sul', 'RS'),
    (gen_random_uuid(), 'Rondônia', 'RO'),
    (gen_random_uuid(), 'Roraima', 'RR'),
    (gen_random_uuid(), 'Santa Catarina', 'SC'),
    (gen_random_uuid(), 'São Paulo', 'SP'),
    (gen_random_uuid(), 'Sergipe', 'SE'),
    (gen_random_uuid(), 'Tocantins', 'TO');

-- Tabela de Blocos
CREATE TABLE blocos (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    nome VARCHAR(100) NOT NULL,
    estado_id UUID REFERENCES estados(id) ON DELETE CASCADE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT TIMEZONE('utc'::text, NOW()) NOT NULL
);

-- Tabela de Regiões
CREATE TABLE regioes (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    nome VARCHAR(100) NOT NULL,
    bloco_id UUID REFERENCES blocos(id) ON DELETE CASCADE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT TIMEZONE('utc'::text, NOW()) NOT NULL
);

-- Tabela de Igrejas
CREATE TABLE igrejas (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    nome VARCHAR(100) NOT NULL,
    regiao_id UUID REFERENCES regioes(id) ON DELETE CASCADE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT TIMEZONE('utc'::text, NOW()) NOT NULL
);

-- Tabela de Perfis de Usuário (relacionada com auth.users)
CREATE TABLE perfis (
    id UUID PRIMARY KEY REFERENCES auth.users(id) ON DELETE CASCADE,
    nome VARCHAR(100) NOT NULL,
    email VARCHAR(255) NOT NULL,
    whatsapp VARCHAR(20),
    foto_url TEXT,
    igreja_id UUID REFERENCES igrejas(id),
    created_at TIMESTAMP WITH TIME ZONE DEFAULT TIMEZONE('utc'::text, NOW()) NOT NULL,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT TIMEZONE('utc'::text, NOW()) NOT NULL
);

-- Tabela de Eventos
CREATE TABLE eventos (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    titulo VARCHAR(255) NOT NULL,
    banner_url TEXT,
    data_evento TIMESTAMP WITH TIME ZONE NOT NULL,
    horario_inicio TIME NOT NULL,
    horario_fim TIME NOT NULL,
    local VARCHAR(255) NOT NULL,
    igreja_id UUID REFERENCES igrejas(id) ON DELETE CASCADE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT TIMEZONE('utc'::text, NOW()) NOT NULL,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT TIMEZONE('utc'::text, NOW()) NOT NULL
);

-- Tabela de Ingressos
CREATE TABLE ingressos (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    evento_id UUID REFERENCES eventos(id) ON DELETE CASCADE,
    usuario_id UUID REFERENCES auth.users(id) ON DELETE CASCADE,
    hash_unico VARCHAR(255) UNIQUE NOT NULL,
    numero_ingresso VARCHAR(50) NOT NULL,
    status VARCHAR(20) DEFAULT 'pendente' CHECK (status IN ('pendente', 'validado', 'cancelado')),
    created_at TIMESTAMP WITH TIME ZONE DEFAULT TIMEZONE('utc'::text, NOW()) NOT NULL
);

-- Tabela de Leituras de QR Code
CREATE TABLE leituras_qr (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    ingresso_id UUID REFERENCES ingressos(id) ON DELETE CASCADE,
    usuario_id UUID REFERENCES auth.users(id) ON DELETE CASCADE,
    data_leitura TIMESTAMP WITH TIME ZONE DEFAULT TIMEZONE('utc'::text, NOW()) NOT NULL,
    status VARCHAR(20) DEFAULT 'valido' CHECK (status IN ('valido', 'invalido', 'duplicado'))
);

-- Função para atualizar o updated_at
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = TIMEZONE('utc'::text, NOW());
    RETURN NEW;
END;
$$ language 'plpgsql';

-- Triggers para atualizar o updated_at
CREATE TRIGGER update_perfis_updated_at
    BEFORE UPDATE ON perfis
    FOR EACH ROW
    EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_eventos_updated_at
    BEFORE UPDATE ON eventos
    FOR EACH ROW
    EXECUTE FUNCTION update_updated_at_column();

-- Políticas de Segurança (RLS)
ALTER TABLE perfis ENABLE ROW LEVEL SECURITY;
ALTER TABLE eventos ENABLE ROW LEVEL SECURITY;
ALTER TABLE ingressos ENABLE ROW LEVEL SECURITY;
ALTER TABLE leituras_qr ENABLE ROW LEVEL SECURITY;
ALTER TABLE estados ENABLE ROW LEVEL SECURITY;

-- Políticas para perfis
CREATE POLICY "Usuários podem ver seus próprios perfis"
    ON perfis FOR SELECT
    USING (auth.uid() = id);

CREATE POLICY "Usuários podem atualizar seus próprios perfis"
    ON perfis FOR UPDATE
    USING (auth.uid() = id);

-- Políticas para eventos
CREATE POLICY "Qualquer um pode ver eventos"
    ON eventos FOR SELECT
    USING (true);

CREATE POLICY "Apenas usuários autenticados podem criar eventos"
    ON eventos FOR INSERT
    WITH CHECK (auth.role() = 'authenticated');

-- Políticas para ingressos
CREATE POLICY "Usuários podem ver seus próprios ingressos"
    ON ingressos FOR SELECT
    USING (auth.uid() = usuario_id);

CREATE POLICY "Usuários podem criar ingressos"
    ON ingressos FOR INSERT
    WITH CHECK (auth.role() = 'authenticated');

-- Políticas para leituras de QR
CREATE POLICY "Apenas usuários autenticados podem registrar leituras"
    ON leituras_qr FOR INSERT
    WITH CHECK (auth.role() = 'authenticated');

-- Política para estados
CREATE POLICY "Qualquer um pode ver estados"
    ON estados FOR SELECT
    USING (true); 