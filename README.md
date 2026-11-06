# 📓 Appunti Universitari In LaTeX

Repository privata per la gestione e il backup degli appunti universitari scritti in LaTeX. Ogni cartella contiene il sorgente `.tex` e la configurazione è ottimizzata per la compilazione rapida tramite VS Code.

## 📚 Materie E Corsi

* **Deep Learning And Robot Perception** 🧠👁️
* **Industrial Robotics** 🤖🏗️
* **Information And Estimation Theory** 📊📈
* **Nonlinear And Robust Control** ⚙️🔄
* **Virtual Networks And Cloud Computing** ☁️🌐

---

## 📂 Struttura Della Repository

La struttura è organizzata per cartelle indipendenti, con una cartella di configurazione globale per VS Code:

```text
.
├── 📁 .vscode/                          # Impostazioni Workspace
├── 📁 DeepLearningAndRobotPerception/
├── 📁 IndustrialRobotics/
├── 📁 InformationAndEstimationTheory/
├── 📁 NonLinearAndRobustControl/
├── 📁 VirtualNetworksAndCloudComputing/
├── 📄 .gitignore                        # Esclusione File
├── 📄 README.md                         # File Per Fare Test Di Compilazione Latex                         
└── 📄 Test.tex                          
```

---

## 🛠️ Workflow di Lavoro

Per mantenere tutto sincronizzato velocemente su GitHub senza scrivere comandi ripetitivi, utilizzo la funzione PowerShell personalizzata:

### Comando Rapido Per Sincronizzazione

```powershell
gitSave "NomeMateria"
```

**Cosa fa:**

1. Esegue `git add .`
2. Crea un commit con timestamp automatico: `📚 NomeMateria | 📅 Data | 🕒 Ora`
3. Esegue `git push` verso il master.

---

## ⚙️ Configurazione Tecnica

* **Compilatore:** `pdflatex` o `xelatex`.
* **Editor:** Visual Studio Code + LaTeX Workshop.
* **Note:** I file ausiliari (`.aux`, `.log`, `.gz`, ecc.) vengono eliminati automaticamente dopo ogni compilazione riuscita grazie alle impostazioni in `.vscode/settings.json` per mantenere le cartelle pulite.
* **Immagini:** Le cartelle delle immagini e i file grafici pesanti sono ignorati per massimizzare la velocità di sincronizzazione.
