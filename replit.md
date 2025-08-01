# replit.md

## Overview

Brainrot Finder Pro is an advanced Roblox Lua script designed for automatically scanning and detecting rare animals ("brainrots") and mutations in pet collection games. Enhanced from the original GitHub repository concept, this version provides comprehensive real-time scanning capabilities, rich Discord webhook notifications, intelligent server hopping, and advanced features to maximize rare animal discovery opportunities.

## Recent Changes (August 1, 2025)

- **EXTREME PERFORMANCE OPTIMIZATION**: Implemented absolute maximum speed scanning
- **Hyper Mode**: RenderStepped + Heartbeat dual-scanning for 120+ scans per second
- **Batch Processing**: Processes 50+ animals simultaneously for maximum efficiency
- **Dynamic Caching**: Smart container caching with automatic refresh cycles
- **Zero-Delay Architecture**: Removed all scan delays for instant detection
- **Redundant Scanning**: Dual scanner engines for 100% coverage
- **SetValue Error Fix**: Removed problematic WindUI synchronization calls
- **Multi-URL WindUI Loading**: Added fallback URLs for better compatibility
- **Mobile Delta Executor Optimization**: Specifically optimized for mobile execution

## User Preferences

Preferred communication style: Simple, everyday language.

## System Architecture

### Core Script Architecture
- **Single Lua File Structure**: The entire application is contained within a single Roblox Lua script (`brainrot-finder.lua`) for easy distribution and execution
- **Event-Driven Scanning**: Uses Roblox's RunService and game events for real-time animal detection and monitoring
- **Modular Component Design**: Separates scanning logic, UI management, notification systems, and configuration handling into distinct functional modules

### User Interface Framework
- **WindUI Integration**: Leverages WindUI library for modern, tabbed interface design with dropdown selections and configuration panels
- **Real-time Configuration**: All settings can be modified during script execution without requiring restarts
- **Persistent Settings**: Configuration data is saved and loaded automatically to maintain user preferences across sessions

### Scanning and Detection System
- **Multi-target Scanning**: Simultaneously scans for multiple animal types and mutation combinations
- **Smart Caching System**: Implements intelligent caching to prevent duplicate notifications and reduce spam
- **Base and World Scanning**: Dual scanning modes for both player bases/displays and active game world animals

### Notification and Communication
- **Discord Webhook Integration**: Sends detailed notifications with animal information, location data, and discovery timestamps
- **Retry Logic**: Implements robust webhook delivery with automatic retry mechanisms for failed requests
- **Multi-channel Alerts**: Supports both Discord notifications and optional in-game sound alerts

### Performance and Reliability Features
- **Auto Server Hopping**: Configurable automatic server switching to maximize scanning opportunities
- **Debug and Monitoring**: Comprehensive logging system for troubleshooting and performance monitoring
- **Statistics Tracking**: Real-time tracking of scanning performance, success rates, and discovery metrics

## External Dependencies

### Roblox Platform Services
- **RunService**: For real-time game loop integration and continuous scanning operations
- **HttpService**: For Discord webhook communications and external API requests
- **TeleportService**: For automatic server hopping functionality
- **Players Service**: For player data access and base scanning capabilities

### UI Framework
- **WindUI Library**: Third-party Roblox UI library providing modern interface components, dropdown menus, and tabbed navigation systems

### Communication Services
- **Discord Webhooks**: External webhook endpoints for sending notifications to Discord servers, including rich embed formatting and multimedia support

### Game-Specific APIs
- **Roblox Game APIs**: Integration with specific pet collection game APIs for animal data retrieval, mutation detection, and game world interaction
