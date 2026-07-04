# Changelog

All notable changes to HumanNode will be documented in this file.

## [1.0.0] - 2026-06-09

### Added
- Initial public release
- On-device GGUF model inference via llama.cpp with Metal/NNAPI acceleration
- Agentic mode with observe-think-act loop and 11 builtin tools
- Streaming token-by-token responses
- Conversation management with create, rename, pin, search, delete
- Conversation branching from any message
- Markdown rendering with syntax-highlighted code blocks
- Voice input via speech-to-text
- Text-to-speech for reading responses aloud
- File attachments in chat
- Conversation export and sharing
- Model catalog with curated GGUF registry
- Model download manager with progress tracking
- Storage management (view cache, clear, delete models)
- Notes with full CRUD
- Light and dark Material Design 3 themes
- Dynamic font size adjustment (12px - 32px)
- Haptic feedback throughout the interface
- Custom animations (message slide-in, thinking pulse, agent spin)
- 5 language localizations (English, Japanese, Korean, Chinese, Spanish)
- Encrypted API key storage via platform keystore/keychain
- MCP client for external tool servers
- Reflexion self-correction on tool failures
- Nudge detection for intent-without-action
- Battery-aware inference throttling
- Comprehensive CI/CD via GitHub Actions
