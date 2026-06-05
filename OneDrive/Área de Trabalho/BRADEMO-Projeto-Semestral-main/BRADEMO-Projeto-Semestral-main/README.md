# BRADEMO - Projeto Bimestral

## 🚀 Guia de Contribuição – Projeto BRADEMO

## 🎯 Objetivo

Seguindo esse fluxo:
- Evitamos conflitos
- Organizamos melhor o projeto
- Facilitamos integração entre telas

---

## 📦 1. Clonando o repositório

Antes de tudo, você precisa baixar o projeto para sua máquina:

```bash
git clone https://github.com/Gatasso/BRADEMO-Projeto-Semestral.git
cd BRADEMO-Projeto-Semestral
```

---

## 🌿 2. Criando sua branch

Cada integrante deve trabalhar **em sua própria branch**, baseada na tela que está desenvolvendo.
Criar a branch com o nome da tela em questão.

### 📌 Padrão de nome:
- `login_screen`
- `home_screen`
- `rest_screen`
- `details_screen`

### ✅ Criar e mudar para a branch:
```bash
git checkout -b nome-da-sua-branch
```

Exemplo:
```bash
git checkout -b login_screen
```

---

## 📁 3. Onde você deve mexer

Alterar **APENAS sua própria tela**, isto é, apenas o seu próprio arquivo, dentro da estrutura:

```
lib/screens/<nome_screen>
```

Exemplo:
```
lib/screens/login_screen.dart
lib/screens/home_screen.dart
```

⚠️ Evite mexer em arquivos de outras telas para não gerar conflitos.

---

## 💾 4. Salvando alterações (commit)

Depois de fazer suas alterações:

```bash
git add .
git commit -m "tipo: descrição do que foi feito"
```


### ✍️ Padrão de commits

Use os seguintes prefixos:

#### `feat`
Para novas funcionalidades:
```bashi
git commit -m "feat: adiciona widget na tela de login"
```

###  `fix`
Para correção de bugs:
```bash
git commit -m "fix: corrige erro no botão de login"
```

---

## ⬆️ 5. Enviando para o GitHub

Agora envie sua branch:

```bash
git push -u origin nome-da-sua-branch
```

Exemplo:
```bash
git push -u origin login_screen
```

---

## 🔄 6. Atualizando seu projeto (muito importante)

Antes de começar a trabalhar, sempre atualize o projeto e sincronize sua branch com a `main`. Isso ajuda a evitar erros:

### 6.1. Ir para a `main` e atualizar

```bash
git checkout main
git pull origin main
```
---

### 6.2. Voltar para sua branch

```bash
git checkout sua-branch
```

---

### 6.3. Fazer merge da `main` na sua branch

```bash
git merge main
```

---

## ⚠️ IMPORTANTE

- ❗ **NÃO crie um commit manual após o merge**
- O próprio Git já cria automaticamente um commit de merge (se necessário)
---

### 6.4. Se houver conflitos

1. Abra os arquivos com conflito  
2. Resolva manualmente (escolha o código de entrada)  
3. Depois execute:

```bash
git add .
git commit -m "fix: resolve conflitos com a main"
git push
```

---


Seguindo esse fluxo, você garante que sua branch está sempre atualizada e evita problemas na hora de integrar com o projeto 🚀

---

## ⚠️ Boas práticas

- ✅ Trabalhe sempre na sua branch  
- ✅ Faça commits frequentes  
- ✅ Use mensagens claras 
- ✅ Sempre sincronize sua branch antes de começar a trabalhar   
- ❌ NÃO trabalhe direto na `main`  
- ❌ NÃO altere outras telas   
- ❌ Não deixe sua branch ficar muitos commits atrás da `main`  
---

## 🧠 Fluxo completo
```bash
git clone <repo>
cd <repo>

git checkout -b minha-branch

# faz alterações

git add .
git commit -m "feat: minha alteração"

git push -u origin minha-branch
```

---
