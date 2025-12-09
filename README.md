# GitHub Live Code Editor (Phoenix LiveView)

A Phoenix LiveView app to **fetch, edit, and save files directly to GitHub** using a single textarea with safe two-way synchronization.

---

## ✅ Features

- Fetch file from GitHub  
- Edit code in real-time  
- Save changes back to GitHub  
- Repo, branch, and file path selection  
- GitHub token authentication  
- Dirty-state protection (prevents overwrite while editing)

---

## 🚀 Tech Stack

- Elixir  
- Phoenix LiveView  
- Tailwind CSS  
- GitHub REST API  

---

## ⚙️ Setup (Step-by-Step)

### 1. Clone the Repository

```shell
git clone https://github.com/murali3194/code_editor.git
cd code_editor
```

### 2. Install frontend dependencies

```shell
cd assets
npm install
cd ..
```

### 3. Set GitHub token (Linux / macOS)
```shell
export GITHUB_TOKEN=your_github_token_here
````
  # Verify the token
  ```shell
  echo $GITHUB_TOKEN
  ```
### 5. To start your Phoenix server

```shell
  mix deps.get  # installs the dependencies
  mix ecto.create  # creates the database.
  mix ecto.migrate  # run the database migrations.
  mix phx.server or iex -S mix phx.server  # runs the application.
  ```
  
  Now you can visit [`localhost:4000/`](http://localhost:4000/) from your browser.




