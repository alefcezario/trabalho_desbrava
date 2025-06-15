import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart'; // Importa o novo pacote

class LegalDocumentScreen extends StatelessWidget {
  final String title;
  final String content;

  const LegalDocumentScreen({
    super.key,
    required this.title,
    required this.content,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(title),
        backgroundColor: const Color(0xFF0A192F),
        foregroundColor: Colors.white,
      ),
      // O corpo agora usa o widget Markdown, que formata o texto automaticamente
      body: Markdown(
        data: content,
        padding: const EdgeInsets.all(16.0),
        styleSheet: MarkdownStyleSheet(
          h1: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          h2: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, height: 2),
          p: const TextStyle(fontSize: 15, height: 1.5),
          listBullet: const TextStyle(fontSize: 15, height: 1.5),
        ),
      ),
    );
  }
}

// <<< TERMOS DE USO ATUALIZADOS COM A NOVA SEÇÃO >>>
const String termsOfUseContent = """
# Termos de Uso do Desbrava App

**Última atualização:** 07 de junho de 2025

Bem-vindo ao Desbrava App! Estes Termos de Uso ("Termos") regem o seu acesso e uso do nosso aplicativo móvel e serviços relacionados ("Serviço").

## 1. Sobre o Aplicativo
Este aplicativo foi desenvolvido como um projeto acadêmico (Trabalho A3) por alunos do curso de **Sistemas de Informação** da faculdade Una de Contagem.

**Integrantes do Grupo:**
* Alef Cezario
* Brenner Luciano
* Elias Victor
* Guilherme Ryan
* Joao Vitor Aguiar
* José Vieira
* Raissa Kethlen
* Tayna Mariana

## 2. Serviço Beta
Você reconhece que o Serviço está atualmente em fase Beta e é fornecido "como está". O serviço pode conter bugs, erros e outras instabilidades. Reservamo-nos o direito de modificar ou descontinuar o Serviço a qualquer momento sem aviso prévio.

## 3. Uso do Serviço
* **Elegibilidade:** Você deve ter pelo menos 18 anos de idade para criar uma conta e usar o nosso Serviço.
* **Sua Conta:** Você é responsável por manter a confidencialidade da sua senha e por todas as atividades que ocorram na sua conta.
* **Uso Aceitável:** Você concorda em não usar o Serviço para qualquer finalidade ilegal ou proibida por estes Termos.

## 4. Conteúdo do Utilizador
* **O seu Conteúdo:** Você é o único responsável por qualquer conteúdo que publique, incluindo avaliações, comentários, fotos e relatórios.
* **Licença para Nós:** Ao publicar conteúdo, você nos concede uma licença mundial, não exclusiva e livre de royalties para usar, reproduzir e exibir esse conteúdo em conexão com o Serviço.

## 5. Limitação de Responsabilidade
Não nos responsabilizamos por quaisquer danos resultantes do uso do Serviço.

## 6. Contato
Se tiver alguma dúvida sobre estes Termos, entre em contato conosco em: **desbravaapp@outlook.com**
""";

// <<< POLÍTICA DE PRIVACIDADE ATUALIZADA E MAIS COMPLETA >>>
const String privacyPolicyContent = """
# Política de Privacidade do Desbrava App

**Última atualização:** 07 de junho de 2025

O Desbrava App ("nós", "nosso") está comprometido em proteger a sua privacidade. Esta Política de Privacidade explica como recolhemos, usamos, partilhamos e protegemos as suas informações pessoais em conformidade com a Lei Geral de Proteção de Dados (LGPD) do Brasil.

## 1. Informações que Recolhemos
* **Dados que Você nos Fornece Diretamente:** Nome, e-mail, senha (encriptada), foto de perfil (opcional), avaliações, comentários, relatórios e locais favoritados.
* **Dados Recolhidos Automaticamente:** Dados de geolocalização (GPS) do seu dispositivo, com a sua permissão explícita.

## 2. Finalidade do Tratamento dos Dados
Usamos as suas informações para:
* Criar e gerir a sua conta.
* Personalizar a sua experiência (ex: mostrar locais próximos).
* Operar as funcionalidades do aplicativo (avaliar, favoritar, etc.).
* Garantir a segurança da plataforma.

## 3. Partilha e Divulgação de Informações
Nós não vendemos os seus dados. A partilha é limitada a:
* **Outros Utilizadores:** O seu nome de perfil e foto (se fornecida) são públicos junto das avaliações que você publica.
* **Fornecedores de Serviços:** Utilizamos a plataforma Google Firebase para o nosso backend.
* **Obrigações Legais:** Se for exigido por lei.

## 4. Armazenamento e Segurança dos Dados
Os seus dados são armazenados nos servidores seguros do Google Firebase. A sua senha é sempre armazenada de forma encriptada.

## 5. Os Seus Direitos de Acordo com a LGPD
De acordo com a LGPD, você tem o direito de aceder, corrigir e eliminar os seus dados. Para exercer estes direitos:
* **Editar:** Você pode editar o seu nome, e-mail e foto de perfil diretamente na tela de 'Configurações de perfil' dentro do aplicativo.
* **Eliminar Conteúdo:** Você pode eliminar as suas avaliações e comentários individualmente através da tela 'Minhas Contribuições'.
* **Eliminar Conta:** Você pode solicitar a eliminação completa da sua conta e de todos os dados associados através da opção 'Excluir Conta' na tela de 'Configurações de perfil'.
* **Revogar o Consentimento:** Pode gerir a permissão de localização nas configurações do seu dispositivo.

## 6. Contato
Se tiver alguma dúvida, entre em contato com o nosso Encarregado pela Proteção de Dados (DPO) através do e-mail: **desbravaapp@outlook.com**
""";
