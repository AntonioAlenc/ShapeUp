# 📱 ShapeUp

**ShapeUp** é um aplicativo desenvolvido como parte do Trabalho de Conclusão de Curso (TCC) em Engenharia de Software. O sistema tem como objetivo auxiliar **personal trainers** e **alunos** no gerenciamento de **treinos, dietas, lembretes, progresso físico e comunicação**, tudo de forma centralizada, moderna e acessível.

---

## 🚀 Tecnologias Utilizadas

- **Flutter** – Interface multiplataforma
- **Dart** – Linguagem de programação
- **Firebase** – Backend como serviço:
  - Autenticação
  - Firestore (banco de dados)
  - Armazenamento
- **Provider** – Gerenciamento de estado
- **Git/GitHub** – Controle de versão

---

## 📦 Estrutura do Projeto

```
lib/
├── main.dart
├── modelos/                # Entidades do sistema
│   ├── usuario.dart
│   ├── treino.dart
│   ├── dieta.dart
│   ├── mensagem.dart
│   ├── progresso.dart
│   └── lembrete.dart
├── servicos/               # CRUD com Firebase
│   ├── firebase_usuario_service.dart
│   ├── firebase_treino_service.dart
│   ├── firebase_dieta_service.dart
│   ├── firebase_mensagem_service.dart
│   ├── firebase_progresso_service.dart
│   └── firebase_lembrete_service.dart
├── telas/                  # (Futuramente) Telas do app
├── provedores/             # Gerenciamento de estado
└── utilitarios/            # Constantes, helpers, etc.
```


## 📚 Funcionalidades implementadas

- [x] Estrutura do projeto organizada em camadas
- [x] Integração com Firebase (Auth e Firestore)
- [x] CRUD completo de:
  - Usuário
  - Treino
  - Dieta
  - Mensagem
  - Progresso
  - Lembrete
- [ ] Telas de cadastro e listagem
- [ ] Validações e testes automatizados

---

## 👨‍🏫 Projeto acadêmico

- **Curso**: Engenharia de Software
- **Instituição**: UNIGRAN – Centro Universitário da Grande Dourados
- **Orientador**: Prof. M.Sc. Felipe Perez
- **Alunos**:
  - Antônio Luiz Inácio Monteiro de Alencar - 802.390
  - João Gabriel Furtado Zamarian - 802.372

---

## 📄 Licença

Este projeto é de uso acadêmico e não possui fins comerciais.
