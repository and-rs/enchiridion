# Enchiridion

A pure Unix dataflow orchestrator for interacting with LLMs. Built in OCaml,
Enchiridion rejects monolithic UI and opaque state management in favor of
standard streams (`stdin`/`stdout`) and plain-text Markdown session files.

It is designed to be completely headless, acting as the underlying execution
engine for Neovim or CLI environments.

## Architecture

- **Stateless by Default:** Conversational context is maintained exclusively via
  physical Markdown files. To branch, time-travel, or alter context, you edit
  the file in your text editor.
- **Streaming Pipeline:** Utilizes Server-Sent Events (SSE) to aggressively
  flush LLM tokens directly to `stdout` with zero runtime buffering.
- **Context Augmentation:** Natively integrates the Exa Search API for
  deterministic context injection prior to LLM execution.
- **Provider Agnostic:** Strictly implements the OpenAI `/v1/chat/completions`
  schema. Use an external proxy (e.g., Bifrost) to translate alternative
  provider APIs.

## Build

Requires OCaml and Dune.

```bash
just setup
```

## Usage Constraints

This tool does not provide terminal UI elements, ANSI escape formatting, or
syntax highlighting. Presentation is strictly delegated to the consuming
application (e.g., Neovim buffer rendering or downstream terminal pagers).

## TODOS

- [ ] think about a stack (perhaps LIFO) based approach for handling the context
      without a repl
  - [ ] list a short form of the stack inputs & outputs, so the user can review
        and rewind quickly
