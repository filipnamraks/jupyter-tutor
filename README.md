# Jupyter Python Tutor

An AI tutor that lives in a chat panel next to your Jupyter notebook. Ask it why
your code broke, what a concept means, or what a line actually does — and it
explains, rather than quietly doing your homework for you.

Built for students learning Python. It reads your notebook, so answers are about
*your* data and *your* error, not a generic example.

## Install

```bash
git clone https://github.com/filipnamraks/jupyter-tutor
cd jupyter-tutor
./install.sh ~/path/to/your/notebooks
```

Then start JupyterLab in that folder, open the chat icon in the left sidebar,
click **+**, and pick **Claude**.

The installer checks what you already have and tells you exactly what is missing
before changing anything.

## What you need first

| | Why |
|---|---|
| **Jupyter** (Anaconda is fine) | it runs inside JupyterLab |
| **Claude Code**, logged in | the tutor *is* Claude — [claude.com/claude-code](https://claude.com/claude-code) |
| **Node.js** | for the adapter connecting JupyterLab to Claude |

**A Claude subscription is required.** That is the one part no installer can do
for you, and there is no free tier that covers it.

It must be `jupyter lab`, not `jupyter notebook` — the chat panel only exists in
the full JupyterLab interface. Same server, different front end: if a notebook
server is already running, just change `/tree` to `/lab` in the address bar.

## What it actually does

Three things:

1. Installs [Jupyter AI](https://github.com/jupyterlab/jupyter-ai), the official
   extension that puts a chat panel in JupyterLab
2. Installs the ACP adapter, which lets that panel drive your local Claude Code
3. Drops a `CLAUDE.md` into your notebook folder — **this is the actual tutor**

Only the third is original. The first two are other people's projects, installed
unmodified.

## The part that matters: `tutor/CLAUDE.md`

Claude Code reads a `CLAUDE.md` from its working directory, and Jupyter AI runs
the agent in the folder containing your chat. So that one file reshapes the whole
conversation.

Without it, you get a coding agent: long structured reports in answer to one-line
questions, walls of tool output, and a tendency to just fix things. Useful when
you are building software; wrong when you are trying to learn.

With it:

- **Short answers.** A one-line question gets a few sentences, not a report.
- **Quiet.** It answers instead of narrating six tool calls first.
- **Asks when you are vague** instead of investigating until the vagueness goes away.
- **Teaches.** Explains the concept, shows the smallest example, and lets you
  write the line yourself.
- **Will not write your prose.** It helps you structure a conclusion and checks
  your reasoning — the sentences stay yours.
- **Asks before editing a cell.**

Read it. Edit it. If you want something different — more Socratic, more direct,
answers in Swedish — change that file and start a new chat. That is the whole
configuration surface, and it is 70 lines of plain English.

## Uninstall

```bash
pip uninstall jupyter-ai
npm uninstall -g @agentclientprotocol/claude-agent-acp
rm /path/to/your/notebooks/CLAUDE.md
```

## Honest limitations

- **Not tested on Windows.** Written and used on macOS; the install script assumes
  a POSIX shell.
- **Jupyter AI is young and moves fast.** These instructions were correct against
  version 3.1.3. If the install breaks, check their docs — the underlying package
  names have changed before.
- **Tool calls still print blocks into the chat.** There is no setting to collapse
  them, so the tutor rules reduce tool *use* instead. It is better, not silent.
- **It can still be wrong.** It is a study aid, not a grader. Check your course's
  rules on AI assistance before using it on work you hand in.

## Licence

MIT — see [LICENSE](LICENSE).
