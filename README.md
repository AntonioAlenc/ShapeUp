
# 📱 ShapeUp

O **ShapeUp** é um aplicativo mobile desenvolvido em **Flutter** com o objetivo de auxiliar **alunos** e **personal trainers** na organização de treinos, dietas, progresso físico e comunicação direta via chat.

---

## 🚀 Funcionalidades (Implementadas)

- ✅ Tela de Carregamento
- ✅ Login e Cadastro com tipo de usuário (aluno ou personal)
- ✅ Recuperação de senha
- ✅ Menus distintos para alunos e personal trainers
- ✅ Treino do Aluno
- ✅ Treino do Personal
- ✅ Dieta do Aluno
- ✅ Dieta do Personal
- ✅ Chat de Conversa
- ✅ Perfil do Aluno
- ✅ Perfil do Personal
- ✅ Progresso físico
- ✅ Telas adicionais placeholder (Alunos, Criar Treino, Criar Dieta, Evolução, Lembretes)

---

## 🛠 Tecnologias

- **Flutter 3.22+**
- **Dart**
- **Firebase (configuração pendente)**
- **Material Design**
- **Estilização personalizada**
  - Fundo preto
  - Texto branco
  - Elementos de destaque em **amarelo vibrante**

---

## 📁 Estrutura de Pastas

```
lib/
│
├── main.dart
├── telas/
│   ├── carregamento_tela.dart
│   ├── login_tela.dart
│   ├── cadastro_tela.dart
│   ├── recuperacao_senha_tela.dart
│   ├── menu_aluno_tela.dart
│   ├── menu_personal_tela.dart
│   ├── treino_aluno_tela.dart
│   ├── treino_personal_tela.dart
│   ├── dieta_aluno_tela.dart
│   ├── dieta_personal_tela.dart
│   ├── chat_tela.dart
│   ├── progresso_tela.dart
│   ├── perfil_aluno_tela.dart
│   ├── perfil_personal_tela.dart
│   └── placeholder_telas.dart
└── imagens/
    └── LogoVazada.png
```

---

## 🔧 Firebase (pendente de integração)

O Firebase será utilizado para:

- Autenticação (e-mail e senha)
- Firestore para armazenar treinos, dietas, progresso e mensagens
- Firebase Messaging (futuramente) para notificações

---

## ▶️ Como rodar o projeto

1. **Clone o repositório:**
   ```bash
   git clone https://github.com/seu-usuario/shapeup.git
   cd shapeup
   ```

2. **Instale as dependências:**
   ```bash
   flutter pub get
   ```

3. **Execute o projeto:**
   - Android: `flutter run`
   - Emulador: `flutter emulators --launch <nome>`
   - Web: `flutter run -d chrome` *(pode exibir limitações visuais)*

---

## 📌 Observações

- Este projeto é voltado para dispositivos **mobile**.
- Algumas rotas ainda utilizam **telas placeholder**, aguardando integração com backend.
- O Firebase já está preparado no `main.dart`, mas o `firebase_options.dart` será gerado após a integração final.

---

## 👨‍💻 Autores

**Antônio Luiz Inácio Monteiro de Alencar - 802.390**  
**João Gabriel Furtado Zamarian - 802.372**  
Engenharia de Software – UNIGRAN

---